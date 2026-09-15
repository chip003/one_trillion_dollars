class_name Menu extends PanelContainer

var active : bool = false

signal active_changed

func _ready() -> void:
	pivot_offset_ratio = Vector2(0.5, 0.5)
	visible = false


func close():
	if !active: return
	visible = false
	Global.change_can_input(true)
	active = false
	active_changed.emit()


var animTween : Tween


func open():
	if active: return
	active = true
	visible = true
	Global.change_can_input(false)
	Global.activeMenu = self
	active_changed.emit()
	
	modulate.a = 0.0
	scale = Vector2(0.5, 0.5)
	
	if animTween: animTween.kill()
	animTween = create_tween()
	animTween.set_parallel(true)
	animTween.set_trans(Tween.TRANS_SPRING)
	animTween.tween_property(self, "scale", Vector2.ONE, 0.2)
	animTween.tween_property(self, "modulate:a", 1.0, 0.2)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	close()


func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
