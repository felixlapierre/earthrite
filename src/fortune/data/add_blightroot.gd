extends Fortune
class_name AddBlightroot

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var blightroot = preload("res://src/fortune/unique/blightroot.tres")
var blightroot_texture = preload("res://assets/fortune/blightroot_fortune.png")
var spark_sf = preload("res://src/animation/blight/blight_spark.tres")

func _init(strength: float = 1.0) -> void:
	super("Blightroot", Fortune.FortuneType.BadFortune, "Turn start: Add {STRENGTH} spreading Blightroot to your farm", 0, blightroot_texture, strength)

func register_fortune(event_manager: EventManager):
	callback = plant_weeds
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func plant_weeds(args: EventArgs):
	await popup_callback.call(true)
	for i in range(strength):
		var tile = args.farm.get_unprotected_tile()
		if tile == null:
			break
		args.farm.do_animation(spark_sf, tile.grid_location)
		await args.farm.use_card_on_targets(blightroot, [tile.grid_location], true, 0.1)
	popup_callback.call(false)
