extends Effect2
class_name BrainInAJar

func _init():
	super(EventManager.EventType.BeforeTurnStart, false, Enums.EffectType.Other, "BrainInAJar")
	
func register(event_manager: EventManager, tile: Tile):
	Global.MAX_HAND_SIZE = 100

func unregister(event_manager: EventManager):
	Global.MAX_HAND_SIZE = 10

func copy():
	return BrainInAJar.new().assign(self)

func get_description(size):
	return "You have no maximum hand size"
