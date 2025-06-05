extends Node2D
class_name Farm

var FarmTile = preload("res://src/farm/tile.tscn")
var Glow = preload("res://src/animation/glow.tscn")
var ManaParticles = preload("res://src/ui/display/mana_particles.tscn")
var blight_spark_sf = preload("res://src/animation/blight/blight_spark.tres")

var event_manager: EventManager

var TILE_SIZE = Vector2(91, 91);
var TOP_LEFT
var tiles = []
var active_actions = []
var effect_queue = []
var next_turn_effects = []
var hovered_tile = null
var current_shape
var selection = []
var mana_added: float = 0.0
var precision_mode = false

signal card_played
signal after_card_played
signal on_yield_gained
signal on_preview_yield
signal on_energy_gained
signal on_card_draw
signal on_show_tile_preview
signal on_hide_tile_preview
signal try_move_structure
signal no_energy

var hover_time = 0.0
var click_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setup(p_event_manager: EventManager):
	# Create the farm tiles
	var x = Constants.VIEWPORT_SIZE.x/2 - TILE_SIZE.x * Constants.FARM_DIMENSIONS.x / 2
	TOP_LEFT = Vector2(x, TILE_SIZE.y * 0.5)
	for i in Constants.FARM_DIMENSIONS.x:
		tiles.append([])
		for j in Constants.FARM_DIMENSIONS.y:
			var tile = FarmTile.instantiate()
			tile.position = TOP_LEFT + TILE_SIZE * Vector2(i, j)
			tile.grid_location = Vector2(i, j)
			tiles[i].append(tile)
			tile.tile_hovered.connect(on_tile_hover)
			tile.on_event.connect(on_farm_tile_on_event)
			tile.on_yield_gained.connect(gain_yield)
			tile.on_yield_added.connect(on_farm_tile_yield_added)
			if i >= Constants.PURPLE_GTE_INDEX:
				tile.purple = true
			$Tiles.add_child(tile)
	event_manager = p_event_manager
	for tile in $Tiles.get_children():
		tile.event_manager = event_manager


