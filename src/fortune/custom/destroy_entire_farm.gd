extends Fortune
class_name DestroyEntireFarm

var callback_after_grow: Callable
var type_after_grow = EventManager.EventType.AfterGrow

var fortune_texture = preload("res://assets/fortune/DestroyFarm.png")
var spark_sf = preload("res://src/animation/blight/blight_spark.tres")

func _init(strength: float = 1.0) -> void:
	super("Annihilation", Fortune.FortuneType.BadFortune, "Turn Start: Mark {STRENGTH} plants to be destroyed at the end of the turn", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	callback_after_grow = func(args: EventArgs):
		var tiles_to_destroy = []
		for tile in args.farm.get_all_tiles():
			if [Enums.TileState.Growing, Enums.TileState.Mature].has(tile.state) and !tile.is_protected():
				tiles_to_destroy.append(tile)
		tiles_to_destroy.shuffle()
		if tiles_to_destroy.size() > 0:
			await popup_callback.call(true)
			for tile in tiles_to_destroy:
				if tile.seed != null:
					tile.destroy_plant()
				tile.set_destroy_targeted(false)
				args.farm.do_animation(spark_sf, tile.grid_location)
				event_manager.shake_screen(30.0)
				await args.farm.get_tree().create_timer(0.01).timeout
			popup_callback.call(false)
	event_manager.register_listener(type_after_grow, callback_after_grow)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_after_grow, callback_after_grow)
