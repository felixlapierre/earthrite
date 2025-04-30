extends Effect2
class_name HarvestReplant

func register(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Mature:
				var seed = tile.seed
				args.farm.effect_queue.append_array(tile.harvest(false))
				if seed.get_effect("plant") == null and seed.yld != 0 and seed.get_effect("corrupted") == null:
					args.farm.effect_queue.append_array(tile.plant_seed_animate(seed.copy()))
		args.farm.process_effect_queue()
	event_manager.register_listener(timing, callback)

func unregister(event_manager: EventManager):
	event_manager.unregister_listener(timing, callback)

func get_description():
	return super.get_description() + "Harvest and replant all plants"

func copy():
	var copy = HarvestReplant.new()
	copy.assign(self)
	return copy
