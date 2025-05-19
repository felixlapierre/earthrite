extends Node2D
class_name Shop

var stock = []
var ShopItem = preload("res://src/shop/shop_item.tscn")
var card_database = preload("res://src/cards/cards_database.gd")
var CardBase = preload("res://src/cards/card_base.tscn")
var ShopCard = preload("res://src/shop/shop_card.tscn")
var ShopButton = preload("res://src/shop/shop_button.tscn")
var ShopDisplay = preload("res://src/shop/shop_display.tscn")
var Confirm = preload("res://src/ui/menus/confirm.tscn")

signal on_shop_closed
signal on_item_bought
signal on_money_spent
signal on_card_removed
signal on_structure_place
signal on_blight_removed
signal view_deck

@export var player_money: int

var shop_item_capacity = 5

var player_cards
var turn_manager

@onready var CHOICE_ONE = $PanelContainer/ShopContainer/ChoiceOne
@onready var STOCK_ONE = $PanelContainer/ShopContainer/ChoiceOne/Stock
@onready var NEXT_YEAR_ONE = $PanelContainer/ShopContainer/ChoiceOne/NextYearCont
@onready var CHOICE_TWO_LABEL = $PanelContainer/ShopContainer/ChoiceTwoLabel
@onready var CHOICE_TWO = $PanelContainer/ShopContainer/ChoiceTwo
@onready var STOCK_TWO = $PanelContainer/ShopContainer/ChoiceTwo/Stock
@onready var NEXT_YEAR_TWO = $PanelContainer/ShopContainer/ChoiceTwo/NextYearCont
@onready var CHOICE_THREE = $PanelContainer/ShopContainer/ChoiceThree
@onready var STOCK_THREE = $PanelContainer/ShopContainer/ChoiceThree/Stock
@onready var tooltip: Tooltip = $Tooltip

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemoveCardContainer.size = Constants.VIEWPORT_SIZE
	$Tooltip/Panel.theme = load("res://assets/game_theme.tres")
	player_money = 1
	update_labels()
	reposition()

func setup(deck, p_turn_manager):
	player_cards = deck
	turn_manager = p_turn_manager
	$RemoveCardContainer/SelectCard.tooltip = tooltip
	reposition()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_shop():
	for i in range(1, 4):
		set_row_visible(i, true)
		clear_row(i)
		fill_row_number(i)
	if ![5, 8, 11].has(turn_manager.week):
		set_row_visible(3, false)
		CHOICE_THREE.visible = false
	reposition()

func clear_row(row):
	var node
	match row:
		1:
			node = STOCK_ONE
		2:
			node = STOCK_TWO
		3:
			node = STOCK_THREE
	for child in node.get_children():
		node.remove_child(child)

func fill_row_number(row):
	match row:
		1:
			fill_row_one()
		2:
			fill_row_two()
		3:
			fill_row_three()

func fill_row_one():
	var options = card_database.get_all_cards()
	var selected = []
	for option in options:
		if (option.type == "SEED" and Global.FARM_TYPE != "WILDERNESS") or option.type == "ACTION":
			selected.append(option)
	var stock = generate_random_shop_items(shop_item_capacity, selected)
	fill_row(STOCK_ONE, 1, stock)
	STOCK_ONE.add_child(create_scrap_option(1, 1))

func fill_row_two():
	var structures = card_database.get_all_structure("common")
	var selected = []
	for structure in structures:
		selected.append(structure)
	var enhances = card_database.get_all_enhance()
	for enhance in enhances:
		selected.append(enhance)
	var item1 = generate_random_shop_items(1, structures)[0]
	var item3 = generate_random_shop_items(1, enhances)[0]
	var item2 = generate_random_shop_items(1, selected)[0]
	while item2 == item1 or item2 == item3:
		item2 = generate_random_shop_items(1, selected)[0]
	#if turn_manager.blight_damage > 0:
	#	fill_row(STOCK_TWO, 2, [item1, item3])
	#	STOCK_TWO.add_child(create_remove_blight_option())
	#else:
	var items = [item1, item2, item3]
	fill_row(STOCK_TWO, 2, items)
	STOCK_TWO.add_child(create_remove_card_option())
	STOCK_TWO.add_child(create_scrap_option(2, 2))

