extends Fortune
class_name DestroyPlants

var callback_turn_start: Callable
var callback_after_grow: Callable
var type_after_grow = EventManager.EventType.AfterGrow
var type_turn_start = EventManager.EventType.BeforeTurnStart

var fortune_texture = preload("res://assets/fortune/DestroyFortune.png")
var spark_sf = preload("res://src/animation/blight/blight_spark.tres")

func _init(strength: float = 1.0) -> void:
	super("Destruction", Fortune.FortuneType.BadFortune, "Turn Start: Mark {STRENGTH} plants to be destroyed at the end of the turn", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	callback_turn_start = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature].has(tile.state)\
				and tile.seed_base_yield != 0.0 and !tile.is_protected() and tile.seed.get_effect("corrupted") == null:
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(strength, targeted_tiles.size())):
			targeted_tiles[i].set_destroy_targeted(true)
	event_manager.register_listener(type_turn_start, callback_turn_start)
	
	callback_after_grow = func(args: EventArgs):
		var tiles_to_destroy = []
		for tile in args.farm.get_all_tiles():
			if tile.destroy_targeted:
				if !tile.is_protected():
					tiles_to_destroy.append(tile)
				else:
					tile.set_destroy_targeted(false)
		if tiles_to_destroy.size() > 0:
			await popup_callback.call(true)
			for tile in tiles_to_destroy:
				if tile.seed != null:
					tile.destroy_plant()
				tile.set_destroy_targeted(false)
				args.farm.do_animation(spark_sf, tile.grid_location)
			popup_callback.call(false)
	event_manager.register_listener(type_after_grow, callback_after_grow)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_turn_start, callback_turn_start)
	event_manager.unregister_listener(type_after_grow, callback_after_grow)
