extends Node2D
class_name DrawLine

var start: Vector2
var end: Vector2
var color: Color
func setup(p_start = Vector2.ZERO, p_end = Vector2.ZERO, p_color = Color.BLACK):
	start = p_start
	end = p_end
	color = p_color

func _draw():
	draw_line(start, end, color, 8.0)
