extends Control

var update_pending := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu/Control/renderResSlide.value = G.render_scale
	$PauseMenu/Control/CheckButton.button_pressed = G.vsync
	$PauseMenu/Control/CheckButton2.button_pressed = G.occlusion


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update_pending:
		G.render_scale = $PauseMenu/Control/renderResSlide.value
		G.occlusion = $PauseMenu/Control/CheckButton2.button_pressed
		$SubViewportContainer.stretch_shrink = G.render_scale
		$SubViewportContainer/SubViewport.use_occlusion_culling = G.occlusion
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


func _on_check_button_2_toggled(button_pressed):
	G.occlusion = $PauseMenu/Control/CheckButton2.button_pressed
	update_pending = true
