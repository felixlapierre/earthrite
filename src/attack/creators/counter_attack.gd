extends AttackPattern
class_name CounterAttackPattern

var block_ritual = BlockRitual.new(1.0)
var counter = Counter.new(5.0)

func get_fortunes_at_week(week: int) -> Array[Fortune]:
	if week >= blight_pattern.size():
		return []
	if blight_pattern[week] == 0:
		return [block_ritual]
	else:
		return [counter]

func get_all_fortunes_display():
	return [block_ritual, counter]

func save_data():
	var data = {}
	data.path = get_script().get_path()
	return data

func load_data(_data):
	pass
