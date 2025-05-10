extends Node2D
class_name Tutorial2

var user_interface: UserInterface
var cards: Cards
var event_manager: EventManager
var turn_manager: TurnManager
var farm: Farm

@onready var click_out: Button = $ClickOutButton
@onready var panel: PanelContainer = $Panel
@onready var label: RichTextLabel = $Panel/Margin/VBox/Label
@onready var continue_label: Label = $Panel/Margin/VBox/Label2

var text1_welcome = "Welcome to Earthrite!\n\nThis tutorial will explain how to play the game.\n\nYou can disable these tutorials with the button on the top right of the screen. You can re-enable tutorials at any time in the Settings menu."
var text1_welcome2 = "You must Plant, Grow, and Harvest crops on your farm to gain [color=gold]Mana ({MANA})[/color]\n\nTo start, plant some Seeds on your farm.\n\nClick on a Seed card in your hand, then click on a Farm Tile to use the card."

var text_week2 = "When you End your Turn, 1 week ({TIME}) passes.\n\nBlueberries and Carrots take 2 weeks {TIME} to grow, indicated on the bottom right of the card. They will be ready for harvest in 1 turn.\n\nFor now, no crops are ready, so you can plant more seeds on your farm."
var text_week3 = "You have plants ready to harvest! Click on a Scythe card to select it, then click on a farm tile to use the Scythe there.\n\nA Scythe card harvests 9 tiles.\n\nFor now, don't harvest the plants on the right (blue) side of your farm. They will be needed later, when the Blight attacks."
var text_week3_ritual = "When you harvest plants on the left (yellow) side of your farm, you gain [color=yellow]Yellow Mana[/color] ({MANA}).\n\nThe amount of mana yielded by a seed on harvest is indicated on the bottom left of the card.\n\nFill up the obelisk on the left of the screen with [color=yellow]Mana {MANA}[/color] to complete the ritual and progress."

var text_week4 = "The Blight hates any who would dare set foot in these woods, and you should prepare accordingly for its attacks.\n\nThis turn, the blight is attacking you with a strength of 6 {BLIGHT}. To protect yourself, you must generate 6 {BLUE_MANA} this turn.\n\nUse a Scythe to harvest plants on the right (blue) side of your farm."
var text_week4_safe = "As long as your total Blue Mana {BLUE_MANA} equals or exceeds the blight attack strength {BLIGHT}, you are safe.\n\nOtherwise, you will take damage equal to the unmatched attack amount {BLIGHT}.\n\n[color=red]Note![/color] Excess Blue Mana {BLUE_MANA} [color=orange]is lost at the end of the turn![/color]"

var text_week5 = "Continue planting, growing and harvesting plants until the ritual is complete.\n\nThe list at the right of the screen indicates when the blight will attack you, and how strong each attack will be.\n\nMake sure to keep the right side of your farm stocked with plants to protect yourself!"

var text_no_energy = "Most cards cost Energy ({ENERGY}) to play, indicated in the top right of the card.\n\nYou gain 3 energy {ENERGY} at the start of each turn.\n\nSince you are out of energy, click 'End Turn' on the bottom right of the screen"
var text_no_energy2 = "You are out of energy. Click 'End Turn' on the bottom right of the screen."

var anchor_center = Vector2(700, 170)
var anchor_right = Vector2(1390, 175)
var anchor_left = Vector2(175, 175)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(p_ui, p_cards, p_events, p_turns):
	user_interface = p_ui
	cards = p_cards
	event_manager = p_events
	turn_manager = p_turns
	farm = event_manager.farm
	
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, start_turn)
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, start_year)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var year = turn_manager.year
	var week = turn_manager.week

	if year == 1 and (week == 1 or week == 2):
		highlight_seeds()

	if year == 1 and week == 3:
		if turn_manager.ritual_counter < turn_manager.total_ritual:
			set_text(text_week3_ritual)
			panel.position = anchor_right
			user_interface.EndTurnButton.disabled = false
		highlight_scythes(false)

	if year == 1 and week == 4:
		if turn_manager.purple_mana >= turn_manager.target_blight:
			set_text(text_week4_safe)
			panel.position = anchor_left
			user_interface.EndTurnButton.disabled = false
		highlight_scythes(true)

	if turn_manager.energy == 0:
		reset_cards()
		if year == 1 and week == 1:
			set_text(text_no_energy)
			panel.position = anchor_left
			user_interface.EndTurnButton.disabled = false
		elif year == 1:
			set_text(text_no_energy2)
			panel.position = anchor_left
			user_interface.EndTurnButton.disabled = false
	if turn_manager.ritual_counter <= 0:
		panel.visible = false

func _on_click_out_button_pressed():
	pass # Replace with function body.

func start_year(args: EventArgs):
	if turn_manager.year == 1:
		panel.position = anchor_center
		set_text(text1_welcome)
		await wait_click_out()
		panel.position = anchor_right
		set_text(text1_welcome2)
		user_interface.EndTurnButton.disabled = true
		
		turn_manager.blight_pattern = [0, 0, 0, 6, 0, 10, 0, 0, 10, 0, 5, 0, 10, 10, 0, 10]
		var attack_pattern = dummy_attack_pattern(turn_manager.blight_pattern, [])
		user_interface.AttackPreview.set_attack(attack_pattern)
	else:
		panel.visible = false

