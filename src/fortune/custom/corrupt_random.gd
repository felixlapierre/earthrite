extends Fortune
class_name CorruptRandom

var listener

var callback_after_grow: Callable
var type_after_grow = EventManager.EventType.AfterGrow

var corrupt_effect = preload("res://src/effect2/basic/data/corrupted_effect.tres")
var fortune_texture = preload("res://assets/random/void.png")
var spark_sf = preload("res://src/animation/blight/blight_spark.tres")

func _init(strength: float = 1.0) -> void:
	super("Corruption", Fortune.FortuneType.BadFortune, "Turn end: Add 'Corrupted' to {STRENGTH} random plant(s)", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	listener = Listener.new(type_after_grow, func(args: EventArgs):
		var candidates = []
		for tile in args.farm.get_all_tiles():
			if [Enums.TileState.Growing, Enums.TileState.Mature].has(tile.state) and !tile.is_protected() and tile.seed_base_yield > 0 and !tile.seed.has_effect(Enums.EffectType.Corrupted):
				candidates.append(tile)
		if candidates.size() > 0:
			await popup_callback.call(true)
			candidates.shuffle()
			for tile in candidates.slice(0, strength):
				tile.seed.effects2.append(corrupt_effect)
				corrupt_effect.owner = tile.seed
				corrupt_effect.register(event_manager, tile)
				args.farm.do_animation(spark_sf, tile.grid_location)
			popup_callback.call(false)
		)
	
	event_manager.register(listener)

func unregister_fortune(event_manager: EventManager):
	listener.disable()
