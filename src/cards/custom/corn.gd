extends CardData
class_name Corn

var tile: Tile
var callback: Callable
var callback_harvest: Callable

var popcorn = preload("res://src/cards/data/unique/popcorn.tres")
var cards_burned_count = 0
# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	# On card played
	callback = func(args: EventArgs):
		tile.play_effect_particles()
	callback_harvest = func(args: EventArgs):
		if tile == args.specific.tile:
			args.farm.use_card_random_tile(popcorn, args.cards.cards_burned)

	# On harvest
	event_manager.register_listener(EventManager.EventType.OnCardBurned, callback)
	event_manager.register_listener(EventManager.EventType.OnPlantHarvest, callback_harvest)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnCardBurned, callback)
	event_manager.unregister_listener(EventManager.EventType.OnPlantHarvest, callback_harvest)

func copy():
	var new = Corn.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return false

func get_long_description():
	return Helper.get_long_description("burn") + "\n" + Helper.get_long_description("popcorn") + "\n" + super.get_long_description()
