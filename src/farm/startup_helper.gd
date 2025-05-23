extends Node
class_name StartupHelper

static var card_database = preload("res://src/cards/cards_database.gd")

static var Blueberry = preload("res://src/cards/data/seed/blueberry.tres")
static var Carrot = preload("res://src/cards/data/seed/carrot.tres")
static var Wildflower = preload("res://src/fortune/unique/wildflower.tres")
static var Potato = preload("res://src/cards/data/seed/potato.tres")
static var Water = preload("res://src/structure/unique/river.tres")

static var manipulate_deck_callback: Callable = func(_deck): pass

static var MOUNTAIN_START_STRUCTURE: Structure = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
static func get_starter_deck():
	return FarmType.farms[Global.FARM_TYPE].load_deck()
	var data;
	match Global.FARM_TYPE:
		"FOREST", "LUNARTEMPLE", "SCRAPYARD":
			data = forest_deck
		"STORMVALE":
			data = []
			data.assign(forest_deck)
			data.append({
				"name": "Control Weather",
				"type": "action",
				"count": 1
			})
		"RIVERLANDS":
			data = riverlands_deck
		"WILDERNESS":
			data = wilderness_deck
		"MOUNTAINS":
			data = mountains_deck
	var deck = load_deck(data)
	manipulate_deck_callback.call(deck)
	return deck

static func register_manipulate_deck_callback(callback):
	manipulate_deck_callback = callback

static func load_deck(data):
	var deck = []
	for card in data:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	return deck

static func setup_farm(farm: Farm, event_manager: EventManager):
	var farm_type: FarmType = FarmType.farms[Global.FARM_TYPE]
	farm_type.setup(farm)
	farm_type.register(event_manager)
	return
	
	match Global.FARM_TYPE:
		"RIVERLANDS":
			setup_riverlands_farm_callback(farm, event_manager)
		"WILDERNESS":
			setup_wilderness_farm_callback(farm, event_manager)
		"MOUNTAINS":
			setup_mountain_farm(farm)
			#Global.FARM_TOPLEFT = Vector2(2, 2)
			#Global.FARM_BOTRIGHT = Vector2(5, 5)
			var candidates: Array[Tile] = []
			for tile: Tile in farm.get_all_tiles():
				if tile.grid_location.x in [2.0, 3.0, 4.0, 5.0] and tile.grid_location.y in [2.0, 3.0, 4.0, 5.0] and tile.rock:
					candidates.append(tile)
			if candidates.size() > 0:
				candidates.pick_random().build_structure(MOUNTAIN_START_STRUCTURE, 0)
			else:
				var rocks = farm.get_all_tiles().filter(func(tile):
					return tile.rock)
				rocks.shuffle()
				rocks[0].build_structure(MOUNTAIN_START_STRUCTURE, 0)
			for tile in farm.get_all_tiles():
				tile.do_active_check()
		"LUNARTEMPLE":
			setup_lunar_temple_callback(farm, event_manager)

static func load_farm(farm: Farm, event_manager: EventManager):
	FarmType.farms[Global.FARM_TYPE].register(event_manager)
	for tile in farm.get_all_tiles():
		tile.do_active_check()

static func setup_wilderness_farm_callback(farm: Farm, event_manager: EventManager):
	event_manager.register_listener(EventManager.EventType.AfterYearStart, wilderness_callable)

static func setup_riverlands_farm_callback(farm: Farm, event_manager: EventManager):
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		for i in range(2, 5):
			farm.tiles[2][i].irrigate()
			farm.tiles[3][i].irrigate()
		for i in range(3, 6):
			farm.tiles[4][i].irrigate()
			farm.tiles[5][i].irrigate())

static func setup_lunar_temple_callback(farm: Farm, event_manager: EventManager):
	var event_type = EventManager.EventType.BeforeGrow
	var event_type_allblue = EventManager.EventType.AfterYearStart
	var allblue_callable = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			tile.purple = true
			tile.update_display()
	var event_callable = func(args: EventArgs):
		if !args.turn_manager.flag_defer_excess:
			var excess = max(args.turn_manager.purple_mana - args.turn_manager.target_blight, 0)
			args.farm.gain_yield(args.farm.tiles[4][4], EventArgs.HarvestArgs.new(excess * 0.70, false, false))
	
	event_manager.register_listener(event_type_allblue, allblue_callable)
	event_manager.register_listener(event_type, event_callable)

static func teardown_wilderness_farm_callback(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeYearStart, wilderness_callable)

static var wilderness_callable = func(event_args: EventArgs):
	event_args.farm.use_card_random_tile(Global.WILDERNESS_PLANT.copy(), Global.WILDERNESS_PLANT.size)

static func setup_mountain_farm(farm: Farm):
	var rocks2 = [Vector2(0, 3), Vector2(0, 6), Vector2(1, 0), Vector2(1, 1), Vector2(2, 3), Vector2(1, 5), Vector2(3, 2), Vector2(2, 5), Vector2(4, 0), Vector2(5, 2), Vector2(6, 2), Vector2(7, 1), Vector2(4, 1), Vector2(7, 0)]
	for rock in rocks2:
		farm.tiles[rock.y][rock.x].rock = true
		farm.tiles[7 - rock.y][7 - rock.x].rock = true
	return
	var rocks = 24
	for tile: Tile in farm.get_all_tiles():
		if rocks == 0:
			return
		if randi() % 2 == 0:
			tile.rock = true
			rocks -= 1

static var forest_deck = [
	{
		"name": "Carrot",
		"type": "seed",
		"count": 2
	},
	{
		"name": "Blueberry",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	},
	{
		"name": "Pumpkin",
		"type": "seed",
		"count": 1
	}
]

static var riverlands_deck = [
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

static var wilderness_deck = [
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

static var mountains_deck = [
		{
		"name": "Pumpkin",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Cabbage",
		"type": "seed",
		"count": 2,
	},
	{
		"name": "Potato",
		"type": "seed",
		"count": 1
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]

static var tutorial_deck = [
	{
		"name": "Radish",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	},
	{
		"name": "Potato",
		"type": "seed",
		"count": 2
	},
	{
		"name": "Pumpkin",
		"type": "seed",
		"count": 1
	}
]

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

static func get_farm_type_index(type: String):
	match type:
		"FOREST":
			return 0
		"MOUNTAINS":
			return 1
		"WILDERNESS":
			return 2
		"RIVERLANDS":
			return 3
		"LUNARTEMPLE":
			return 4
		"STORMVALE":
			return 5
		"SCRAPYARD":
			return 6

static func get_farm_name_from_id(id: int):
	match id:
		0: return "FOREST"
		1: return "MOUNTAINS"
		2: return "WILDERNESS"
		3: return "RIVERLANDS"
		4: return "LUNARTEMPLE"
		5: return "STORMVALE"
		6: return "SCRAPYARD"
