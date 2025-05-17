extends Fortune
class_name SnowstormWeather

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var display_texture = preload("res://assets/fortune/snowflake.png")

func _init() -> void:
	super("Snowstorm", Fortune.FortuneType.GoodFortune, "Plants will not grow naturally this turn\nSet [img]res://assets/custom/BlightAttack.png[/img] to 0", 0, display_texture, strength)

func register_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = true
	event_manager.user_interface.get_node("..").get_node("Background").set_snow_visible(true)
	callback = func(args: EventArgs):
		args.turn_manager.target_blight = 0
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = false
	event_manager.user_interface.get_node("..").get_node("Background").set_snow_visible(false)
	event_manager.unregister_listener(event_type, callback)
