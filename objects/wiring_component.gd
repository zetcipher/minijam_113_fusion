class_name WiringComponent extends Node3D

signal activation_changed(active: bool)

var activated := false

func set_active(active: bool):
	if active == activated: return
	activated = active
	emit_signal("activation_changed", active)
