extends StrEffect
class_name DarkPower

var listener: Listener

func _init(p_delay = false):
	super(EventManager.EventType.OnHealthChanged, true, Enums.EffectType.Passive, "Dark Power", 0.0, 0.0, 1.0)

func register(event_manager: EventManager, tile: Tile):
	var apply_dark_power = func(args: EventArgs):
		do_passive_effect()
	listener = Listener.create(self, apply_dark_power)
	
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func do_passive_effect():
	var dark_power_strength = TurnManager.get_dark_power() + strength
	for effect in owner.effects2:
		if effect.can_strengthen() and effect.name != "Dark Power":
			effect.highlight_color_override = "violet"
			effect.strength = effect.base_strength + (dark_power_strength - 1) * effect.strength_increment
			owner.updated.emit()
			return
	if owner.can_strengthen_custom_effect():
		owner.strength = owner.strength_increment * dark_power_strength
		owner.updated.emit()

func get_description(size):
	var str_desc = "" if strength == 0 else " " + str(strength)
	return "[color=violet](Dark Power" + str_desc + ")[/color]"

func get_long_description():
	return Helper.get_long_description("dark_power", strength)

func copy():
	var copy = DarkPower.new()
	copy.assign(self)
	return copy
