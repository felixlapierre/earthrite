extends StrEffect
class_name MeteorEffect

var listener: Listener
var listener2: Listener

var total = 0

@export var timing: EventManager.EventType:
	set(value): event_type = value

func _init():
	super(timing, false, Enums.EffectType.DestroyTile, "Meteor")

func register(event_manager: EventManager, _tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		var tile = args.specific.tile
		if !tile.is_destroyed():
			tile.destroy()
			total += 1
		event_manager.shake_screen(50.0)
		)
	
	listener2 = Listener.new(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		for i in range(total + strength):
			args.cards.drawcard()
		args.turn_manager.energy += total + strength
		args.user_interface.update()
		)

	owner.register(listener)
	owner.register(listener2)

func unregister(event_manager: EventManager):
	listener.disable()
	listener2.disable()

func copy():
	return MeteorEffect.new().assign(self)

func get_description(size):
	var str_text = "" if strength == 0 else highlight(" plus " + str(strength))
	return "[color=gold]Destroy[/color] up to " + str(size) + " tiles. For each tile destroyed" + str_text + ", gain 1 {ENERGY} and draw 1 card."

func get_type():
	return Enums.EffectType.DestroyTile
