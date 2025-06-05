extends Effect2
class_name Epochrite

var spark_sf = preload("res://src/animation/other/lightning_sf.tres")

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Grow, "Epochrite")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var target: Tile = args.specific.tile
		if target.seed != null:
			var i = 0
			while target.current_grow_progress < target.seed_grow_time and i < 10:
				await target.grow_one_week()
				i += 1
				args.farm.do_animation(spark_sf, target.grid_location)
				await args.farm.get_tree().create_timer(0.01).timeout
		)

	owner.register(listener)

func get_description(size: int):
	return "Grow " + str(size) + " plants 10 times."

func copy():
	var copy = Epochrite.new()
	copy.assign(self)
	return copy
