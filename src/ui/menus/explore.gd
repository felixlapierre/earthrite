extends Node2D
class_name Explore

var player_deck
var tooltip
var year = 0

var ExplorePoint = load("res://src/ui/menus/explore_point.tscn")
var PickOption = preload("res://src/ui/pick_option.tscn")
var cards_database = preload("res://src/cards/cards_database.gd")
var SelectCard = preload("res://src/cards/select_card.tscn")

@onready var points = $Points

signal apply_upgrade
signal on_structure_select
signal on_expand
signal on_event
signal on_fortune

static var explores = 0

var expands = 0
var enhances = 0
var structures = 0
var removals = 0

var show_tutorial: Callable

var fixed_explores = []
static var bonus_explores = 0

var current_event: CustomEvent
var generate_random_event: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(deck, p_tooltip, p_tutorial_callback):
	player_deck = deck
	tooltip = p_tooltip
	explores = 0
	show_tutorial = p_tutorial_callback

func create_explore(p_explores, turn_manager: TurnManager):
	year = turn_manager.year
	explores = p_explores
	if turn_manager.year >= 3 and Global.DIFFICULTY < 3:
		explores += 1
	if turn_manager.year == 3:
		fixed_explores.append("Rare Card" if !scrapyard() else "Rare Bag of Tricks")
	elif turn_manager.year == 6:
		fixed_explores.append("Rare Structure" if !scrapyard() else "Rare Bag of Tricks")
	elif turn_manager.year == 8:
		fixed_explores.append("Rare Enhance" if !scrapyard() else "Rare Bag of Tricks")
	if Global.FARM_TYPE == "MOUNTAINS" and turn_manager.year % 2 == 0:
		fixed_explores.append("Bonus Structure")
		explores += 1
	#else:
	#	fixed_explores.append("Gain Card")
	create_binary_explore()
	return

func create_point_from_name(name, location):
	match name:
		"Gain Card":
			create_point("Gain Card", location, func(pt):
				show_tutorial.call("card", "farleft")
				use_explore(pt)
				add_card("common", 4 - Mastery.less_options()))
		"Event":
			create_point("Event", location, func(pt):
				show_tutorial.call("event", "farleft")
				use_explore(pt)
				on_event.emit())
		"Enhance Card":
			create_point("Enhance Card", location, func(pt):
				show_tutorial.call("enhance", "farleft")
				use_explore(pt)
				enhances += 1
				select_enhance("common"))
		"Structure":
			create_point("Structure", location, func(pt):
				show_tutorial.call("structure", "farleft")
				use_explore(pt)
				structures += 1
				add_structure("common"))
		"Bonus Structure":
			create_point("Bonus Structure", location, func(pt):
				show_tutorial.call("structure", "farleft")
				use_explore(pt)
				structures += 1
				add_structure("common"))
		"Expand Farm":
			create_point("Expand Farm", location, func(pt):
				show_tutorial.call("expand", "farleft")
				use_explore(pt)
				expands += 1
				expand_farm())
		"Remove Card":
			create_point("Remove Card", location, func(pt):
				show_tutorial.call("remove", "farleft", true)
				select_card_to_remove(pt))
		"Rare Card":
			create_point("Rare Card", location, func(pt):
				show_tutorial.call("card", "farleft")
				use_explore(pt)
				add_card("rare", 3))
		"Rare Structure":
			create_point("Rare Structure", location, func(pt):
				show_tutorial.call("structure", "farleft")
				use_explore(pt)
				add_structure("rare"))
		"Rare Enhance":
			create_point("Rare Enhance", location, func(pt):
				show_tutorial.call("enhance", "farleft")
				use_explore(pt)
				select_enhance("rare"))
		"Legendary Card":
			create_point("Legendary Card", location, func(pt):
				show_tutorial.call("card", "farleft")
				use_explore(pt)
				add_card("legendary", 2 - Mastery.less_options()))
		"Bag of Tricks":
			create_point("Bag of Tricks", location, func(pt):
				use_explore(pt)
				pick_bag_of_tricks(4 - Mastery.less_options(), false))
		"Rare Bag of Tricks":
			create_point("Rare Bag of Tricks", location, func(pt):
				use_explore(pt)
				pick_bag_of_tricks(3 - Mastery.less_options(), true))

