extends MeshInstance3D

func _ready():
	#var unique_material = mesh.surface_get_material(0).duplicate() as ShaderMaterial
	#unique_material.set_shader_parameter("Paint", get_parent().get_node("DrawViewport").get_texture())
	#mesh.surface_set_material(0, unique_material)
	var viewport = get_parent().get_node("DrawViewport")
	
	# Clear the viewport
	await clear_viewport(viewport)
	
	(mesh.surface_get_material(0) as ShaderMaterial).set_shader_parameter("Paint", viewport.get_texture())

func clear_viewport(viewport: SubViewport) -> void:
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# Wait a frame to ensure clearing happens
	await get_tree().process_frame
	
	# Reset back to original settings
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