func use_card(grid_position, external_source: bool = false):
	if Global.LOCK and !external_source:
		return
	hover_time = 0.0
	var energy = $"../TurnManager".energy
	if Global.selected_card == null and Global.selected_structure == null:
		try_move_structure.emit(tiles[grid_position.x][grid_position.y])
		return
	if Global.selected_structure != null:
		var tile: Tile = tiles[grid_position.x][grid_position.y]
		if tile.state == Enums.TileState.Empty and tile.not_destroyed():
			tile.build_structure(Global.selected_structure, Global.rotate)
			clear_overlay()
			card_played.emit(Global.selected_structure)
		return
	if Global.selected_card == null or Global.selected_card.cost > energy:
		no_energy.emit()
		return
	var card = Global.selected_card.copy()
	# Handle X cost cards
	if card.cost == -1:
		for effect in card.effects:
			if effect.strength < 0:
				effect.strength = (effect.strength * -1) * energy
				card.cost = energy
	var targets = []
	if selection.size() > 0:
		targets.assign(selection)
	else:
		targets = get_targeted_tiles(grid_position, Global.selected_card, Global.selected_card.size, Global.shape, Global.rotate)
	targets.shuffle()
	card.register_events(event_manager, null)
	var args = EventArgs.SpecificArgs.new(tiles[grid_position.x][grid_position.y])
	args.play_args = EventArgs.PlayArgs.new(card, external_source)
	await card.notify(event_manager, EventManager.EventType.BeforeCardPlayed, args)
	await event_manager.notify_specific_args(EventManager.EventType.BeforeCardPlayed, args)
	# Animate
	var spriteframes: SpriteFrames = null
	var delay = 0.0
	var on = Enums.AnimOn.Mouse
	delay = card.delay
	if card.animation != null:
		spriteframes = card.animation
		on = card.anim_on
	elif card.get_effect("harvest") != null:
		spriteframes = load("res://src/animation/scythe_frames.tres")
		delay = 0.2
	var animation_position = Vector2.ZERO
	if spriteframes != null:
		if on == Enums.AnimOn.Mouse:
			var location = grid_position if card.size == 9 else targets[0]
			animation_position = do_animation(spriteframes, location)
		elif on == Enums.AnimOn.Tiles:
			for target in targets:
				var inbounds = Helper.in_bounds(target)
				var cantarget = tiles[target.x][target.y].card_can_target(card)
				if inbounds and cantarget:
					do_animation(spriteframes, target)
		elif on == Enums.AnimOn.Center:
			animation_position = do_animation(spriteframes, null)
	if !external_source:
		card_played.emit(Global.selected_card)
	await get_tree().create_timer(delay).timeout
	do_plant_shearing_animation(animation_position, card.size)
	if on == Enums.AnimOn.Tiles:
		for target in targets:
			if tiles[target.x][target.y].card_can_target(card):
				tiles[target.x][target.y].nudge()
	mana_added = 0.0
	await use_card_on_targets(card, targets, false)
	clear_overlay()
	process_effect_queue()
	
	await card.notify(event_manager, EventManager.EventType.AfterCardPlayed, args)
	await event_manager.notify_specific_args(EventManager.EventType.AfterCardPlayed, args)

	card.unregister_events(event_manager)
	$"../".shake_mana(mana_added)
	mana_added = 0.0
	after_card_played.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var selected_card_null = Global.selected_card == null
	var selected_structure_null = Global.selected_structure == null
	if !Settings.CLICK_MODE:
		hover_time += delta
		
		# Show select overlay if hovering
		if !Input.is_action_pressed("leftclick") and !precision_mode and current_shape != Global.shape and hovered_tile != null:
			show_select_overlay()
	
	# Change to Precision Mode if clicking the tile for long enough
	if Input.is_action_pressed("leftclick"):
		click_time += delta
	else:
		click_time = 0

	# No precision mode for structures and size-1 cards
	# For now, also disable for size-9 Scythes
	if !precision_mode and click_time > 1.0 and !selected_card_null and Global.selected_card.size != -1:
		clear_overlay()
		precision_mode = true
		selection.clear()
		if hovered_tile != null:
			selection.append(hovered_tile.grid_location)
		show_select_overlay()
	
	# Clear overlay if you mouse off the farm
	if hovered_tile == null or (Global.selected_card == null and Global.selected_structure == null) and $SelectOverlay.get_children().size() > 0:
		if !precision_mode:
			clear_overlay()
	# Remove precision mode if you deselect a card
	if Global.selected_card == null:
		precision_mode = false
	# Disable confirm button if selection is empty
	$ConfirmButton.disabled = selection.size() == 0 and precision_mode
	
