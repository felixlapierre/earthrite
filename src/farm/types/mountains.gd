extends FarmType
class_name MountainsFarm

static var ID = 1
static var NAME = "MOUNTAINS"
static var START_STRUCTURE: Structure = null
var ICON = preload("res://assets/fortune/mountains.png")
static var DESCR = "Start with a Structure on your farm.\n\nSome farm tiles contain rocks that can hold structures, but not plants."
var listener: Listener

func _init():
	super(ID, NAME, ICON, DESCR)

func setup(farm: Farm):
	# Create rocks
	var rocks2 = [Vector2(0, 3), Vector2(0, 6), Vector2(1, 0), Vector2(1, 1), Vector2(2, 3), Vector2(1, 5), Vector2(3, 2), Vector2(2, 5), Vector2(4, 0), Vector2(5, 2), Vector2(6, 2), Vector2(7, 1), Vector2(4, 1), Vector2(7, 0)]
	for rock in rocks2:
		farm.tiles[rock.y][rock.x].rock = true
		farm.tiles[7 - rock.y][7 - rock.x].rock = true

	# Place starting structure
	var candidates: Array[Tile] = []
	for tile: Tile in farm.get_all_tiles():
		if tile.grid_location.x in [2.0, 3.0, 4.0, 5.0] and tile.grid_location.y in [2.0, 3.0, 4.0, 5.0] and tile.rock:
			candidates.append(tile)
	if candidates.size() > 0:
		candidates.pick_random().build_structure(START_STRUCTURE, 0)
	else:
		var rocks = farm.get_all_tiles().filter(func(tile):
			return tile.rock)
		rocks.shuffle()
		rocks[0].build_structure(START_STRUCTURE, 0)
	for tile in farm.get_all_tiles():
		tile.do_active_check()

func get_starter_deck():
	return [
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
