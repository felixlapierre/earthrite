extends StrEffect
class_name Reprise

var listener

var types_seed = [
	EventManager.EventType.BeforeTurnStart,
	EventManager.EventType.AfterGrow,
	EventManager.EventType.BeforeGrow,
	EventManager.EventType.OnPlantGrow
]

var types_notseed = [
	EventManager.EventType.BeforeTurnStart,
	EventManager.EventType.AfterGrow,
	EventManager.EventType.BeforeGrow
]

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.Other, "Reprise")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var target = args.specific.tile
		if target.seed != null:
			for eff in target.seed.effects2:
				if (eff.event_type in types_seed and eff.is_seed) or (eff.event_type in types_notseed and !eff.is_seed):
					eff.listener.invoke(args)
					return
		if target.structure != null:
			for eff in target.structure.effects2:
				if eff.event_type in types_notseed:
					eff.listener.invoke(args)
					return
		)
	owner.register(listener)

func unregister(event_manager):
	listener.disable()

func get_description(size):
	return get_timing_text(event_type) + "Activate all 'Turn Start' and 'On Grow' effects of target plants and structures"

static func get_resource():
	var inst = CardData.new("ACTION", "Reprise", "legendary", 1, 0, 0, 9, "", preload("res://assets/custom/Temp.png"),\
		0, ["Growing", "Mature", "Structure"], [], 1, 1, 0, [], 1, null, 0.0, Enums.AnimOn.Mouse, [Reprise.new()])
	return inst

func copy():
	var copy = Reprise.new()
	copy.assign(self)
	return copy