func show_select_overlay():
	var size = 0
	var targets = []
	# If a card is selected
	if Global.selected_card != null:
		var crd = Global.selected_card
		size = crd.size
		targets = crd.targets if crd.type == "ACTION" else ["Empty"]
	
	# If a structure is selected
	elif Global.selected_structure != null:
		size = Global.selected_structure.size
		targets = ["Empty", "Growing", "Mature"]
	elif hovered_tile != null and (hover_time > Constants.HOVER_PREVIEW_DELAY or (Settings.CLICK_MODE and !precision_mode)):
		clear_overlay()
		on_show_tile_preview.emit(hovered_tile)
		return
	if hovered_tile == null:
		return
	clear_overlay()
	if size == 0 and Global.selected_structure == null:
		$ConfirmButton.visible = Settings.CLICK_MODE
		return
	var grid_position = hovered_tile.grid_location
	var shape = Global.shape
	$ConfirmButton.visible = Settings.CLICK_MODE or precision_mode
	if Global.selected_structure != null:
		shape = Enums.CursorShape.Elbow
		var sprite = Sprite2D.new()
		sprite.texture = Global.selected_structure.texture
		sprite.position = TOP_LEFT + (grid_position) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$SelectOverlay.add_child(sprite)
	
	var selected = Global.selected_card if Global.selected_card != null else Global.selected_structure
	var targeted_grid_locations = []
	if !precision_mode:
		targeted_grid_locations = get_targeted_tiles(grid_position, selected, selected.size, shape, Global.rotate)
	else:
		targeted_grid_locations.assign(selection)
	var yld_preview_yellow = 0
	var yld_preview_purple = 0
	var yld_preview_green = 0
	var yld_preview_defer = false

	for item in targeted_grid_locations:
		var error = false
		if not Helper.in_bounds(item):
			error = true
		else:
			var targeted_tile = tiles[item.x][item.y]
			if Global.selected_card != null:
				error = !targeted_tile.card_can_target(Global.selected_card)
				if !error:
					var preview: EventArgs.HarvestArgs = Global.selected_card.preview_yield(targeted_tile)
					var specific = EventArgs.SpecificArgs.new(targeted_tile)
					specific.harvest_args = preview
					event_manager.notify_specific_args(EventManager.EventType.OnYieldPreview, specific)
					yld_preview_purple += preview.yld if preview.purple else 0.0
					yld_preview_yellow += preview.yld if !preview.purple else 0.0
					yld_preview_green += preview.green
					yld_preview_defer = yld_preview_defer or preview.delay
			elif Global.selected_structure != null:
				error = !targeted_tile.structure_can_target()
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/custom/SelectTile.png")
		sprite.position = TOP_LEFT + (item) * TILE_SIZE + TILE_SIZE / 2
		sprite.scale *= TILE_SIZE / sprite.texture.get_size()
		sprite.z_index = 1
		if error:
			sprite.modulate = Color8(255, 0, 0)
		else:
			sprite.modulate = Color8(0, 255, 0)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$SelectOverlay.add_child(sprite)
		if !precision_mode:
			selection.append(item)
	if yld_preview_purple != 0 or yld_preview_yellow != 0 or yld_preview_green != 0:
		on_preview_yield.emit({
			"yellow": yld_preview_yellow, 
			"purple": yld_preview_purple,
			"green": yld_preview_green,
			"defer": yld_preview_defer
		})

func get_targeted_tiles(grid_position, card, size, shape, rotate):
	var target_tiles = []
	if size != -1:
		if shape == Enums.CursorShape.Smart:
			for item in Helper.get_smart_select_shape(grid_position, tiles, card, $Tiles.get_global_mouse_position()):
				target_tiles.append(item)
		else:
			for item in Helper.get_tile_shape_rotated(size, shape, rotate):
				if Global.flip == 1:
					item.x = -item.x
				target_tiles.append(item + grid_position)
	else:
		for i in range(0, Constants.FARM_DIMENSIONS.x):
			for j in range(0, Constants.FARM_DIMENSIONS.y):
				target_tiles.append(Vector2(i, j))
	return target_tiles

func pct(num):
	return float(num)/100.0

func on_tile_hover(tile):
	if Settings.CLICK_MODE:
		await get_tree().create_timer(0.1).timeout
		hovered_tile = tile
		show_select_overlay()
	else:
		hover_time = 0.0
		hovered_tile = tile
		if Input.is_action_pressed("leftclick"):
			if precision_mode and tile != null:
				toggle_tile_selection(tile.grid_location)
			else:
				clear_overlay()
		else:
			if tile != null:
				show_select_overlay()

func clear_overlay():
	for node in $SelectOverlay.get_children():
		$SelectOverlay.remove_child(node)
		node.queue_free()
	if !precision_mode:
		selection.clear()
	on_preview_yield.emit({
		"purple": 0,
		"yellow": 0,
		"green": 0,
		"defer": false
	}) #This signals to clear the preview
	on_hide_tile_preview.emit()
	$ConfirmButton.visible = false

