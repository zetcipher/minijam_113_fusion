extends Node3D

signal opened()
signal closed()

@export var linked_wire : WiringComponent
@export var active_is_open := true

@export var open := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if linked_wire != null:
		if linked_wire.activated and active_is_open: open = true
		elif not linked_wire.activated and not active_is_open: open = true
		else: open = false
		
		linked_wire.connect("activation_changed", Callable(self, "handle_door"))
	
	if open: $Panel.position = Vector3(0,-1.75,-0.25)
	else: $Panel.position = Vector3(0,1.25,-0.25)
	
	

func handle_door(active: bool):
	if ((active and active_is_open) or (active and not active_is_open)) and not open: 
		open_door()
	elif open: 
		close_door()

func open_door():
	open = true
	$AnimationPlayer.play("open")
	emit_signal("opened")

func close_door():
	open = false
	$AnimationPlayer.play("close")
	emit_signal("closed")
