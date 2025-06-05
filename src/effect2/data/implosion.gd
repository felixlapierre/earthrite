extends StrEffect
class_name Implosion

var listener: Listener

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.DestroyPlant, "Implosion")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var center = args.specific.tile
		var ring = Helper.get_adjacent_active_tiles(center.grid_location, args.farm)
		var mana = 0.0
		for t: Tile in ring:
			if t.seed != null:
				mana += t.current_yield
				t.destroy_plant()
		await args.farm.get_tree().create_timer(1.0).timeout
		var increased_mana = mana * (1.0 + strength)
		center.add_yield(increased_mana))
	owner.register(listener)

func get_description(_size):
	var str_text = highlight(str((1.0 + strength) * 100) + "% of ") if strength != base_strength else ""
	return "Target plant [color=gold]Destroys[/color] all adjacent plants and gains " + str_text + "their {MANA}"

func unregister(event_manager: EventManager):
	pass

func copy():
	var copy = Implosion.new()
	copy.assign(self)
	return copy
