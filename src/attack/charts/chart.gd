extends Resource
class_name Chart

enum ChartType {
	Ritual,
	Blight
}

@export var name: String = ""
@export var type: ChartType
@export var rank: int = 0
@export var values: Array[float] = []

func _init(p_values = [], p_rank = 0, p_name = ""):
	values.append_array(p_values)
	rank = p_rank
	name = p_name

func get_value(at: int) -> float:
	if values.size() == 0:
		return 0.0
	if at >= values.size():
		return values.back()
	return values[at]
