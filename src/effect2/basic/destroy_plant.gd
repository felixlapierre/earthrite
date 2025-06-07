extends Effect2
class_name DestroyPlantEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.DestroyPlant, "DestroyPlant")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.tile.destroy_plant()
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "[color=gold]Destroy[/color] target plants"

func assign(other):
	super.assign(other)
	timing = other.timing
	seed = other.seed
	return self

func copy():
	return DestroyPlantEffect.new().assign(self)
