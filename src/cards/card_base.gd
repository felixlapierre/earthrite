extends MarginContainer
class_name CardBase

var card_info;
var card_image = "res://assets/1616tinygarden/objects.png"
var card_database
var card_size = Vector2(200, 280)

var starting_position # For animating movement, start position of the card
var target_position # For animating movement, position card should end up at
var resting_position: Vector2 # Card comes back to rest at this position when we need to unfocus etc

var starting_scale: Vector2 # For animating scale, start scale
var resting_scale = Vector2(1, 1)
var target_scale;

var starting_rotation = 0
var target_rotation = 0
var resting_rotation = 0

var ZoomInSize = 1.8
var t = 0

var tween

var number_of_cards_in_hand = 0
var card_number_in_hand = 0;

var DRAWTIME = 0.5
var ZOOMTIME = 0.3
var HAND_TOP_Y

var state = Enums.CardState.InHand

signal on_clicked
var tooltip: Tooltip

var CARD_ICON
var SIZE_LABEL

var frozen = false

@onready var COST_LABEL = $HBoxContainer/VBoxContainer/TopBar/CardCostLabel
@onready var COST_TEXTURE = $HBoxContainer/VBoxContainer/TopBar/TextureRect
@onready var SIZE_CONTAINER = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/SizeCont
@onready var DESCRIPTION_LABEL = $HBoxContainer/VBoxContainer/DescriptionLabel #also hardcoded
@onready var YIELD_TEXTURE = $HBoxContainer/VBoxContainer/BottomBar/YieldTexture
@onready var YIELD_LABEL = $HBoxContainer/VBoxContainer/BottomBar/YieldLabel
@onready var TIME_LABEL = $HBoxContainer/VBoxContainer/BottomBar/TimeLabel
@onready var TIME_TEXTURE = $HBoxContainer/VBoxContainer/BottomBar/TimeTexture
@onready var HIGHLIGHT = $Highlight
@onready var FOCUS = $Focus

