extends StrEffect
class_name Inscribe

var listener_used: Listener
var listener_played: Listener

var destroyed: int = 0

func _init():
	super(EventManager.EventType.OnActionCardUsed, false, Enums.EffectType.DestroyPlant, "InscribeEffect")

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	listener_used = Listener.create(self, func(args: EventArgs):
		args.specific.tile.destroy_plant()
		destroyed += 1
	)
	listener_played = Listener.new(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		args.farm.on_card_draw.emit(destroyed + self.strength, null)
	)
	listener_played.effect_type = Enums.EffectType.Draw
	owner.register(listener_used)
	owner.register(listener_played)

func unregister_events(event_manager: EventManager):
	listener_used.disable()
	listener_played.disable()
	
func get_description(size) -> String:
	var descr = "[color=gold]Destroy[/color] target plants. Draw a card for each plant destroyed"
	var str_descr = highlight(", plus " + str(strength))
	return descr + (str_descr if strength > 0 else "")

func copy():
	var new = Inscribe.new()
	new.assign(self)
	return new