func start_turn(args: EventArgs):
	var year = turn_manager.year
	var week = turn_manager.week
	
	if week <= 2:
		var count = 0
		for card in cards.HAND_CARDS.get_children():
			if card.card_info.type == "SEED":
				count += 1
		if count < 3:
			cards.drawcard()
	
	if year == 1 and week == 2:
		set_text(text_week2)
		user_interface.EndTurnButton.disabled = true
		panel.position = anchor_right
	elif year == 1 and week == 3:
		set_text(text_week3)
		user_interface.EndTurnButton.disabled = true
		panel.position = anchor_right
	elif year == 1 and week == 4:
		set_text(text_week4)
		user_interface.EndTurnButton.disabled = true
		panel.position = anchor_left
	elif year == 1 and week == 5:
		set_text(text_week5)
		panel.position = anchor_center
		await wait_click_out()
	elif week > 5:
		panel.visible = false

func set_text(text: String):
	text = text.replace("{MANA}", Helper.mana_icon())\
		.replace("{BLUE_MANA}", Helper.blue_mana())\
		.replace("{TIME}", Helper.time_icon())\
		.replace("{ENERGY}", Helper.energy_icon())\
		.replace("{BLIGHT}", Helper.blight_attack_icon())
	label.text = text
	panel.visible = true

func wait_click_out():
	panel.visible = true
	click_out.visible = true
	continue_label.visible = true
	await click_out.pressed
	panel.visible = false
	click_out.visible = false
	continue_label.visible = false

func highlight_tiles(grid_locations: Array[Vector2], state: Enums.TileState):
	for tile in farm.get_all_tiles():
		if tile.grid_location in grid_locations and (tile.state == null or tile.state == state):
			tile.SELECT_PROMPT.visible = true
			tile.SELECT_PROMPT.play("default")
		else:
			tile.TILE_BUTTON.disabled = true

func reset_tiles():
	for tile in farm.get_all_tiles():
		tile.SELECT_PROMPT.visible = false
		tile.SELECT_PROMPT.play("default")
		tile.TILE_BUTTON.disabled = false

func highlight_scythes(purple: bool):
	if Global.selected_card != null:
		if Global.selected_card.type == "ACTION":
			highlight_scythe_spots(purple)
		else:
			reset_tiles()
	else:
		reset_tiles()
		# Check if a tile is ready for harvest
		var any_plant_mature = false
		for tile in farm.get_all_tiles():
			if tile.state == Enums.TileState.Mature and tile.purple == purple:
				any_plant_mature = true
		if any_plant_mature and !purple:
			for card in cards.HAND_CARDS.get_children():
				if card.card_info.type == "ACTION":
					card.set_highlight(true)
				else:
					card.set_disabled(true)
		else:
			reset_cards()

func highlight_scythe_spots(purple: bool):
	var loc = [Vector2(2, 2), Vector2(2, 3), Vector2(2, 4), Vector2(2, 5), Vector2(2, 6)] if !purple else [Vector2(5, 2), Vector2(5, 3), Vector2(5, 4), Vector2(5, 5), Vector2(5, 6)]
	
	var copy = []
	copy.assign(loc)
	for l in copy:
		var adjacent_tiles = Helper.get_adjacent_active_tiles(l, farm)
		var any_mature = false
		for tile in adjacent_tiles:
			if tile.state == Enums.TileState.Mature:
				any_mature = true
		if !any_mature:
			loc.erase(l)
		
	for tile in farm.get_all_tiles():
		tile.TILE_BUTTON.disabled = !tile.grid_location in loc
		tile.SELECT_PROMPT.visible = tile.grid_location in loc
		tile.SELECT_PROMPT.play("default")

func highlight_seeds():
	var week = turn_manager.week
	if Global.selected_card != null:
		for card in cards.HAND_CARDS.get_children():
			card.set_highlight(false)
		if week == 1:
			highlight_tiles([Vector2(2, 2), Vector2(5, 2), Vector2(2, 4)], Enums.TileState.Empty)
	else:
		reset_tiles()
		for card in cards.HAND_CARDS.get_children():
			if card.card_info.type == "SEED":
				card.set_highlight(true)
			else:
				card.set_disabled(true)

func reset_cards():
	for card in cards.HAND_CARDS.get_children():
		card.set_highlight(false)
		card.set_disabled(false)

func dummy_attack_pattern(blight_pattern, fortunes: Array[Fortune]):
	var attack_pattern = SimpleAttackBuilder.new()
	for fortune in fortunes:
		attack_pattern.fortune_once(fortune)
	attack_pattern = attack_pattern.build()
	var pattern: Array[int] = []
	pattern.assign(blight_pattern)
	attack_pattern.blight_pattern = pattern
	attack_pattern.compute_fortunes(1)
	return attack_pattern