var ChevronTexture = preload("res://assets/custom/EnhanceChevron.png")
var BorderUncommon = preload("res://assets/ui/border_common.png")
var BorderRare = preload("res://assets/ui/border_uncommon.png")
var BorderUnique = preload("res://assets/ui/border_unique.png")
var BorderBlight = preload("res://assets/ui/border_blight.png")
var BorderLegendary = preload("res://assets/ui/border_legend.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var card_size = size
	HAND_TOP_Y = Constants.VIEWPORT_SIZE.y - card_size.y
	$Focus.scale *= card_size / $Focus.size
	register_tooltips()

func set_card_info(card_data):
	card_info = card_data
	if card_data.rarity == 'uncommon':
		$CardBorder.texture = BorderUncommon
	elif card_data.rarity == 'rare':
		$CardBorder.texture = BorderRare
	elif card_data.rarity == 'unique':
		$CardBorder.texture = BorderUnique
	elif card_data.rarity == 'blight':
		$CardBorder.texture = BorderBlight
	elif card_data.rarity == 'legendary':
		$CardBorder.texture = BorderLegendary
	CARD_ICON = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/CardIconCont/CardIcon
	SIZE_LABEL = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/SizeCont/SizeLabel
	match card_info.type:
		"SEED":
			var texture = AtlasTexture.new()
			if card_data.texture != null:
				texture.atlas = card_data.texture
				texture.set_region(Rect2(Vector2(texture.get_width() - 16, card_info.texture_icon_offset), Vector2(16, 16)))
			else:
				texture.atlas = load("res://assets/1616tinygarden/objects.png")
				texture.set_region(Rect2(Vector2(card_data.seed_texture * 16, 0), Vector2(16, 16)))
			CARD_ICON.texture = texture
			var corrupted = card_data.has_effect(Enums.EffectType.Corrupted)
			var negative = "-" if corrupted else ""

			$HBoxContainer/VBoxContainer/TopBar/CardCostLabel.visible = card_info.cost != 99
			$HBoxContainer/VBoxContainer/TopBar/TextureRect.visible = card_info.cost != 99
			$HBoxContainer/VBoxContainer/BottomBar/YieldTexture.visible = card_info.yld > 0
			$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.visible = card_info.yld > 0
			$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.visible = card_info.time != 99
			$HBoxContainer/VBoxContainer/BottomBar/TimeTexture.visible = card_info.time != 99
			$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.visible = card_info.time != 99
			var total_yield_text = " (" + negative + str(card_info.yld * card_info.size) + ")" if card_info.size != -1 else ""
			var yield_text = negative + str(card_info.yld)\
				+ total_yield_text
			if card_info.has_enhance_type(Enhance.Type.Mana):
				yield_text = "[color=aqua]" + yield_text
			elif card_info.has_effect(Enums.EffectType.Corrupted):
				yield_text = "[color=tomato]" + yield_text
			$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.text = yield_text
			var time_text = str(card_info.time)

			if card_info.has_enhance_type(Enhance.Type.GrowSpeed):
				time_text = "[color=aqua][right]" + time_text + "[/right][/color]"
			$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.text = time_text
			if corrupted:
				$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.set("theme_override_colors/font_color", Color(1.0, 0.0, 0.0, 1.0))
			else:
				$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.set("theme_override_colors/font_color", Color(1.0, 1.0, 1.0, 1.0))
		"ACTION", "STRUCTURE":
			CARD_ICON.texture = card_info.texture
			$HBoxContainer/VBoxContainer/BottomBar/YieldLabel.visible = false
			$HBoxContainer/VBoxContainer/BottomBar/YieldTexture.visible = false
			$HBoxContainer/VBoxContainer/BottomBar/TimeLabel.visible = false
			$HBoxContainer/VBoxContainer/BottomBar/TimeTexture.visible = false
	if card_info.type == "SEED":
		$CardBorder.modulate = Color8(202, 255, 191)
	elif card_info.type == "ACTION":
		$CardBorder.modulate = Color8(255, 213, 186)
	if card_data.has_effect(Enums.EffectType.Fleeting):
		$CardBorder.self_modulate.a = 0.8
	$HBoxContainer/VBoxContainer/BottomBar/TypeLabel.text = card_info.type
	$HBoxContainer/VBoxContainer/TopBar/CardNameLabel.text = card_info.name
	var cost_label = str(card_info.cost if card_info.cost >= 0 else "X")
	cost_label = ("" if card_info.cost == 99 else cost_label)
	$HBoxContainer/VBoxContainer/TopBar/TextureRect.visible = card_info.cost != 99
	if card_data.type != "STRUCTURE" and card_data.has_enhance_type(Enhance.Type.Discount):
		cost_label = "[color=aqua]" + cost_label + "[/color]"
	$HBoxContainer/VBoxContainer/TopBar/CardCostLabel.text = cost_label
	$HBoxContainer/VBoxContainer/DescriptionLabel.text = card_info.get_description()
	card_info.updated.connect(func():
		$HBoxContainer/VBoxContainer/DescriptionLabel.text = card_info.get_description()
		var description_tooltip = card_info.get_long_description()
		if description_tooltip.length() > 0 and tooltip != null and DESCRIPTION_LABEL != null:
			tooltip.register_tooltip(DESCRIPTION_LABEL, description_tooltip)
			if state != Enums.CardState.InMouse:
				tooltip.register_tooltip($Focus, description_tooltip)
	)
	
	if card_info.size == 0:
		$HBoxContainer/VBoxContainer/ImageMargin/ImageCont/SizeCont.visible = false
	else:
		var size_text = str(card_info.size) if card_info.size != -1 else "All"
		if card_info.type != "STRUCTURE" and card_info.has_enhance_type(Enhance.Type.Size):
			size_text = "[color=aqua]" + size_text
		SIZE_LABEL.text = size_text
	if card_info.type == "SEED" or card_info.type == "ACTION":
		var chev1 = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/VBox/Chev1
		var chev2 = $HBoxContainer/VBoxContainer/ImageMargin/ImageCont/VBox/Chev2
		chev1.texture = AtlasTexture.new()
		chev1.texture.set_atlas(ChevronTexture)
		chev2.texture = AtlasTexture.new()
		chev2.texture.set_atlas(ChevronTexture)
		if card_info.enhances.size() > 0:
			chev1.texture.set_region(Rect2(16, 0, 16, 16))
		else:
			chev1.texture.set_region(Rect2(0, 0, 16, 16))
		chev2.visible = Mastery.less_enhance() == 0
		if card_info.enhances.size() > 1:
			chev2.texture.set_region(Rect2(16, 0, 16, 16))
		else:
			chev2.texture.set_region(Rect2(0, 0, 16, 16))
	register_tooltips()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		Enums.CardState.InShop:
			pass
		Enums.CardState.InHand:
			pass
		Enums.CardState.InPlay:
			pass
		Enums.CardState.InMouse:
			target_position = Constants.VIEWPORT_SIZE / Vector2(14, 4)
			scale = resting_scale * 1.7
			target_scale = scale
			process_move_linear(delta, 0.1)
		Enums.CardState.FocusInHand:
			process_move_linear(delta, ZOOMTIME/2)
		Enums.CardState.MoveDrawnCardToHand:
			if t > 1:
				state = Enums.CardState.InHand
			process_move_linear(delta, DRAWTIME)
		Enums.CardState.ReOrganiseHand:
			$Focus.visible = true
			if t > 1:
				state = Enums.CardState.InHand
			process_move_linear(delta, 0.3)
		Enums.CardState.MoveToDiscard:
			if t > 1:
				$"../../".finish_discard(self)
			process_move_linear(delta, 0.5)

func reset_starting_position():
	starting_position = position
	starting_rotation = rotation
	starting_scale = scale
	t = 0

func Reset_Card(card_number_in_hand):
	var neighbor_card = $'../'.get_child(card_number_in_hand)
	# Allows mousing directly from one card to another
	if neighbor_card != null and neighbor_card.state != Enums.CardState.FocusInHand\
		and neighbor_card.state != Enums.CardState.InMouse:
		neighbor_card.state = Enums.CardState.ReOrganiseHand
		neighbor_card.target_position = neighbor_card.resting_position
		neighbor_card.reset_starting_position()

func _on_focus_mouse_entered() -> void:
	match state:
		Enums.CardState.InHand, Enums.CardState.ReOrganiseHand:
			var new_position = resting_position
			new_position.y = Constants.VIEWPORT_SIZE.y - card_size.y*ZoomInSize*0.9
			set_state(Enums.CardState.FocusInHand, new_position, 0, resting_scale * ZoomInSize)
			move_neighbors()


func _on_focus_mouse_exited() -> void:
	match state:
		Enums.CardState.FocusInHand:
			set_state(Enums.CardState.ReOrganiseHand, resting_position, resting_rotation, resting_scale)
			reset_neighbors()

func move_neighbors():
	number_of_cards_in_hand = $'../../'.number_of_cards_in_hand - 1
	if card_number_in_hand - 1 >= 0:
		move_neighbor_card(card_number_in_hand - 1, true, 1) #true is left
	if card_number_in_hand - 2 >= 0:
		move_neighbor_card(card_number_in_hand - 2, true, 0.25) #true is left
	if card_number_in_hand + 1 <= number_of_cards_in_hand:
		move_neighbor_card(card_number_in_hand + 1, false, 1)
	if card_number_in_hand + 2 <= number_of_cards_in_hand:
		move_neighbor_card(card_number_in_hand + 2, false, 0.25)
		
func reset_neighbors():
	if card_number_in_hand - 1 >= 0:
		Reset_Card(card_number_in_hand - 1) #true is left
	if card_number_in_hand - 2 >= 0:
		Reset_Card(card_number_in_hand - 2) #true is left
	if card_number_in_hand + 1 <= number_of_cards_in_hand:
		Reset_Card(card_number_in_hand + 1)
	if card_number_in_hand + 2 <= number_of_cards_in_hand:
		Reset_Card(card_number_in_hand + 2)

func move_neighbor_card(card_number_in_hand, Left, SpreadFactor):
	var neighbor_card = $'../'.get_child(card_number_in_hand)
	if neighbor_card.state == Enums.CardState.InMouse:
		return
	var new_position;
	if Left:
		new_position = neighbor_card.resting_position - SpreadFactor*Vector2(65,0)
	else:
		new_position = neighbor_card.resting_position + SpreadFactor*Vector2(65,0)
	neighbor_card.set_state(Enums.CardState.ReOrganiseHand, new_position, null, null)

func set_state(new_state, new_position, new_rotation, new_scale):
	starting_position = position
	starting_rotation = rotation
	starting_scale = scale
	t = 0
	if new_position != null:
		target_position = new_position
	if new_scale != null:
		target_scale = new_scale
	if new_rotation != null:
		target_rotation = new_rotation
	state = new_state
	
func set_new_resting_position(new_position, new_rotation):
	resting_position = new_position
	resting_rotation = new_rotation
	
func move_using_tween(time):
	var trans = Tween.TRANS_CUBIC
	if tween:
		tween.kill()
		trans = Tween.EASE_OUT
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, time).set_trans(trans)
	

