extends Effect2
class_name CopyStructure

var listener: Listener
var copied_structure: Structure

func _init():
	super(EventManager.EventType.OnPlantPlanted, true, Enums.EffectType.Other, "CopyStructure")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		# Find an adjacent tile that has a structure
		var tiles = Helper.get_adjacent_active_tiles(args.specific.tile.grid_location, args.farm)
		var filtered = tiles.filter(func(tile: Tile): return tile.structure != null)
		var structure: Structure = filtered.pick_random().structure
		copied_structure = structure.copy()
		copied_structure.register_events(event_manager, tile)
		)
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()
	if copied_structure != null:
		copied_structure.unregister_events(event_manager)

func copy():
	return CopyStructure.new().assign(self)

func get_description(size):
	return "Acts as a copy of an adjacent structure"
