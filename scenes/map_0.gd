extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if G.game_started: $CanvasLayer.hide()
	else: $CanvasLayer.show()
