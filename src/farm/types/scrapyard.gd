extends FarmType

static var ID = 6
static var NAME = "SCRAPYARD"
static var ICON = preload("res://assets/custom/Temp.png")
static var DESCR = "When Exploring, find Bag of Tricks instead of Card, Enhance or Structure."

func _init():
	super(ID, NAME, ICON)