func create_binary_explore():
	var remaining = explores + bonus_explores
	$CenterContainer/PanelContainer/VBox/HBox/Label.text = "Explorations Remaining: " + str(remaining)
	for point in $Points.get_children():
		$Points.remove_child(point)
	if remaining == 0:
		return
	var DIST = 250
	if fixed_explores.size() > 0:
		var option = fixed_explores.pop_front()
		create_point_from_name(option, Vector2(0, 0))
		return
		
	var option1 = pick_binary_explore()
	var option2 = pick_binary_explore()
	while option1 == option2:
		option2 = pick_binary_explore()
	
	create_point_from_name(option1, Vector2(-DIST, 0))
	create_point_from_name(option2, Vector2(DIST, 0))
	if randi_range(0, 100) <= 15:
		var option3 = pick_binary_explore()
		while option3 == option1 or option3 == option2:
			option3 = pick_binary_explore()
		create_point_from_name(option3, Vector2(0, DIST))
	
func pick_binary_explore():
	var i = randf_range(0, 100)
	if i <= 15:
		return "Event"
	if i <= 30:
		return "Enhance Card" if !scrapyard() else "Bag of Tricks"
	if i <= 45:
		return "Structure" if !scrapyard() else "Bag of Tricks"
	if i <= 55:
		return "Remove Card"
	if i <= 65.5:
		if Helper.can_expand_farm() and expands < 4:
			return "Expand Farm"
		else:
			return "Gain Card" if !scrapyard() else "Bag of Tricks"
	if i <= 67.5:
		return "Rare Card" if !scrapyard() else "Rare Bag of Tricks"
	if i <= 68.5:
		return "Rare Structure" if !scrapyard() else "Rare Bag of Tricks"
	if i <= 69.0:
		return "Rare Enhance" if !scrapyard() else "Rare Bag of Tricks"
	if i <= 69.4:
		return "Legendary Card"
	return "Gain Card" if !scrapyard() else "Bag of Tricks"

func use_explore(node):
	if node != null:
		explores -= 1
		if node.point_name != "Event":
			generate_random_event.call()
		create_binary_explore()
		return
	
	if node != null:
		node.disable()
		explores -= 1
		if explores == 0:
			for child in $Points.get_children():
				child.disable()
		$CenterContainer/PanelContainer/VBox/HBox/Label.text = "Explorations Remaining: " + str(explores)

func create_point(name: String, pos: Vector2, callback: Callable):
	var point: ExplorePoint = ExplorePoint.instantiate()
	point.setup(name, current_event)
	point.position = pos
	point.on_select.connect(func():
		visible = false
		callback.call(point))
	$Points.add_child(point)

func add_card(rarity: String, count: int):
	var get_cards = func(rerolls: int = 0):
		var cards = []
		var cards2 = []
		if rarity == "rare" or rarity == "legendary":
			cards = cards_database.get_random_cards(rarity, count)
		else:
			cards = cards_database.get_random_cards_weighted_rarity(count, float(rerolls))
		for card in cards:
			if randi_range(0, 100) < year:
				var enhanced = DataFetcher.apply_random_enhance(card)
				cards2.append(enhanced)
			else:
				cards2.append(card)
		return cards2
	pick_card_from(get_cards.call(), get_cards)

