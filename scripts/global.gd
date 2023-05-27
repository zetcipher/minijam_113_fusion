extends Node

signal power_updated(aspect: int, element: int)

enum Aspects {BASIC, HEAVY, BEAM, MELEE}
enum Elements {FIRE, ICE, WIND, EARTH}

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
		damage = 1.0,
	},
	{ # ice
		shot_speed = 0.2,
		shot_grav = 0.0,
		shot_accel = 0.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 0.1,
		blast_lift = 0.1,
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
		blast_force = 0.5,
		blast_lift = 0.5,
		damage = 1.0,
	},
	{ # ice
		shot_speed = 0.2,
		shot_grav = 0.0,
		shot_accel = 0.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 0.1,
		blast_lift = 0.1,
		damage = 1.5,
	},
	{ # wind
		shot_speed = 2.0,
		shot_grav = 1.0,
		shot_accel = 1.5,
		shot_scale = 1.5,
		blast_radius = 1.5,
		blast_force = 2.0,
		blast_lift = 5.0,
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
		damage = 2.5,
	},
]

var basic_shot := preload("res://objects/basic_shot.tscn")

var blast := preload("res://materials/object/blast.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


static func bool_to_sign(input: bool) -> int:
	if input: return 1
	else: return -1
