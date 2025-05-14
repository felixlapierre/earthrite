extends Resource
class_name Effect

@export var name: String

# Optional, depends on effect
@export var strength: float = 0

# Optional, depends on effect, always needed for structure
# Values: turn_start, before_grow, after_grow
# plant, grow, harvest
@export var on: String

# Optional, required for structure
# Values: self, adjacent, nearby
@export var range: String = "self"

# Should only be defined through at_location to avoid modifying what's on the seed
var grid_location: Vector2

# Will be defined during code execution for certain effects
@export var card: CardData = null

func _init(p_name = "", p_strength = 0.0, p_on = "", p_range = "self", p_grid_location = Vector2.ZERO, p_card = null):
	name = p_name
	strength = p_strength
	range = p_range
	on = p_on
	grid_location = p_grid_location
	card = p_card

# Creates a copy of this effect at the given location
func copy() -> Effect:
	var copy = Effect.new()
	copy.name = name
	copy.strength = strength
	copy.range = range
	copy.on = on
	copy.grid_location = grid_location
	copy.card = card.copy() if card != null else null
	return copy

func set_location(new_location: Vector2) -> Effect:
	grid_location = new_location
	return self

func set_card(new_card: CardData) -> Effect:
	if card == null and new_card != null:
		card = new_card
	return self

func sort(a: Effect, b: Effect):
	# return true if a is less than b
	var priority = ["irrigate", "plant"]
	var a_prio = priority.find(a, 0)
	var b_prio = priority.find(b, 0)
	#if a_prio == b_prio:
	#	return randi_range(0, 1) < 1
	#else:
	#	return a_prio > b_prio
	return a_prio > b_prio

func get_short_description(card: CardData, highlight: bool = false):
	var color_open = "[color=aqua]" if highlight else ""
	var color_close = "[/color]" if highlight else ""
	match name:
		"plant":
			if on == "harvest":
				return color_open + "Regrow " + (str(strength) if strength > 0 else "" + color_close)
		"springbound", "fleeting", "corrupted", "frozen", "burn", "echo":
			return "[color=gold]" + color_open + name.capitalize() + color_close + "[/color]"
		"energy":
			return get_on_text() + "Gain " + color_open + str(strength) + color_close + "[img]res://assets/custom/Energy.png[/img]"
		"draw":
			if self.card != null:
				return get_on_text() + "Add " + color_open + str(strength) + color_close + " copy of '" + self.card.name + "' to your hand"
			else:
				return get_on_text() + "Draw " + color_open + str(strength) + color_close + " card" + ("s" if strength > 1 else "")
		"spread":
			if on == "grow" or on == "harvest":
				if strength >= 1:
					return get_on_text() + "[color=gold]Spread[/color] " + color_open + str(strength) + color_close + " time(s)"
				else:
					return get_on_text() + color_open + str(strength*100) + "%" + color_close + " chance to spread"
			else:
				if strength >= 1:
					return "[color=gold]Spread[/color] " + get_size_target_plants(card) + " " + color_open + str(strength) + color_close + " time(s)"
				else:
					return color_open + str(strength*100) + "%" + color_close + " chance to spread " + get_size_target_plants(card)
		"increase_yield":
			return "Increase the " + Helper.mana_icon() + " of " + get_size_target_plants(card) + " by " + color_open + str(strength * 100) + "%" + color_close
		"harvest":
			return "Harvest " + get_size_target_plants(card)
		"harvest_delay":
			return "Harvest " + get_size_target_plants(card) + ". " + Helper.blue_mana() + " will not be lost at the end of this turn."
		"grow":
			return "Grow " + get_size_target_plants(card) + " by " + color_open + str(strength) + color_close + " week" + ("s" if strength != 1 else "")
		"add_yield":
			if card.type == "SEED":
				return get_on_text() + "Add " + color_open + get_strength_text() + color_close + " " + Helper.mana_icon()
			else:
				return "Add " + color_open + get_strength_text() + color_close + " " + Helper.mana_icon() + " to " + get_size_target_plants(card)
		"irrigate":
			if card.type == "ACTION":
				return "[color=gold]Water[/color] " + get_size(card) + " tiles"
			elif range == "adjacent":
				return get_on_text() + "[color=gold]Water[/color] 9 adjacent tiles"
			else:
				return get_on_text() + "[color=gold]Water[/color] tile"
		"absorb":
			return "Benefits " + str(strength*100) + "% more from being watered"
		"destroy_tile":
			if card.type == "SEED":
				return get_on_text() + "[color=gold]Destroy[/color] tile"
			else:
				return "[color=gold]Destroy[/color] " + get_size(card) + " tiles"
		"destroy_plant":
			return get_on_text() + "[color=gold]Destroy[/color] " + get_size_target_plants(card)
		"replant":
			return "Replant " + get_size_target_plants(card)
		"add_recurring":
			return "Add '[color=gold]Regrow[/color]' to " + get_size_target_plants(card)
		"draw_target":
			return "Add " + color_open + get_strength_text() +  color_close + " [color=gold]Fleeting[/color] cop" + ("y" if strength == 1 else "ies") + " of the plant's seed to your hand"
		"add_blight_yield":
			return "Add " + color_open + get_strength_text() + color_close + " base " + Helper.mana_icon() + " per " + Helper.blight_icon() + " when planted"
		"protect":
			return "Protect " + get_size(card) + " tiles from the Blight"
		_:
			return ""

func get_long_description():
	match name:
		"plant":
			if on == "harvest":
				if strength == 0:
					return Helper.get_long_description("regrow")
				else:
					return Helper.get_long_description("regrow-strength", strength)
		"add_recurring":
			return Helper.get_long_description("regrow")
		"harvest_delay":
			return Helper.get_long_description("harvest")
		"draw_target":
			return Helper.get_long_description("fleeting")
		"irrigate":
			return Helper.get_long_description("water")
		"absorb":
			return Helper.get_long_description("watered")
		_:
			return Helper.get_long_description(name)

func get_size(card: CardData):
	if card.size == -1:
		return "all"
	else:
		return str(card.size)

func get_size_target_plants(card: CardData):
	if card.size == -1:
		return "all plants"
	elif card.size == 1:
		return "1 plant"
	else:
		return str(card.size) + " plants"

func get_on_text():
	match on:
		"plant":
			return "[color=gold]When Planted[/color]: "
		"":
			return ""
		_:
			return "[color=gold]On " + on.capitalize() + "[/color]: "

func get_strength_text():
	if strength >= 0:
		return str(strength)
	elif strength == -1:
		return "(1× the energy spent)"
	else:
		return "(" + str(strength * -1) + "× the energy spent)"

func save_data():
	return {
		"path": get_script().get_path(),
		"name": name,
		"strength": strength,
		"on": on,
		"range": range
	}

func load_data(data) -> Effect:
	name = data.name
	strength = data.strength
	on = data.on
	range = data.range
	return self
