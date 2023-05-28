class_name WireGate extends Node3D

signal activation_changed(active: bool)

enum LogicGates {AND, OR, NOR, A_NOT_B, B_NOT_A}

var reds := [Color(0.25,0.0,0.0,1.0),Color(1.0,0.0,0.0,1.0)]
var greens := [Color(0.0,0.25,0.0,1.0),Color(0.0,1.0,0.0,1.0)]

@export var input_a : InteractableObject
@export var input_b : InteractableObject
@export var logic := LogicGates.AND

var activated := false

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(input_a != null)
	assert(input_b != null)
	set_colors()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match logic:
		LogicGates.OR: 
			set_active(check_or())
			$Descriptor/Label3D.text = "OR"
		LogicGates.NOR: 
			set_active(check_nor())
			$Descriptor/Label3D.text = "NOR"
		LogicGates.A_NOT_B: 
			set_active(check_anotb())
			$Descriptor/Label3D.text = "A NOT B"
		LogicGates.B_NOT_A: 
			set_active(check_bnota())
			$Descriptor/Label3D.text = "B NOT A"
		_: 
			set_active(check_and())
			$Descriptor/Label3D.text = "AND"
	set_lights()
	


func set_colors():
	var mat_A := $LightA.material_override as ShaderMaterial
	var mat_B := $LightB.material_override as ShaderMaterial
	
	if logic == LogicGates.AND or logic == LogicGates.OR or logic == LogicGates.A_NOT_B:
		mat_A.set_shader_parameter("off_color", greens[0])
		mat_A.set_shader_parameter("on_color", greens[1])
	else:
		mat_A.set_shader_parameter("off_color", reds[0])
		mat_A.set_shader_parameter("on_color", reds[1])
	
	if logic == LogicGates.AND or logic == LogicGates.OR or logic == LogicGates.B_NOT_A:
		mat_B.set_shader_parameter("off_color", greens[0])
		mat_B.set_shader_parameter("on_color", greens[1])
	else:
		mat_B.set_shader_parameter("off_color", reds[0])
		mat_B.set_shader_parameter("on_color", reds[1])

func set_lights():
	var mat_A := $LightA.material_override as ShaderMaterial
	var mat_B := $LightB.material_override as ShaderMaterial
	var mat_C := $LightC.material_override as ShaderMaterial
	
	mat_A.set_shader_parameter("on", input_a.activated)
	mat_B.set_shader_parameter("on", input_b.activated)
	mat_C.set_shader_parameter("on", self.activated)



func check_and() -> bool:
	var result := false
	
	if input_a.activated and input_b.activated: result = true
	
	return result 

func check_or() -> bool:
	var result := false
	
	if input_a.activated or input_b.activated: result = true
	
	return result 

func check_nor() -> bool:
	var result := false
	
	if not input_a.activated and not input_b.activated: result = true
	
	return result 

func check_anotb() -> bool:
	var result := false
	
	if input_a.activated and not input_b.activated: result = true
	
	return result 

func check_bnota() -> bool:
	var result := false
	
	if not input_a.activated and input_b.activated: result = true
	
	return result 


func set_active(active: bool):
	if active == activated: return
	activated = active
	emit_signal("activation_changed", active)
