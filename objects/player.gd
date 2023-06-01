class_name Player extends RigidBody3D

const TOP_SPEED := 6.0
const JUMP_VELOCITY := 17.5
const ACCEL_GRND := 100.0
const ACCEL_AIR := 10.0
const DECEL_GRND := 30.0
const DECEL_AIR := 5.0

@export var starting_rot := 0.0

var speed := 0.0
var plr_force := Vector3.ZERO
var env_force := Vector3.ZERO

var last_dir := Vector3.ZERO

var life := 100.0
var energy := 100.0
var using_energy := false
var energy_regen := 100.0
var water_life_drain := 50.0
var lava_life_drain := 100.0
var life_regen := 10.0
var must_refill := false
var regen_delay := 0.0
var life_regen_delay := 0.0

var can_pick_power := false
var can_switch := false
var has_gun := false

var shot_type := 0
var shot_type_alt := 0
var element := 0
var element_alt := 0

var cam_sens := Vector2(3,3)

var water_zones := 0
var lava_zones := 0


@onready var cam := $Head/Camera3D as Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$Head.rotation_degrees.y = starting_rot

func _physics_process(delta):
	if G.game_started: $CanvasLayer.show()
	else: $CanvasLayer.hide()
	movement(delta)
	if Input.is_action_just_pressed("shoot") and has_gun and ((shot_type == 0 and element != 3) or shot_type == 1) and not must_refill: shoot()
	if Input.is_action_just_pressed("shoot") and has_gun and (shot_type == 0 and element == 3) and not must_refill: shoot_block()
	
	if Input.is_action_pressed("shoot") and has_gun and shot_type == 2 and not must_refill:
		var beam = $Body/Beam as Area3D
		beam.set_element(element)
		beam.show()
		beam.active = true
		beam.monitorable = true
		beam.monitorable = true
		if element == 2 and $Head/Camera3D/RayCast3D.is_colliding() and Vector3(linear_velocity.x, 0.0, linear_velocity.z).length() < 20.0: 
			apply_central_force(Vector3((position + Vector3.UP) - $Head/Camera3D/Target.global_position) * Vector3(2.0, 1.5, 2.0))
		if element == 3 and $Head/Camera3D/RayCast3D.is_colliding() and Vector3(linear_velocity.x, 0.0, linear_velocity.z).length() < 20.0: 
			apply_central_force(Vector3($Head/Camera3D/Target.global_position - (position + Vector3.UP)) * Vector3(1.5, 2.5, 1.5))
		energy -= G.aspect_energy_use[shot_type] * G.element_energy_use[shot_type][element] * delta
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
	
	if OS.is_debug_build() and Input.is_physical_key_pressed(KEY_DELETE): 
		has_gun = true
		can_switch = true
		energy_regen = 300.0
	
	if can_switch:
		if Input.is_physical_key_pressed(KEY_1): element = 0
		if Input.is_physical_key_pressed(KEY_2): element = 1
		if Input.is_physical_key_pressed(KEY_3): element = 2
		if Input.is_physical_key_pressed(KEY_4): element = 3
		
		if Input.is_physical_key_pressed(KEY_Z): shot_type = 0
		if Input.is_physical_key_pressed(KEY_X): shot_type = 1
		if Input.is_physical_key_pressed(KEY_C): shot_type = 2
	if shot_type < 0: shot_type = 2
	if shot_type > 2: shot_type = 0
	
	match element:
		0: $CanvasLayer/Control/crosshair.modulate = Color(1.0, 0.2, 0.1)
		1: $CanvasLayer/Control/crosshair.modulate = Color(0.2, 0.6, 1.0)
		2: $CanvasLayer/Control/crosshair.modulate = Color(0.6, 1.0, 0.5)
		3: $CanvasLayer/Control/crosshair.modulate = Color(0.7, 0.5, 0.2)
	$CanvasLayer/Control/ProgressBar.value = energy
	$CanvasLayer/Control/lifebar.value = life
	
	if $Head/Camera3D/RayCast3D.get_collider() != self and $Head/Camera3D/RayCast3D.is_colliding():
		$Body/Beam.look_at($Head/Camera3D/RayCast3D.get_collision_point())
	else:
		$Body/Beam.look_at($Head/Camera3D/Target.global_position)
	
	
	var pCheck_ray := $Head/Camera3D/RayCast3D2 as RayCast3D
	var ptext0 := "Press RMB to equip ["
	var ptext1 := "]."
	
	if Input.is_action_just_pressed("scroll_aspect_back"):
		var st := shot_type
		var e := element
		shot_type = shot_type_alt
		element = element_alt
		shot_type_alt = st
		element_alt = e
	
	if pCheck_ray.is_colliding() and pCheck_ray.get_collider() is PowerCrystal: can_pick_power = true
	else: can_pick_power = false
	
	if can_pick_power:
		var ptext2 := ""
		var power : int = pCheck_ray.get_collider().power
		var is_aspect : bool = pCheck_ray.get_collider().is_aspect
		
		if is_aspect: match power:
			1: ptext2 = "BLAST"
			2: ptext2 = "BEAM"
			3: ptext2 = "MELEE"
			_: ptext2 = "BULLET"
		else: match power:
			1: ptext2 = "ICE"
			2: ptext2 = "WIND"
			3: ptext2 = "EARTH"
			_: ptext2 = "FIRE"
		
		$CanvasLayer/Control/powerText.text = ptext0 + ptext2 + ptext1
		$CanvasLayer/Control/powerText.show()
		
		if Input.is_action_just_pressed("interact"):
			if is_aspect: 
				shot_type = power
			else: 
				element = power
			if not has_gun: has_gun = true
			G.emit_signal("power_updated", shot_type, element)
	else:
		$CanvasLayer/Control/powerText.hide()
	
	$CanvasLayer/Control/Power0/Aspect.frame = shot_type + 4
	$CanvasLayer/Control/Power0/Element.frame = element
	
	$CanvasLayer/Control/Power1/Aspect.frame = shot_type_alt + 4
	$CanvasLayer/Control/Power1/Element.frame = element_alt
	
	if not has_gun:
		$CanvasLayer/Control/energytext.hide()
		$CanvasLayer/Control/ProgressBar.hide()
		$CanvasLayer/Control/Label.hide()
		$CanvasLayer/Control/Label2.hide()
		$CanvasLayer/Control/Power0.hide()
		$CanvasLayer/Control/Power1.hide()
	else:
		$CanvasLayer/Control/energytext.show()
		$CanvasLayer/Control/ProgressBar.show()
		$CanvasLayer/Control/Label.show()
		$CanvasLayer/Control/Label2.show()
		$CanvasLayer/Control/Power0.show()
		$CanvasLayer/Control/Power1.show()
	
	if energy < 100.0 and not using_energy and regen_delay <= 0.0:
		if must_refill:
			energy += energy_regen * delta * 0.5
		else:
			energy += energy_regen * delta
		if energy >= 100.0: 
			energy = 100.0
			must_refill = false
	
	if water_zones:
		subtract_life(water_life_drain * delta)
	if lava_zones:
		subtract_life(lava_life_drain * delta)
	
	if life < 100.0 and life_regen_delay <= 0.0:
		heal_life(life_regen * delta)
	
	if regen_delay > 0.0:
		regen_delay -= delta
		if regen_delay < 0.0:
			regen_delay = 0.0
	
	if life_regen_delay > 0.0:
		life_regen_delay -= delta
		if life_regen_delay < 0.0:
			life_regen_delay = 0.0
	
	$CanvasLayer/Control/Label.text = G.power_names[shot_type][element]
	
	#print(Vector3(1,2,4).rotated(Vector3(0,1,0), cam.rotation.y))

