extends Area3D

var blast_force := 2.0;
var lift_force := 0.5;

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("blowup")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(_anim_name):
	self.queue_free()


func _on_body_entered(body):
	if not body is RigidBody3D: return
	
	var obj : RigidBody3D = body as RigidBody3D
	var dir := obj.position - position
	var dist := dir.length()
	dir = dir.normalized()
	dist = clampf(dist, 0.1, 1.0 * scale.x)
	
	var force := dir * blast_force
	force.y += lift_force
	force *= 1 / dist
	
	#obj.apply_impulse(force * (1 / dist), position)
	obj.apply_central_impulse(force)
	obj.apply_torque_impulse(force * 0.3)
