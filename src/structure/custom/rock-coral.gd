extends Effect2
class_name RockCoral

var listener: Listener

static var ACTIVE = false

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(EventManager.EventType.OnTileDestroyed, func(args: EventArgs):
		args.specific.tile.irrigate())
	
	ACTIVE = true
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	ACTIVE = false
	listener.disable()

func copy():
	return RockCoral.new().assign(self)

func get_description(size: int):
	return "Effects treat [color=gold]Destroyed[/color] tiles as [color=gold]Watered[/color] and vice-versa."

func get_long_description():
	return Helper.get_long_description_list(["destroyed_tile", "watered"])
