extends Node2D
class_name AttackPreview

@onready var PromptLabel = $CurrentTurn/VBox/PromptLabel
@onready var AmountLabel = $CurrentTurn/VBox/HBox/AmountLabel
@onready var AttackParticles = $CurrentTurn/AttackParticles
@onready var AttackImg = $CurrentTurn/VBox/HBox/Attack
@onready var Fortunes = $CurrentTurn/VBox/Margin/Fortunes
var FutureTurnPreview = preload("res://src/attack/future_turn_preview.tscn")
var FortuneHover = preload("res://src/fortune/fortune_hover.tscn")

var turn_manager: TurnManager
var mage_fortune: Fortune
var attack: AttackPattern

signal on_peek_week

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.register_click_callback(self)

func setup(p_turn_manager: TurnManager, p_mage_fortune: Fortune, event_manager: EventManager):
	turn_manager = p_turn_manager
	mage_fortune = p_mage_fortune
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, func(args):
		next_week())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	AttackParticles.emitting = false
	AttackImg.modulate = Color8(94, 102, 115)
	if turn_manager.target_blight > 0:
		AmountLabel.text = str(turn_manager.purple_mana) + " / " + str(turn_manager.target_blight)
	else:
		AmountLabel.text = str(turn_manager.purple_mana)
	if turn_manager.purple_mana < turn_manager.target_blight:
		PromptLabel.text = "Blight Attack!"
		AttackParticles.emitting = true
		AttackImg.modulate = Color8(255, 255, 255)
	elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.flag_defer_excess:
		PromptLabel.text = "Defer: " + str(turn_manager.purple_mana - turn_manager.target_blight) + Helper.blue_mana()
	elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.target_blight == 0 and Global.FARM_TYPE != "LUNARTEMPLE":
		PromptLabel.text = "Wasted"
	elif turn_manager.purple_mana > turn_manager.target_blight and Global.FARM_TYPE == "LUNARTEMPLE":
		PromptLabel.text = "Excess: " + str(ceil((turn_manager.purple_mana - turn_manager.target_blight) * 0.7)) + Helper.mana_icon()
	else:
		PromptLabel.text = "Safe!"

func yield_preview(args):
	var yellow = args.yellow
	var purple = args.purple
	var blightamt = turn_manager.purple_mana + purple
	if purple != 0:
		var color = "[color=aquamarine]" if blightamt > turn_manager.target_blight\
			else "[color=white]"
		AmountLabel.text = color + str(blightamt) + " / " + str(turn_manager.target_blight)
	else:
		AmountLabel.text = str(turn_manager.purple_mana) + " / " + str(turn_manager.target_blight)


func set_attack(p_attack: AttackPattern):
	if p_attack == null:
		return
	attack = p_attack
	var pattern = attack.get_blight_pattern()
	var fortunes = attack.get_fortunes()
	for child in $NextTurns/List.get_children():
		$NextTurns/List.remove_child(child)
	for i in range(1, Global.FINAL_WEEK):
		var preview = FutureTurnPreview.instantiate()
		preview.setup(i, pattern[i], fortunes[i])
		preview.selected.connect(func(week):
			on_peek_week.emit(week))
		$NextTurns/List.add_child(preview)
		var last_visible = 3 if !Mastery.hide_preview() else 1
		if i > last_visible:
			preview.visible = false
	update_fortunes(fortunes[0])

func next_week():
	var next = $NextTurns/List.get_child(0)
	$NextTurns/List.remove_child(next)
	var i = 0
	for preview in $NextTurns/List.get_children():
		preview.decrement_week()
		preview.visible = i <= 2 if !Mastery.hide_preview() else i == 0
		i += 1
	
	var fortunes = attack.fortunes[turn_manager.week % attack.fortunes.size()]
	update_fortunes(fortunes)
	update()

func update_fortunes(fortunes: Array[Fortune]):
	for node in Fortunes.get_children():
		Fortunes.remove_child(node)
	for fortune in fortunes:
		var hover = FortuneHover.instantiate()
		Fortunes.add_child(hover)
		hover.setup(fortune)

# Disconnected
func _on_next_turns_mouse_entered():
	if false:#!Settings.CLICK_MODE:
		show_full_preview()

# Disconnected
func _on_next_turns_mouse_exited():
	if false:#!Settings.CLICK_MODE:
		hide_full_preview()

# Disconnected
func _on_list_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick") and true:#Settings.CLICK_MODE:
		show_full_preview()

func on_other_clicked():
	hide_full_preview()
	on_peek_week.emit(-1)

func show_full_preview():
	if Mastery.hide_preview(): return
	for i in range(0, $NextTurns/List.get_child_count()):
		if i < 9:
			$NextTurns/List.get_child(i).visible = true
	
func hide_full_preview():
	if Mastery.hide_preview(): return
	for i in range(0, $NextTurns/List.get_child_count()):
		if i > 2:
			$NextTurns/List.get_child(i).visible = false
