extends CardData
class_name Puffshroom

var listener: Listener

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	listener = Listener.new(EventManager.EventType.OnPlantGrow, func(args: EventArgs):
		var t = args.specific.tile
		if t.state == Enums.TileState.Mature:
			args.farm.effect_queue.append_array(p_tile.harvest(false))
			args.farm.process_effect_queue()
		)
	
	register(listener)

func unregister_seed_events(event_manager: EventManager):
	listener.disable()

func copy():
	var new = Puffshroom.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return false
