class_name Item extends RigidBody3D

@export var grabbable : bool = true
@export var itemID : String = ""
var original : bool = true

func _ready() -> void:
	$Sprite3D.texture = Global.items[itemID].Sprite


func interact():
	pass


func can_interact():
	pass
