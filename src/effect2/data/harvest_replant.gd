extends Effect2
class_name HarvestReplant

var sf = preload("res://src/animation/frames/windrite.tres")

@export var timing: EventManager.EventType:
	set(value): event_type = value

var listener: Listener

func _init(p_timing = EventManager.EventType.AfterCardPlayed):
	super(p_timing, false, Enums.EffectType.Harvest, "Windrite")
	timing = p_timing

func register(event_manager: EventManager, p_tile: Tile):
	listener = Listener.new(event_type, func(args: EventArgs):
		var targets = []
		if event_type == EventManager.EventType.OnActionCardUsed:
			targets.append(args.specific.tile)
		else:
			targets.append_array(args.farm.get_all_tiles())
			args.farm.do_animation(sf, null)
			await args.farm.get_tree().create_timer(0.2).timeout
		for tile in targets:
			if tile.state == Enums.TileState.Mature:
				var seed = tile.seed.copy()
				await tile.harvest(false)
				if tile.state == Enums.TileState.Empty and seed.yld > 0 and !seed.has_effect(Enums.EffectType.Corrupted):
					await tile.plant_seed(seed)
	)
	listener.effect_type = Enums.EffectType.Harvest
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	var pre = tile.preview_harvest()
	args.yld += pre.yld

func get_description(size: int):
	var size_descr = "all" if size == -1 else str(size)
	return get_timing_text() + "Harvest and Replant " + size_descr + " non-blight plants"

func copy():
	var copy = HarvestReplant.new()
	copy.assign(self)
	return copy