func subtract_life(amount: float):
	life -= amount
	if life <= 0.0: 
		voidout()
	life_regen_delay = 2.0

func heal_life(amount: float):
	life += amount
	if life > 100.0: life = 100.0

func voidout():
	linear_velocity = Vector3.ZERO
	position = G.respawn_location
	G.death_count += 1
	life = 50.0

func shoot_block():
	if get_tree().get_nodes_in_group("PlayerEarthBlocks").size() > 2:
		get_tree().get_first_node_in_group("PlayerEarthBlocks").queue_free()
	var block := G.earth_block.instantiate() as RigidBody3D
	var dir : Vector3 = $Head/Camera3D/Target.global_position - position
	dir = dir.normalized()
	block.position = $Head.global_position + (dir * 0.75)
	block.apply_central_impulse(dir * 10.0)
	get_parent().add_child(block)
	

func shoot():
	var shot := G.basic_shot.instantiate() as BasicProjectile
	shot.element = element
	shot.shot_type = shot_type
	match shot_type:
		1:
			shot.speed = 30.0 * G.element_mods_heavy[self.element].shot_speed
			shot.acceleration = -20.0 * G.element_mods_heavy[self.element].shot_accel
			shot.grav_mult = 1.5 * G.element_mods_heavy[self.element].shot_grav
			shot.scale = Vector3.ONE * 1 * G.element_mods_heavy[self.element].shot_scale
			shot.blast_radius = 3 * G.element_mods_heavy[self.element].blast_radius
			shot.blast_force = 5.0 * G.element_mods_heavy[self.element].blast_force
			shot.blast_lift = 1.25 * G.element_mods_heavy[self.element].blast_lift
			shot.destruction_power = G.element_mods_heavy[self.element].destruction_power
			shot.freeze_power = G.element_mods_heavy[self.element].freeze_power
			shot.burn_power = G.element_mods_heavy[self.element].burn_power
		_:
			shot.speed = 50.0 * G.element_mods_basic[self.element].shot_speed
			shot.acceleration = -10.0 * G.element_mods_basic[self.element].shot_accel
			shot.grav_mult = 1.0 * G.element_mods_basic[self.element].shot_grav
			shot.scale = Vector3.ONE * 0.5 * G.element_mods_basic[self.element].shot_scale
			shot.blast_radius = 0.5 * G.element_mods_basic[self.element].blast_radius
			shot.blast_force = 1.0 * G.element_mods_basic[self.element].blast_force
			shot.blast_lift = 0.25 * G.element_mods_basic[self.element].blast_lift
			shot.destruction_power = G.element_mods_basic[self.element].destruction_power
			shot.freeze_power = G.element_mods_basic[self.element].freeze_power
			shot.burn_power = G.element_mods_basic[self.element].burn_power
	
	shot.add_exception(self)
	shot.position = position + $Head.position
	#shot.look_at_from_position($Head.position, $Head/Camera3D/Target.position, Vector3.UP)
	shot.target_pos = $Head/Camera3D/Target.global_position
