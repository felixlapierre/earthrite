extends Resource
class_name AttackPattern

var blight_pattern: Array[int] = []
var fortunes: = []
var rank: int = 0
var simple_attack_callback: Callable
var damage_multiplier = 1.0

var difficulty_map = {}

var current_fortunes = []

func get_fortunes():
	return fortunes

func compute_fortunes(_year: int):
	fortunes = []
	for i in range(1, Global.FINAL_WEEK + 1):
		fortunes.append(get_fortunes_at_week(i))

func get_fortunes_at_week(_week: int) -> Array[Fortune]:
	return []

func register_fortunes(event_manager: EventManager, week: int):
	unregister_fortunes(event_manager)
	current_fortunes.append_array(get_fortunes_at_week(week))
	for fortune: Fortune in current_fortunes:
		fortune.register_fortune(event_manager)

func unregister_fortunes(event_manager: EventManager):
	for fortune: Fortune in current_fortunes:
		fortune.unregister_fortune(event_manager)
	current_fortunes.clear()

func get_blight_pattern():
	return blight_pattern

func compute_blight_pattern(year: int):
	if blight_pattern.size() > 0:
		return
	blight_pattern = [0]
	var charge: float = 0.0
	var chance = 0.0
	var base_charge_inc = 5.0
	base_charge_inc += 2 if year >= 2 else 0
	base_charge_inc += 3 if year >= 3 else 0
	for i in range(1, Global.FINAL_WEEK):
		charge += base_charge_inc
		if Global.DIFFICULTY >= Constants.DIFFICULTY_INCREASE_TARGETS:
			charge += 0.6 * year
		if Global.DIFFICULTY >= Constants.DIFFICULTY_HARD:
			charge += 1.0 * year
		if Mastery.MasteryLevel > 0:
			charge += 0.5 * year * Mastery.MasteryLevel
		chance += 0.3
		if (year < 3 and i < 3) or (year < 8 and i < 2):
			blight_pattern.append(0)
		elif i == Global.FINAL_WEEK - 1:
			blight_pattern.append(int(charge))
			charge = 0.0
		elif randf() < chance:
			chance = 0.0
			var amount = int(randf_range(0.4, 1.0) * charge)
			charge -= amount
			blight_pattern.append(amount)
		else:
			blight_pattern.append(0)
	# Winter
	blight_pattern.append(30 + 10 * year)
	for i in range(blight_pattern.size()):
		blight_pattern[i] = int(blight_pattern[i] * get_multiplier(year))

func get_multiplier(year: int):
	var year_multiplier = 1.0 + (year - 1) * 0.1
	var difficulty_multiplier = Global.BLIGHT_TARGET_MULTIPLIER
	return year_multiplier * difficulty_multiplier * damage_multiplier

func save_data():
	var data = {}
	data.path = get_script().get_path()
	data.damage_multiplier = damage_multiplier
	return data

func load_data(data):
	damage_multiplier = data.damage_multiplier

func get_all_fortunes_display():
	return []
