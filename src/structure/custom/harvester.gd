extends Effect2
class_name Harvester

var tile = null
var listener: Listener
var spriteframes = preload("res://src/animation/scythe_frames.tres")

func _init():
	super(EventManager.EventType.BeforeTurnStart, false, Enums.EffectType.Harvest, "Harvested")

func copy():
	var copy = Harvester.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	listener = Listener.create(self, func(args: EventArgs):
		args.farm.do_animation(spriteframes, tile.grid_location)
		await args.farm.get_tree().create_timer(0.2).timeout
		for target_tile in args.farm.get_all_tiles():
			if Helper.is_adjacent(target_tile.grid_location, tile.grid_location)\
				and target_tile.state == Enums.TileState.Mature:
				target_tile.harvest(false)
	)

	event_manager.register(listener)

func unregister_events(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return get_timing_text() + "Harvest %s adjacent tiles" % size

static func get_resource() -> Structure:
	return Structure.Builder.new()\
		.name("Harvester").size(8).rarity("common")\
		.text("")\
		.effect(Harvester.new())\
		.texture(load("res://assets/custom/Harvester.png"))\
		.build()
