extends Effect2
class_name Epochrite

var spark_sf = preload("res://src/animation/other/lightning_sf.tres")

var listener_pertile
var listener_destroy

var tiles_grown = []

func register(event_manager: EventManager, tile: Tile):
	listener_pertile = Listener.new(EventManager.EventType.OnActionCardUsed, func(args: EventArgs):
		var target: Tile = args.specific.tile
		tiles_grown.append(target)
		if target.seed != null:
			var i = 0
			while target.current_grow_progress < target.seed_grow_time and i < 10:
				target.grow_one_week()
				i += 1
				args.farm.do_animation(spark_sf, target.grid_location)
				await args.farm.get_tree().create_timer(0.01).timeout
		)
	listener_destroy = Listener.new(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		for target in args.farm.get_all_tiles():
			if !tiles_grown.has(target) and target.seed != null:
				target.destroy_plant()
		)

	owner.register(listener_destroy)
	owner.register(listener_pertile)

func get_description(size: int):
	return "Grow " + str(size) + " plants 10 times. [color=gold]Destroy[/color] ALL other plants on your farm."

func get_type():
	return Enums.EffectType.DestroyPlant

func unregister(event_manager: EventManager):
	listener_pertile.disable()
	listener_destroy.disable()

func copy():
	var copy = Epochrite.new()
	copy.assign(self)
	return copy
