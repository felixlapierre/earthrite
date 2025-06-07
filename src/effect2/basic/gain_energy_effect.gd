extends StrEffect
class_name GainEnergyEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.GainEnergy, "GainEnergyEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.turn_manager.energy += strength
		args.user_interface.update())
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return (get_timing_text() + "Gain %s" + Helper.energy_icon()) % highlight(str(strength))

func copy():
	return GainEnergyEffect.new().assign(self)
