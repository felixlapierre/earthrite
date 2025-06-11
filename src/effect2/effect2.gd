extends Resource
class_name Effect2

var event_type: EventManager.EventType
var is_seed: bool = false
var effect_type: Enums.EffectType
var name: String = "default"

var owner: CardData

func _init(p_event_type = EventManager.EventType.AfterCardPlayed, p_seed = false, p_effect_type = Enums.EffectType.Other, p_name = "defaultname"):
	event_type = p_event_type
	is_seed = p_seed
	effect_type = p_effect_type
	name = p_name
	owner = null

func register_events(event_manager: EventManager, tile: Tile):
	if !is_seed:
		register(event_manager, tile)

func unregister_events(event_manager: EventManager):
	if !is_seed:
		unregister(event_manager)

func register_seed_events(event_manager: EventManager, tile: Tile):
	if is_seed:
		register(event_manager, tile)

func unregister_seed_events(event_manager: EventManager):
	if is_seed:
		unregister(event_manager)

# To be overridden
func register(event_manager: EventManager, tile: Tile):
	pass

# To be overridden
func unregister(event_manager: EventManager):
	pass

# To be overridden
func get_description(size: int) -> String:
	return get_timing_text()

func get_timing_text(p_timing: EventManager.EventType = event_type) -> String:
	match p_timing:
		EventManager.EventType.BeforeTurnStart:
			return "[color=gold]Turn Start[/color]: "
		EventManager.EventType.OnPlantHarvest:
			return "[color=gold]On Harvest[/color]: "
		EventManager.EventType.OnPlantPlanted:
			return "[color=gold]When Planted[/color]: "
		EventManager.EventType.OnPlantGrow:
			return "[color=gold]On Grow[/color]: "
		EventManager.EventType.BeforeCardPlayed, EventManager.EventType.AfterCardPlayed, EventManager.EventType.OnActionCardUsed:
			return ""
		_:
			return ""

func save_data() -> Dictionary:
	var save_dict = {
		"path": get_script().get_path(),
		"event_type": event_type,
		"is_seed": is_seed,
		"name": name,
		"effect_type": effect_type
	}
	return save_dict

func load_data(data) -> Effect2:
	event_type = data.event_type
	is_seed = data.is_seed
	name = data.name
	effect_type = data.effect_type
	return self

func can_strengthen():
	return false

func assign(other: Effect2):
	event_type = other.event_type
	is_seed = other.is_seed
	name = other.name
	effect_type = other.effect_type
	return self

func get_type() -> Enums.EffectType:
	return effect_type

func get_long_description() -> String:
	return Helper.get_long_description_type(get_type())

# Modify args in-place
func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	pass
