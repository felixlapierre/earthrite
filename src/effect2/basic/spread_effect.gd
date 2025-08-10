extends StrEffect
class_name SpreadEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.Spread, "SpreadEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var target = args.specific.tile
		if target == null:
			target = tile
		if strength < 1.0:
			var rand = randf_range(0, 1.0)
			if rand < strength:
				spread(args, target)
		for i in range(strength):
			spread(args, target)
	)
	
	owner.register(listener)

func spread(args: EventArgs, target: Tile):
	var options = Helper.get_adjacent_active_tiles(target.grid_location, args.farm)
	options = options.filter(func(tile: Tile): return tile.state == Enums.TileState.Empty)
	if options.size() > 0:
		options.pick_random().plant_seed_animate(target.seed)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	if is_seed:
		return get_timing_text() + highlight(str(strength * 100)) + "% chance to [color=gold]Spread[/color]"
	return get_timing_text() + "Spread %s plants %s times" % [Helper.get_size_text(size), highlight(str(strength))]

func copy():
	return SpreadEffect.new().assign(self)
