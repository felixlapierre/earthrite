extends Effect2
class_name Epochrite

var listener_pertile
var listener_destroy

var tiles_grown = []

func register(event_manager: EventManager, tile: Tile):
	listener_pertile = Listener.new("epochrite-pertile", EventManager.EventType.OnActionCardUsed, func(args: EventArgs):
		var target: Tile = args.specific.tile
		tiles_grown.append(target)
		if target.seed != null:
			while target.current_grow_progress < target.seed_grow_time:
				target.grow_one_week()
		)
	listener_destroy = Listener.new("epochrite-destroy", EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		for target in args.farm.get_all_tiles():
			if !tiles_grown.has(target) and target.seed != null:
				target.destroy_plant()
		)

	owner.register(listener_destroy)
	owner.register(listener_pertile)

func get_description(size: int):
	return "Fully grow " + str(size) + " plants. [color=gold]Destroy[/color] ALL other plants on your farm."

func get_type():
	return "destroy_plant"

func unregister(event_manager: EventManager):
	listener_pertile.disable()
	listener_destroy.disable()

func copy():
	var copy = Epochrite.new()
	copy.assign(self)
	return copy
