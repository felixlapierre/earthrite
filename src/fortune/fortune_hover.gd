extends Control
class_name FortuneHover

var offset = Vector2(30, 30)
@onready var fortune_display = $Fortune
@onready var fortune_name = $Fortune/VBox/Name
@onready var fortune_descr = $Fortune/VBox/Description
@onready var fortune_texture = $Fortune/VBox/Texture
@onready var button = $Panel/Margin/Button

var hover = false
var fortune: Fortune

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.register_click_callback(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hover:
		reposition()

func reposition():
	fortune_display.scale = Vector2.ONE
	fortune_display.global_position = get_global_mouse_position() + offset
	if fortune_display.global_position.x > 1300:
		fortune_display.global_position.x -= fortune_display.size.x + 10
	if fortune_display.global_position.y > 800:
		fortune_display.global_position.y -= fortune_display.size.y + 30

func setup(p_fortune: Fortune):
	fortune = p_fortune
	if fortune is MageAbility:
		fortune.update_text()
	fortune.popup_callback = popup_fortune
	$Fortune/VBox/Name.text = fortune.name
	$Fortune/VBox/Description.text = fortune.get_description()
	$Fortune/VBox/Texture.texture = fortune.texture
	$Panel/Margin/Button.texture_normal = fortune.texture
	if fortune.strength > 1.0:
		$Label.text = str(fortune.strength)
		$Label.visible = true
	else:
		$Label.visible = false

func setup_custom(name: String, text: String, texture: Texture2D, count: int):
	fortune_name.text = name
	fortune_descr.text = text
	fortune_texture.texture = texture
	button.texture_normal = texture
	if count > 0:
		$Label.text = str(count)
		$Label.visible = true
	else:
		$Label.visible = false

func setup_energy_fragments():
	var count = Global.ENERGY_FRAGMENTS
	var name = "Energy Fragment" + ("s" if count > 0 else "")
	var desc = "Each fragment grants one energy every 1 out of 3 turns"
	var texture = load("res://assets/custom/EnergyFrag.png")
	setup_custom(name, desc, texture, count)

func setup_card_fragments():
	var count = Global.SCROLL_FRAGMENTS
	var name = "Card Fragment" + ("s" if count > 0 else "")
	var desc = "Each fragment grants one extra card draw every 1 out of 3 turns"
	var texture = load("res://assets/custom/CardFragment.png")
	setup_custom(name, desc, texture, count)

func _on_button_mouse_entered() -> void:
	if !Settings.CLICK_MODE and !fortune_display.visible:
		fortune_display.visible = true
		hover = true

func _on_button_mouse_exited() -> void:
	if !Settings.CLICK_MODE and hover == true:
		fortune_display.visible = false
		hover = false

func _on_button_pressed() -> void:
	if Settings.CLICK_MODE:
		fortune_display.visible = true
		reposition()

func on_other_clicked():
	fortune_display.visible = false

func popup_fortune(visible: bool):
	fortune_display.visible = true

	var base_position = global_position
	var target_position = Vector2(250, 50) if fortune.type == Fortune.FortuneType.GoodFortune else Vector2(1400, 50)
	var base_scale = Vector2.ZERO
	var target_scale = Vector2.ONE

	fortune_display.scale = base_scale if visible else target_scale
	fortune_display.global_position = base_position if visible else target_position
	create_tween().tween_property(fortune_display, "scale", target_scale if visible else base_scale, 0.3).set_ease(Tween.EASE_IN)
	create_tween().tween_property(fortune_display, "global_position", target_position if visible else base_position, 0.3).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(1.0).timeout
	fortune_display.visible = visible
