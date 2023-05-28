extends StaticBody3D

var destroyed := false
var timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destroyed and timer < 1.0:
		timer += delta
	elif destroyed: queue_free()


func _on_area_3d_area_entered(area):
	if not area is Blast: return
	var blast := area as Blast
	if blast.destruction_power >= 1.0:
		destroyed = true
		$GPUParticles3D.emitting = true
		$CollisionShape3D.disabled = true
		$Area3D/CollisionShape3D.disabled = true
		$MeshInstance3D.hide()
