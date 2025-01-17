extends Control

@onready var time_label: Label = $Time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var final_time = SceneManager.scene_data.get("final_time", 0.0)
	time_label.text = format_time(final_time)

func format_time(time: float) -> String:
	var msec = fmod(time, 1) * 100
	var sec = fmod(time, 60)
	var mins = time / 60
	var format_string = "%02d : %02d : %02d"
	var string = format_string % [mins, sec, msec]
	return string

func _on_continue_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")
