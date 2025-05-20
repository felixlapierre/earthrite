extends Fortune
class_name DestroyPlantOnCard

var callback_card_played: Callable
var event_type_card_played = EventManager.EventType.AfterCardPlayed

var listener_end_turn: Listener

var texture_display = load("res://assets/fortune/destroy-on-play.png")
var spark_sf = preload("res://src/animation/blight/blight_spark.tres")

func _init(strength: float = 1.0) -> void:
	super("Spell Breaker", FortuneType.BadFortune, "Whenever you play a card, mark {STRENGTH} plant(s) to be destroyed at the end of the turn", -1, texture_display, strength)

func register_fortune(event_manager: EventManager):
	listener_end_turn = Listener.new("destroy-plant-per-card", EventManager.EventType.AfterGrow, func(args: EventArgs):
		var tiles_to_destroy = []
		for tile in args.farm.get_all_tiles():
			if tile.destroy_targeted:
				if !tile.is_protected():
					tiles_to_destroy.append(tile)
		if tiles_to_destroy.size() > 0:
			await popup_callback.call(true)
			for tile in tiles_to_destroy:
				if tile.seed != null:
					tile.destroy_plant()
				tile.set_destroy_targeted(false)
				args.farm.do_animation(spark_sf, tile.grid_location)
			popup_callback.call(false)
		)
	
	callback_card_played = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature].has(tile.state)\
				and tile.seed_base_yield != 0.0 and !tile.is_protected() and tile.seed.get_effect("corrupted") == null:
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(strength, targeted_tiles.size())):
			targeted_tiles[i].set_destroy_targeted(true)
	event_manager.register_listener(event_type_card_played, callback_card_played)
	event_manager.register(listener_end_turn)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_card_played, callback_card_played)
	listener_end_turn.disable()
