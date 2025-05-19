extends Structure
class_name Telescope

func _init():
	super()

func copy():
	var copy = Telescope.new()
	copy.assign(self)
	return copy

# Need to give the bonus explore when you load the game
# And moving strucuture can't give you excess explores
# And at the start of winter each year get a bonus explore
func register_events(event_manager: EventManager, tile: Tile):
	Explore.bonus_explores += 1

func unregister_events(event_manager: EventManager):
	Explore.bonus_explores -= 1
