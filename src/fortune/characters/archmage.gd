extends MageAbility
class_name ArchmageFortune

var icon = preload("res://assets/ui/Mastery.png")



static var MAGE_NAME = "Archmage"
static var MAGE_ID = 9

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with a Legendary Card in your deck.\n\n[color=gold]Unlock: [/color]Win on Mastery difficulty", MAGE_ID, icon, 1.0)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(DataFetcher.get_random_cards("legendary", 3).pick_random())
