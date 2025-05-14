extends Node2D
class_name ExplorePoint

signal on_select

var gain_card = preload("res://assets/ui/explore/gain-card-2.png")
var gain_card_rare = preload("res://assets/ui/explore/gain-card-rare.png")
var gain_card_legendary = preload("res://assets/ui/explore/explore-legendary.png")
var enhance = preload("res://assets/enhance/strength.png")
var rare_enhance = preload("res://assets/enhance/strength2.png")
var structure = preload("res://assets/structure/beehive.png")
var rare_structure = preload("res://assets/structure/petrified_tree.png")

var expand = preload("res://assets/ui/explore/expand-farm.png")
var remove = preload("res://assets/ui/remove-card.png")
var event = preload("res://assets/ui/explore/event.png")

var bag_tricks = preload("res://assets/ui/explore/bag-tricks.png")
var bag_tricks_rare = preload("res://assets/ui/explore/bag-tricks-rare.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(name: String):
	$VBox/Button.text = name
	var display = $VBox/DisplayButton
	var container = $VBox
	var texture = preload("res://assets/custom/Temp.png")
	match name:
		"Gain Card":
			texture = gain_card
		"Event":
			texture = event
		"Expand Farm":
			texture = expand
		"Remove Card":
			texture = remove
		"Rare Card":
			texture = gain_card_rare
		"Rare Enhance":
			texture = rare_enhance
		"Rare Structure":
			texture = rare_structure
		"Structure": 
			texture = structure
		"Enhance Card":
			texture = enhance
		"Legendary Card":
			texture = gain_card_legendary
		"Bag of Tricks":
			texture = bag_tricks
		"Rare Bag of Tricks":
			texture = bag_tricks_rare
	display.texture_normal = texture

func _on_button_pressed():
	on_select.emit()

func disable():
	$Button.disabled = true

func _on_display_button_pressed():
	on_select.emit()