#	shot.rotation.x = self.rotation.x
#	shot.rotation.y = cam.rotation.y
	energy -= G.aspect_energy_use[shot_type] * G.element_energy_use[shot_type][element]
	if energy <= 0.0:
		energy = 0.0
		must_refill = true
	regen_delay = 0.5
	
	get_parent().add_child(shot)


func can_spend_energy(aspect: int, element: int) -> bool:
	if aspect == 2:
		if energy >= G.aspect_energy_use[shot_type][element] * G.element_energy_use[shot_type][element] * (1.0 / 60.0):
			return true
		else:
			return false
	else:
		if energy >= G.aspect_energy_use[shot_type][element] * G.element_energy_use[shot_type][element]:
			return true
		else:
			return false



func movement(delta: float):
	var floorcast := $floor_cast as RayCast3D
	var floorarea := $floor_detect as Area3D
	var on_floor := floorcast.is_colliding()
	
	var speed_mult := 1.0
	if OS.is_debug_build() and Input.is_physical_key_pressed(KEY_SHIFT):
		speed_mult = 2.5
	
	if floorarea.get_overlapping_bodies().size() > 1:
		on_floor = true
		physics_material_override.friction = 1.0
		physics_material_override.rough = false
	else:
		on_floor = false
		physics_material_override.friction = 0.0
		physics_material_override.rough = true
	
#	if on_floor:
#		apply_central_force(Vector3.DOWN * gravity * 0.25)
#	else:
#		apply_central_force(Vector3.DOWN * gravity)
	
	if Input.is_action_just_pressed("jump") and (on_floor or (OS.is_debug_build() and Input.is_physical_key_pressed(KEY_SHIFT))) and not water_zones:
		apply_central_impulse(Vector3.UP * JUMP_VELOCITY)
		#apply_central_impulse(Vector3(1,0,1) * -0.5)
	if Input.is_action_just_pressed("jump") and water_zones and linear_velocity.y < 3.5:
		apply_central_impulse(Vector3.UP * JUMP_VELOCITY * 0.5)
	if Input.is_action_pressed("jump") and water_zones and linear_velocity.y < 5.0:
		apply_central_force(Vector3.UP * gravity * 0.5)
	
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3($Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var h_vel := Vector3(linear_velocity.x, 0, linear_velocity.z)
	
	if direction.length() > 0.0 and h_vel.length() < TOP_SPEED * speed_mult:
		if on_floor:
			apply_central_force(direction * ACCEL_GRND * speed_mult)
		else:
			apply_central_force(direction * ACCEL_AIR * speed_mult)
	
	if (position.x < G.play_area_min.x or position.x > G.play_area_max.x) or \
	(position.y < G.play_area_min.y or position.y > G.play_area_max.y) or \
	(position.z < G.play_area_min.z or position.z > G.play_area_max.z):
		voidout()
	
	
#	# Add the gravity.
#	if not is_on_floor():
#		plr_force.y -= gravity * delta
#	velocity.y = env_force.y + plr_force.y
#
#	# Handle Jump.
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		plr_force.y = JUMP_VELOCITY
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
#	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
#		if speed < TOP_SPEED:
#			if is_on_floor():
#				speed += ACCEL_GRND * delta
#			else:
#				speed += ACCEL_AIR * delta
#			if speed > TOP_SPEED: speed = TOP_SPEED
#	elif is_on_floor():
#		if speed > 0.0:
#			speed -= DECEL_GRND * delta
#	else:
#		if speed > 0.0:
#			speed -= DECEL_AIR * delta
#	if speed < 0.0:
#		speed = 0.0
#
#	if direction:
#		plr_force.x = direction.x * speed
#		plr_force.z = direction.z * speed
#	else:
#		plr_force.x = last_dir.x * speed
#		plr_force.z = last_dir.z * speed
#
#	velocity.x = plr_force.x + env_force.x
#	velocity.z = plr_force.z + env_force.z
#
#	if direction: last_dir = direction
#
#	move_and_slide()


func _input(event):
	if not event is InputEventMouseMotion:
		return
	
	var ev := event as InputEventMouseMotion
	
	$Head.rotation.y -= ev.relative.x * 0.001 * cam_sens.x
	cam.rotation.x -= ev.relative.y * 0.001 * cam_sens.y
	cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	

