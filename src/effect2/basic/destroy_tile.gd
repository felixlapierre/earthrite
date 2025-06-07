extends Effect2
class_name DestroyTileEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.DestroyPlant, "DestroyTileEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.tile.destroy()
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "[color=gold]Destroy[/color] tile(s)"

func copy():
	return DestroyTileEffect.new().assign(self)
