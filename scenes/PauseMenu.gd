extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().paused and G.game_started: show()
	else: hide()
	
	if Input.is_action_just_pressed("pause") and G.game_started:
		get_tree().paused = !get_tree().paused


func _on_button_pressed():
	get_tree().paused = false


func _on_button_2_pressed():
	G.reset()

func _on_button_3_pressed():
	get_tree().quit()

