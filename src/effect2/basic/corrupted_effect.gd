extends Effect2
class_name CorruptedEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantHarvest, true, Enums.EffectType.Corrupted, "CorruptedEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var harvest: EventArgs.HarvestArgs = args.specific.harvest_args
		harvest.yld *= -1
		)

func unregister(event_manager: EventManager):
	pass

func get_description(size):
	return "[color=red]Corrupted[/color]"

func copy():
	return CorruptedEffect.new().assign(self)
