extends StrEffect
class_name Gemflower

var listener

func _init():
	super(EventManager.EventType.BeforeTurnStart, true, Enums.EffectType.AddMana, "Gemflower")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		tile.play_effect_particles()
		var adjacent = Helper.get_adjacent_active_tiles(tile.grid_location, args.farm)
		for t in adjacent:
			if t.seed != null:
				t.add_yield(strength)
		)
	event_manager.register(listener)

func unregister(event_manager):
	listener.disable()

func get_description(size):
	return get_timing_text(event_type) + "Add " + highlight(str(strength)) + Helper.mana_icon() + " to adjacent plants"

static func get_resource():
	var inst = CardData.new("SEED", "Gemflower", "uncommon", 1, 15, 5, 1, "", preload("res://assets/seed/blue-crown.png"),\
		0, [], [], 1, 1, 5, [], 1, null, 0.0, Enums.AnimOn.Mouse, [Gemflower.new()])
	return inst

func copy():
	var copy = Gemflower.new()
	copy.assign(self)
	return copy
