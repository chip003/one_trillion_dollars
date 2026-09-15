extends Sign

func _ready() -> void:
	super()
	$Dog.visible = false


func _completed():
	$Dog.visible = true
