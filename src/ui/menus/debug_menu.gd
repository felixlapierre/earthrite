extends Node2D

var SELECT_CARD = preload("res://src/cards/select_card.tscn")
var cards_database: DataFetcher = preload("res://src/cards/cards_database.gd").new()
var user_interface: UserInterface
var turn_manager: TurnManager

var on_close: Callable

var tooltip: Tooltip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(p_user_interface: UserInterface, p_turn_manager: TurnManager, p_on_close: Callable):
	user_interface = p_user_interface
	turn_manager = p_turn_manager
	on_close = p_on_close
	$Center/Panel/VBox/Menu/Year.text = "Add Year (Current: " + str(turn_manager.year) + ")"

func _on_card_pressed() -> void:
	var combined = []
	combined.append_array(cards_database.cards_rarity["basic"])
	combined.append_array(cards_database.get_all_cards())
	combined.append_array(cards_database.cards_rarity["unique"])
	combined.append_array(cards_database.cards_rarity["blight"])
	create_select_card(combined, "Select a card to add to your deck", func(card):
		user_interface.deck.append(card))

func create_select_card(options: Array[Variant], prompt: String, callback: Callable):
	create_select_card_enhance(options, prompt, null, callback)

func create_select_card_enhance(options: Array[Variant], prompt: String, enhance: Variant, callback: Callable):
	var select_card = SELECT_CARD.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.select_callback = func(data):
		callback.call(data)
		remove_child(select_card)
	select_card.select_cancelled.connect(func():
		remove_child(select_card))
	add_child(select_card)
	if enhance != null:
		select_card.do_enhance_pick(options, enhance, prompt)
	else:
		select_card.do_card_pick(options, prompt)

func _on_enhance_pressed() -> void:
	var all_enhances = cards_database.get_all_enhance()
	create_select_card(all_enhances, "Select an enhance to apply", func(enhance):
		create_select_card_enhance(user_interface.deck, "Select a card to enhance", enhance, func(card):
			user_interface.deck.erase(card)
			user_interface.deck.append(card.apply_enhance(enhance))))


func _on_close_button_pressed() -> void:
	on_close.call()

func _on_structure_pressed() -> void:
	var all_structures = cards_database.get_all_structure(null)
	create_select_card(all_structures, "Select a Structure", func(structure):
		visible = false
		user_interface._on_explore_on_structure_select(structure, func(): 
			visible = true))


func _on_blessing_pressed() -> void:
	var blessings = cards_database.get_all_blessings()
	blessings.append_array(cards_database.get_all_curses())
	create_select_card(blessings, "Select a Blessing", func(blessing):
		user_interface._on_explore_on_fortune(blessing))


func _on_event_pressed() -> void:
	var select_options = $Center/Panel/VBox/SelectOptions
	var events: Array[CustomEvent] = cards_database.get_custom_events()
	for event in events:
		var button: Button = Button.new()
		button.text = event.name
		button.custom_minimum_size.y = 100
		button.pressed.connect(func():
			for child in select_options.get_children():
				select_options.remove_child(child)
			event.setup(turn_manager, user_interface, cards_database)
			user_interface.GameEventDialog.custom_event = event
			user_interface.GameEventDialog.update_interface()
			user_interface._on_explore_on_event()
			on_close.call()
			)
		select_options.add_child(button)
	$Center/Panel/VBox/Menu.visible = false
	


func _on_attack_pressed() -> void:
	var attack_database: AttackDatabase = user_interface.FortuneTeller.attack_database
	var difficulty = "easy"
	match Global.DIFFICULTY:
		2, 3, 4:
			difficulty = "hard"
		5, 6:
			difficulty = "mastery"
		7:
			difficulty = "absurd"
	var attacks: Array[AttackPattern] = attack_database.get_attacks(difficulty, turn_manager.year)
	var select_options = $Center/Panel/VBox/SelectOptions2
	for attack in attacks:
		var button: Button = Button.new()
		var name = ""
		for fortune in attack.get_all_fortunes_display():
			name += fortune.name + " "
		button.text = name
		button.custom_minimum_size.y = 100
		button.pressed.connect(func():
			for child in select_options.get_children():
				select_options.remove_child(child)
			user_interface.FortuneTeller.attack_pattern = attack
			user_interface.FortuneTeller.display_fortunes()
			on_close.call()
			)
		select_options.add_child(button)
	$Center/Panel/VBox/Menu.visible = false


func _on_year_pressed() -> void:
	turn_manager.year += 1
	Explore.explores = 0
	$Center/Panel/VBox/Menu/Year.text = "Add Year (Current: " + str(turn_manager.year) + ")"
	user_interface.end_year()


func _on_acorn_pressed():
	Global.ACORNS += 5
	Global.TOTAL_ACORNS += 5
