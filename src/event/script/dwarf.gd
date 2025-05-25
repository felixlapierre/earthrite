extends CustomEvent

func _init():
	super._init("Dwarf", "You are rudely awoken one day by the sound of your cottage's entire floor shaking as though from an earthquake. After a short investigation, you find the cause to be the impossibly loud snoring of a dwarf in your cellar. He seems to have helped himself to one of the kegs of ancient fruit wine.\n\nThough you seem unable to communicate due to the language barrier, you eventually figure out what he's trying to offer you as repayment for the stolen wine.")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_options():
	var option1 = CustomEvent.Option.new("I dig",\
	OptionPreview.instantiate().text_preview("Expand your farm"), func():
		user_interface.on_expand_farm()
	)
	var option2 = CustomEvent.Option.new("No dig",\
	OptionPreview.instantiate().text_preview("No dig"), func(): 
		user_interface.explore.show_window())
	return [option1, option2]

func check_prerequisites():
	return Helper.can_expand_farm()
