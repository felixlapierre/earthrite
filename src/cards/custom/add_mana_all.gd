extends StrEffect
class_name AddManaAll

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.AddMana, "AddManaEffect")

# To be overridden by specific code seeds
func register(event_manager: EventManager, p_tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.seed != null:
				tile.add_yield(strength)
	)
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func copy():
	var new = AddManaAll.new();
	new.assign(self)
	return new

func get_description(size: int) -> String:
	return get_timing_text() + get_description_interp("Add {STRENGTH} " + Helper.mana_icon() + " to all plants")
