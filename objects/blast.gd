class_name Blast extends Area3D

var element := 0
var shot_type := 0
var destruction_power := 1.0
var freeze_power := 0.0
var burn_power := 0.0
var weight_divisor := 2.0

var blast_force := 10.0
var lift_force := 2.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("blowup")
	if shot_type == 0: weight_divisor = 1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(_anim_name):
	self.queue_free()


func _on_body_entered(body):
	if not body is RigidBody3D: return
	
	var obj : RigidBody3D = body as RigidBody3D
	var dir := obj.position - position
	var dist := dir.length() / scale.x
	dir = dir.normalized()
	dist = clampf(dist, 0.7, 0.95)
	
	var force := dir * blast_force
	force.y += lift_force
	force *= 1.7 - dist
	
	if element == 2: force *= (obj.mass / weight_divisor)
	
	#obj.apply_impulse(force * (1 / dist), position)
	obj.apply_central_impulse(force)
	obj.apply_torque_impulse(force * 0.15)
