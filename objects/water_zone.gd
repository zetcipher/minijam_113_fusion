extends Area3D

var pressure_scale := 1.0
var grav : float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for i in get_overlapping_bodies():
		if not i is RigidBody3D: continue
		var body := i as RigidBody3D
		
		var lift_force : float = (position.y - body.position.y) / 20.0
		
		body.gravity_scale = lift_force
		
		if not body is Player:
			body.apply_central_force(Vector3.UP * lift_force * pressure_scale * grav * 2.0)


func _on_body_entered(body):
	if not body is RigidBody3D: return
	if body is Player: body.water_zones += 1


func _on_body_exited(body):
	if not body is RigidBody3D: return
	body.gravity_scale = 1.0
	if body is Player: body.water_zones -= 1


func _on_area_entered(area):
	if not area is BasicProjectile: return
	if not area.element == 1 and not area.element == 0: return
	blast(area)

func blast(shot: BasicProjectile):
	#print(blast_pos)
	var blast := G.blast.instantiate()
	var effect : MeshInstance3D
	match shot.element:
		1: effect = G.ice_blast.instantiate()
		2: effect = G.wind_blast.instantiate()
		3: effect = G.earth_blast.instantiate()
		_: effect = G.fire_blast.instantiate()
	blast.element = shot.element
	blast.destruction_power = shot.destruction_power
	blast.freeze_power = shot.freeze_power
	blast.burn_power = shot.burn_power
	blast.position = shot.position
	effect.position = shot.position
	blast.position.y = position.y
	effect.position.y = position.y
	blast.scale *= shot.blast_radius
	effect.scale *= shot.blast_radius
	blast.blast_force = shot.blast_force
	blast.lift_force = shot.blast_lift
	
	if shot.freeze_power >= 2.0:
		var ice_plat := G.ice_plat.instantiate()
		ice_plat.position = blast.position
		get_parent().add_child(ice_plat)
	
	get_parent().add_child(blast)
	get_parent().add_child(effect)
	shot.queue_free()
	
