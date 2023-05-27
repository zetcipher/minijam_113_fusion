class_name BasicProjectile extends Area3D

var element := 0

var target_pos := Vector3.ZERO
var speed := 20.0
var acceleration := 0.0
var grav_mult := 0.0
var y_vel := 0.0
var dir := Vector3.ZERO
var blast_radius := 5.0
var blast_force := 1.0
var blast_lift := 0.5
var time := 0.0

var blast_pos := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	var material := $MeshInstance3D.material_override as StandardMaterial3D
	match element:
		0: material.albedo_color = Color(1.0, 0.2, 0.1)
		1: material.albedo_color = Color(0.2, 0.6, 1.0)
		2: material.albedo_color = Color(0.6, 1.0, 0.5)
		3: material.albedo_color = Color(0.7, 0.5, 0.2)
	
	dir = target_pos - position
	dir = dir.normalized()
	$MeshInstance3D.rotation = self.rotation
	self.rotation = Vector3.ZERO
	$RayCast3D.position = -dir * 2
	$RayCast3D.target_position = dir * speed * (1 / 60) * 2.5
	$RayCast3D2.target_position = dir * speed * (1 / 60) * 16


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if $RayCast3D.is_colliding():
		blast()
		return
	
	position += dir * speed * delta
	y_vel -= gravity * grav_mult * delta
	position.y += y_vel * delta
	
	if acceleration < 0.0 and speed > 0.0:
		speed += acceleration * delta
		if speed < 0.0: speed = 0.0
	if acceleration > 0.0:
		speed += acceleration * delta
	
	$RayCast3D.position = -dir * 2
	$RayCast3D.target_position = dir * speed * delta * 2.5
	$RayCast3D2.target_position = dir * speed * delta * 16
	
	if time > 10.0:
		self.queue_free()
	else:
		time += delta


func blast():
	blast_pos = $RayCast3D2.get_collision_point()
	#print(blast_pos)
	var blast := G.blast.instantiate()
	blast.element = element
	if blast_pos == Vector3.ZERO:
		blast.position = position
	else:
		blast.position = blast_pos
	blast.scale *= blast_radius
	blast.blast_force = blast_force
	blast.lift_force = blast_lift
	get_parent().add_child(blast)
	self.queue_free()

func _on_body_entered(body):
	if body is Player: return
	blast()


