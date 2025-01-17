extends GridMap

signal maze_done(spawn_position: Vector3)

const MAX_X = 3
const MAX_Y = 3
const MAX_Z = 3
var scene_to_place = preload("res://scenes/cell_2.tscn")
var maze_cells = []
var unvisited_cells = []
var stack = []

func validate_maze_size() -> bool:
	if MAX_X < 3 or MAX_Y < 3 or MAX_Z < 3:
			printerr("Error: Maze dimensions must be at least 3!")
			return false
	return true

# Place the preloaded scene into gridmap and return the instance
func place_scene_in_gridmap_cell(cell_x: int, cell_y: int, cell_z: int):
	var scene_instance = scene_to_place.instantiate()
	
	# Calculate the world position for the grid cell
	var cell_position = Vector3(cell_x, cell_y, cell_z) * cell_size
	
	# Set the instance's position
	scene_instance.transform.origin = cell_position
	
	add_child(scene_instance)
	
	return scene_instance

func place_boundaries() -> void:
	# Place bottom face (y = -1)
	for x in range(-1, MAX_X + 1):
		for z in range(-1, MAX_Z + 1):
			place_scene_in_gridmap_cell(x, -1, z)
	
	# Place top face (y = MAX_Y)
	for x in range(-1, MAX_X + 1):
		for z in range(-1, MAX_Z + 1):
			place_scene_in_gridmap_cell(x, MAX_Y, z)
	
	# Place front and back faces (z = -1 and z = MAX_Z)
	for x in range(-1, MAX_X + 1):
		for y in range(0, MAX_Y):  # -1 and MAX_Y are already placed
			place_scene_in_gridmap_cell(x, y, -1)
			place_scene_in_gridmap_cell(x, y, MAX_Z)
	
	# Place left and right faces (x = -1 and x = MAX_X)
	for z in range(0, MAX_Z):  # -1 and MAX_Z are already placed
		for y in range(0, MAX_Y):  # -1 and MAX_Y are already placed
			place_scene_in_gridmap_cell(-1, y, z)
			place_scene_in_gridmap_cell(MAX_X, y, z)

# Check adjecent cells (with step 2) and return the list of cells which were not visited yet
func check_neighbors(current_cell: Vector3, unv_cells: Array) -> Array:
	var neighbors = []
	var directions = [Vector3(2, 0, 0), Vector3(-2, 0, 0), Vector3(0, 2, 0), Vector3(0, -2, 0), Vector3(0, 0, 2), Vector3(0, 0, -2)]
	
	# Check each direction (right, left, up, down, front, back)
	for dir in directions:
		var neighbor_pos = current_cell + dir
		
		# Check if neighbor position is within bounds
		if neighbor_pos.x >= 0 and neighbor_pos.x < MAX_X and neighbor_pos.y >= 0 and neighbor_pos.y < MAX_Y and neighbor_pos.z >= 0 and neighbor_pos.z < MAX_Z:
			
			# Check if this neighbor is in the unvisited_cells list
			if neighbor_pos in unv_cells:
				neighbors.append(neighbor_pos)
				
	return neighbors

# Check ALL neighbors of each cell which was deleted
func check_all_neighbors(current_cell: Vector3) -> Array:
	var neighbors = []
	var directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
	
	for dir in directions:
		var neighbor_pos = current_cell + dir
		
		# Check if neighbor position is within bounds
		if neighbor_pos.x >= 0 and neighbor_pos.x < MAX_X and \
			neighbor_pos.y >= 0 and neighbor_pos.y < MAX_Y and \
			neighbor_pos.z >= 0 and neighbor_pos.z < MAX_Z:
			
			# Check if the cell is empty (null/deleted)
			if maze_cells[neighbor_pos.x][neighbor_pos.y][neighbor_pos.z] == null:
				neighbors.append(neighbor_pos)
	
	return neighbors

# Find all dead ends and randomly pick one
func find_dead_ends(cells: Array) -> Array:
	var dead_ends = []
	for x in MAX_X:
		for y in MAX_Y:
			for z in MAX_Z:
				if cells[x][y][z] != null:
					continue
				var all_neighbors = check_all_neighbors(Vector3(x,y,z))
				if all_neighbors.size() == 1:     # # Only one deleted cell
					dead_ends.append(Vector3(x,y,z))
	print("Dead ends: ", dead_ends)
	
	return dead_ends
	
# Find spawn position from dead ends
func find_spawn_position(dead_end_list: Array) -> Vector3:
	return dead_end_list[randi() % dead_end_list.size()]
	
# Find finish position from dead ends, avoiding spawn's y level
func find_finish_position(dead_end_list: Array, spawn_pos: Vector3) -> Vector3:
	var valid_ends = dead_end_list.filter(func(pos): return pos.y != spawn_pos.y)
	if valid_ends.is_empty():
		# Make the filter easier by filtering only spawn position
		valid_ends = dead_end_list.filter(func(pos): return pos != spawn_pos)
		if valid_ends.is_empty():
			print("Error: No valid finish position found!")
			return dead_end_list[0]  # Emergency fallback
	return valid_ends[randi() % valid_ends.size()]

func delete_cell(pos: Vector3) -> void:
	if maze_cells[pos.x][pos.y][pos.z]:
		var body = maze_cells[pos.x][pos.y][pos.z].get_node("MeshInstance3D")
		body.queue_free()
		maze_cells[pos.x][pos.y][pos.z] = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var map_seed = SceneManager.scene_data.get("seed", 0)
	
	if not validate_maze_size():
		get_tree().quit()
		return
	
	# Needed to wait for signal connection first
	await get_tree().process_frame
	
	# Seed the random number generator
	randomize()
	if !map_seed:
		map_seed = randi()
	seed(map_seed)
	print("Seed: ", map_seed)
	
	# Place all cells in given X,Y,Z coordinates
	for x in MAX_X:
		var y_list = []
		for y in MAX_Y:
			var z_list = []
			for z in MAX_Z:
				var cell_instance = place_scene_in_gridmap_cell(x, y, z)
				z_list.append(cell_instance)
				# Unvisited cells will contain only even ones, for future algorithm
				if x % 2 == 0 and y % 2 == 0 and z % 2 == 0:
					unvisited_cells.append(Vector3(x, y, z))
			y_list.append(z_list)
		maze_cells.append(y_list) # maze_cells[x][y][z] - contains all the instances
	
	place_boundaries()
	
	var current_cell = Vector3(2, 2, 2) # Fixed start of algorithm
	unvisited_cells.erase(current_cell)
	delete_cell(current_cell)
	
	# Back-tracking algorithm to through all cells and delete walls between them
	while unvisited_cells:
		var neighbors = check_neighbors(current_cell, unvisited_cells)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current_cell)
			var dir = next - current_cell
			var middle_cell = current_cell + (dir / 2)
			
			# Delete the middle cell to create a path + next
			delete_cell(middle_cell)
			delete_cell(next)
			
			current_cell = next
			unvisited_cells.erase(current_cell)
		elif stack:
			current_cell = stack.pop_back()
	
	var dead_ends = find_dead_ends(maze_cells)
	var spawn_position = find_spawn_position(dead_ends)
	var finish_position = find_finish_position(dead_ends, spawn_position)
	## Emit signal with the spawn position
	maze_done.emit(spawn_position, finish_position)
