extends Node2D

var event_manager

@onready var TutorialText = $PCont/Margin/VBox/TutorialText

var blightdamage_lastturn = 0
var PURPLE_MANA_IMG = "res://assets/custom/PurpleMana.png"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setup(p_event_manager: EventManager):
	event_manager = p_event_manager
	event_manager.register_listener(EventManager.EventType.BeforeTurnStart, func(args: EventArgs):
		TutorialText.clear()

		if blightdamage_lastturn != args.turn_manager.blight_damage:
			add_text(tr("TUTORIAL_BLIGHTDAMAGE"))
		blightdamage_lastturn = args.turn_manager.blight_damage
		var blightdiff = args.turn_manager.target_blight - args.turn_manager.purple_mana
		if blightdiff > 0:
			blightattack_text(blightdiff, args)
		else:
			if args.turn_manager.next_turn_blight > 0:
				add_text(tr("TUTORIAL_PURPLE_WAIT"))
			if args.farm.get_all_tiles().any(func(tile: Tile):
					return tile.purple == false and tile.state == Enums.TileState.Mature):
				add_text(tr("TUTORIAL_YELLOW"))
		if TutorialText.get_total_character_count() == 0:
			add_text(tr("TUTORIAL_TURN1"))
		)
	event_manager.register_listener(EventManager.EventType.AfterCardPlayed, func(args: EventArgs):
		var cleared = false
		if args.turn_manager.target_blight > 0 and args.turn_manager.purple_mana > args.turn_manager.target_blight:
			TutorialText.clear()
			cleared = true
			add_text("You are now protected from the Blight for this turn.")
			if args.farm.get_all_tiles().any(func(tile: Tile):
					return tile.purple == false and tile.state == Enums.TileState.Mature)\
					and args.turn_manager.energy - args.specific.play_args.card.cost > 0:
				add_text(tr("TUTORIAL_YELLOW"))
		if args.turn_manager.energy - args.specific.play_args.card.cost <= 0:
			if !cleared: TutorialText.clear()
			add_text(tr("TUTORIAL_NOENERGY"))
		)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_text(text: String):
	if TutorialText.get_total_character_count() > 0:
		TutorialText.append_text("\n\n")
	TutorialText.append_text(text)

func blightattack_text(blightdiff: int, args: EventArgs):
	if !args.farm.get_all_tiles().any(func(tile: Tile):
		return tile.purple == true and tile.state == Enums.TileState.Mature):
		add_text(tr("TUTORIAL_NOREADY").format({
			path=PURPLE_MANA_IMG
		}))
	elif args.cards.get_hand_info().all(func(card_data: CardData):
			!card_data.has_effect(Enums.EffectType.Harvest)):
		add_text(tr("TUTORIAL_NOSCYTHE").format({
			path=PURPLE_MANA_IMG
		}))
	else:
		add_text(tr("TUTORIAL_PURPLE_HARVEST").format({
			count=blightdiff,
			path=PURPLE_MANA_IMG
		}))

func _on_button_pressed() -> void:
	Settings.TUTORIALS_ENABLED = false
	Settings.save_settings()
	visible = false

func on_winter() -> void:
	TutorialText.clear()
	TutorialText.append_text(tr("TUTORIAL_WINTER"))

func check_visible():
	visible = Settings.TUTORIALS_ENABLED
