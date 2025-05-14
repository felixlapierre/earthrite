extends Effect2
class_name HarvestReplant

func register(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		await args.farm.get_tree().create_timer(0.2).timeout
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

func get_description(size: int):
	var size_descr = "all" if size == -1 else str(size)
	return get_timing_text() + "Harvest and Replant " + size_descr + " plants"

func copy():
	var copy = HarvestReplant.new()
	copy.assign(self)
	return copy

func get_type():
	return "harvest"
