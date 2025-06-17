extends Effect2
class_name GrapeEffect

var listener: Listener

func _init():
	super(EventManager.EventType.AfterGrow, true, Enums.EffectType.Other, "GrapeEffect")

func register(event_manager: EventManager, tile: Tile):
	pass

func card_can_target(card: CardData):
	return card.targets.has("Growing")

func get_description(size):
	return "Continues Growing even if Mature"

func copy():
	return GrapeEffect.new().assign(self)
