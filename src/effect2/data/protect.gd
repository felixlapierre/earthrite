extends Effect2
class_name ProtectTile

var listener: Listener

var my_tile: Tile

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, false, Enums.EffectType.Protect, "Protect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
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
	var size_text = str(size) if size != -1 else "ALL"
	return "[color=gold]Protect[/color] " + size_text + " tile(s) until the end of the turn"

func get_long_description():
	return Helper.get_long_description("protect")
