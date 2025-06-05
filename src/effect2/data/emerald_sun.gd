extends Effect2
class_name PlantRandomSeeds

var spriteframes = preload("res://src/animation/frames/emerald_sun_sf.tres")
var anim

var banned = ["Iris", "Fire Flower", "Morel", "Lotus", "Cactus", "Rainbow Cactus"]
var number_of_seeds = 3

var options = []
# To be overridden
func register(event_manager: EventManager, tile: Tile):
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
	
	for i in range(number_of_seeds):
		# Pick cards until you get a non-banned, non-legendary seed
		var card = DataFetcher.get_random_card()
		while card.type != "SEED" or banned.has(card.name) or card.rarity == "legendary":
			card = DataFetcher.get_random_card()
		options.append(card)
	
	callback = func(args: EventArgs):
		var target = args.specific.tile
		if target.state == Enums.TileState.Empty and !target.is_destroyed():
			var card = options.pick_random()
			# Plant it on the farm
			var effects = target.plant_seed_animate(card)
			args.farm.effect_queue.append_array(effects)
			args.farm.process_effect_queue()

			# Draw a line for animation
			var line = DrawLine.new()
			line.setup(Vector2(963, 131), target.position + Constants.TILE_SIZE / 2, Color.DARK_GREEN)
			args.farm.add_child(line)
			event_manager.shake_screen(10.0)
			await args.farm.get_tree().create_timer(0.025).timeout
			args.farm.remove_child(line)
			
	event_manager.register_listener(timing, callback)

# To be overridden
func unregister(event_manager: EventManager):
	event_manager.unregister_listener(timing, callback)
	event_manager.farm.remove_child(anim)

# To be overridden
func get_description(size: int) -> String:
	var size_descr = "entire farm" if size == -1 else str(size) + " tiles"
	return get_timing_text() + "Fill " + size_descr + " with " + str(number_of_seeds) + " random seeds"

func copy():
	var copy = PlantRandomSeeds.new()
	copy.assign(self)
	return copy
