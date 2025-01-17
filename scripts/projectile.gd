extends Area3D

const PROJECTILE_SPEED = 25
@export var offset_distance: float = 0.7

var direction: Vector3

func set_direction(dir: Vector3):
	direction = dir.normalized()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * PROJECTILE_SPEED * delta


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	var space_state = get_world_3d().direct_space_state
	
	# Main raycast
	var query = PhysicsRayQueryParameters3D.create(
		global_position - direction, 
		global_position + direction
	)
	var result = space_state.intersect_ray(query)
	
	#if result.is_empty():
		#print("Ray intersection failed")
		#queue_free()
		#return
	
	if body.get_parent() is MeshInstance3D:
		if result:
			# Process the main raycast
			process_hit(result)
		
		var offsets = [
			Vector3(0, offset_distance, 0),  # up
			Vector3(offset_distance, 0, 0),  # right
			Vector3(0, -offset_distance, 0), # down
			Vector3(-offset_distance, 0, 0)  # left
		]
		
		# Additional 4 raycasts around the hit point
		for offset in offsets:
			
			var offset_query = PhysicsRayQueryParameters3D.create(
				global_position - direction + offset, 
				global_position + direction + offset
			)
			var offset_result = space_state.intersect_ray(offset_query)
			
			if result:
				# Process the offset hit if it's on a different collider
				if !offset_result.is_empty() and offset_result.collider != result.collider:
					process_hit(offset_result)
			else:
				
				# Special case when we dont have the main raycast
				if !offset_result.is_empty():
					process_hit(offset_result)
		
	queue_free()

# Paint at the hit position
func process_hit(ray_result: Dictionary) -> void:
	var collider = ray_result.collider
	if collider.get_parent() is MeshInstance3D:
		var mesh_instance = collider.get_parent()
		var draw_viewport = collider.get_parent().get_node_or_null("../DrawViewport")
		UVPosition.set_mesh(mesh_instance)
		var uv = UVPosition.get_uv_coords(ray_result.position, ray_result.normal, true)
		if uv:
			draw_viewport.paint(uv)
