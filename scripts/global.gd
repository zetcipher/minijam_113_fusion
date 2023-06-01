extends Node

signal power_updated(aspect: int, element: int)

enum Aspects {BASIC, HEAVY, BEAM, MELEE}
enum Elements {FIRE, ICE, WIND, EARTH}

var render_scale := 1.0

var play_time := 0.0
var respawn_location := Vector3.ZERO
var death_count := 0

var game_started := false
var game_cleared := false

var play_area_min := Vector3.ONE * -512
var play_area_max := Vector3.ONE * 512

var power_names := [
	["FIRE BALL", "ICE SHOT", "PUSH FORCE", "ROCK SHOT"], # basic shot
	["INFERNO BLAST", "FREEZE BLAST", "HURRICANE SHOT", "CUTE BOMB"], # heavy shot
	["HEAT RAY", "CHILL RAY", "WIND BEAM", "TRACTOR BEAM"], # beam
	["FLAME SWORD", "FROST SLICER", "ZEPHYR BLADE", "ACE OF CLUBS"], # melee
]

var element_energy_use := [
	[1.0, 0.66, 0.5, 1.5], # basic shot
	[0.5, 0.75, 1.0, 1.0], # heavy shot
	[1.0, 1.0, 2.0, 1.5], # beam
	[1.0, 1.25, 0.5, 1.5], # melee
	
]
var aspect_energy_use := [7.5, 33.4, 20.0, 20.0]

var element_mods_basic := [
	{ # fire
		shot_speed = 1.5,
		shot_grav = 0.75,
		shot_accel = 1.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 0.2,
		blast_lift = 0.3,
		destruction_power = 0.0,
		freeze_power = 0.0,
		burn_power = 1.0,
		damage = 1.0,
	},
	{ # ice
		shot_speed = 0.75,
		shot_grav = 1.5,
		shot_accel = 1.5,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 0.1,
		blast_lift = 0.1,
		destruction_power = 0.0,
		freeze_power = 0.25,
		burn_power = 0.0,
		damage = 1.5,
	},
	{ # wind
		shot_speed = 2.0,
		shot_grav = 0.5,
		shot_accel = 0.5,
		shot_scale = 1.5,
		blast_radius = 1.5,
		blast_force = 4.0,
		blast_lift = 3.0,
		destruction_power = 0.0,
		freeze_power = 0.0,
		burn_power = 0.0,
		damage = 0.25,
	},
	{ # earth
		shot_speed = 2.0,
		shot_grav = 2.0,
		shot_accel = 20.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 1.0,
		blast_lift = 1.0,
		destruction_power = 0.0,
		freeze_power = 0.0,
		burn_power = 0.0,
		damage = 2.5,
	},
]

var element_mods_heavy := [
	{ # fire
		shot_speed = 1.5,
		shot_grav = 0.75,
		shot_accel = 1.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 0.25,
		blast_lift = 0.25,
		destruction_power = 0.0,
		freeze_power = 0.0,
		burn_power = 2.0,
		damage = 1.0,
	},
	{ # ice
		shot_speed = 1.0,
		shot_grav = 1.5,
		shot_accel = 1.5,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 0.1,
		blast_lift = 0.1,
		destruction_power = 0.0,
		freeze_power = 2.0,
		burn_power = 0.0,
		damage = 1.5,
	},
	{ # wind
		shot_speed = 2.0,
		shot_grav = 1.0,
		shot_accel = 1.5,
		shot_scale = 1.5,
		blast_radius = 1.5,
		blast_force = 2.0,
		blast_lift = 4.5,
		destruction_power = 0.0,
		freeze_power = 0.0,
		burn_power = 0.0,
		damage = 0.25,
	},
	{ # earth
		shot_speed = 1.0,
		shot_grav = 1.0,
		shot_accel = 2.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = -1.0,
		blast_lift = 0.5,
		destruction_power = 1.0,
		freeze_power = 0.0,
		burn_power = 0.0,
		damage = 2.5,
	},
]

var basic_shot := preload("res://objects/basic_shot.tscn")

var blast := preload("res://objects/blast.tscn")

var fire_blast := preload("res://objects/fire_blast.tscn")
var ice_blast := preload("res://objects/ice_blast.tscn")
var wind_blast := preload("res://objects/wind_blast.tscn")
var earth_blast := preload("res://objects/earth_blast.tscn")

var ice_plat := preload("res://objects/ice_platform.tscn")
var earth_block := preload("res://objects/earth_block_s.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_started and not game_cleared: play_time += delta
	
	if not game_started and Input.is_action_just_pressed("shoot"): 
		game_started = true
		get_tree().paused = false
	
	if Input.is_action_just_pressed("pause") and G.game_started:
		get_tree().paused = not get_tree().paused
	
	if get_tree().paused: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func reset():
	game_started = false
	game_cleared = false
	play_time = 0.0
	death_count = 0
	respawn_location = Vector3.ZERO
	get_tree().reload_current_scene()


func bool_to_sign(input: bool) -> int:
	if input: return 1
	else: return -1
