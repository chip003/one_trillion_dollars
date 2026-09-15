extends CanvasLayer

@export var world : World
@export var staminaBar : ProgressBar
@export var joyCounter : Label

func _ready() -> void:
	staminaBar.max_value = world.player.maxStamina
	Global.player.joy_changed.connect(func(): staminaBar.material.set_shader_parameter("active", Global.player.joyBoost > 0.0))
	Global.player.inventory_changed.connect(update_bar)
	update_bar()


func update_bar():
	if Global.player.inventory.has("dumbell_left"):
		$MarginContainer/HBoxContainer3/Left.texture = preload("res://dumbell_left.png")
	elif Global.player.inventory.has("cowboy_hat"):
		$MarginContainer/HBoxContainer3/Left.texture = preload("res://cowboy_hat.png")
	else:
		$MarginContainer/HBoxContainer3/Left.texture = null
	
	if Global.player.inventory.has("dumbell_middle"):
		$MarginContainer/HBoxContainer3/Middle.texture = preload("res://dumbell_middle.png")
	elif Global.player.inventory.has("dog"):
		$MarginContainer/HBoxContainer3/Middle.texture = preload("res://dog.png")
	else:
		$MarginContainer/HBoxContainer3/Middle.texture = null
	
	if Global.player.inventory.has("dumbell_right"):
		$MarginContainer/HBoxContainer3/Right.texture = preload("res://dumbell_right.png")
	elif Global.player.inventory.has("diamond"):
		$MarginContainer/HBoxContainer3/Right.texture = preload("res://diamond.png")
	else:
		$MarginContainer/HBoxContainer3/Right.texture = null


func _process(_delta: float) -> void:
	staminaBar.value = world.player.stamina
	joyCounter.text = "x" + str(Global.player.joyCount)
	$Crosshair/Prompt.visible = false
	$Crosshair/InteractWheel.visible = Global.player.interactTime > 0.0
	$Crosshair/InteractWheel.value = Global.player.interactTime
	
	if !Global.player.hoverObject: return
	
	if Global.player.hoverObject is Item:
		var objectName = Global.items[Global.player.hoverObject.itemID].get("Name", "Item")
		$Crosshair/Prompt.visible = true
		if Global.player.hoverObject.itemID == "joy":
			$Crosshair/Prompt/Grab.text = "Pickup/Use JOY™"
		else:
			$Crosshair/Prompt/Grab.text = "Pickup {0}".format([objectName])
		
	elif Global.player.hoverObject is Sign && Global.player.hoverObject.can_interact():
		$Crosshair/Prompt.visible = true
		$Crosshair/Prompt/Grab.text = Global.player.hoverObject.objectName


func _on_button_pressed() -> void:
	$TextPopup.visible = false
	Global.change_can_input(true)
