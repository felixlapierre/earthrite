extends Effect2
class_name CrystalBall

func register(event_manager: EventManager, tile: Tile):
	Mastery.BonusOptions += 1
	ExplorePoint.PEEK_EVENT_NAME = true

func unregister(event_manager: EventManager):
	Mastery.BonusOptions -= 1
	ExplorePoint.PEEK_EVENT_NAME = false

func copy():
	return CrystalBall.new().assign(self)

func get_description(size):
	return "When [color=gold]Exploring[/color]: Predict Events. See 1 extra option when picking Cards, Enhances, Structures"
