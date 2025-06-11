extends MarginContainer
class_name Tile

@onready var TILE_BUTTON: TextureButton = $TileButton
@onready var SELECT_PROMPT: AnimatedSprite2D = $SelectPrompt

var state = Enums.TileState.Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed: CardData = null # To contain information about the seed being grown here
var structure: Structure = null

var seed_base_yield = 0.0
var seed_grow_time = 0.0
var current_yield = 0.0
var current_grow_progress = 0.0
var irrigated = false
var purple = false
var structure_rotate = 0
var blight_targeted = false
var destroy_targeted = false

var destroyed = false
var blighted = false
var protected = false
var rock = false

signal tile_hovered
signal on_event
signal on_yield_gained
signal on_yield_added

var event_manager: EventManager

var COLOR_NONE = Color8(255, 255, 255)
var COLOR_IRRIGATE = Color8(136, 183, 252)
var COLOR_DESTROYED = Color8(45, 45, 45)
var COLOR_BLIGHTED = Color8(110, 41, 110)

var yield_particles
var shader = load("res://src/farm/tile/tile.gdshader")

var push_vector: Vector2 = Vector2.ZERO
var push_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.register_click_callback(self)
	do_active_check()
	yield_particles = $AddYieldParticles
	var material = ShaderMaterial.new()
	material.shader = shader
	$PlantSprite.material = material

func do_active_check():
	if grid_location.x < Global.FARM_TOPLEFT.x\
		or grid_location.x > Global.FARM_BOTRIGHT.x\
		or grid_location.y < Global.FARM_TOPLEFT.y\
		or grid_location.y > Global.FARM_BOTRIGHT.y:
		state = Enums.TileState.Inactive
	elif state == Enums.TileState.Inactive:
		state = Enums.TileState.Empty
	update_display()

func update_display():
	update_purple_overlay()
	$Rock.visible = rock
	if state == Enums.TileState.Inactive:
		$PurpleOverlay.visible = false
		$Farmland.visible = false
		$TileButton.visible = false
		return
	$PurpleOverlay.visible = purple
	if is_protected():
		$ProtectOverlay.visible = true
	else:
		$ProtectOverlay.visible = false
	$Farmland.visible = true
	$TileButton.visible = true
	if grid_location.x == Global.FARM_TOPLEFT.x:
		$Farmland.region_rect.position.x = 0
	elif grid_location.x == Global.FARM_BOTRIGHT.x:
		$Farmland.region_rect.position.x = 48
	else:
		$Farmland.region_rect.position.x = 16

	if grid_location.y == Global.FARM_TOPLEFT.y:
		$Farmland.region_rect.position.y = 0
	elif grid_location.y == Global.FARM_BOTRIGHT.y:
		$Farmland.region_rect.position.y = 48
	else:
		$Farmland.region_rect.position.y = 16

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$PlantSprite.material.set_shader_parameter("push", push_vector)
	if seed != null:
		$PlantSprite.material.set_shader_parameter("corrupted", seed.has_effect(Enums.EffectType.Corrupted))

func _on_tile_button_mouse_entered() -> void:
	if !Settings.CLICK_MODE:
		tile_hovered.emit(self)

func _on_tile_button_mouse_exited() -> void:
	if !Settings.CLICK_MODE:
		tile_hovered.emit(null)

func _on_tile_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		nudge()
	if event is InputEventScreenTouch and !Settings.CLICK_MODE:
		Global.MOBILE = true
		Global.pressed = event.pressed
		if event.pressed:
			tile_hovered.emit(self)
		else:
			tile_hovered.emit(null)
			if Global.pressed_time <= 0.5:
				$"../../".use_card(grid_location)
	# TILE_BUTTON.disabled used only in tutorial
	#elif event.is_action_pressed("leftclick") and Settings.CLICK_MODE and !TILE_BUTTON.disabled:
	#	if $"../../".hovered_tile == self:
	#		$"../../".use_card(grid_location)
	#	else:
	#		tile_hovered.emit(self)
	if event.is_action_released("leftclick") and !TILE_BUTTON.disabled:
		$"../../".tile_mouse_up(grid_location)
	elif event.is_action_pressed("leftclick") and !TILE_BUTTON.disabled:
		$"../../".tile_mouse_down(grid_location)

func on_other_clicked():
	if Settings.CLICK_MODE:
		tile_hovered.emit(null)

func plant_seed_animate(planted_seed):
	var copy = planted_seed.copy()
	await plant_seed(copy)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale, 0.1);
	$PlantSprite.scale = Vector2(0, 0)

