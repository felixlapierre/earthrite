extends Effect2
class_name StrEffect

@export var strength: float
@export var base_strength: float = 1.0
@export var strength_increment: float = 1.0

func _init(p_timing = EventManager.EventType.AfterCardPlayed, p_seed = false, p_strength: float = 1.0, p_base_strength = 1.0, p_strength_increment = 1.0):
	super(p_timing, p_seed)
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

func get_description_interp(child_description: String) -> String:
	var replacement = str(strength) if strength == base_strength else "[color=aqua]" + str(strength) + "[/color]"
	return child_description.replace("{STRENGTH}", replacement)
