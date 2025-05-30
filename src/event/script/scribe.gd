extends CustomEvent

func _init():
	super._init("Scribe", "A halfling woman comes to visit your farm this winter. She is a humble scribe, who offers to copy one of your spells for you if you let her stay a few nights. You assume she must be crazy to venture into such dangerous territory armed with nothing but a quill and ink.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("Copy a card in your deck", null, func():
		user_interface.select_card_to_copy()
	)
	var option2 = CustomEvent.Option.new("Refuse the offer", null, func():
		user_interface.explore.show_window())
	return [option1, option2]

func check_prerequisites():
	return true
