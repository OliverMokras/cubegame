extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(_body: Node3D) -> void:
	# Get final time from HUD
	var hud = get_tree().get_first_node_in_group("hud")
	var final_time = hud.time
	hud.stopped = true
	# Change the scene
	SceneManager.change_scene("res://scenes/final_screen.tscn", {"final_time": final_time})
	#SceneManager.change_scene("res://scenes/main_menu.tscn")
