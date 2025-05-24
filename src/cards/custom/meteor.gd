extends StrEffect
class_name MeteorEffect

var listener: Listener

func register(event_manager: EventManager, _tile: Tile):
	listener = Listener.new(timing, func(args: EventArgs):
		var tile = args.specific.tile
		if !tile.is_destroyed():
			tile.destroy()
			for t2 in args.farm.get_all_tiles():
				if t2.seed != null:
					t2.add_yield(strength)
		event_manager.shake_screen(50.0)
		)

	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	return MeteorEffect.new().assign(self)

func get_description(size):
	return "[color=gold]Destroy[/color] up to " + str(size) + " tiles. For each tile destroyed, add " + highlight(str(strength)) + " {MANA} to all plants."

func get_type():
	return Enums.EffectType.DestroyTile
