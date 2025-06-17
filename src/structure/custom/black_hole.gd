extends Effect2
class_name BlackHole

var listener: Listener

func _init():
	super(EventManager.EventType.OnPlantPlanted, false, Enums.EffectType.Other, "BlackHole")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var target_tile = args.specific.tile
		if Helper.is_adjacent(tile.grid_location, target_tile.grid_location):
			var old_grow_time = target_tile.seed_grow_time
			target_tile.seed_grow_time *= 2
			target_tile.seed_base_yield *= 2
	)
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	return BlackHole.new().assign(self)

func get_description(size):
	return "Double the grow time " + Helper.time_icon() + " and base " + Helper.mana_icon() + " of adjacent plants."

static func get_resource() -> Structure:
	return Structure.Builder.new()\
		.name("Black Hole").size(8).rarity("uncommon")\
		.text("")\
		.effect(BlackHole.new())\
		.texture(load("res://assets/structure/temporal_rift.png"))\
		.build()