func process_one_week(week: int):
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_before_grow_effects())
	process_effect_queue()

	if week < Global.WINTER_WEEK and !Global.BLOCK_GROW:
		var growing_tiles = []
		for tile: Tile in $Tiles.get_children():
			if tile.state == Enums.TileState.Growing and (Global.FARM_TYPE != "RIVERLANDS" or tile.is_watered()):
				growing_tiles.append(tile)
		growing_tiles.shuffle()
		for tile in growing_tiles:
			await tile.grow_one_week()
			await get_tree().create_timer(0.01).timeout
		process_effect_queue()
	for tile: Tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_after_grow_effects())
	process_effect_queue()
	for tile in $Tiles.get_children():
		effect_queue.append_array(tile.get_turn_start_effects())
	process_effect_queue()
	effect_queue.append_array(next_turn_effects)
	next_turn_effects.clear()
	process_effect_queue()

func use_action_card(card, grid_location):
	var args = EventArgs.SpecificArgs.new(tiles[grid_location.x][grid_location.y])
	args.play_args = EventArgs.PlayArgs.new(card)
	await card.notify(event_manager, EventManager.EventType.OnActionCardUsed, args)
	await event_manager.notify_specific_args(EventManager.EventType.OnActionCardUsed, args)
	
	for effect in card.effects:
		var n_effect = effect.copy().set_location(grid_location)
		if n_effect.name == "spread":
			n_effect.card = tiles[grid_location.x][grid_location.y].seed
		effect_queue.append(n_effect)

func process_effect_queue():
	while effect_queue.size() > 0:
		var next = effect_queue.pop_front()
		var tile = tiles[next.grid_location.x][next.grid_location.y]
		perform_effect(next, tile)

func perform_effect(effect, tile: Tile):
	match effect.name:
		"harvest":
			await tile.harvest(false)
		"harvest_delay":
			await tile.harvest(true)
		"irrigate":
			tile.irrigate()
		"grow":
			for i in range(effect.strength):
				await tile.grow_one_week()
		"increase_yield":
			tile.multiply_yield(1.0 + effect.strength)
		"add_yield":
			tile.add_yield(effect.strength)
		"plant":
			var card = effect.card.copy()
			if effect.strength > 0:
				card.yld += effect.strength
			await tile.plant_seed(card)
		"spread":
			var i = effect.strength
			while i >= 1.0:
				spread(effect.card, tile.grid_location, 8, Enums.CursorShape.Elbow)
				i -= 1.0
			if i > 0.0 and randf_range(0, 1) <= effect.strength:
				spread(effect.card, tile.grid_location, 8, Enums.CursorShape.Elbow)
		"energy":
			on_energy_gained.emit(effect.strength)
		"draw":
			if effect.on != "play":
				on_card_draw.emit(effect.strength, effect.card)
		"destroy_tile":
			tile.destroy()
		"destroy_plant":
			tile.destroy_plant()
		"replant":
			if tile.seed.get_effect("plant") == null:
				effect_queue.append(Effect.new("plant", 0, "", "self", tile.grid_location, tile.seed.copy()))
		"add_recurring":
			if tile.seed.get_effect("plant") == null:
				var new_seed = tile.seed.copy()
				new_seed.effects.append(Effect.new("plant", 0, "harvest", "self", Vector2.ZERO, null))
				tile.seed = new_seed
				tile.play_effect_particles()
		"draw_target":
			var new_seed = tile.seed.copy()
			new_seed.effects.append(load("res://src/effect/data/fleeting.tres"))
			on_card_draw.emit(effect.strength, new_seed.copy())
		"add_blight_yield":
			tile.seed_base_yield += effect.strength * (event_manager.turn_manager.get_blight_strength())
		"protect":
			tile.protected = true
			tile.update_display()

func gain_yield(tile: Tile, args: EventArgs.HarvestArgs):
	var destination = Global.MANA_TARGET_LOCATION_PURPLE if args.purple else Global.MANA_TARGET_LOCATION_YELLOW
	var specific = EventArgs.SpecificArgs.new(tile)
	specific.harvest_args = args
	event_manager.notify_specific_args(EventManager.EventType.OnManaGained, specific)
	blight_bubble_animation(tile, args, destination)
	on_yield_gained.emit(args)

