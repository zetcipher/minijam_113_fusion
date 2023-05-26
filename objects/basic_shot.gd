extends Area3D

var element := 0

var target_pos := Vector3.ZERO
var speed := 20.0
var acceleration := 0.0
var grav_mult := 0.0
var y_vel := 0.0
var dir := Vector3.ZERO
var blast_radius := 5
var time := 0.0

var blast_pos := Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	dir = target_pos - position
	dir = dir.normalized()
	$MeshInstance3D.rotation = self.rotation
	self.rotation = Vector3.ZERO
	$RayCast3D.target_position = dir * speed * (1 / 60)
	$RayCast3D2.target_position = dir * speed * (1 / 60) * 16


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if $RayCast3D.is_colliding():
		blast()
		return
	
	position += dir * speed * delta
	y_vel -= gravity * grav_mult * delta
	position.y += y_vel * delta
	
	speed += acceleration * delta
	
	$RayCast3D.target_position = dir * speed * delta
	$RayCast3D2.target_position = dir * speed * delta * 16
	
	if time > 10.0:
		self.queue_free()
	else:
		time += delta


func blast():
	blast_pos = $RayCast3D2.get_collision_point()
	#print(blast_pos)
	var blast := preload("res://materials/object/blast.tscn").instantiate()
	if blast_pos == Vector3.ZERO:
		blast.position = position
	else:
		blast.position = blast_pos
	blast.scale *= blast_radius
	get_parent().add_child(blast)
	self.queue_free()

func _on_body_entered(body):
	blast()


