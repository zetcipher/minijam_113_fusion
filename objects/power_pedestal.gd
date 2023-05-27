extends StaticBody3D

@export_range(0,3) var power := 0
@export var is_aspect := false


# Called when the node enters the scene tree for the first time.
func _ready():
	$PowerCrystal.set_power(power, is_aspect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
