extends Area3D

var target_pos := Vector3.ZERO
var speed := 10.0
var acceleration := 0.0
var grav_mult := 0.0
var y_vel := 0.0
var dir := Vector3.ZERO
var time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	dir = target_pos - position
	dir = dir.normalized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += dir * speed * delta
	y_vel -= gravity * grav_mult * delta
	position.y += y_vel * delta
	
	speed += acceleration * delta
	
	if time > 10.0:
		self.queue_free()
	else:
		time += delta
