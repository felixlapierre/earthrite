extends FarmType
class_name RiverlandsFarm

static var ID = 3
static var NAME = "RIVERLANDS"
static var ICON = preload("res://assets/mage/riverlands.png")
static var DESCR = "Start each year with 8 tiles already [color=gold] Watered [/color] on your farm.\n\nWatered plants additionally gain +50% mana when growing."
func _init():
	super(ID, NAME, ICON, DESCR)

func register(event_manager: EventManager):
	Global.WATERED_MULTIPLIER += 0.5
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		for i in range(2, 5):
			args.farm.tiles[2][i].irrigate()
			args.farm.tiles[3][i].irrigate()
		for i in range(3, 6):
			args.farm.tiles[4][i].irrigate()
			args.farm.tiles[5][i].irrigate())

func unregister(event_manager: EventManager):
	Global.WATERED_MULTIPLIER -= 0.5

func get_starter_deck():
	return [
	{
		"name": "Cabbage",
		"type": "seed",
		"count": 2
	},
	{
		"name": "Water Lily",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Pumpkin",
		"type": "seed",
		"count": 1
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]
