extends Node2D
class_name WeatherDisplay

var enabled

static var now: Fortune
static var in_one_week: Fortune
static var in_two_weeks: Fortune

var event_manager: EventManager

@onready var now_hover = $Panel/VBox/HBox/Now/FortuneHover
@onready var in_one_week_hover = $Panel/VBox/HBox/OneTurn/FortuneHover
@onready var in_two_weeks_hover = $Panel/VBox/HBox/TwoTurn/FortuneHover

static var options = [
	preload("res://src/fortune/weather/heatwave.gd").new(),
	preload("res://src/fortune/weather/hurricane.tres"),
	preload("res://src/fortune/weather/monsoon.gd").new(),
	preload("res://src/fortune/weather/snowstorm.gd").new(),
	preload("res://src/fortune/weather/thunderstorm.gd").new()
]

static var clear = preload("res://src/fortune/weather/clear.gd").new()

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, func(args: EventArgs):
		end_week(args.turn_manager.week))

func start_year():
	if now != null:
		now.unregister_fortune(event_manager)
	now = clear
	if Global.FARM_TYPE == "STORMVALE":
		in_one_week = Helper.pick_random(options)
	else:
		in_one_week = clear
	in_two_weeks = clear
	update()

func update():
	if now == null:
		return
	visible = clear != now or in_one_week != clear or  in_two_weeks != clear
	now_hover.setup(now)
	in_one_week_hover.setup(in_one_week)
	in_two_weeks_hover.setup(in_two_weeks)

func end_week(week: int):
	now.unregister_fortune(event_manager)
	now = in_one_week
	now.register_fortune(event_manager)
	in_one_week = in_two_weeks
	if Global.FARM_TYPE == "STORMVALE":
		in_two_weeks = clear if week % 2 == 0 else Helper.pick_random(options)
	else:
		in_two_weeks = clear
	update()
