class_name InteractionZone extends Area3D

@export var activated := false
@export var on_elements : Array[int] = [0]
@export var off_elements : Array[int] = [2]

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is InteractableObject: activated = get_parent().activated


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activation_check(area: Area3D):
	if not area is BasicProjectile and not area is Blast and not area is Beam:
		return
	
	var element : int = area.get("element")
	#assert(element == 0)
	print(element)
	
	if on_elements.has(element): activated = true
	if off_elements.has(element): activated = false
	
	if get_parent() is InteractableObject: get_parent().set_active(activated)

func _on_area_entered(area: Area3D):
	activation_check(area)
