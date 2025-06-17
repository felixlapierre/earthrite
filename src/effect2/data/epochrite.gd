extends Effect2
class_name Epochrite

var spark_sf = preload("res://src/animation/other/lightning_sf.tres")

var listener: Listener

func _init():
	super(EventManager.EventType.AfterCardPlayed, false, Enums.EffectType.Grow, "Epochrite")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var times = 50
		var growable_tiles = args.farm.get_all_tiles().filter(func(tile: Tile): return tile.can_grow())
		while times > 0 and growable_tiles.size() > 0:
			var target: Tile = growable_tiles.pick_random()
			await target.grow_one_week()
			times -= 1
			args.farm.do_animation(spark_sf, target.grid_location)
			await args.farm.get_tree().create_timer(0.01).timeout
			if !target.can_grow():
				growable_tiles.erase(target)
		)

	owner.register(listener)

func get_description(size: int):
	return "Grow a random plant on your farm. Repeat 50 times."

func copy():
	var copy = Epochrite.new()
	copy.assign(self)
	return copy
