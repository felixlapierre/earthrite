extends PanelContainer

var FortuneHover = preload("res://src/fortune/fortune_hover.tscn")

var m_week = 0
signal selected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(week: int, attack: int, fortunes: Array[Fortune]):
	m_week = week
	for fortune in $VBox/Attack/Fortunes.get_children():
		$VBox/Attack/Fortunes.remove_child(fortune)
	$VBox/Attack/Turns.text = str(week)
	$VBox/Attack/Attack.clear()
	if attack == 0:
		$VBox/Attack/Attack.append_text("[color=dimgray]")
	$VBox/Attack/Attack.append_text(str(attack))
	$VBox/Attack/AttackImg.visible = attack > 0
	for fortune in fortunes:
		var hover = FortuneHover.instantiate()
		$VBox/Attack/Fortunes.add_child(hover)
		hover.setup(fortune)

func decrement_week():
	m_week -= 1
	var turn = int($VBox/Attack/Turns.text) - 1
	$VBox/Attack/Turns.text = str(turn)


func _on_gui_input(event):
	if event.is_action_pressed("leftclick") and Settings.CLICK_MODE:
		selected.emit(m_week)


func _on_attack_mouse_entered():
	if !Settings.CLICK_MODE:
		selected.emit(m_week)


func _on_attack_mouse_exited():
	if !Settings.CLICK_MODE:
		selected.emit(-1)
