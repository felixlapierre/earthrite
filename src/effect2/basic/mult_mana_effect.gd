extends StrEffect
class_name MultiplyManaEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.AddMana, "MultManaEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var mana = args.specific.tile.current_yield
		args.specific.tile.add_yield(mana * (1 + strength))
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return get_timing_text() + "Add %s% mana to %s plants" % [highlight(str(strength * 100)), Helper.get_size_text(size)]

func copy():
	return MultiplyManaEffect.new().assign(self)
