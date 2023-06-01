extends Control

var update_pending := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu/Control/renderResSlide.value = G.render_scale
	$PauseMenu/Control/CheckButton.button_pressed = G.vsync


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update_pending:
		G.render_scale = $PauseMenu/Control/renderResSlide.value
		$SubViewportContainer.stretch_shrink = G.render_scale
		if G.vsync:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		update_pending = false


func _on_render_res_slide_value_changed(value):
	G.render_scale = value
	$PauseMenu/Control/Label.text = "Render Scale - " + str(100.0 / value) + "%"
	update_pending = true


func _on_check_button_toggled(button_pressed):
	G.vsync = button_pressed
	update_pending = true
