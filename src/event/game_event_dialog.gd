extends Node2D

var current_event: GameEvent
var completed_events: Array[String] = []
var always_do_event = null#load("res://src/event/script/sacred_glade.gd").new()

signal on_upgrades_selected

var card_database: DataFetcher
var deck: Array[CardData] = []
var turn_manager: TurnManager = null
var user_interface: UserInterface = null

var custom_event: CustomEvent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_database = preload("res://src/cards/cards_database.gd").new()

func setup(p_deck: Array[CardData], p_turn_manager: TurnManager, p_ui: UserInterface):
	deck = p_deck
	turn_manager = p_turn_manager
	user_interface = p_ui

func generate_random_event():
	if always_do_event != null and !completed_events.has(always_do_event.name):
		custom_event = always_do_event
		custom_event.setup(turn_manager, $"../../", card_database)
	else:
		# Prioritize custom events
		var custom_events = card_database.get_custom_events()
		var options = []
		for event in custom_events:
			event.setup(turn_manager, $"../../", card_database)
			if event.check_prerequisites() and !completed_events.has(event.name):
				options.append(event)
		
		if options.size() > 0:
			options.shuffle()
			custom_event = options[0]

	if custom_event != null:
		update_interface()
		return

	if always_do_event != null and !completed_events.has(always_do_event.name):
		current_event = always_do_event
	else:
		var events = card_database.get_all_event()
		events.shuffle()
		for event in events:
			if !completed_events.has(event.name)\
				and (event.prerequisite == null or completed_events.has(event.prerequisite.name))\
				and event.check_upgrade_prerequisite(deck, turn_manager):
				current_event = event
				break

	completed_events.append(current_event.name)
	update_interface()

func update_interface():
	$EventDialog.set_event(custom_event)

func _on_click_out_button_pressed():
	visible = false

func _on_event_dialog_on_confirm() -> void:
	completed_events.append(custom_event.name)
	generate_random_event()
	update_interface()
	visible = false
	user_interface._on_explore_button_pressed()
