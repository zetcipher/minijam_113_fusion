class_name Player extends CharacterBody3D

const TOP_SPEED := 6.0
const JUMP_VELOCITY := 6.0
const ACCEL_GRND := 40.0
const ACCEL_AIR := 6.67
const DECEL_GRND := 30.0
const DECEL_AIR := 5.0

var speed := 0.0
var plr_force := Vector3.ZERO
var env_force := Vector3.ZERO

var last_dir := Vector3.ZERO

var energy := 100.0
var using_energy := false
var energy_regen := 50.0
var must_refill := false
var regen_delay := 0.0

var shot_type := 0
var element := 0

var cam_sens := Vector2(3,3)


@onready var cam := $Head/Camera3D as Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	movement(delta)
	if Input.is_action_just_pressed("shoot") and shot_type != 2 and not must_refill: shoot()
	
	if Input.is_action_pressed("shoot") and shot_type == 2 and not must_refill:
		var beam = $Body/Beam as Area3D
		beam.show()
		beam.active = true
		beam.monitorable = true
		beam.monitorable = true
		energy -= G.aspect_energy_use[shot_type] * G.element_energy_use[element] * delta
		if energy <= 0.0:
			energy = 0.0
			must_refill = true
		using_energy = true
		regen_delay = 0.5
	else:
		var beam = $Body/Beam as Area3D
		beam.hide()
		beam.active = false
		beam.monitorable = false
		beam.monitorable = false
		using_energy = false
	
	if Input.is_physical_key_pressed(KEY_1): element = 0
	if Input.is_physical_key_pressed(KEY_2): element = 1
	if Input.is_physical_key_pressed(KEY_3): element = 2
	if Input.is_physical_key_pressed(KEY_4): element = 3
	
	if Input.is_action_just_pressed("scroll_aspect_back"): shot_type -= 1
	if Input.is_action_just_pressed("scroll_aspect_for"): shot_type += 1
	if shot_type < 0: shot_type = 2
	if shot_type > 2: shot_type = 0
	
	match element:
		0: $CanvasLayer/Control/crosshair.modulate = Color(1.0, 0.2, 0.1)
		1: $CanvasLayer/Control/crosshair.modulate = Color(0.2, 0.6, 1.0)
		2: $CanvasLayer/Control/crosshair.modulate = Color(0.6, 1.0, 0.5)
		3: $CanvasLayer/Control/crosshair.modulate = Color(0.7, 0.5, 0.2)
	$CanvasLayer/Control/ProgressBar.value = energy
	
	if $Head/Camera3D/RayCast3D.get_collider() != self and $Head/Camera3D/RayCast3D.is_colliding():
		$Body/Beam.look_at($Head/Camera3D/RayCast3D.get_collision_point())
	else:
		$Body/Beam.look_at($Head/Camera3D/Target.global_position)
	
	
	if energy < 100.0 and not using_energy and regen_delay <= 0.0:
		if must_refill:
			energy += energy_regen * delta * 0.5
		else:
			energy += energy_regen * delta
		if energy >= 100.0: 
			energy = 100.0
			must_refill = false
	
	if regen_delay > 0.0:
		regen_delay -= delta
		if regen_delay < 0.0:
			regen_delay = 0.0
	
	$CanvasLayer/Control/Label.text = "SHOT TYPE: " + str(shot_type)
	
	#print(Vector3(1,2,4).rotated(Vector3(0,1,0), cam.rotation.y))


func shoot():
	var shot := G.basic_shot.instantiate() as BasicProjectile
	shot.element = element
	match shot_type:
		1:
			shot.speed = 30.0 * G.element_mods[self.element].shot_speed
			shot.acceleration = -20.0 * G.element_mods[self.element].shot_accel
			shot.grav_mult = 1.5 * G.element_mods[self.element].shot_grav
			shot.scale = Vector3.ONE * 1 * G.element_mods[self.element].shot_scale
			shot.blast_radius = 3 * G.element_mods[self.element].blast_radius
			shot.blast_force = 3.5 * G.element_mods[self.element].blast_force
			shot.blast_lift = 1.0 * G.element_mods[self.element].blast_lift
		_:
			shot.speed = 50.0 * G.element_mods[self.element].shot_speed
			shot.acceleration = -10.0 * G.element_mods[self.element].shot_accel
			shot.grav_mult = 1.0 * G.element_mods[self.element].shot_grav
			shot.scale = Vector3.ONE * 0.5 * G.element_mods[self.element].shot_scale
			shot.blast_radius = 0.5 * G.element_mods[self.element].blast_radius
			shot.blast_force = 0.5 * G.element_mods[self.element].blast_force
			shot.blast_lift = 0.125 * G.element_mods[self.element].blast_lift
	
	shot.position = position + $Head.position
	shot.look_at($Head/Camera3D/Target.position, Vector3.UP)
	shot.target_pos = $Head/Camera3D/Target.global_position
#	shot.rotation.x = self.rotation.x
#	shot.rotation.y = cam.rotation.y
	energy -= G.aspect_energy_use[shot_type] * G.element_energy_use[element]
	if energy <= 0.0:
		energy = 0.0
		must_refill = true
	regen_delay = 0.5
	
	get_parent().add_child(shot)


func can_spend_energy(aspect: int, element: int) -> bool:
	if aspect == 2:
		if energy >= G.aspect_energy_use[aspect] * G.element_energy_use[element] * (1 / 60):
			return true
		else:
			return false
	else:
		if energy >= G.aspect_energy_use[aspect] * G.element_energy_use[element]:
			return true
		else:
			return false



func movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		plr_force.y -= gravity * delta
	velocity.y = env_force.y + plr_force.y

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		plr_force.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if speed < TOP_SPEED:
			if is_on_floor():
				speed += ACCEL_GRND * delta
			else:
				speed += ACCEL_AIR * delta
			if speed > TOP_SPEED: speed = TOP_SPEED
	elif is_on_floor():
		if speed > 0.0:
			speed -= DECEL_GRND * delta
	else:
		if speed > 0.0:
			speed -= DECEL_AIR * delta
	if speed < 0.0:
		speed = 0.0
	
	if direction:
		plr_force.x = direction.x * speed
		plr_force.z = direction.z * speed
	else:
		plr_force.x = last_dir.x * speed
		plr_force.z = last_dir.z * speed
	
	velocity.x = plr_force.x + env_force.x
	velocity.z = plr_force.z + env_force.z
	
	if direction: last_dir = direction

	move_and_slide()


func _input(event):
	if not event is InputEventMouseMotion:
		return
	
	var ev := event as InputEventMouseMotion
	
	rotation.y -= ev.relative.x * 0.001 * cam_sens.x
	cam.rotation.x -= ev.relative.y * 0.001 * cam_sens.y
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	

