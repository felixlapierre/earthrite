extends Node2D

var CardBase = preload("res://src/cards/card_base.tscn")

signal on_yes
signal on_no

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(card_data: CardData):
	var card = CardBase.instantiate()
	card.set_card_info(card_data)
	card.do_passive_effects()
	card.set_state(Enums.CardState.InShop, null, null, null)
	$Panel/Center/Panel/Margin/VBox/Label.add_sibling(card)
	$Panel/Center/Panel/Margin/VBox/Description.clear()
	$Panel/Center/Panel/Margin/VBox/Description.append_text(card_data.get_long_description())

func _on_yes_pressed() -> void:
	on_yes.emit()

func _on_no_pressed() -> void:
	on_no.emit()