func pick_card_from(cards, callback: Callable):
	var pick_option_ui = PickOption.instantiate()
	add_sibling(pick_option_ui)
	var prompt = "Pick a card to add to your deck"
	pick_option_ui.reroll_callable = callback
	pick_option_ui.reroll_enabled = true
	pick_option_ui.tooltip = tooltip

	pick_option_ui.setup(prompt, cards, func(selected):
		player_deck.append(selected)
		remove_sibling(pick_option_ui)
		show_tutorial.call("")
		show_window(), func():
			remove_sibling(pick_option_ui)
			show_tutorial.call("")
			show_window())
	if pick_option_ui.has_acorn and player_deck.size() > 10:
		show_tutorial.call("lucky acorns", "farleft")

func select_card_to_remove(pt):
	var select_card = SelectCard.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.select_callback = func(card_data):
		remove_sibling(select_card)
		player_deck.erase(card_data)
		use_explore(pt)
		show_window()
		removals += 1
	select_card.select_cancelled.connect(func():
		remove_sibling(select_card)
		show_tutorial.call("")
		show_window())
	add_sibling(select_card)
	select_card.do_card_pick(player_deck, "Select a card to remove")

func select_enhance(rarity: String):
	var count = 3 - Mastery.less_options()
	var get_enhances_fn = func(rerolls: int = 0):
		if rarity == "rare":
			if Global.FARM_TYPE == "WILDERNESS":
				return cards_database.get_random_enhance_noseed(rarity, count)
			else:
				return cards_database.get_random_enhance(rarity, count, false)
		else:
			return cards_database.get_random_enhances_weighted_rarity(count, float(rerolls))

	var pick_option_ui = PickOption.instantiate()
	pick_option_ui.tooltip = tooltip
	pick_option_ui.reroll_callable = get_enhances_fn
	pick_option_ui.reroll_enabled = true
	add_sibling(pick_option_ui)
	var prompt = "Pick an enhance to apply"
	
	var enhance_picked_callback = func(selected):
		show_tutorial.call("")
		select_card_to_enhance(selected, pick_option_ui)
	var enhance_canceled_callback = func():
		remove_sibling(pick_option_ui)
		show_window()

	pick_option_ui.setup(prompt, get_enhances_fn.call(), enhance_picked_callback, enhance_canceled_callback)
	if pick_option_ui.has_acorn and enhances > 1:
		show_tutorial.call("lucky acorns", "farleft")

func select_card_to_enhance(enhance: Enhance, pick_enhance_ui: Node = null):
	var select_card = SelectCard.instantiate()
	select_card.tooltip = tooltip
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	select_card.select_callback = func(card_data: CardData):
		remove_sibling(select_card)
		if pick_enhance_ui != null:
			remove_sibling(pick_enhance_ui)
		var new_card = card_data.apply_enhance(enhance)
		player_deck.erase(card_data)
		player_deck.append(new_card)
		show_window()
	if pick_enhance_ui != null:
		pick_enhance_ui.add_sibling(select_card)
	else:
		add_sibling(select_card)
		select_card.disable_cancel()
	select_card.select_cancelled.connect(func():
		remove_sibling(select_card)
		if pick_enhance_ui != null:
			pick_enhance_ui.visible = true)
	select_card.do_enhance_pick(player_deck, enhance, "Select a card to enhance")

func add_structure(rarity: String):
	var count = 3 - Mastery.less_options()
	var get_structures_fn = func(rerolls: int = 0):
		if rarity == "rare":
			return cards_database.get_random_structures(count, rarity)
		else:
			return cards_database.get_random_structures_weighted_rarity(count, float(rerolls))

	var pick_option_ui = PickOption.instantiate()
	pick_option_ui.tooltip = tooltip
	pick_option_ui.reroll_callable = get_structures_fn
	pick_option_ui.reroll_enabled = true
	add_sibling(pick_option_ui)
	var prompt = "Pick a structure to add to your farm"
	var on_pick = func(selected):
		remove_sibling(pick_option_ui)
		show_tutorial.call("")
		on_structure_select.emit(selected, func():
			show_window())
	var on_cancel = func(): 
		remove_sibling(pick_option_ui)
		show_tutorial.call("")
		show_window()
	pick_option_ui.setup(prompt, get_structures_fn.call(), on_pick, on_cancel)
	if pick_option_ui.has_acorn and structures > 1:
		show_tutorial.call("lucky acorns", "farleft")
