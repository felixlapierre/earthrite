extends FarmType
class_name WildernessFarm

var SelectCardScene = preload("res://src/cards/select_card.tscn")

static var ID = 2
static var NAME = "WILDERNESS"
var ICON = preload("res://assets/mage/wilderness.png")
static var DESCR = "Choose a [color=gold]Native Seed[/color] at the start of the game.\n\nStart each year with the [color=gold]Native Seed[/color] already planted on the farm.\n\nStarting deck has no Seed cards, and you cannot add Seed cards to your deck."

static var WILDERNESS_PLANT = null

var listener: Listener

func _init():
	super(ID, NAME, ICON, DESCR)

func register(event_manager: EventManager):
	listener = Listener.new(EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		var locations = args.farm.use_card_random_tile(WILDERNESS_PLANT.copy(), WILDERNESS_PLANT.size)
		for l in locations:
			args.farm.tiles[l.x][l.y].protected = true
	)
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()
	
static func get_wilderness_seed_options():
	return [
		load("res://src/cards/data/seed/inky_cap.tres"),
		load("res://src/fortune/unique/wildflower.tres"),
		load("res://src/cards/data/seed/asphodel.tres"),
		load("res://src/cards/data/seed/gilded_rose.tres"),
		load("res://src/cards/data/seed/corn.tres"),
		load("res://src/cards/data/seed/watermelon.tres"),
		load("res://src/cards/data/seed/mint.tres"),
		load("res://src/cards/data/seed/dandelion.tres"),
		load("res://src/cards/data/seed/coffee.tres"),
		load("res://src/cards/data/seed/cranberry.tres")
	]

func get_starter_deck():
	return [
	{
		"name": "Spread",
		"type": "action",
		"count": 3
	},
	{
		"name": "Graft",
		"type": "action",
		"count": 1,
	},
	{
		"name": "Fertilize",
		"type": "action",
		"count": 2
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]

func do_setup_dialogue(node: Node):
	var select_card = SelectCardScene.instantiate()
	select_card.size = Constants.VIEWPORT_SIZE
	select_card.z_index = 2
	select_card.theme = load("res://assets/theme_large.tres")
	var options = StartupHelper.get_wilderness_seed_options()
	node.add_child(select_card)
	select_card.set_close_button_text("Pick Random Plant")
	select_card.do_card_pick(options, "Select the native plant on the Wilderness Farm")
	select_card.select_cancelled.connect(func():
		node.remove_child(select_card)
		WildernessFarm.WILDERNESS_PLANT = Helper.pick_random(options))
	select_card.select_callback = func(card: CardData):
		node.remove_child(select_card)
		WildernessFarm.WILDERNESS_PLANT = card
	await select_card.select_finished
