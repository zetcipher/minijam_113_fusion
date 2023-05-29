extends Area3D


func _on_body_entered(body):
	if body is Player: body.lava_zones += 1


func _on_body_exited(body):
	if body is Player: body.lava_zones -= 1
