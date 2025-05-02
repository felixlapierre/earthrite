extends Resource
class_name Fortune

enum FortuneType {
	GoodFortune,
	BadFortune
}

var temp: Texture2D = preload("res://assets/custom/Temp.png")

@export var name: String
@export var type: FortuneType
@export var text: String
@export var rank: int
@export var texture: Texture2D
@export var strength: float = 0.0
@export var effects: Array[Effect2]

func _init(p_name = "", p_type = FortuneType.GoodFortune, p_text = "", p_rank = 0, p_texture = temp, p_strength = 1.0, p_effects = []):
	name = p_name
	type = p_type
	text = p_text
	rank = p_rank
	texture = p_texture
	strength = p_strength
	effects.assign(p_effects)

func register_fortune(event_manager: EventManager):
	for effect in effects:
		effect.register_events(event_manager, null)

func unregister_fortune(event_manager: EventManager):
	for effect in effects:
		effect.unregister_events(event_manager)

func get_description():
	var descr = text.replace("{STRENGTH}", str(strength))\
		.replace("{STR_PER}", str(strength * 100) + "%")
	for effect in effects:
		descr += effect.get_description(-1)
	return descr

func save_data() -> Dictionary:
	var save_dict = {
		"path": get_script().get_path(),
		"name": name,
		"type": type,
		"text": text,
		"rank": rank,
		"texture": texture.resource_path if texture != null else null,
		"strength": strength,
		"effects": effects.map(func(effect):
			return effect.save_data())
	}
	return save_dict

func load_data(data) -> Fortune:
	name = data.name
	type = data.type
	text = data.text
	rank = data.rank
	texture = load(data.texture) if data.texture != null else null
	strength = data.strength
	effects.assign(data.effects.map(func(effect):
		var eff = load(effect.path).new()
		eff.load_data(effect)
		return eff))
	return self
