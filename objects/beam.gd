class_name Beam extends Area3D

var element := 0

var active := false
var push_force := 15.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("beam_scroll")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if active:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if not body is RigidBody3D: continue
			var b = body as RigidBody3D
			var dir : Vector3 = b.position - global_position
			if element == 2: b.apply_central_force(dir.normalized() * push_force)
			if element == 3: b.apply_central_force(dir.normalized() * -push_force)
			#b.apply_torque(dir.normalized() * push_force * 0.4)

func set_element(elmt: int):
	var material := $MeshInstance3D.material_override as StandardMaterial3D
	
	match elmt:
		0: material.albedo_color = Color(1.0, 0.2, 0.1)
		1: material.albedo_color = Color(0.2, 0.6, 1.0)
		2: material.albedo_color = Color(0.6, 1.0, 0.5)
		3: material.albedo_color = Color(0.7, 0.5, 0.2)
	
	element = elmt
