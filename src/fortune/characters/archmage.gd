extends MageAbility
class_name ArchmageFortune

var icon = preload("res://assets/ui/Mastery.png")

static var MAGE_NAME = "Archmage"
static var MAGE_ID = 9

var PickOptionsScene = preload("res://src/ui/pick_option.tscn")
var selected_card: CardData

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with a [color=gold]Legendary Card[/color] in your deck.\n\n[color=gold]Unlock: [/color]Win on Mastery difficulty", MAGE_ID, icon, 1.0)
	modify_deck_callback = func(deck: Array[CardData]):
		deck.append(selected_card)

func do_setup_dialogue(node: Node):
	var options = DataFetcher.get_all_cards_rarity("legendary")
	var pick_options = PickOptionsScene.instantiate()
	node.add_child(pick_options)
	pick_options.setup("Pick a Legendary Card", options, func(selected):
		node.remove_child(pick_options)
		MountainsFarm.START_STRUCTURE = selected)
	await pick_options.pick_finished
