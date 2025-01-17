extends CharacterBody3D

const SPEED = 15.0
const SENSITIVITY = 0.003

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var projectile_spawn_point = $Head/Camera3D/BulletSpawn
@onready var world: Node = get_tree().get_root().get_node("World")  # Gets the parent node (World)
@onready var projectile_scene = preload("res://scenes/projectile.tscn")

var jump_requested = false
var is_moving_forward = false
var is_moving_backward = false
var is_moving_left = false
var is_moving_right = false
# TODO: add signals for move_up and move_down and shoot

func _on_move_forward():
	is_moving_forward = true
	
func _on_move_backward():
	is_moving_backward = true
	
func _on_move_left():
	is_moving_left = true
	
func _on_move_right():
	is_moving_right = true
	
func _on_stop_movement() -> void:
	is_moving_forward = false
	is_moving_backward = false
	is_moving_left = false
	is_moving_right = false
	print("movement_stopped")
	
func spawn_bullet():
	var projectile = projectile_scene.instantiate()
	
	add_sibling(projectile)
	
	projectile.transform = projectile_spawn_point.global_transform
	projectile.set_direction(-camera.global_transform.basis.z)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Connect the signal from server.gd and call respective function
	world.move_forward.connect(_on_move_forward)
	world.move_backward.connect(_on_move_backward)
	world.move_left.connect(_on_move_left)
	world.move_right.connect(_on_move_right)
	world.stop_signal.connect(_on_stop_movement)
	
# Rotate camera with mouse
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(_delta: float) -> void:
	
	var input_dir = Vector2()
	var up_or_down = 0
	
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		# Get the input direction from keyboard
		input_dir = Input.get_vector("left", "right", "forward", "backward")
	else:  # if no action was pressed but there are active movement signals
		if is_moving_forward:
			input_dir.y -= 1
			print("moving_forward")
		if is_moving_backward:
			input_dir.y += 1
			print("moving_back")
		if is_moving_left:
			input_dir.x -= 1
			print("moving_left")
		if is_moving_right:
			input_dir.x += 1
			print("moving_right")

	if Input.is_action_pressed("up"):
		up_or_down = 1
	if Input.is_action_pressed("down"):
		up_or_down = -1
		
	if Input.is_action_just_pressed("shoot") and not get_tree().paused:
		spawn_bullet()
		
	# Count direction and update velocity needed for move_and_slide func
	var direction = (head.transform.basis * Vector3(input_dir.x, up_or_down, input_dir.y)).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	velocity.y = direction.y * SPEED

	move_and_slide()
