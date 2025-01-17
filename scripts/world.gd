extends Node3D

var player = preload("res://scenes/player.tscn")
var server_scene = preload("res://scenes/server.tscn")
var finish = preload("res://scenes/finish.tscn")

@onready var grid_map: GridMap = $GridMap
@onready var game_menu: Control = $GameMenu
@onready var hud = get_tree().get_first_node_in_group("hud")

# Forward the signals from server
signal jump_signal
signal move_forward
signal move_backward
signal move_left
signal move_right
signal stop_signal

func _ready() -> void:
	game_menu.hide()
	grid_map.maze_done.connect(_on_maze_generated)
	# Instantiate server
	var server_instance = server_scene.instantiate()
	add_child(server_instance)
	
	# Connect server signals to world signals
	server_instance.move_forward.connect(func(): move_forward.emit())
	server_instance.move_backward.connect(func(): move_backward.emit())
	server_instance.move_left.connect(func(): move_left.emit())
	server_instance.move_right.connect(func(): move_right.emit())
	server_instance.stop_signal.connect(func(): stop_signal.emit())
	server_instance.jump_signal.connect(func(): jump_signal.emit())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		toggle_pause()

func _on_maze_generated(spawn_position: Vector3, finish_position: Vector3) -> void:
	print("Received maze_generated signal, spawning player at: ", spawn_position,
	"and finsh at: ", finish_position)
	# Setup player
	var player_instance = player.instantiate()
	player_instance.transform.origin = spawn_position * grid_map.cell_size
	add_child(player_instance)
	# Setup finish
	var finish_instance = finish.instantiate()
	finish_instance.transform.origin = finish_position * grid_map.cell_size # Cell size is 6m so -3 will put it on a wall
	add_child(finish_instance)

func toggle_pause():
	if get_tree().paused:
		# Resume game
		get_tree().paused = false
		hud.stopped = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		game_menu.hide()
	else:
		# Pause game
		get_tree().paused = true
		hud.stopped = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		game_menu.show()
