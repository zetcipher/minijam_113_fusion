class_name PowerCrystal extends StaticBody3D

var is_aspect := false
var power := 0

var rot_speed := 0.5
var bob_speed := 1.0
var going_up := false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_power(power, is_aspect)
	G.connect("power_updated", Callable(self, "set_alpha"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): # visual effects, so physics timing is not important
	var mesh := $MeshInstance3D as MeshInstance3D
	var material := mesh.material_override as StandardMaterial3D
	
	mesh.rotation_degrees.y += 360.0 * rot_speed * delta
	if mesh.rotation_degrees.y > 360.0: mesh.rotation_degrees.y -= 360.0
	
	if going_up and mesh.position.y > 0.05: going_up = false
	if not going_up and mesh.position.y < -0.05: going_up = true
	
	mesh.position.y += (0.25 * bob_speed * delta) * G.bool_to_sign(going_up)


func set_alpha(a_id: int, e_id: int):
	if (is_aspect and a_id == power) or (not is_aspect and e_id == power):
		$MeshInstance3D/Sprite3D.modulate.a = 0.33
	else:
		$MeshInstance3D/Sprite3D.modulate.a = 1.0


func set_power(id: int, aspect := true):
	var material := $MeshInstance3D.material_override as StandardMaterial3D
	power = id
	is_aspect = aspect
	if aspect:
		$MeshInstance3D/Sprite3D.frame = power + 4
		material.albedo_color = Color(0.51, 0.88, 1.0, 1.0)
	else:
		$MeshInstance3D/Sprite3D.frame = power
		material.albedo_color = Color(0.98, 1.0, 0.51, 1.0)


func _on_tree_exiting():
	G.disconnect("power_updated", Callable(self, "set_alpha"))