func do_winter_clear():
	var blighted_tiles: Array[Tile] = []
	var reset_colors = $Tiles.get_children().any(func(tile): return !tile.purple)
	for tile: Tile in $Tiles.get_children():
		tile.do_winter_clear()
		tile.set_blight_targeted(false)
		tile.set_destroy_targeted(false)
		tile.lose_irrigate()
		tile.update_display()
		if tile.blighted:
			blighted_tiles.append(tile)
		if reset_colors:
			tile.purple = tile.grid_location.x >= Constants.PURPLE_GTE_INDEX
			tile.update_purple_overlay()
	if Global.DIFFICULTY < Constants.DIFFICULTY_HEAL_SLOWER:
		remove_blight_from_all_tiles()
	else:
		blighted_tiles.shuffle()
		for i in range(0, blighted_tiles.size()):
			if i < ceil(float(blighted_tiles.size()) / 2.0):
				blighted_tiles[i].remove_blight()
	next_turn_effects.clear()

func remove_protected():
	for tile: Tile in get_all_tiles():
		tile.protected = false
		tile.update_display()

func spread(card, grid_position, size, shape):
	var targets = get_targeted_tiles(grid_position, card, size, shape, 0)
	targets.shuffle()
	var targeted_tile = await use_card_on_targets(card, targets, true)
	if targeted_tile != null:
		do_animation(load("res://src/animation/spread.tres"), targeted_tile.grid_location)

func use_card_on_targets(card, targets, only_first, delay: float = 0.0):
	for target in targets:
		if not Helper.in_bounds(target):
			continue
		var target_tile = tiles[target.x][target.y]
		if not target_tile.card_can_target(card):
			continue
		if card.type == "SEED":
			effect_queue.append_array(target_tile.plant_seed_animate(card))
			if target_tile.seed != null:
				var args = EventArgs.SpecificArgs.new(target_tile)
				args.play_args = EventArgs.PlayArgs.new(card)
				await target_tile.seed.notify(event_manager, EventManager.EventType.OnActionCardUsed, args)
				await event_manager.notify_specific_args(EventManager.EventType.OnActionCardUsed, args)
		elif card.type == "ACTION":
			await use_action_card(card, Vector2(target.x, target.y))
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		if only_first:
			return target_tile

func gain_energy(amount):
	on_energy_gained.emit(amount)

# Unused, moved to CardData
func preview_yield(card, targeted_tile: Tile):
	var yld_purple = 0.0
	var yld_yellow = 0.0
	var defer = card.get_effect("harvest_delay") != null
	if (card.get_effect("harvest") != null\
		or card.get_effect("harvest_delay") != null or card.has_effect(Enums.EffectType.Harvest))\
		and targeted_tile.card_can_target(card):
		var harvest: EventArgs.HarvestArgs = targeted_tile.preview_harvest()
		harvest.yld = round(harvest.yld)
		var specific = EventArgs.SpecificArgs.new(targeted_tile)
		specific.harvest_args = harvest
		event_manager.notify_specific_args(EventManager.EventType.OnYieldPreview, specific)
		if harvest.purple:
			yld_purple += harvest.yld
		else:
			yld_yellow += harvest.yld
		defer = defer or harvest.delay
	var increase_yield = card.get_effect("increase_yield")
	if increase_yield != null:
		yld_purple *= 1.0 + increase_yield.strength
		yld_yellow *= 1.0 + increase_yield.strength
	return {
		"purple": round(yld_purple),
		"yellow": round(yld_yellow),
		"defer": defer
	}

func on_expand_farm():
	for tile in $Tiles.get_children():
		tile.do_active_check()

func destroy_blighted_tiles():
	for tile in $Tiles.get_children():
		if tile.destroy_targeted == true:
			if !tile.is_protected():
				tile.destroy_plant()
				do_animation(blight_spark_sf, tile.grid_location)
				await get_tree().create_timer(0.1).timeout
			tile.set_destroy_targeted(false)
		if tile.blight_targeted == true:
			if !tile.is_protected():
				tile.destroy()
			tile.set_blight_targeted(false)

