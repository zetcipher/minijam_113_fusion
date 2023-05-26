extends Area3D

var element := 0

var active := false
var push_force := 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if active:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if not body is RigidBody3D: continue
			var b = body as RigidBody3D
			var dir : Vector3 = b.position - global_position
			b.apply_central_force(dir.normalized() * push_force)
			#b.apply_torque(dir.normalized() * push_force * 0.4)
