extends Control

@onready var world = $".."

func _on_resume_button_pressed() -> void:
	world.toggle_pause()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
