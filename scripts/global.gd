extends Node

enum Aspects {BASIC, HEAVY, BEAM, MELEE}
enum Elements {FIRE, ICE, WIND, EARTH}

var element_energy_use := [1.0, 1.0, 1.0, 1.0]
var aspect_energy_use := [7.5, 33.4, 20.0, 20.0]

var element_mods := [
	{ # fire
		shot_speed = 1.5,
		shot_grav = 0.75,
		shot_accel = 1.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 1.0,
		blast_lift = 1.0,
		beam_length = 1.0,
		beam_width = 1.0,
		damage = 1.0,
	},
	{ # ice
		shot_speed = 1.0,
		shot_grav = 1.0,
		shot_accel = 1.0,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 1.0,
		blast_lift = 1.0,
		beam_length = 1.0,
		beam_width = 1.0,
		damage = 1.5,
	},
	{ # wind
		shot_speed = 2.0,
		shot_grav = 0.5,
		shot_accel = 0.5,
		shot_scale = 1.5,
		blast_radius = 1.5,
		blast_force = 2.0,
		blast_lift = 3.0,
		beam_length = 1.0,
		beam_width = 1.0,
		damage = 0.25,
	},
	{ # earth
		shot_speed = 1.0,
		shot_grav = 1.0,
		shot_accel = 1.5,
		shot_scale = 1.0,
		blast_radius = 1.0,
		blast_force = 1.0,
		blast_lift = 1.0,
		beam_length = 1.0,
		beam_width = 1.0,
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
