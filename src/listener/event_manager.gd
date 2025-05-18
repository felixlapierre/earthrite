extends Node
class_name EventManager

var farm: Farm
var turn_manager: TurnManager
var cards: Cards
var user_interface: UserInterface

var on_year_start_listeners: Array[Callable] = []
var on_turn_end_listeners: Array[Callable] = []

var listeners: Dictionary = {}

var listeners2: Dictionary = {}

enum EventType {
	# Time-based triggers
	BeforeYearStart,
	AfterYearStart,
	BeforeTurnStart,
	BeforeGrow,
	AfterGrow,
	OnTurnEnd,
	# Game action triggers
	OnPlantPlanted,
	OnPlantGrow,
	OnPlantHarvest,
	OnPlantDestroyed,
	BeforeCardPlayed,
	AfterCardPlayed,
	OnTileDestroyed,
	OnActionCardUsed,
	OnYieldPreview,
	OnPickCard,
	OnCardBurned,
	OnCardDrawn,
	OnTileWatered,
	EndYear
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for type in EventType.values():
		listeners[type] = []
		listeners2[type] = []

func setup(p_farm: Farm, p_turn_manager: TurnManager, p_cards: Cards, p_user_interface: UserInterface):
	farm = p_farm
	turn_manager = p_turn_manager
	cards = p_cards
	user_interface = p_user_interface

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_listener(event_type: EventType, callback: Callable):
	listeners[event_type].append(callback)

func unregister_listener(event_type: EventType, callback: Callable):
	if event_type == EventManager.EventType.AfterCardPlayed:
		pass
	listeners[event_type].erase(callback)

func notify(event_type: EventType):
	# Making a copy because some listeners will unregister themselves, which is
	# problematic as removing an element from an array while iterating through
	# it can cause elements to be skipped
	var listeners_copy = []
	listeners_copy.assign(listeners[event_type])
	for listener in listeners_copy:
		if !listener.is_null():
			await listener.call(get_event_args(null))
	
	for listener in listeners2[event_type]:
		listener.invoke(get_event_args(null))

func notify_specific_args(event_type: EventType, specific_args: EventArgs.SpecificArgs):
	var listeners_copy = []
	listeners_copy.assign(listeners[event_type])
	for listener in listeners_copy:
		if !listener.is_null():
			await listener.call(get_event_args(specific_args))
	
	var remove = []
	for listener in listeners2[event_type]:
		if listener.disabled:
			remove.append(listener)
		listener.invoke(get_event_args(specific_args))
	for listener in remove:
		listeners2[event_type].erase(listener)

func notify_card(card: CardData, event_type: EventType):
	card.notify(event_type, get_event_args(null))

func get_event_args(spec):
	return EventArgs.new(farm, turn_manager, cards, spec, user_interface)

func shake_screen(amount: float):
	$"../".shake_camera(amount)

func register(listener: Listener):
	listeners2[listener.type].append(listener)
