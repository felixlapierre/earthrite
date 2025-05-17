extends Node2D

var spring1 = Color8(199, 183, 101)
var spring2 = Color8(161, 199, 101)
var summer = Color8(67, 163, 84)
var fall = Color8(186, 199, 101)
var winter = Color8(226, 226, 226)

var ground_tween_time = 1.0

var trees = []
var snows = []

var ts_spring1 = preload("res://assets/farm/tileset-seasons2.png")
var ts_spring2 = preload("res://assets/farm/tileset-seasons4.png")
var ts_summer = preload("res://assets/farm/tileset-seasons5.png")
var ts_summer_end = preload("res://assets/farm/tileset-seasons6.png")
var ts_fall_tr1 = preload("res://assets/farm/tileset-seasons7.png")
var ts_fall_tr2 = preload("res://assets/farm/tileset-seasons8.png")
var ts_fall = preload("res://assets/farm/tileset-seasons9.png")
var ts_winter_tr1 = preload("res://assets/farm/tileset-seasons10.png")
var ts_winter_tr2 = preload("res://assets/farm/tileset-seasons11.png")
var ts_winter_tr3 = preload("res://assets/farm/tileset-seasons12.png")
var ts_winter_tr4 = preload("res://assets/farm/tileset-seasons13.png")
var ts_winter = preload("res://assets/farm/tileset-seasons14.png")
var ts_winter_night = preload("res://assets/farm/tileset-seasons15.png")

var Glow = preload("res://src/animation/glow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ground.modulate = spring1
	$Ground.visible = true
	$Blightroots.play("none")
	trees = [$Tree, $Tree2, $Tree3]
	snows = [$Snow1, $Snow2, $Snow3, $Snow4, $Snow5]
	$RitualComplete.play("hidden")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func do_week(week: int):
	do_ground(week)
	do_trees(week)
	do_snow(week)
	if week == 1:
		set_snow_visible(false)
	pass
	
func do_snow(week: int):
	var animation = null
	match week:
		1:
			animation = "spring1"
		2:
			animation = "spring2"
		13:
			animation = "winter"
	if animation != null:
		for snow in snows:
			snow.play(animation)

func do_winter(current_week: int):
	do_ground(13)
	var animation = "skip-spring1"
	var tween = create_tween()
	match current_week:
		1:
			animation = "skip-spring1"
			for snow in snows:
				snow.play("spring2")
			tween.tween_property($Ground, "modulate", spring2, 0.5)
			tween.tween_property($Ground, "modulate", summer, 0.5)
			tween.tween_property($Ground, "modulate", fall, 0.5)
			tween.tween_property($Ground, "modulate", winter, 0.5)
		2:
			animation = "skip-spring2"
			tween.tween_property($Ground, "modulate", summer, 0.5)
			tween.tween_property($Ground, "modulate", fall, 0.5)
			tween.tween_property($Ground, "modulate", winter, 0.5)
		3, 4, 5, 6, 7, 8, 9:
			animation = "skip-summer"
			tween.tween_property($Ground, "modulate", fall, 0.5)
			tween.tween_property($Ground, "modulate", winter, 0.5)
		10, 11, 12:
			animation = "winter"
			tween.tween_property($Ground, "modulate", winter, 1.0)
		_:
			animation = "winter2"
			$Ground.modulate = winter
	if current_week <= 12:
		tween.tween_callback(func(): 
			do_snow(13)
			set_snow_visible(true))
	for tree in trees:
		tree.play(animation)


func load_winter():
	$Ground.modulate = winter
	for tree in trees:
		tree.play("winter2")
	set_snow_visible(true)
	set_background_texture(load("res://assets/1616tinygarden/tileset-winter.png"))

func do_trees(week: int):
	var animation = null
	if week == 1:
		animation = "spring1"
	elif week == 2:
		animation = "spring2"
	elif week == 3:
		animation = "summer"
	elif week == Global.FALL_WEEK - 1:
		animation = "pre-fall"
	elif week == Global.FALL_WEEK:
		animation = "fall"
	elif week == Global.WINTER_WEEK - 1:
		animation = "pre-winter"
	elif week == Global.WINTER_WEEK:
		animation = "winter"
	if animation != null:
		for tree in trees:
			tree.play(animation)
	pass

func do_ground(week: int):
	var color = spring1
	if week == 1:
		color = spring1
	elif week < Global.SUMMER_WEEK:
		color = spring2
	elif week < Global.FALL_WEEK:
		color = summer
	elif week < Global.WINTER_WEEK:
		color = fall
	else:
		color = winter
	var tween = create_tween()
	tween.tween_property($Ground, "modulate", color, ground_tween_time)

func set_background_texture(texture: Texture2D):
	if texture != null:
		var tileset: TileSet = $TileMap.tile_set
		var src: TileSetAtlasSource = tileset.get_source(0)
		src.texture = texture

func animate_blightroots(animation: String):
	$Blightroots.play(animation)

func set_background_winter(week: int):
	var sequence = [ts_spring1, ts_spring2, ts_summer, ts_summer_end, ts_fall_tr1, ts_fall_tr2, ts_fall, ts_winter_tr1, ts_winter_tr2, ts_winter_tr3, ts_winter_tr4, ts_winter]
	var start
	if week == 1:
		start = 1
	elif week == 2:
		start = 2
	elif week < Global.FALL_WEEK - 1:
		start = 3
	elif week < Global.FALL_WEEK:
		start = 4
	elif week < Global.WINTER_WEEK - 1:
		start = 7
	elif week < Global.WINTER_WEEK:
		start = 8
	else:
		start = 11
	for i in range(start, sequence.size()):
		get_tree().create_timer(0.1 * i).timeout.connect(func():
			set_background_texture(sequence[i]))
	do_week(week)

func set_background(week: int):
	var texture
	if week == 1:
		texture = ts_spring1
	elif week == 2:
		texture = ts_spring1
	elif week < Global.FALL_WEEK - 1:
		texture = ts_summer
	elif week < Global.FALL_WEEK:
		texture = ts_summer_end
	elif week == Global.FALL_WEEK:
		texture = ts_fall_tr1
		get_tree().create_timer(0.3).timeout.connect(func():
			set_background_texture(ts_fall_tr2))
		get_tree().create_timer(0.6).timeout.connect(func():
			set_background_texture(ts_fall))
	elif week == Global.WINTER_WEEK - 1:
		texture = ts_winter_tr1
	elif week == Global.WINTER_WEEK:
		texture = ts_winter_tr2
		get_tree().create_timer(0.3).timeout.connect(func():
			set_background_texture(ts_winter_tr3))
		get_tree().create_timer(0.6).timeout.connect(func():
			set_background_texture(ts_winter_tr4))
		get_tree().create_timer(0.9).timeout.connect(func():
			set_background_texture(ts_winter))
	do_week(week)
	set_background_texture(texture)

func ritual_complete():
	$RitualComplete.play("default")
	$RitualParticles.emitting = true

func set_snow_visible(value: bool):
	$SnowParticles.visible = value
