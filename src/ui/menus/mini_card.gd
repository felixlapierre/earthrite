extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(card: CardData):
	if card.type == "SEED":
		var texture = AtlasTexture.new()
		if card.texture != null:
			texture.atlas = card.texture
			texture.set_region(Rect2(Vector2(texture.get_width() - 16, card.texture_icon_offset), Vector2(16, 16)))
		else:
			texture.atlas = load("res://assets/1616tinygarden/objects.png")
			texture.set_region(Rect2(Vector2(card.seed_texture * 16, 0), Vector2(16, 16)))
		$Texture.texture = texture
	else:
		$Texture.texture = card.texture
	var db_enhances = DataFetcher.get_all_enhance()
	for i in range(card.enhances.size()):
		for enh in db_enhances:
			if card.enhances[i].name == enh.name:
				var texture = enh.texture
				if i == 0:
					$Enhance1.texture = texture
				elif i == 1:
					$Enhance2.texture = texture

	$Label.text = card.name

func setup_structure(structure: Structure):
	$Texture.texture = structure.texture
	$Label.text = structure.name
