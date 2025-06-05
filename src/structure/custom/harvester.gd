extends Effect2
class_name Harvester

var event_type = EventManager.EventType.BeforeTurnStart
var effect_type = Enums.EffectType.Harvest
var tile = null
var listener: Listener

func _init():
	super()
	name = "Harvester"

func copy():
	var copy = Harvester.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	listener = Listener.create(self, func(args: EventArgs):
		for target_tile in args.farm.get_all_tiles():
			if Helper.is_adjacent(target_tile.grid_location, tile.grid_location)\
				and target_tile.state == Enums.TileState.Mature:
				target_tile.harvest(false)
	)

	event_manager.register(listener)

func unregister_events(event_manager: EventManager):
	listener.disable()

static func get_resource() -> Structure:
	return Structure.Builder.new()\
		.name("Harvester").size(8).rarity("common")\
		.text("Harvest 8 adjacent tiles every turn")\
		.effect(Harvester.new())\
		.texture(load("res://assets/custom/Harvester.png"))\
		.build()
