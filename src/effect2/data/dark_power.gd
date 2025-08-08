extends Effect2
class_name DarkPower

var listener: Listener

func _init(p_delay = false):
	super(EventManager.EventType.OnHealthChanged, true, Enums.EffectType.Passive, "Dark Power")

func register(event_manager: EventManager, tile: Tile):
	var apply_dark_power = func(args: EventArgs):
		var dark_power_strength = event_manager.turn_manager.get_dark_power()
		for effect in owner.effects2:
			if effect.can_strengthen():
				effect.strength = effect.base_strength + (dark_power_strength - 1) * effect.strength_increment
				owner.updated.emit()
				return
		if owner.can_strengthen_custom_effect():
			owner.strength = owner.strength_increment * dark_power_strength
			owner.updated.emit()
	listener = Listener.create(self, apply_dark_power)
	
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()
	
func get_description(size):
	return "[color=fuchsia]Dark Power[/color]"

func get_long_description():
	return "[color=fuchsia]Dark Power[/color]: Effect strength is proportional to blight damage taken"

func copy():
	var copy = DarkPower.new()
	copy.assign(self)
	return copy
