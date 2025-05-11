extends MageAbility
class_name ArchmageFortune

var icon = preload("res://assets/ui/Mastery.png")

static var MAGE_NAME = "Archmage"

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with a Legendary Card in your deck", 9, icon, 1.0)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(load("res://src/cards/data/seed/witch_hazel.tres"))
