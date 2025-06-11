extends StrEffect
class_name GainManaEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value
@export var purple: bool

func _init(p_timing = EventManager.EventType.AfterCardPlayed, p_seed = false, p_purple = false):
	super(timing, is_seed, Enums.EffectType.AddMana, "GainManaEffect")
	timing = p_timing
	seed = p_seed
	purple = p_purple

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var harvest_args = EventArgs.HarvestArgs.new(strength, purple)
		args.farm.gain_yield(tile, harvest_args)
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	return GainManaEffect.new().assign(self)

func assign(other):
	super.assign(other)
	purple = other.purple
	return self

func save_data():
	var data = super.save_data()
	data.purple = purple
	return data

func load_data(data):
	super.load_data(data)
	purple = data.purple
	return self

func get_description(size):
	if !purple:
		return "Gain " + highlight(str(strength)) + " {MANA}"
	else:
		return "Gain " + highlight(str(strength)) + " " + Helper.blue_mana()
