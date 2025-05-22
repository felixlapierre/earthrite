extends Resource
class_name Effect2

var callback: Callable

@export var timing: EventManager.EventType
@export var is_seed: bool = false

var owner: CardData

func _init(p_timing = EventManager.EventType.AfterCardPlayed, p_seed = false):
	timing = p_timing
	is_seed = p_seed
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

func get_timing_text(p_timing: EventManager.EventType = timing) -> String:
	match p_timing:
		EventManager.EventType.BeforeTurnStart:
			return "[color=gold]Turn Start[/color]: "
		EventManager.EventType.OnPlantHarvest:
			return "[color=gold]On Harvest[/color]: "
		EventManager.EventType.BeforeCardPlayed, EventManager.EventType.AfterCardPlayed, EventManager.EventType.OnActionCardUsed:
			return ""
		_:
			return "On ???: "

func save_data() -> Dictionary:
	var save_dict = {
		"path": get_script().get_path(),
		"timing": timing,
		"is_seed": is_seed
	}
	return save_dict

func load_data(data) -> Effect2:
	timing = data.timing
	is_seed = data.is_seed
	return self

func can_strengthen():
	return false

func assign(other: Effect2):
	timing = other.timing
	is_seed = other.is_seed

func get_type() -> String:
	return "other"

func get_long_description() -> String:
	return Helper.get_long_description(get_type())
