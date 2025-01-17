extends Control

@onready var popup_panel: PopupPanel = $PopupPanel
@onready var line_edit: LineEdit = $PopupPanel/VBoxContainer/Container/LineEdit

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	popup_panel.hide()

func _on_play_button_pressed() -> void:
	popup_panel.popup_centered()
	#SceneManager.change_scene("res://scenes/world.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	var seed_value = line_edit.text.strip_edges()
	var final_seed
	
	if seed_value.is_empty():
		final_seed = 0
	elif not seed_value.is_valid_int():
		line_edit.text = ""  # Clear invalid input
		#line_edit.placeholder_text = "Enter valid number!"
		return
	else:
		final_seed = seed_value.to_int()
	
	SceneManager.change_scene("res://scenes/world.tscn", {"seed": final_seed})
