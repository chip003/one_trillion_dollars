extends CanvasLayer

var transition : Tween

var index = -1
var initial : bool = true

var phases = [
	{
		"Image": preload("res://Texture/intro_1.png"),
		"Text": "Society was at peace. Life was good.",
	},
	{
		"Image": preload("res://Texture/intro_2.png"),
		"Text": "But their greed for wealth drove them to destruction.",
	},
	{
		"Image": preload("res://Texture/intro_3.png"),
		"Text": "Now, in their pursuit, all that remains are paper ruins.",
	},
	{
		"Image": preload("res://Texture/intro_4.png"),
		"Text": "You adventurer, must climb the mountain. Seek what we have once lost.",
	},
]

func _ready() -> void:
	$MarginContainer.modulate.a = 0.0
	
	ResourceLoader.load_threaded_request("res://world.tscn")
	
	next()
	#transition = create_tween()
	#transition.tween_property($MarginContainer, "modulate:a", 1.0, 2.0)


func next():
	if transition:
		if transition.is_running(): return
	
	index += 1
	
	if index < phases.size():
		if !initial:
			$MarginContainer.modulate.a = 1.0
			if transition: transition.kill()
			transition = create_tween()
			transition.tween_property($MarginContainer, "modulate:a", 0.0, 2.0)
		
		if transition:
			await transition.finished
		
		$MarginContainer.modulate.a = 0.0
		if transition: transition.kill()
		transition = create_tween()
		transition.tween_property($MarginContainer, "modulate:a", 1.0, 2.0)
		
		var data = phases[index]
		$MarginContainer/VBoxContainer/RichTextLabel.text = data.Text
		$MarginContainer/VBoxContainer/TextureRect.texture = data.Image
		initial = false
	else:
		$MarginContainer.modulate.a = 1.0
		if transition: transition.kill()
		transition = create_tween()
		transition.set_parallel(true)
		transition.tween_property($MarginContainer, "modulate:a", 0.0, 4.0)
		transition.tween_property($AudioStreamPlayer, "volume_linear", 0.0, 4.0)
		
		await transition.finished
		
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://world.tscn"))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		next()
	
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://world.tscn"))
