extends StrEffect
class_name AddBlightMana

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.AddMana, "AddBlightMana")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.tile.add_yield(args.turn_manager.get_blight_strength() * strength)
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	return AddBlightMana.new().assign(self)

func get_description(size):
	if is_seed:
		return get_timing_text() + "Gain " + highlight(str(strength)) + Helper.blight_icon() + "{MANA}"
	return get_timing_text() + "Add " + highlight(str(strength)) + Helper.blight_icon() + "{MANA} to target plants"
