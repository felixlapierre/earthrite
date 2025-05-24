extends Resource

class_name Structure

const CLASS_NAME = "Structure"

@export var name: String
@export var rarity: String
@export var cost: int
@export var size: int
@export var text: String
@export var texture: Texture2D
@export var effects: Array[Effect]
@export var tooltip: String
@export var effects2: Array[Effect2]

var grid_location: Vector2
var type = "STRUCTURE"
var rotate: int = 0

func _init(p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1,\
	p_size = 1, p_text = "", p_texture = null, p_effects = [],\
	p_tooltip = "", p_grid_location = Vector2.ZERO, p_effects_2 = []):
		name = p_name
		rarity = p_rarity
		cost = p_cost
		size = p_size
		text = p_text
		texture = p_texture
		effects.assign(p_effects)
		grid_location = p_grid_location
		tooltip = p_tooltip
		effects2.assign(p_effects_2)

func get_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return effect
	return null

func copy():
	var n_targets = []
	var n_effects = []
	var n_effects_2 = []
	for effect in effects:
		n_effects.append(effect.copy())
	for effect in effects2:
		n_effects_2.append(effect.copy())
	return Structure.new(name, rarity, cost, size, text, texture, n_effects, tooltip, Vector2.ZERO, n_effects_2)

func assign(s: Structure):
	name = s.name
	rarity = s.rarity
	cost = s.cost
	size = s.size
	text = s.text
	texture = s.texture
	effects.assign(s.effects)
	grid_location = s.grid_location
	rotate = s.rotate
	tooltip = s.tooltip
	effects2.assign(s.effects2)

func get_description():
	var result = text
	for effect in effects2:
		var descr = effect.get_description(size)
		if descr.length() > 0:
			if result.length() > 0:
				result += ". "
			result += descr
	return result.replace("{MANA}", Helper.mana_icon())\
		.replace("{BLUE_MANA}", Helper.blue_mana())\
		.replace("{ENERGY}", Helper.energy_icon())

# To be overridden by specific script structures
func register_events(event_manager: EventManager, tile: Tile):
	for effect in effects2:
		effect.register_events(event_manager, tile)

func unregister_events(event_manager: EventManager):
	for effect in effects2:
		effect.unregister_events(event_manager)

func do_winter_clear():
	pass

func save_data():
	return {
		"path": get_script().get_path(),
		"name": name,
		"rarity": rarity,
		"cost": cost,
		"size": size,
		"text": text,
		"texture": texture.resource_path if texture != null else null,
		"effects": effects.map(func(effect):
			return effect.save_data()),
		"effects2": effects2.map(func(effect):
			return effect.save_data()),
		"x": grid_location.x,
		"y": grid_location.y,
		"rotate": rotate,
		"tooltip": tooltip
	}

func load_data(data) -> Structure:
	name = data.name
	rarity = data.rarity
	cost = data.cost
	size = data.size
	text = data.text
	texture = load(data.texture)
	effects.assign(data.effects.map(func(effect):
		var eff = load(effect.path).new()
		eff.load_data(effect)
		return eff))
	effects2.assign(data.effects2.map(func(effect):
		var eff = load(effect.path).new()
		eff.load_data(effect)
		return eff))
	grid_location = Vector2(data.x, data.y)
	rotate = data.rotate
	tooltip = data.tooltip
	return self
