extends InteractableObject


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("activation_changed", Callable(self, "set_flame"))
	set_flame(activated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_flame(on: bool):
	print("hi")
	if on: $FlameTorch/FlameMesh.show()
	else: $FlameTorch/FlameMesh.hide()
