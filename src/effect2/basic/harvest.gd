extends Effect2
class_name HarvestEffect

var listener: Listener

@export var delay: bool

func _init(p_delay = false):
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Harvest, "Harvest")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.tile.harvest(delay)
	)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	return "Harvest " + str(size) + " tile(s)"

func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	var args2 = tile.seed.get_yield(tile)
	args.yld += args2.yld
	args.delay = delay or args.delay

func save_data():
	var data = super.save_data()
	data.delay = delay
	return data

func load_data(data):
	super.load_data(data)
	delay = data.delay
	
func assign(other):
	super.assign(other)
	delay = other.delay
	return self

func copy():
	var copy = HarvestEffect.new()
	copy.assign(self)
	return copy
