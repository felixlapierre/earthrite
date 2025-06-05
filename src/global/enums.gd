class_name Enums

enum CursorShape {
	Smart,
	Square,
	Line,
	Elbow
}

enum TileState {
	Empty,
	Growing,
	Mature,
	Structure,
	Inactive
}

enum CardState {
	InHand,
	InPlay,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReOrganiseHand,
	MoveToDiscard,
	InShop
}

enum AnimOn {
	Mouse,
	Tiles,
	Center
}

enum EffectType {
	Draw,
	Harvest,
	Grow,
	Spread,
	AddMana,
	GainMana,
	DestroyPlant,
	DestroyTile,
	Other,
	Protect,
	Water,
	Burn,
	Plant,
	Regrow,
	GainEnergy,
	Fleeting
}

enum MultiplayerGameType {
	Versus,
	Cooperative
}
