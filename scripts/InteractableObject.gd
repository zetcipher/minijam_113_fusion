class_name InteractableObject extends WiringComponent

@export var ActionZone : InteractionZone


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(ActionZone != null)