# MUST COPY SEED PROVIDED TO NOT BREAK EFFECTS
func plant_seed(planted_seed):
	if seed != null:
		remove_seed()
	if card_can_target(planted_seed):
		set_seed(planted_seed)
		var specific_args = EventArgs.SpecificArgs.new(self)
		await planted_seed.notify(event_manager, EventManager.EventType.OnPlantPlanted, specific_args)
		await event_manager.notify_specific_args(EventManager.EventType.OnPlantPlanted, specific_args)

# Doesn't trigger on-plant stuff
func set_seed(planted_seed):
	seed = planted_seed
	seed.register_seed_events(event_manager, self)
	seed_grow_time = float(seed.time)
	seed_base_yield = float(seed.yld)
	current_grow_progress = 0.0
	current_yield = 0.0
	state = Enums.TileState.Growing
	if seed_grow_time == 0:
		state = Enums.TileState.Mature
		current_yield = seed_base_yield
	$PlantSprite.visible = true
	if seed.texture != null:
		$PlantSprite.texture = seed.texture
	else:
		$PlantSprite.texture = load(objects_image)
	$PlantSprite.region_enabled = true
	update_plant_sprite()
	
	
func grow_one_week():
	var effects: Array[Effect] = []
	if state == Enums.TileState.Growing:
		current_grow_progress += 1.0
		var multiplier = 1.0
		var water_bonus = 0.0
		if is_watered():
			multiplier += Global.WATERED_MULTIPLIER
			var absorb = seed.get_effect("absorb")
			if absorb != null:
				multiplier += Global.WATERED_MULTIPLIER * absorb.strength
			water_bonus = 1.0
			$"../../".blight_bubble_animation(self, EventArgs.HarvestArgs.new(1 if Global.WATERED_MULTIPLIER == 0 else 2), Vector2.ZERO, Color.ROYAL_BLUE, 1)
		current_yield += (seed_base_yield / seed_grow_time + water_bonus) * multiplier
		update_plant_sprite()
		grow_animation()
		if current_grow_progress == seed_grow_time:
			state = Enums.TileState.Mature
	await seed.notify(event_manager, EventManager.EventType.OnPlantGrow, EventArgs.SpecificArgs.new(self))
	await event_manager.notify_specific_args(EventManager.EventType.OnPlantGrow, EventArgs.SpecificArgs.new(self))

func grow_animation():
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale * Vector2(0.8, 1.2), 0.1)
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale * Vector2(1, 1), 0.1)

func update_plant_sprite():
	if seed.texture == null:
		var stage = 3 if seed_grow_time == 0 else int(current_grow_progress / seed_grow_time * 3)
		var y
		var h
		match stage:
			0:
				y = 32
				h = 16
			1:
				h = 16
				y = 48
			2:
				y = 64
				h = 32
			3:
				y = 96
				h = 32
			
		$PlantSprite.set_region_rect(Rect2(seed.seed_texture * 16, y, 16, h))
		$PlantSprite.offset = Vector2(0, -8 if h == 16 else -14)
		$PlantSprite.scale = Vector2(5.7, 5.7)
	else:
		var resolution = seed.texture.get_height() / 2
		var max_stage: int = seed.texture.get_width() / resolution - 1
		var current_stage = int(current_grow_progress / seed_grow_time * max_stage)
		var x = resolution * current_stage
		$PlantSprite.set_region_rect(Rect2(x, 0, resolution, resolution*2))
		$PlantSprite.offset = Vector2(0, -resolution)
		$PlantSprite.scale = Vector2(91.0 / resolution, 91.0 / resolution)

func harvest(delay) -> Array[Effect]:
	var harvest_args = get_harvest_event_args(delay)
	var specific_args = EventArgs.SpecificArgs.new(self)
	specific_args.harvest_args = harvest_args
	var seed_copy = seed

	state = Enums.TileState.Empty
	on_yield_gained.emit(self, harvest_args)
	remove_seed()
	$HarvestParticles.emitting = true
	
	await seed_copy.notify(event_manager, EventManager.EventType.OnPlantHarvest, specific_args)
	await event_manager.notify_specific_args(EventManager.EventType.OnPlantHarvest, specific_args)

	return []

func remove_seed():
	#if seed != null:
	#	seed.unregister_seed_events(event_manager)
	seed_base_yield = 0
	seed_grow_time = 0
	current_grow_progress = 0.0
	current_yield = 0.0
	$PlantSprite.visible = false
	seed = null
	state = Enums.TileState.Empty

