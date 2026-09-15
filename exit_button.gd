extends Button

func _ready() -> void:
	pressed.connect(func(): owner.close())


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if owner.active:
			owner.close()
