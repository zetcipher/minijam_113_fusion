extends InteractableObject


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("activation_changed", Callable(self, "set_anim"))
	set_anim(activated)


func set_anim(active: bool):
	if active: $AnimationPlayer.play("frozen")
	else: $AnimationPlayer.play("flowing")
