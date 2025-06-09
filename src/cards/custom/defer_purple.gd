extends Effect2
class_name DeferPurple

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.Other, "DeferExcessPurple")

# To be overridden by specific code seeds
func register(event_manager: EventManager, p_tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.harvest_args.purple = true
	)
	owner.register(listener)

func get_description(size):
	return get_timing_text() + "Excess {BLUE_MANA} will not be lost at the end of this turn."

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	var new = DeferPurple.new()
	new.assign(self)
	return new

func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	args.delay = true
