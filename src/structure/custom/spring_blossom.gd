extends Effect2
class_name SpringBlossom

var listener: Listener

func _init() -> void:
	super(EventManager.EventType.BeforeTurnStart, false, Enums.EffectType.Draw, "SpringBlossom")

func register(event_manager: EventManager, tile: Tile):
	listener = Listener.create(self, func(args: EventArgs):
		if args.turn_manager.week == 1:
			args.cards.drawcard())
	event_manager.register(listener)

func unregister(event_manager: EventManager):
	listener.disable()

func get_description(size):
	return "Draw 1 extra card on the first week of Spring"

func copy():
	return SpringBlossom.new().assign(self)

static func get_resource():
	return Structure.Builder.new()\
		.name("Spring Blossom").text("").effect(SpringBlossom.new())\
		.size(0).rarity("common")\
		.texture(preload("res://assets/structure/spring_blossom.png")).build()
