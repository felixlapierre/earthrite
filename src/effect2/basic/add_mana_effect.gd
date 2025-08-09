extends StrEffect
class_name AddManaEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.AddMana, "AddManaEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		# note for seed harvest effects it actually uses preview_yield to get the actual yield :(
		if !is_seed_harvest_effect():
			args.specific.tile.add_yield(strength)
	)
	
	owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	if is_seed_harvest_effect():
		if args.yld > 0:
			args.yld += strength
	else:
		args.green += strength

func get_description(size: int):
	var descr = get_timing_text() + "Add {STRENGTH}%s to %s plants" % [Helper.mana_icon(), Helper.get_size_text(size)]
	if is_seed:
		descr = get_timing_text() + "Gain {STRENGTH}%s" % [Helper.mana_icon()]
	return get_description_interp(descr)

func copy():
	return AddManaEffect.new().assign(self)

func is_seed_harvest_effect():
	return is_seed and event_type == EventManager.EventType.OnPlantHarvest
