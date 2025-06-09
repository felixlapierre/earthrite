extends StrEffect
class_name Kindling

var listener_play: Listener
var listener_used: Listener

var destroyed: int = 0

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.DestroyPlant, "Catalyze")

func copy():
	var new = Kindling.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	listener_used = Listener.create(self, func(args: EventArgs):
		args.specific.tile.destroy_plant()
		destroyed += 1)
	listener_play = Listener.new(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		args.farm.on_energy_gained.emit(destroyed + strength)
	)
	listener_play.effect_type = Enums.EffectType.Draw
	
	owner.register(listener_play)
	owner.register(listener_used)

func unregister_events(event_manager: EventManager):
	listener_used.disable()
	listener_play.disable()
	
func get_description(size) -> String:
	var descr = "Destroy target plants. Gain 1 {ENERGY} for each plant destroyed"
	var str_txt = highlight(", plus " + str(strength)) if strength > 0 else ""
	return descr + str_txt