func irrigate():
	if !irrigated:
		irrigated = true
		if not_destroyed():
			$Farmland.modulate = COLOR_IRRIGATE
	elif Global.IRRIGATE_PROTECTED:
		protected = true
	var args: EventArgs.SpecificArgs = EventArgs.SpecificArgs.new(self)
	event_manager.notify_specific_args(EventManager.EventType.OnTileWatered, args)

func lose_irrigate():
	irrigated = false
	protected = false
	if not_destroyed():
		$Farmland.modulate = COLOR_NONE

func build_structure(n_structure: Structure, rotate):
	state = Enums.TileState.Structure
	var image_scale = (n_structure.texture.get_size() / Vector2(16, 16))
	structure = n_structure.copy()
	structure_rotate = rotate
	structure.register_events(event_manager, self)
	structure.grid_location = grid_location
	$PlantSprite.texture = n_structure.texture
	$PlantSprite.visible = true
	$PlantSprite.region_enabled = false
	var rest_position = $PlantSprite.position
	$PlantSprite.position += Vector2(0, -200)
	$PlantSprite.offset = Vector2(0, -8 * image_scale.y)
	$PlantSprite.scale = Vector2(5.7, 5.7) / image_scale

	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "position", rest_position, 0.6).set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func preview_harvest() -> EventArgs.HarvestArgs:
	if seed != null:
		return seed.get_yield(self)
	return EventArgs.HarvestArgs.new(current_yield, purple, false)

func do_winter_clear():
	if state == Enums.TileState.Growing or state == Enums.TileState.Mature or destroyed:
		state = Enums.TileState.Empty
		destroyed = false
		if seed != null:
			remove_seed()
		lose_irrigate()
		update_purple_overlay()
		update_display()
	elif structure != null:
		structure.do_winter_clear()

func multiply_yield(strength):
	on_yield_added.emit(self, current_yield * (strength - 1))
	current_yield *= strength

func add_yield(strength):
	current_yield += strength
	on_yield_added.emit(self, strength)

func set_blight_targeted(value):
	blight_targeted = value
	$BlightTargetOverlay.visible = value

func set_destroy_targeted(value):
	destroy_targeted = value
	$DestroyTargetOverlay.visible = value

func set_blighted():
	notify_destroyed()
	remove_seed()
	blighted = true
	$PlantSprite.visible = false
	$Farmland.modulate = COLOR_BLIGHTED
	$DestroyParticles.emitting = true

func destroy():
	on_event.emit()
	destroyed = true
	$Farmland.modulate = COLOR_DESTROYED
	notify_destroyed()
	notify_tile_destroyed()
	if seed != null:
		remove_seed()
	update_purple_overlay()
	$DestroyParticles.emitting = true
	state = Enums.TileState.Empty

func destroy_plant():
	state = Enums.TileState.Empty
	notify_destroyed()
	remove_seed()
	$DestroyParticles.emitting = true

func update_purple_overlay():
	$PurpleOverlay.visible = purple and state != Enums.TileState.Inactive and not_destroyed()

func get_harvest_event_args(delay: bool) -> EventArgs.HarvestArgs:
	var harvest_args: EventArgs.HarvestArgs = seed.get_yield(self)
	harvest_args.delay = harvest_args.delay or delay
	return harvest_args

func notify_destroyed():
	if seed != null:
		seed.notify(event_manager, EventManager.EventType.OnPlantDestroyed, EventArgs.SpecificArgs.new(self))
	event_manager.notify_specific_args(EventManager.EventType.OnPlantDestroyed,\
		EventArgs.SpecificArgs.new(self))

func notify_tile_destroyed():
	event_manager.notify_specific_args(EventManager.EventType.OnTileDestroyed,\
		EventArgs.SpecificArgs.new(self))

func remove_blight():
	blighted = false
	if structure != null:
		state = Enums.TileState.Structure
	else:
		state = Enums.TileState.Empty
	$Farmland.modulate = Color8(255, 255, 255)
	update_display()

func set_tile_size(n_size: Vector2):
	scale = n_size / Vector2(16, 16)
	$HarvestParticles.process_material.scale_min = 3.2
	$HarvestParticles.process_material.scale_max = 3.2
	$AddYieldParticles.process_material.scale_min = 2
	$AddYieldParticles.process_material.scale_max = 2
	$DestroyParticles.process_material.scale_min = 5
	$DestroyParticles.process_material.scale_max = 5
	$EffectParticles.process_material.scale_min = 1.5
	$EffectParticles.process_material.scale_max = 1.5
	
