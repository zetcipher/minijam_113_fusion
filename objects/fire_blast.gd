extends MeshInstance3D

var decay_speed := 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$GPUParticles3D.emitting = true
	var sphere := $GPUParticles3D.draw_pass_1 as SphereMesh
	sphere.radius *= (scale.x * 0.5)
	sphere.height *= (scale.x * 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mat := material_override as ShaderMaterial
	var mat2 := $inside.material_override as ShaderMaterial
	var fire_ap : float = mat.get_shader_parameter("fire_aperture")
	var fire_alpha : float = mat.get_shader_parameter("fire_alpha")
	
	if fire_ap < 2.0:
		mat.set_shader_parameter("fire_aperture", fire_ap + (delta * 3.0 * decay_speed))
		if fire_ap >= 0.75:
			mat.set_shader_parameter("fire_alpha", fire_alpha + (delta * 3.0 * decay_speed))
	else:
		queue_free()
