extends Node

var scene_data: Dictionary = {}

func change_scene(scene_path: String, data: Dictionary = {}) -> void:
	# If we going to final screen clean the world scene
	if scene_path == "res://scenes/final_screen.tscn":
		var current_scene = get_tree().current_scene
		current_scene.queue_free()
	scene_data = data
	await get_tree().create_timer(0.1).timeout # Small delay to ensure cleanup
	get_tree().change_scene_to_file(scene_path)