func use_card_random_tile(card: CardData, times: int):
	var tiles = []
	for tile: Tile in $Tiles.get_children():
		if tile.state == Enums.TileState.Empty && tile.not_destroyed() && !tile.rock:
			tiles.append(tile)
	tiles.shuffle()
	var locations = []
	if tiles.size() == 0:
		return []
	for i in range(times):
		if i < tiles.size():
			locations.append(tiles[i].grid_location)
	use_card_on_targets(card, locations, false)
	return locations

func get_unprotected_tile():
	var tiles = get_all_tiles()
	tiles.shuffle()
	for tile: Tile in tiles:
		if tile.state == Enums.TileState.Empty && !tile.is_protected() && tile.not_destroyed() && !tile.rock:
			return tile
	return null

func use_card_unprotected_tile(card: CardData, times: int, delay: float = 0.0):
	var tiles = []
	for tile: Tile in $Tiles.get_children():
		if tile.state == Enums.TileState.Empty && !tile.is_protected() && tile.not_destroyed() && !tile.rock:
			tiles.append(tile)
	tiles.shuffle()
	var locations = []
	var i = 0
	if tiles.size() == 0:
		return
	while i < times and i < tiles.size():
		locations.append(tiles[i].grid_location)
		i += 1
	await use_card_on_targets(card, locations, false, delay)
	
func get_all_tiles() -> Array[Tile]:
	var result: Array[Tile] = []
	result.assign($Tiles.get_children())
	return result

func on_farm_tile_on_event(event_type: EventManager.EventType, specific_args):
	event_manager.notify_specific_args(event_type, specific_args)

func remove_blight_from_all_tiles():
	for tile in $Tiles.get_children():
		if tile.blighted:
			tile.remove_blight()

func blight_bubble_animation(tile, args: EventArgs.HarvestArgs, destination: Vector2, color_override: Color = Color.BLACK):
	var mana_amount = args.yld
	var color = Color8(166, 252, 219) if args.purple else Color8(255, 252, 64)
	if color_override != Color.BLACK:
		color = color_override
	if args.green > 0:
		mana_amount = args.green
		color = Color8(15, 252, 3)
	if mana_amount == 0:
		return
	var mana_particles: ManaParticles = ManaParticles.instantiate()
	mana_particles.color = color
	mana_particles.amount = min(max(int(mana_amount / 5), 3), 10)
	mana_particles.max_scale = min(1.3 + mana_amount / 15, 4.0)
	mana_particles.size = 100
	mana_particles.position = tile.position + TILE_SIZE / 2
	mana_particles.hue_variation_max = min(0.0 + 0.01 * (mana_amount / 10), 0.10)
	mana_particles.on_finish = func():
		$Animations.remove_child(mana_particles)

	$Animations.add_child(mana_particles)
	return
	var bubbles = args.yld
	var purple = args.purple
	for i in range(min(10, bubbles)):
		create_bubble(tile, destination, Color8(166, 252, 219) if purple else Color8(255, 252, 64), purple)
	while bubbles > 100:
		create_bubble(tile, destination, Color8(32, 214, 199) if purple else Color8(255, 213, 65), purple)
		create_bubble(tile, destination, Color8(32, 214, 199) if purple else Color8(255, 213, 65), purple)
		bubbles -= 100
	while bubbles > 20:
		create_bubble(tile, destination, Color8(40, 92, 196) if purple else Color8(249, 163, 27), purple)
		create_bubble(tile, destination, Color8(40, 92, 196) if purple else Color8(249, 163, 27), purple)
		bubbles -= 20


func create_bubble(tile: Tile, destination: Vector2, color: Color, purple: bool):
	var glow = Glow.instantiate()
	glow.modulate = color
	glow.position = tile.position + Vector2(TILE_SIZE.x * randf(), TILE_SIZE.y * randf())
	var target_position = Vector2(destination)
	target_position += Vector2(-8 + 16 * randf(), -8 + 16 * randf())
	var time = Constants.MANA_MOVE_TIME + randf() * Constants.MANA_MOVE_VARIANCE
	var tween = get_tree().create_tween()
	tween.tween_property(glow, "position", target_position, time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		$Animations.remove_child(glow))
	$Animations.add_child(glow)