func pick_fortune(prompt: String, options: Array[Fortune]):
	if options.size() == 0:
		options = cards_database.get_all_blessings()
		options.shuffle()
		options = options.slice(0, 3)
	var pick_option_ui = PickOption.instantiate()
	pick_option_ui.tooltip = tooltip
	add_sibling(pick_option_ui)
	var on_pick = func(selected):
		remove_sibling(pick_option_ui)
		on_fortune.emit(selected)
		show_window()
	pick_option_ui.setup(prompt, options, on_pick, null)

func pick_bag_of_tricks(count: int, rare: bool = false):
	var get_options_fn = func(rerolls: int = 0):
		var results = []
		for i in range(count):
			results.append(get_bag_of_tricks_option(rerolls) if !rare else get_bag_of_tricks_option_rare())
		return results
	var pick_option_ui = PickOption.instantiate()
	pick_option_ui.tooltip = tooltip
	add_sibling(pick_option_ui)
	pick_option_ui.reroll_callable = get_options_fn
	pick_option_ui.reroll_enabled = true
	var on_pick = func(selected):
		if selected is CardData:
			player_deck.append(selected)
			remove_sibling(pick_option_ui)
			show_window()
		elif selected is Enhance:
			select_card_to_enhance(selected, pick_option_ui)
		elif selected is Structure:
			remove_sibling(pick_option_ui)
			on_structure_select.emit(selected, func():
				show_window())
	var on_skip = func():
		remove_sibling(pick_option_ui)
		show_window()
	pick_option_ui.setup("Pick something!", get_options_fn.call(), on_pick, on_skip)

func get_bag_of_tricks_option(rerolls: int):
	# Card, Enhance, Structure
	var selected = randf_range(0, 100)
	if selected <= 50:
		return cards_database.get_random_cards_weighted_rarity(1, float(rerolls))[0]
	elif selected <= 75:
		return cards_database.get_random_enhances_weighted_rarity(1, float(rerolls))[0]
	else:
		return cards_database.get_random_structures_weighted_rarity(1, float(rerolls))[0]

func get_bag_of_tricks_option_rare():
	# Card, Enhance, Structure
	var selected = randf_range(0, 100)
	if selected <= 60:
		return cards_database.get_random_cards("rare", 1)[0]
	elif selected <= 80:
		return cards_database.get_random_enhance("rare", 1, false)[0]
	else:
		return cards_database.get_random_structures(1, "rare")[0]

func remove_sibling(node):
	$'../'.remove_child(node)

func show_window():
	if explores + bonus_explores == 0:
		_on_close_pressed()
	else:
		visible = true

func _on_close_pressed():
	visible = false
	if explores + bonus_explores == 0:
		var shown = show_tutorial.call("winter_end", "center")
		if !shown and structures > 0:
			show_tutorial.call("moving structures", "right")
		else:
			show_tutorial.call("")

func expand_farm():
	if Helper.can_expand_farm():
		$"../../".on_expand_farm()
	else:
		add_card("common", 4 - Mastery.less_options())

func scrapyard():
	return Global.FARM_TYPE == "SCRAPYARD"

func save_data():
	return {
		"expands": expands,
		"structures": structures,
		"removals": removals,
		"enhances": enhances
	}

func load_data(data):
	expands = data.expands
	structures = data.structures
	removals = data.removals
	enhances = data.enhances

func set_current_event(event: CustomEvent):
	current_event = event
	for point: ExplorePoint in $Points.get_children():
		if point.point_name == "Event":
			point.setup("Event", current_event)

func has_explores_remaining():
	return explores + bonus_explores > 0

func set_explores_remaining(value: int):
	explores = value
	$CenterContainer/PanelContainer/VBox/HBox/Label.text = "Explorations Remaining: " + str(explores)
