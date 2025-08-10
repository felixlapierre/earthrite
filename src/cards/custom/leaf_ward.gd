extends CardData
class_name LeafWard

var listener: Listener

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	listener = Listener.new(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Growing:
				var harvest_args = EventArgs.HarvestArgs.new(self.strength, true, false)
				args.farm.gain_yield(tile, harvest_args)
	)
	event_manager.register(listener)

func unregister_events(event_manager: EventManager):
	listener.disable()

func copy():
	var new = LeafWard.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true

func preview_yield(tile: Tile):
	var purple = 0
	if tile.state == Enums.TileState.Growing:
		purple = self.strength
	return EventArgs.HarvestArgs.new(purple, true, false)
