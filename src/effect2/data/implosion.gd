extends Effect2
class_name Implosion

var listener: Listener

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.new("implosion", timing, func(args: EventArgs):
		var center = args.specific.tile
		var ring = Helper.get_adjacent_active_tiles(center.grid_location, args.farm)
		var mana = 0.0
		for t: Tile in ring:
			if t.seed != null:
				mana += t.current_yield
				t.destroy_plant()
		center.add_yield(mana))
	owner.register(listener)

func get_description(_size):
	return "Target plant [color=gold]Destroys[/color] all adjacent plants and gains their {MANA}"

func get_type():
	return "destroy"

func unregister(event_manager: EventManager):
	pass

func copy():
	var copy = Implosion.new()
	copy.assign(self)
	return copy
