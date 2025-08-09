extends StrEffect
class_name MultiplyManaEffect

var listener: Listener

@export var timing: EventManager.EventType:
	set(value): event_type = value
@export var seed: bool:
	set(value): is_seed = value

func _init():
	super(timing, seed, Enums.EffectType.AddMana, "MultManaEffect")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var t = tile if is_seed else args.specific.tile
		var mana = t.current_yield
		t.add_yield(mana * strength)
	)
	if is_seed:
		event_manager.register(listener)
	else:
		owner.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size: int):
	var timing_text = get_timing_text()
	var strength_text = highlight(str(strength * 100) + "%")
	var size_text = Helper.get_size_text(size)
	if is_seed:
		return timing_text + "Increases plant's " + Helper.mana_icon() + " by " + strength_text
	return timing_text + "Increase the " + Helper.mana_icon() + " of " + size_text + " target plants by " + strength_text

func copy():
	return MultiplyManaEffect.new().assign(self)

func preview_yield(tile: Tile, args: EventArgs.HarvestArgs):
	args.green += tile.current_yield * strength
	args.yld *= (1 + strength)
