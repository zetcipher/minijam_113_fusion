extends Node3D

var readable_seconds := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	G.play_area_min = Vector3(-64, -16, -64)
	G.play_area_max = Vector3(64, 112, 64)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if G.game_started: $CanvasLayer.hide()
	else: $CanvasLayer.show()
	
	if G.game_cleared: $CanvasLayer2.show()
	else: $CanvasLayer2.hide()
	
	readable_seconds = snappedf(G.play_time, 0.01)
	var minutes := int(readable_seconds) / 60
	var seconds := str(readable_seconds - (minutes * 60)).pad_zeros(2)
	
	
	$CanvasLayer2/Control/Label.text = "CLEAR!!  Your time: " + str(minutes, ":", seconds) + "  Deaths: " + str(G.death_count)
