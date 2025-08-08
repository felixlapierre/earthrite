extends CardData
class_name WaterRite

var spriteframes: SpriteFrames = preload("res://src/animation/frames/waterrite.tres")

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed
var turn_end = EventManager.EventType.AfterGrow
var turn_end_callback: Callable
var year_start = EventManager.EventType.BeforeYearStart

var anim

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	super.register_events(event_manager, p_tile)
	anim = AnimatedSprite2D.new()
	anim.sprite_frames = spriteframes
	anim.position = Vector2(963, 450)
	anim.scale = Constants.TILE_SIZE / Vector2(16, 16)
	anim.animation_finished.connect(func():
		anim.play("ongoing")
		anim.position = Vector2(963, 131))
	anim.z_index = 1
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	event_manager.farm.add_child(anim)
	anim.play("default")
	event_manager.shake_screen(10.0)

	callback = func(args: EventArgs):
		var card: CardData = args.specific.play_args.card
		if card.type == "SEED":
			var tiles = args.farm.get_all_tiles()
			tiles.shuffle()
			for tile in tiles:
				if tile.is_watered() and tile.state == Enums.TileState.Empty:
					tile.plant_seed_animate(card)
					var line = DrawLine.new()
					line.setup(Vector2(963, 131), tile.position + Constants.TILE_SIZE / 2, Color.ROYAL_BLUE)
					args.farm.add_child(line)
					await args.farm.get_tree().create_timer(0.1).timeout
					event_manager.shake_screen(10.0)
					args.farm.remove_child(line)
			event_manager.farm.remove_child(anim)
			
	turn_end_callback = func(args: EventArgs):
		event_manager.farm.remove_child(anim)
		event_manager.unregister_listener(event_type, callback)
		event_manager.unregister_listener(turn_end, turn_end_callback)
		event_manager.unregister_listener(year_start, turn_end_callback)
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(turn_end, turn_end_callback)
	event_manager.register_listener(year_start, turn_end_callback)

func unregister_events(event_manager: EventManager):
	#event_manager.unregister_listener(event_type, callback)
	pass

func copy():
	var new = WaterRite.new()
	new.assign(self)
	return new
