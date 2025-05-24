extends Effect2
class_name ProtectTile

var listener: Listener

var my_tile: Tile

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
		args.specific.tile.protected = true
		args.specific.tile.update_display())
	owner.register(listener)
	
func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	var copy = ProtectTile.new()
	copy.assign(self)
	return copy

func get_type():
	return Enums.EffectType.Protect

func get_description(size: int):
	return "[color=gold]Protect[/color] " + str(size) + " tile(s) until the end of the turn"

func get_long_description():
	return Helper.get_long_description("protect")
