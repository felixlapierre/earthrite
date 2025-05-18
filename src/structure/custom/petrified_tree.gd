extends Structure
class_name PetrifiedTree

var listener_destroy
var listener_energy

var callback: Callable
var callback2: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var event_type_yearstart = EventManager.EventType.BeforeYearStart

func _init():
	super()

func copy():
	var copy = PetrifiedTree.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	listener_energy = Listener.new("petrified-tree-energy", EventManager.EventType.BeforeTurnStart, func(args: EventArgs):
		args.turn_manager.energy += 1
		tile.play_effect_particles())

	listener_destroy = Listener.new("petrified-tree-tiles", EventManager.EventType.BeforeYearStart, func(args: EventArgs):
		var destroy_count = Global.FARM_BOTRIGHT.x - Global.FARM_TOPLEFT.x
		var candidates: Array[Tile] = []
		for target_tile in args.farm.get_all_tiles():
			if !target_tile.is_destroyed() and target_tile.state != Enums.TileState.Inactive and target_tile.structure == null:
				candidates.append(target_tile)
		candidates.sort_custom(func(a: Tile, b: Tile):
			var adist = abs(a.grid_location.y - tile.grid_location.y)
			var bdist = abs(b.grid_location.y - tile.grid_location.y)
			if adist == bdist:
				var adist2 = abs(a.grid_location.x - tile.grid_location.x)
				var bdist2 = abs(b.grid_location.x - tile.grid_location.x)
				return adist2 < bdist2
			return adist < bdist)
		for i in range(min(destroy_count, candidates.size())):
			candidates[i].destroy())

	event_manager.register(listener_energy)
	event_manager.register(listener_destroy)

func unregister_events(event_manager: EventManager):
	listener_energy.disable()
	listener_destroy.disable()