func process_move_linear(delta, totaltime):
	if t <= 1: # Interpolate uses a scale from 0 to 1, so this is always 1
		if !tween:
			position = starting_position.lerp(target_position, t)
		rotation = starting_rotation * (1-t) + target_rotation * t
		t += delta/float(totaltime) # DRAWTIME is in seconds
		scale = starting_scale * (1-t) + target_scale*t
	else:
		position = target_position
		rotation = target_rotation
		scale = target_scale
		if tween:
			tween.kill()
			tween = null


func _on_focus_gui_input(event: InputEvent) -> void:
	if !FOCUS.disabled and event.is_action_pressed("leftclick"):
		on_card_clicked()

func on_card_clicked():
	match state:
		Enums.CardState.FocusInHand, Enums.CardState.InHand:
			set_state(Enums.CardState.InMouse, null, 0, resting_scale)
			Global.selected_card = card_info
			Global.shape = Enums.CursorShape.Smart
			Global.rotate = 0
			reset_hand_card()
		Enums.CardState.InMouse:
			set_state(Enums.CardState.ReOrganiseHand, resting_position, resting_rotation, resting_scale)
			Global.selected_card = null
			reset_neighbors()
		Enums.CardState.InShop:
			pass
	on_clicked.emit(self)

func reset_hand_card():
	var cards = $'../'.get_children()
	for card in cards:
		if card.state == Enums.CardState.InMouse and card != self:
			card.set_state(Enums.CardState.ReOrganiseHand, card.resting_position, card.resting_rotation, card.resting_scale)
			card.reset_starting_position()

