extends Node3D

func _ready() -> void:
	rotation.y = randf_range(0, TAU)
	scale *= randf_range(0.9, 1.2)