func _on_user_interface_farm_preview_hide() -> void:
	for tile: Tile in get_all_tiles():
		tile.hide_peek()

func _on_user_interface_farm_preview_show(weeks: int, callback: Callable) -> void:
	var yellow = 0.0
	var purple = 0.0
	for tile: Tile in get_all_tiles():
		var mana = tile.show_peek(weeks)
		if tile.purple:
			purple += mana
		else:
			yellow += mana
	callback.call(weeks, {
		"purple": purple,
		"yellow": yellow
	})

func _on_confirm_button_pressed() -> void:
	if hovered_tile != null:
		use_card(hovered_tile.grid_location)
	if selection.size() > 0:
		use_card(selection[0])
		if precision_mode:
			precision_mode = false
			selection.clear()
			clear_overlay()

func do_animation(spriteframes, grid_location):
	var anim = AnimatedSprite2D.new()
	anim.sprite_frames = spriteframes
	if grid_location != null:
		anim.position = TOP_LEFT + grid_location * Constants.TILE_SIZE + Constants.TILE_SIZE / 2
	else:
		anim.position = TOP_LEFT + Vector2(4, 4) * Constants.TILE_SIZE
	anim.scale = Constants.TILE_SIZE / Vector2(16, 16)
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var path: String = spriteframes.resource_path
	if path.contains("catalyze") or path.contains("downpour"):
		anim.position -= Vector2(0, Constants.TILE_SIZE.y / 2)
	if path.contains("spark") or path.contains("lightning"):
		anim.position -= Vector2(0, Constants.TILE_SIZE.y)
	add_child(anim)
	anim.play("default")
	anim.animation_finished.connect(func():
		remove_child(anim))
	return anim.position

func do_plant_shearing_animation(origin: Vector2, size: int):
	if origin == Vector2.ZERO:
		return
	for tile: Tile in get_all_tiles():
		var decay = 6 if size == -1 else size / 2
		var push_direction = tile.position.direction_to(origin)
		var push_intensity = max(0, 12 * (1 - (origin.distance_to(tile.position) / TILE_SIZE.x / decay)))
		tile.push_animate(push_direction * push_intensity)

func on_farm_tile_yield_added(tile: Tile, amount: float):
	mana_added += amount
	blight_bubble_animation(tile, EventArgs.HarvestArgs.new(0, false, false, amount), tile.position)

func tile_mouse_up(grid_location: Vector2):
	if Settings.CLICK_MODE:
		return
	if !precision_mode and hovered_tile != null and hovered_tile.grid_location == grid_location:
		use_card(grid_location)

func tile_mouse_down(grid_location: Vector2):
	var tile = tiles[grid_location.x][grid_location.y]
	if Settings.CLICK_MODE and !precision_mode:
		# Move structure on the first click

		if tile.structure != null:
			try_move_structure.emit(tile)
		# Double click = use card
		if hovered_tile != null and hovered_tile.grid_location == grid_location:
			use_card(grid_location)
		# First click = set as hovered
		else:
			on_tile_hover(tile)
	if precision_mode:
		hovered_tile = tile
		toggle_tile_selection(grid_location)

func toggle_tile_selection(grid_location: Vector2):
	if selection.has(grid_location):
		selection.erase(grid_location)
	else:
		var copy = []
		copy.assign(selection)
		for loc in copy:
			var deltax = abs(loc.x - grid_location.x)
			var deltay = abs(loc.y - grid_location.y)
			if deltax > 2 or deltay > 2:
				selection.erase(loc)
			elif selection.size() + 1 > Global.selected_card.size:
				var error = !tiles[loc.x][loc.y].card_can_target(Global.selected_card)
				if error:
					selection.erase(loc)
		selection.append(grid_location)
		while selection.size() > Global.selected_card.size:
			selection.pop_front()
	show_select_overlay()
