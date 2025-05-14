extends Node2D

var ShopCard = preload("res://src/shop/shop_card.tscn")
var ShopDisplay = preload("res://src/shop/shop_display.tscn")
var FortuneDisplay = preload("res://src/fortune/fortune.tscn")
@onready var options_container = $Center/Panel/VBox/HBox
@onready var prompt_label = $Center/Panel/VBox/PromptLabel
@onready var tooltip: Tooltip = $Tooltip

var on_skip: Callable

var reroll_callable: Callable
var reroll_enabled: bool = false

var pick_callback: Callable

var rerolls = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(prompt: String, items, p_pick_callback: Callable, skip_callback = null):
	prompt_label.text = prompt
	if skip_callback != null:
		on_skip = skip_callback
	pick_callback = p_pick_callback
	$Center/Panel/VBox/SkipButton.visible = skip_callback != null
	$Center/Panel/VBox/RerollButton.visible = reroll_enabled and Global.ACORNS > 0
	update_reroll_button()
	setup_items(items)

func setup_items(items):
	for child in options_container.get_children():
		options_container.remove_child(child)
	for item in items:
		var acorn = false
		var callback = func(option):
			pick_callback.call(option)
		var bonus = Global.ACORN_BONUS
		if reroll_enabled and randi_range(0, 100) < 15 * (1.0 + bonus):
			callback = func(option):
				pick_callback.call(option)
				Global.ACORNS += 1
				Global.TOTAL_ACORNS += 1
			acorn = true
		var new_node = null
		if item is Fortune:
			new_node = FortuneDisplay.instantiate()
			new_node.setup(item)
			new_node.clicked.connect(callback)

		elif item.CLASS_NAME == "CardData":
			new_node = ShopCard.instantiate()
			new_node.tooltip = tooltip
			new_node.card_data = item
			new_node.on_clicked.connect(callback)

		elif item.CLASS_NAME == "Structure":
			new_node = ShopDisplay.instantiate()
			new_node.tooltip = tooltip
			new_node.set_data(item)
			new_node.callback = callback

		elif item.CLASS_NAME == "Enhance":
			new_node = ShopDisplay.instantiate()
			new_node.tooltip = tooltip
			new_node.set_data(item)
			new_node.callback = callback
		
		if acorn:
			var vbox = VBoxContainer.new()
			vbox.add_child(new_node)
			var acorn_label = RichTextLabel.new()
			acorn_label.text = "[center]+1 [img]res://assets/custom/acorn.png[/img]"
			acorn_label.bbcode_enabled = true
			acorn_label.fit_content = true
			tooltip.register_tooltip(acorn_label,  "[color=gold]Lucky Acorn[/color]: If you pick this option, gain a Lucky Acorn for free! Lucky Acorns can be used later to reroll a card choice - getting a different set of options instead.")
			vbox.add_child(acorn_label)
			new_node = vbox

		options_container.add_child(new_node)

func _on_skip_button_pressed():
	if on_skip != null:
		on_skip.call()

func _on_reroll_button_pressed():
	Global.ACORNS -= 1
	rerolls += 1
	setup_items(reroll_callable.call(rerolls))
	update_reroll_button()

func update_reroll_button():
	$Center/Panel/VBox/RerollButton.text = "Reroll (" + str(Global.ACORNS) + " left)"
	$Center/Panel/VBox/RerollButton.disabled = Global.ACORNS <= 0