func remove_structure():
	structure.unregister_events(event_manager)
	structure = null
	$PlantSprite.visible = false
	state = Enums.TileState.Empty

func is_protected():
	return protected

func is_watered():
	return irrigated or Global.ALL_WATERED

func show_peek(weeks: int = 0):
	if !(state == Enums.TileState.Mature or state == Enums.TileState.Growing):
		return 0.0
	$PeekCont.visible = true
	var panel = $PeekCont
	
	var projected_mana = current_yield
	var water_bonus = 0.0
	var multiplier = 1.0
	if is_watered():
		multiplier += Global.WATERED_MULTIPLIER
		water_bonus = 1.0
	if seed_grow_time > 0:
		projected_mana += (seed_base_yield / seed_grow_time + water_bonus) * multiplier * min(weeks, seed_grow_time - current_grow_progress)

	var projected_state = Enums.TileState.Growing if current_grow_progress + weeks < seed_grow_time else Enums.TileState.Mature

	projected_mana = round(projected_mana)
	$PeekCont/CenterCont/PeekLabel.text = str(projected_mana)
	var corrupted = false
	if seed != null and seed.has_effect(Enums.EffectType.Corrupted):
		corrupted = true
		var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
		stylebox.set("bg_color", Color(Color.RED, 0.5))
		panel.add_theme_stylebox_override("panel", stylebox)
		return -projected_mana
	match projected_state:
		Enums.TileState.Growing:
			var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
			stylebox.set("bg_color", Color(Color.YELLOW, 0.5))
			panel.add_theme_stylebox_override("panel", stylebox)
			$PeekCont/CenterCont/PeekLabel.set("theme_override_colors/font_color", Color.BLACK)
			return 0
		Enums.TileState.Mature:
			var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
			stylebox.set("bg_color", Color(Color.GREEN, 0.5))
			panel.add_theme_stylebox_override("panel", stylebox)
			$PeekCont/CenterCont/PeekLabel.set("theme_override_colors/font_color", Color.BLACK)
			return projected_mana if !corrupted else -projected_mana
		_:
			$PeekCont.visible = false
	return 0


func hide_peek():
	$PeekCont.visible = false

func not_destroyed():
	return !destroyed and !blighted

func is_destroyed():
	return destroyed or blighted

func active_and_not_destroyed():
	return Enums.TileState.Inactive != state and not_destroyed

func card_can_target(card: CardData):
	if state == Enums.TileState.Inactive:
		return false
	var targets = []
	targets.assign(card.targets)
	if rock and !targets.has("Rock"):
		return false
	if card.type == "SEED" and targets.size() == 0:
		targets.append("Empty");
	if state == Enums.TileState.Empty and (targets.has("Destroyed") or targets.has("Blighted")):
		return is_destroyed() or targets.has("Empty") or (RockCoral.ACTIVE and is_watered())
	return (targets.has(Enums.TileState.keys()[state]))\
		and (!destroyed or state != Enums.TileState.Empty or targets.has("Destroyed"))\
		and (!blighted or state != Enums.TileState.Empty or targets.has("Blighted"))

func structure_can_target():
	return state != Enums.TileState.Structure and state != Enums.TileState.Inactive and !blighted

func play_effect_particles():
	$EffectParticles.emitting = true

func nudge():
	push_animate(Vector2(-3 * randf(), -3 * randf()))

func push_animate(vector: Vector2):
	push_vector = vector
	if push_tween != null:
		push_tween.kill()
		push_tween = null
	push_tween = create_tween()
	push_tween.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)\
		.tween_property(self, "push_vector", Vector2.ZERO, 0.4)

func get_id():
	return str(grid_location.x) + "-" + str(grid_location.y)

func save_data():
	var data = {}
	data.state = state
	data.current_yield = current_yield
	data.current_grow_progress = current_grow_progress
	data.seed_base_yield = seed_base_yield
	data.seed_grow_time = seed_grow_time
	if seed != null:
		data.seed = seed.save_data()
	data.irrigated = irrigated
	data.destroyed = destroyed
	data.rock = rock

func load_data(data: Dictionary):
	state = data.state
	current_yield = data.current_yield
	current_grow_progress = data.current_grow_progress
	seed_base_yield = data.seed_base_yield
	seed_grow_time = data.seed_grow_time
	if data.has("seed"):
		var s = load(data.seed.path).new()
		s.load_data(data.seed)
		seed = s
	irrigated = data.irrigated
	destroyed = data.destroyed
	rock = data.rock
