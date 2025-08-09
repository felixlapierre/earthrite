extends Effect2
class_name CorruptedEffect

var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantHarvest, true, Enums.EffectType.Corrupted, "CorruptedEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		args.specific.harvest_args.yld = args.specific.harvest_args.yld * -1
		)
	#owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return "[color=tomato]Corrupted[/color] ([color=gold]On Harvest[/color], Mana is lost, not gained)"
	
func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	args.yld *= -1

func copy():
	return CorruptedEffect.new().assign(self)
