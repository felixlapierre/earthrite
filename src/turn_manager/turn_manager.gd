extends Node
class_name TurnManager

var week = 1
var year = 0

var energy: int = 3
var total_ritual: int = 0
var ritual_counter: int = 0
var purple_mana: int = 0
var target_blight: int = 0
var next_turn_blight: int = 0
var flag_defer_excess: bool = false

var blight_damage = 0

const TWEEN_DURATION = 0.8

var blight_pattern = []
var attack_pattern: AttackPattern
var event_manager: EventManager

var ritual_charts = []
var blight_charts = []

@onready var multiplayer_turn: MultiplayerTurn = $MultiplayerTurn

signal animate_blightroot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	ritual_charts.append(load("res://src/attack/charts/ritual_tier1.tres"))
	ritual_charts.append(load("res://src/attack/charts/ritual_tier2.tres"))
	ritual_charts.append(load("res://src/attack/charts/ritual_tier3.tres"))
	ritual_charts.append(load("res://src/attack/charts/ritual_tier4.tres"))
	blight_charts.append(load("res://src/attack/charts/blight_tier1.tres"))
	blight_charts.append(load("res://src/attack/charts/blight_tier2.tres"))
	blight_charts.append(load("res://src/attack/charts/blight_tier3.tres"))
	blight_charts.append(load("res://src/attack/charts/blight_tier4.tres"))

# Return bool indicating if the ritual is complete
func gain_yellow_mana(amount, delay = false):
	flag_defer_excess = flag_defer_excess or delay
	ritual_counter -= amount
	if ritual_counter > total_ritual:
		ritual_counter = total_ritual
	if ritual_counter <= 0 and !multiplayer_enabled():
		ritual_counter = 0
		return true
	return false

func gain_purple_mana(amount, delay):
	if purple_mana < target_blight and purple_mana + amount >= target_blight:
		if next_turn_blight > 0:
			animate_blightroot.emit("attack_to_threat")
		else:
			animate_blightroot.emit("attack_to_safe")
	flag_defer_excess = flag_defer_excess or delay
	if purple_mana + amount < 0: #meaning amount < 0
		amount += purple_mana
		purple_mana = 0
		if flag_defer_excess:
			next_turn_blight -= amount
		else:
			target_blight -= amount
	else:
		purple_mana += amount

# Return boolean if the player took damage
func end_turn():
	var damage = 0
	var blight_remaining = target_blight - purple_mana
	
	if multiplayer_turn.enabled:
		# Multiplayer
		var data = {
			"ritual_counter": ritual_counter,
			"ritual_target": total_ritual,
			"blight_attack": target_blight,
			"purple_mana": purple_mana,
			"target": -1, #-1 for no specific target, otherwise ID of the peer under attack
			"damage": blight_damage
		}
		if flag_defer_excess and purple_mana > target_blight:
			purple_mana -= target_blight
			data.purple_mana = target_blight
		else:
			purple_mana = 0
		multiplayer_turn.notify_turn_ended.rpc(data)
		print("Waiting for other players (turn end)")
		var result = await multiplayer_turn.wait_for_end_turn_results()
		damage = result.damage - blight_damage
		blight_damage = result.damage
		target_blight = result.blight_attack
		ritual_counter = result.ritual_counter
		week += 1
		if result.victory == true:
			$'../'.victory = true
	else:
		if blight_remaining > 0:
			damage = blight_remaining
			if week < Global.FINAL_WEEK:
				blight_damage += blight_remaining
			else:
				blight_damage = 100
				damage = 100
		elif next_turn_blight > 0:
			animate_blightroot.emit("attack")
		elif get_blight_requirements(week + 2, year) > 0:
			animate_blightroot.emit("threat")

		blight_remaining = 0 if blight_remaining < 0 else blight_remaining
		week += 1
		if !flag_defer_excess or purple_mana < target_blight:
			purple_mana = 0
		else:
			purple_mana -= target_blight
		target_blight = next_turn_blight
		next_turn_blight = get_blight_requirements(week + 1, year)
	energy = get_max_energy()
	flag_defer_excess = false
	attack_pattern.register_fortunes(event_manager, week)
	return damage

func register_attack_pattern(p_attack_pattern: AttackPattern):
	attack_pattern = p_attack_pattern
	var chart: Chart = get_chart(blight_charts)
	attack_pattern.compute_blight_pattern(chart, year)
	attack_pattern.compute_fortunes(year+1)
	attack_pattern.register_fortunes(event_manager, 1)

