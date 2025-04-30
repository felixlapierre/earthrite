extends Resource
class_name Effect2

var callback: Callable

@export var timing: EventManager.EventType
@export var is_seed: bool = false
@export var strength: float = 1.0
@export var strength_increment: float = 1.0

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
func get_description() -> String:
	# Timing
	match timing:
		EventManager.EventType.BeforeTurnStart:
			return "Turn start: "
		EventManager.EventType.BeforeCardPlayed, _:
			return ""

func save_data() -> Dictionary:
	var save_dict = {
		"path": get_script().get_path(),
		"timing": timing,
		"is_seed": is_seed,
		"strength": strength,
		"strength_increment": strength_increment
	}
	return save_dict

func load_data(data) -> Effect2:
	timing = data.timing
	strength = data.strength
	strength_increment = data.strength_increment
	is_seed = data.is_seed
	return self

func can_strengthen():
	return false

func assign(other: Effect2):
	timing = other.timing
	is_seed = other.is_seed
	strength = other.strength
	strength_increment = other.strength_increment
