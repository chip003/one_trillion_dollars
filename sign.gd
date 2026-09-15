class_name Sign extends StaticBody3D

@export var textIDs : Array[String] = []
@export var neededItem : String = ""
@export var gives : String = ""
@export var objectName : String = "Sign Man"
var index = 0
@onready var audioPlayer : AudioStreamPlayer3D = get_node_or_null('AudioStreamPlayer3D')

func _ready() -> void:
	if audioPlayer:
		Global.menu_closed.connect(func(): 
			if $AudioStreamPlayer3D.stream:
				$AudioStreamPlayer3D.stop()
		)


func can_interact() -> bool:
	if !gives.is_empty():
		if Global.player.inventory.has(gives): return false
	return true


func _completed():
	pass


func interact() -> void:
	if !gives.is_empty():
		if Global.player.inventory.has(neededItem):
			index = 1
			Global.player.inventory.push_back(gives)
			Global.player.inventory_changed.emit()
			Global.play_success()
			Global.world.peopleHelped += 1
			_completed()
	
	Global.world.text_popup(textIDs[index])
	if audioPlayer:
		var sound = Global.textTable.get(textIDs[index]).get("Sound")
		if sound:
			$AudioStreamPlayer3D.stream = sound
		
		if $AudioStreamPlayer3D.stream:
			$AudioStreamPlayer3D.play()
