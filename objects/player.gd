class_name Player extends CharacterBody3D

const SPEED := 6.0
const JUMP_VELOCITY := 6.0

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
	if Input.is_action_just_pressed("shoot"): shoot()
	
	if Input.is_physical_key_pressed(KEY_1): element = 0
	if Input.is_physical_key_pressed(KEY_2): element = 1
	if Input.is_physical_key_pressed(KEY_3): element = 2
	if Input.is_physical_key_pressed(KEY_4): element = 3
	
	if Input.is_physical_key_pressed(KEY_Q): shot_type = 0
	if Input.is_physical_key_pressed(KEY_E): shot_type = 1
	
	match element:
		0: $CanvasLayer/Control/crosshair.modulate = Color(1.0, 0.3, 0.0)
		1: $CanvasLayer/Control/crosshair.modulate = Color(0.2, 0.6, 1.0)
		2: $CanvasLayer/Control/crosshair.modulate = Color(0.6, 1.0, 0.5)
		3: $CanvasLayer/Control/crosshair.modulate = Color(0.7, 0.5, 0.2)
	
	$CanvasLayer/Control/Label.text = "SHOT TYPE: " + str(shot_type)
	
	#print(Vector3(1,2,4).rotated(Vector3(0,1,0), cam.rotation.y))


func shoot():
	var shot := G.basic_shot.instantiate() as BasicProjectile
	
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
	
	get_parent().add_child(shot)


func movement(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _input(event):
	if not event is InputEventMouseMotion:
		return
	
	var ev := event as InputEventMouseMotion
	
	rotation.y -= ev.relative.x * 0.001 * cam_sens.x
	cam.rotation.x -= ev.relative.y * 0.001 * cam_sens.y
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	

