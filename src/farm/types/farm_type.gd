extends Resource
class_name FarmType

var id: int
var name: String
var display_name: String
var icon: Texture2D
var description: String

static var farms = {}
static var farms_id_map = {}

static func load_farms():
	var paths = DataFetcher.get_all_file_paths("res://src/farm/types");
	for path in paths:
		var farm: FarmType = load(path).new()
		farms[farm.name] = farm
		farms_id_map[farm.id] = farm

func _init(p_id = 0, p_name = "FOREST", p_texture = load("res://assets/mage/forest.png"), p_descr = "Basic farm, with no special effects"):
	id = p_id
	name = p_name
	icon = p_texture
	display_name = p_name.to_lower().capitalize()
	description = p_descr
	
func setup(farm: Farm):
	pass

func register(event_manager: EventManager):
	pass

func unregister(event_manager: EventManager):
	pass

func load_deck():
	var deck = []
	for card in get_starter_deck():
		for i in range(card.count):
			deck.append(DataFetcher.get_card_by_name(card.name, card.type))
	return deck

func get_starter_deck():
	return [
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
