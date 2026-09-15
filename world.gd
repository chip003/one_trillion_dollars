class_name World extends Node3D

var intro : bool = true
@export var player : Player
var burning = false:
	set(val):
		burning = val
		if val:
			$Fire.emitting = true
			$FireSound.play()

var mat : StandardMaterial3D

var gameOver : bool = false

func _enter_tree() -> void:
	Global.world = self

var cinematicCameraActive : bool = false
func cinematic_camera_start():
	cinematicCameraActive = true
	Global.change_can_input(false)
	$CameraAnchor/Camera3D.current = true
	$CanvasLayer.visible = false


func game_win():
	gameOver = true
	cinematic_camera_start()
	$WinTune.play()
	$WinVoice.play()
	$CanvasLayer2/VBoxContainer/RichTextLabel.text = "GOOD ENDING"
	show_game_over_menu()


func game_lose():
	gameOver = true
	cinematic_camera_start()
	$LoseTune.play()
	$LoseVoice.play()
	$CanvasLayer2/VBoxContainer/RichTextLabel.text = "BAD ENDING"
	show_game_over_menu()
	await get_tree().create_timer(11.0).timeout
	burning = true


var peopleHelped : int = 0
var joyFound : int = 0
var totalJoyCount : int = 0
var totalTime : float = 0.0

func show_game_over_menu():
	var time = Time.get_time_dict_from_unix_time(roundi(totalTime))
	var timestamp = "{0}hr, {1}min, {2}s".format([time.hour, time.minute, time.second])
	
	$CanvasLayer2.visible = true
	$CanvasLayer2/VBoxContainer/PanelContainer/Stats.append_text("People Helped: {0}/3\n".format([peopleHelped]))
	$CanvasLayer2/VBoxContainer/PanelContainer/Stats.append_text("JOY™ Found: {0}/{1}\n".format([joyFound, totalJoyCount]))
	$CanvasLayer2/VBoxContainer/PanelContainer/Stats.append_text("Climbing Time: {0}\n".format([timestamp]))


func cinematic_camera_end():
	cinematicCameraActive = false
	Global.change_can_input(true)
	Global.player.camera.current = true
	$CanvasLayer.visible = true


func _ready() -> void:
	$CanvasLayer/TextPopup.visible = false
	$CanvasLayer2.visible = false
	mat = $world_model/Cone.get_surface_override_material(0)
	cinematic_camera_start()
	Global.change_can_input(true)
	totalJoyCount = $Joys.get_children().size()
	$IntroJingle.play()
	await get_tree().physics_frame
	var tweener = create_tween()
	tweener.tween_property($Fade/Fade, "modulate:a", 0.0, 1.0)


func _process(delta: float) -> void:
	if burning:
		mat.albedo_color = mat.albedo_color.lerp(Color.BLACK, delta*1.0)
		#if mat.albedo_color.r < 0.01:

	totalTime += delta
	
	#if Input.is_action_just_pressed("jump"):
		#game_lose()
		#burning = true
		#cinematic_camera_start()
	
	if cinematicCameraActive:
		$CameraAnchor.rotation.y += 0.2*delta
	
	if Input.is_anything_pressed() && intro:
		cinematic_camera_end()
		intro = false
	
	if Input.is_action_just_pressed("escape") && !Global.activeMenu && !gameOver:
		await get_tree().physics_frame
		$CanvasLayer/EscapeMenu.open()


func splash():
	$CanvasLayer/Control/Water.emitting = true


func burn():
	$CanvasLayer/Control/Fire.emitting = true


func text_popup(textID : String):
	var title = Global.textTable.get(textID).get("Title", "NPC")
	var text = Global.textTable.get(textID).Text
	$CanvasLayer/TextPopup/VBoxContainer/HBoxContainer/Title.text = title
	$CanvasLayer/TextPopup/VBoxContainer/ScrollContainer/RichTextLabel.text = text
	$CanvasLayer/TextPopup.open()


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_button_2_pressed() -> void:
	get_tree().quit()
