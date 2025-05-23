extends FarmType
class_name StormValeFarm

static var ID = 5
static var NAME = "STORMVALE"
static var ICON = preload("res://assets/mage/Storm.png")
static var DESCR = "Trigger a random weather effect every 2 weeks."

func _init():
	super(ID, NAME, ICON)

func get_starter_deck():
	var deck = super.get_starter_deck()
	deck.append({
		"name": "Control Weather",
		"type": "action",
		"count": 1
	})
	return deck
