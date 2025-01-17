extends SubViewport

@onready var brush: Node2D = $Brush

func paint(position : Vector2):
	brush.queue_brush(position * size.x) # Size = subviewport size
