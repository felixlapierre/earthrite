extends Effect2
class_name StrEffect

@export var strength: float
@export var base_strength: float = 1.0
@export var strength_increment: float = 1.0

func _init(event_type, seed, effect_type, name, p_strength: float = 1.0, p_base_strength = 1.0, p_strength_increment = 1.0):
	super(event_type, seed, effect_type, name)
	strength = p_strength
	base_strength = p_base_strength
	strength_increment = p_strength_increment

func save_data() -> Dictionary:
	var save_dict = super.save_data()
	save_dict["strength"] = strength
	save_dict["base_strength"] = base_strength
	save_dict["strength_increment"] = strength_increment
	return save_dict

func load_data(data) -> Effect2:
	super.load_data(data)
	strength = data.strength
	strength_increment = data.strength_increment
	base_strength = data.base_strength
	return self

func can_strengthen():
	return true

func assign(other: Effect2):
	super.assign(other)
	strength = other.strength
	strength_increment = other.strength_increment
	base_strength = other.base_strength
	return self

func get_description_interp(child_description: String) -> String:
	var str_descr = str(strength)
	if strength < 0:
		str_descr = str(abs(strength)) + Helper.energy_icon()
	return child_description.replace("{STRENGTH}", highlight(str_descr))

func highlight(text: String):
	if strength > base_strength:
		return "[color=aqua]" + text + "[/color]"
	elif strength < base_strength:
		return "[color=tomato]" + text + "[/color]"
	return text
