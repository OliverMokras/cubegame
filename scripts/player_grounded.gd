extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var world: Node = get_parent()  # Gets the parent node (World)

var jump_requested = false
var is_moving_forward = false
var is_moving_backward = false
var is_moving_left = false
var is_moving_right = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Connect the signal from server.gd and call respective function
	world.jump_signal.connect(_on_jump_signal)
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

# Called when "jump_signal" comes
func _on_jump_signal():
	jump_requested = true
	
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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if (Input.is_action_just_pressed("jump") or jump_requested) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_requested = false
		print("jumped")
		
	# Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	var input_dir = Vector2()
	
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		# Get the input direction from keyboard and handle the movement/deceleration.
		input_dir = Input.get_vector("left", "right", "forward", "backward")
	else:
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

	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	move_and_slide()