func start_new_year():
	year += 1
	week = 1
	blight_pattern = attack_pattern.get_blight_pattern()
	print(blight_pattern)
	ritual_counter = get_ritual_requirements(year)
	total_ritual = ritual_counter
	target_blight = get_blight_requirements(week, year)
	next_turn_blight = get_blight_requirements(week + 1, year)
	purple_mana = 0
	energy = get_max_energy()

func end_year():
	attack_pattern.unregister_fortunes(event_manager)

func compute_blight_pattern(week, year):
	blight_pattern = [0]
	var charge: float = 0.0
	var chance = 0.0
	for i in range(1, Global.FINAL_WEEK):
		charge += 10.0
		chance += 0.3
		if (year < 4 and i < 3) or (year < 10 and i < 2):
			blight_pattern.append(0)
		elif i == Global.FINAL_WEEK - 1:
			blight_pattern.append(charge)
			charge = 0.0
		elif randf() < chance:
			chance = 0.0
			var amount = int(randf_range(0.4, 0.8) * charge)
			charge -= amount
			blight_pattern.append(amount)
		else:
			blight_pattern.append(0)
	return

func get_ritual_requirements(year):
	var chart: Chart = get_chart(ritual_charts)
	var value = chart.get_value(year - 1)
	for i in range(8, year):
		value *= 2
	return value

func get_blight_requirements(week, year):
	if week > blight_pattern.size():
		return blight_pattern[blight_pattern.size() - 1]
	else:
		return blight_pattern[week - 1]

func get_max_energy():
	var new_energy = Constants.MAX_ENERGY
	if (Global.ENERGY_FRAGMENTS % 3 > (week-1) % 3):
		new_energy += 1
	new_energy += int(float(Global.ENERGY_FRAGMENTS) / 3)
	return new_energy

func get_cards_drawn():
	var cards_drawn = Constants.BASE_HAND_SIZE
	if (Global.SCROLL_FRAGMENTS % 3 > (week-1) % 3):
		cards_drawn += 1
	cards_drawn += int(float(Global.SCROLL_FRAGMENTS) / 3)
	return cards_drawn

func get_blight_at_week(week):
	return 0 if week < 5 else randi_range(0, 1) * (week * randi_range(1,3))

func set_blight_targeted_tiles(farm: Farm):
	var number_tiles = Constants.BASE_BLIGHT_DAMAGE if target_blight > 0 else 0
	var all_tiles = farm.get_all_tiles()
	all_tiles.shuffle()
	var target_tile_states = [Enums.TileState.Empty, Enums.TileState.Growing, Enums.TileState.Mature]
	var valid_targets = []
	for tile in all_tiles:
		tile.set_blight_targeted(false)
		if target_tile_states.has(tile.state) && !tile.is_protected() && !tile.is_destroyed():
			valid_targets.append(tile)
	# In case we are targeting only growing plants and there aren't enough
	if valid_targets.size() < number_tiles:
		for tile in all_tiles:
			if [Enums.TileState.Empty, Enums.TileState.Mature].has(tile.state) && !tile.is_protected():
				valid_targets.append(tile)
				if valid_targets.size() >= number_tiles:
					break
	for i in range(number_tiles):
		if i < valid_targets.size():
			valid_targets[i].set_blight_targeted(true)

func destroy_blighted_tiles(farm: Farm):
	farm.destroy_blighted_tiles()

func get_current_ritual():
	return total_ritual - ritual_counter

func get_blight_strength():
	return ceil(float(blight_damage + 1) / 20)

func get_chart(list):
	var chart: Chart = null
	match Global.DIFFICULTY:
		0:
			print("Easy chart")
			chart = list[0]
		1, 2, 3:
			print("Normal-Mastery1 chart")
			chart = list[1]
		4, 5, 6:
			print("Mastery 2-4 chart")
			chart = list[2]
		7:
			print("Mastery charts")
			chart = list[3]
	return chart

func gain_energy():
	energy += 1

func wait_next_year():
	if multiplayer_turn.enabled:
		multiplayer_turn.notify_done_exploring.rpc()
		print("Waiting for other players (explore)")
		await multiplayer_turn.wait_for_explore_results()

func multiplayer_enabled():
	return multiplayer_turn.enabled