func fill_row_three():
	var options = card_database.get_all_cards()
	var selected = []
	for option in options:
		if option.type == "SEED" or option.type == "ACTION":
			selected.append(option)
	var stock = generate_random_shop_items(shop_item_capacity, selected)
	fill_row(STOCK_THREE, 3, stock)
	STOCK_THREE.add_child(create_scrap_option(1, 3))

func fill_row(node, row_number, stock):
	for item in stock:
		if item.CLASS_NAME == "CardData":
			var new_node = ShopCard.instantiate()
			new_node.tooltip = tooltip
			new_node.card_data = item
			new_node.on_clicked.connect(func(option): on_select_card(option, row_number))
			node.add_child(new_node)
		elif item.CLASS_NAME == "Structure":
			var new_node = ShopDisplay.instantiate()
			new_node.tooltip = tooltip
			new_node.set_data(item)
			new_node.callback = func(option): on_buy_structure(option, row_number)
			node.add_child(new_node)
		elif item.CLASS_NAME == "Enhance":
			var new_node = ShopDisplay.instantiate()
			new_node.tooltip = tooltip
			new_node.set_data(item)
			new_node.callback = func(option): on_enhance_selected(option, row_number)
			node.add_child(new_node)

func on_select_card(card_base, row_number):
	var confirm = Confirm.instantiate()
	confirm.setup(card_base.card_info)
	add_child(confirm)
	confirm.on_yes.connect(func(): 
		on_buy(card_base, row_number)
		remove_child(confirm))
	confirm.on_no.connect(func():
		remove_child(confirm))

func create_scrap_option(amount, row):
	var scrap = ShopButton.instantiate()
	scrap.title = "Skip Choice"
	scrap.text = "Gain"
	scrap.cost = amount
	scrap.row = row
	scrap.option_selected.connect(on_scrap)
	return scrap

func create_remove_card_option():
	var remove = ShopButton.instantiate()
	remove.title = "Remove Card"
	remove.text = "Remove a card from your deck"
	remove.row = 2
	remove.option_selected.connect(_on_remove_card_button_pressed)
	return remove
	
func create_remove_blight_option():
	var remove_blight = ShopButton.instantiate()
	remove_blight.text = "Reduce Blight by 1 and restore blighted tiles"
	remove_blight.cost = 0
	remove_blight.row = 2
	remove_blight.option_selected.connect(_on_remove_blight_button_pressed)
	return remove_blight

# returns an array, items can be either CardData or Enhance
func generate_random_shop_items(count, options):
	var common = []
	var uncommon = []
	var rare = []
	for option in options:
		if option.rarity == "common":
			common.append(option)
		elif option.rarity == "uncommon":
			uncommon.append(option)
		elif option.rarity == "rare":
			rare.append(option)

	var result = []
	var i = 0
	while i < count:
		var r = randf()
		var selection = common
		if r >= 0.40 and r < 0.75:
			selection = uncommon
		elif r >= 0.75:
			selection = rare
		if selection.size() > 0:
			var selected = randi_range(0, selection.size() - 1)
			result.append(selection.pop_at(selected))
			i += 1
	return result

func on_buy_row1(option):
	on_buy(option, 1)

func on_buy_row2(option):
	on_buy(option, 2)

func on_buy(option, row):
	finish_item_bought(option, option.card_info, row)

func finish_item_bought(card, card_data, row) -> void:
	if card_data.type != "STRUCTURE":
		on_item_bought.emit(card_data)
	set_row_visible(row, false)
	update_labels()

func set_row_visible(row, vis):
	match row:
		1:
			for child in CHOICE_ONE.get_children():
				child.visible = vis
			NEXT_YEAR_ONE.visible = !vis
		2:
			for child in CHOICE_TWO.get_children():
				child.visible = vis
			NEXT_YEAR_TWO.visible = !vis
		3:
			for child in CHOICE_THREE.get_children():
				child.visible = vis
	if vis == false:
		$'../'.update()

