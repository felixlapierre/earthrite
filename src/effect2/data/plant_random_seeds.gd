extends Effect2
class_name PlantRandomSeeds

var banned = ["Iris", "Fire Flower", "Morel", "Lotus"]
# To be overridden
func register(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		var target = args.specific.tile
		if target.state == Enums.TileState.Empty and !target.is_destroyed():
			var card = DataFetcher.get_random_card()
			while card.type != "SEED" or banned.has(card.name):
				card = DataFetcher.get_random_card()
			print(card.name)
			var effects = target.plant_seed_animate(card)
			args.farm.effect_queue.append_array(effects)
			args.farm.process_effect_queue()
	event_manager.register_listener(timing, callback)

# To be overridden
func unregister(event_manager: EventManager):
	event_manager.unregister_listener(timing, callback)

# To be overridden
func get_description() -> String:
	return get_timing_text() + "Fill target area with random seeds"

func copy():
	var copy = PlantRandomSeeds.new()
	copy.assign(self)
	return copy
