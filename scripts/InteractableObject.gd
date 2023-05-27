class_name InteractableObject extends StaticBody3D

signal activation_changed(active: bool)

@export var ActionZone : InteractionZone
@export var activated := false


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(ActionZone != null)


func set_active(active: bool):
	if active == activated: return
	activated = active
	emit_signal("activation_changed", active)
