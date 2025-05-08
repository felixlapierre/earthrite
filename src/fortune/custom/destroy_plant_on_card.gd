extends Fortune
class_name DestroyPlantOnCard

var callback_card_played: Callable
var event_type_card_played = EventManager.EventType.AfterCardPlayed

var texture_display = load("res://assets/fortune/destroy-on-play.png")
var spark_sf = preload("res://src/animation/blight/blight_spark.tres")

func _init(strength: float = 1.0) -> void:
	super("Spell Breaker", FortuneType.BadFortune, "Destroy {STRENGTH} plant(s) whenever you play a card", -1, texture_display, strength)

func register_fortune(event_manager: EventManager):
	await popup_callback.call(true)
	await event_manager.farm.get_tree().create_timer(0.7).timeout
	popup_callback.call(false)
	callback_card_played = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature].has(tile.state)\
				and tile.seed_base_yield != 0.0 and !tile.is_protected() and tile.seed.get_effect("corrupted") == null:
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(strength, targeted_tiles.size())):
			targeted_tiles[i].destroy_plant()
			args.farm.do_animation(spark_sf, targeted_tiles[i].grid_location)
	event_manager.register_listener(event_type_card_played, callback_card_played)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_card_played, callback_card_played)
