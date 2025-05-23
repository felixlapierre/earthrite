extends AttackPattern
class_name EmptyAttackPattern

func register_fortunes(event_manager: EventManager, week: int):
	pass

func unregister_fortunes(event_manager: EventManager):
	pass

func compute_blight_pattern(chart: Chart, year: int):
	blight_pattern = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
