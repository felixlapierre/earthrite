extends MageAbility
class_name BlightMageFortune

var icon = preload("res://assets/card/corruption.png")
static var MAGE_NAME = "Blight Druid"
var event_type = EventManager.EventType.BeforeCardPlayed
var event_callable: Callable

func _init() -> void:
	super(MAGE_NAME, Fortune.FortuneType.GoodFortune, "Start with 20 blight damage and 1 copy of 'Blightrose' in your deck. Blight cards appear in card rewards.", 3, icon, 1.0)
	modify_deck_callback = func(deck):
		deck.append(load("res://src/event/unique/blight_rose.tres"))

func register_fortune(event_manager: EventManager):
	super.register_fortune(event_manager)
	if strength >= 2.0:
		Global.MAX_BLIGHT += 1
		Global.MAX_HEALTH += 20
	if event_manager.turn_manager.blight_damage == 0:
		event_manager.turn_manager.blight_damage = 20
	update_text()

func unregister_fortune(event_manager: EventManager):
	pass
	
func upgrade_power():
	strength += 1.0
	update_text()
	Global.MAX_BLIGHT += 1

func update_text():
	if strength >= 2.0:
		text = "Start with 20 blight damage and 1 copy of 'Blightrose' in your deck. Gain +20 max health. Blight cards appear in card rewards."
	else:
		text = "Start with 20 blight damage and 1 copy of 'Blightrose' in your deck. Blight cards appear in card rewards."
