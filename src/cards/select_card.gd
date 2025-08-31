extends Control

class_name SelectCard

var CardBase
var options = []

enum SelectState {
	Selecting,
	Confirming
}

var state = SelectState.Selecting
var card_selected_index
var enhance: Enhance

signal select_cancelled

var select_callback: Callable
var tooltip: Tooltip
var display_only = false

var ShopCard = preload("res://src/shop/shop_card.tscn")
var ShopDisplay = preload("res://src/shop/shop_display.tscn")
var FortuneDisplay = preload("res://src/fortune/fortune.tscn")

var selected
signal select_finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CardBase = preload("res://src/cards/card_base.tscn")
	Helper.fade_in(self)

func disable_cancel():
	$SelectContainer/Header/CloseButton.visible = false

func do_card_display(cards_input, prompt_text):
	$SelectContainer/Header/CloseButton.text = "Close"
	display_only = true
	do_card_pick(cards_input, prompt_text)

func do_card_pick(items, prompt_text):
	options = items
	$SelectContainer/Header/PromptLabel.text = prompt_text
	state = SelectState.Selecting
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false
	var card_container = $SelectContainer/Scroll/CardContainer
	for item in items:
		var node = create_selection_display(item, func(option): on_card_selected(option))
		card_container.add_child(node)
	$ConfirmContainer/ConfirmVbox/EnhanceLabel.visible = enhance != null

func do_enhance_pick(cards_input, p_enhance: Enhance, prompt_text):
	options = []
	enhance = p_enhance
	# Filter for cards the enhance applies to
	for card in cards_input:
		if enhance.is_card_eligible(card):
			options.append(card)
	do_card_pick(options, prompt_text)
	enhance = p_enhance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_card_selected(card):
	match state:
		SelectState.Selecting:
			state = SelectState.Confirming
			$SelectContainer.visible = false
			var confirm_option_node = create_selection_display(card, func():
				pass)
			$ConfirmContainer/ConfirmVbox/ConfirmCards.add_child(confirm_option_node)
			$ConfirmContainer.visible = true
			selected = card
			if enhance != null:
				var enhanced_card = card.apply_enhance(enhance)
				var confirm_option_node_2 = create_selection_display(enhanced_card, func():
					pass)
				$ConfirmContainer/ConfirmVbox/ConfirmCards.add_child(confirm_option_node_2)
			pass

func _on_confirm_button_pressed() -> void:
	for child in $SelectContainer/Scroll/CardContainer.get_children():
		$SelectContainer/Scroll/CardContainer.remove_child(child)
		
	var card = selected
	await select_callback.call(card)
	select_finished.emit()
	for child in $ConfirmContainer/ConfirmVbox/ConfirmCards.get_children():
		$ConfirmContainer/ConfirmVbox/ConfirmCards.remove_child(child)
	enhance = null

func _on_cancel_button_pressed() -> void:
	state = SelectState.Selecting
	selected = null
	for child in $ConfirmContainer/ConfirmVbox/ConfirmCards.get_children():
		$ConfirmContainer/ConfirmVbox/ConfirmCards.remove_child(child)
	$SelectContainer.visible = true
	$ConfirmContainer.visible = false


func _on_close_button_pressed() -> void:
	for child in $SelectContainer/Scroll/CardContainer.get_children():
		$SelectContainer/Scroll/CardContainer.remove_child(child)
	select_cancelled.emit()
	enhance = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if state == SelectState.Confirming:
			_on_cancel_button_pressed()
		elif state == SelectState.Selecting:
			_on_close_button_pressed()

func set_close_button_text(text: String):
	$SelectContainer/Header/CloseButton.text = text

func create_selection_display(item: Variant, callback: Callable):
	if item is Fortune:
		var new_node = FortuneDisplay.instantiate()
		new_node.setup(item)
		if !display_only:
			new_node.clicked.connect(callback)
		#new_node.tooltip = tooltip
		return new_node
	elif item.CLASS_NAME == "CardData":
		var new_node = ShopCard.instantiate()
		new_node.tooltip = tooltip
		new_node.card_data = item
		new_node.tooltip = tooltip
		if !display_only:
			new_node.on_clicked.connect(callback)
		return new_node
	elif item.CLASS_NAME == "Structure":
		var new_node = ShopDisplay.instantiate()
		new_node.set_data(item)
		if !display_only:
			new_node.callback = callback
		new_node.tooltip = tooltip
		return new_node
	elif item.CLASS_NAME == "Enhance":
		var new_node = ShopDisplay.instantiate()
		new_node.set_data(item)
		if !display_only:
			new_node.callback = callback
		new_node.tooltip = tooltip
		return new_node
