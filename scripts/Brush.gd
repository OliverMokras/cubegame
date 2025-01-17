extends Node2D

@export var textures: Array[Texture2D] = []
@export var brush_size: float = 400.0

var brush_queue = []

func queue_brush(_position: Vector2):
	var random_texture = textures[randi() % textures.size()]
	brush_queue.push_back([_position, Color.WHITE, random_texture])
	queue_redraw()

func _draw():
	for b in brush_queue:
		draw_texture_rect(b[2], Rect2(b[0].x - brush_size/2.0, b[0].y - brush_size/2.0, brush_size, brush_size), false, b[1])
	brush_queue = []