func _on_close_button_pressed() -> void:
	on_shop_closed.emit()

func _on_remove_card_button_pressed(cost, row) -> void:
	player_money += cost
	$RemoveCardContainer.visible = true
	$RemoveCardContainer/SelectCard.select_callback = func(card_data):
		on_card_removed.emit(card_data)
		set_row_visible(row, false)
		update_labels()
		$RemoveCardContainer.visible = false
	$RemoveCardContainer/SelectCard.do_card_pick(player_cards, "Select a card to remove")

func _on_card_remove_cancelled() -> void:
	$RemoveCardContainer.visible = false

func on_week_pass():
	fill_shop()
	update_labels()

func update_labels():
	$PanelContainer/ShopContainer/Header/MoneyLabel.text = "Rerolls: " + str(player_money)

func on_reroll(cost, row):
	if !Settings.DEBUG and player_money + cost < 0:
			return
	player_money += cost
	update_labels()
	clear_row(row)
	fill_row_number(row)

func on_scrap(amount, row):
	player_money += amount
	set_row_visible(row, false)
	update_labels()

func on_enhance_selected(enhance: Enhance, row):
	$RemoveCardContainer.visible = true
	$RemoveCardContainer/SelectCard.select_callback = func(card_data: CardData):
		var enhanced = card_data.apply_enhance(enhance)
		on_card_removed.emit(card_data)
		on_item_bought.emit(enhanced)
		set_row_visible(row, false)
		update_labels()
		$RemoveCardContainer.visible = false
	$RemoveCardContainer/SelectCard.do_enhance_pick(player_cards, enhance, "Select a card to enhance")

func on_buy_structure(structure, row):
	on_structure_place.emit(structure, func(): 
		await get_tree().create_timer(1.0).timeout
		visible = true
		set_row_visible(row, false)
		update_labels())

func _on_remove_blight_button_pressed(cost, row):
	on_blight_removed.emit()
	set_row_visible(row, false)
	update_labels()

func save_data() -> Dictionary:
	var data = {}
	data.row1_visible = CHOICE_ONE.get_child(0).visible
	data.row2_visible = CHOICE_TWO.get_child(0).visible
	data.row3_visible = CHOICE_THREE.get_child(0).visible
	data.row1 = []
	data.row2 = []
	data.row3 = []
	for child in STOCK_ONE.get_children():
		if child.get_data() != null:
			data.row1.append(child.get_data().save_data())
	for child in STOCK_TWO.get_children():
		if child.get_data() != null:
			data.row2.append(child.get_data().save_data())
	for child in STOCK_THREE.get_children():
		if child.get_data() != null:
			data.row3.append(child.get_data().save_data())
	return data

func load_data(save_data: Dictionary):
	clear_row(1)
	clear_row(2)
	clear_row(3)
	fill_row(STOCK_ONE, 1, save_data.row1.map(func(data):
		return load(data.path).new().load_data(data)))
	fill_row(STOCK_TWO, 2, save_data.row2.map(func(data):
		return load(data.path).new().load_data(data)))
	fill_row(STOCK_THREE, 3, save_data.row3.map(func(data):
		return load(data.path).new().load_data(data)))
	set_row_visible(1, save_data.row1_visible)
	set_row_visible(2, save_data.row2_visible)
	set_row_visible(3, save_data.row3_visible)
	STOCK_ONE.add_child(create_scrap_option(1, 1))
	STOCK_TWO.add_child(create_remove_card_option())
	STOCK_TWO.add_child(create_scrap_option(2, 2))
	STOCK_THREE.add_child(create_scrap_option(1, 3))
	reposition()

func reposition():
	$PanelContainer.position = Constants.VIEWPORT_SIZE / 2 - $PanelContainer.size / 2

func _on_view_deck_pressed() -> void:
	view_deck.emit()
