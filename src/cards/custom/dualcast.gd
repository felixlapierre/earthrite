extends CardData
class_name Dualcast

var tile: Tile
var callback: Callable
var callback_harvest: Callable

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile

	# On card played
	callback = func(args: EventArgs):
		if !tile.seed.has_effect(Enums.EffectType.Draw):
			var card = args.specific.play_args.card
			tile.seed.effects.append(Effect.new("draw", strength, "harvest", "self", Vector2.ZERO, card.copy()))
			tile.seed.text = ""
			tile.play_effect_particles()

	event_manager.register_listener(EventManager.EventType.BeforeCardPlayed, callback)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeCardPlayed, callback)

func copy():
	var new = Dualcast.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