func _input(event: InputEvent) -> void:
	if state == Enums.CardState.InMouse and event.is_action_pressed("rightclick"):
		set_state(Enums.CardState.ReOrganiseHand, resting_position, resting_rotation, resting_scale)
		reset_neighbors()
		Global.selected_card = null
		$Focus.visible = true

func register_tooltips():
	if tooltip == null or SIZE_CONTAINER == null:
		return
	if card_info.type == "SEED":
		tooltip.register_tooltip(SIZE_CONTAINER, tr("SIZE_TOOLTIP_SEED").format({"size": card_info.size}))
	elif card_info.type == "ACTION":
		tooltip.register_tooltip(SIZE_CONTAINER, tr("SIZE_TOOLTIP_ACTION").format({"size": card_info.size}))
	tooltip.register_tooltip(COST_LABEL, tr("CARD_ENERGY_COST_TOOLTIP").format({"cost": card_info.cost}))
	tooltip.register_tooltip(COST_TEXTURE, tr("CARD_ENERGY_COST_TOOLTIP").format({"cost": card_info.cost}))
	tooltip.register_tooltip(YIELD_LABEL, tr("CARD_YIELD_TOOLTIP").format({
		"yield": card_info.yld,
		"size": card_info.size,
		"total_yield": card_info.yld * card_info.size
	}))
	tooltip.register_tooltip(YIELD_TEXTURE, tr("CARD_YIELD_TOOLTIP").format({
		"yield": card_info.yld,
		"size": card_info.size,
		"total_yield": card_info.yld * card_info.size
	}))
	tooltip.register_tooltip(TIME_LABEL, tr("CARD_DURATION_TOOLTIP").format({
		"duration": card_info.time
	}))
	tooltip.register_tooltip(TIME_TEXTURE, tr("CARD_DURATION_TOOLTIP").format({
		"duration": card_info.time
	}))
	var description_tooltip = card_info.get_long_description()
	if description_tooltip.length() > 0:
		tooltip.register_tooltip(DESCRIPTION_LABEL, description_tooltip)
		if state != Enums.CardState.InMouse:
			tooltip.register_tooltip($Focus, description_tooltip)

func set_highlight(value: bool):
	HIGHLIGHT.visible = value
	HIGHLIGHT.play("default")

func set_burn_targeted(value: bool):
	$BurnSelected.visible = value
	$BurnSelected.play("default")

func set_disabled(value: bool):
	FOCUS.disabled = value

func do_passive_effects(event_manager_optional = null):
	for effect2 in card_info.effects2:
		if effect2.effect_type == Enums.EffectType.Passive:
			effect2.owner = card_info
			if event_manager_optional != null:
				effect2.register(event_manager_optional, null)
			effect2.do_passive_effect()

func play_effect_particles():
	$EffectParticles.emitting = true

func play_burn_particles():
	$BurnParticles.emitting = true
