extends HSlider

@export var valueLabel : Label
var index : int

func _ready() -> void:
	value = 1.0
	update_label()


func _value_changed(new_value: float) -> void:
	get_window().content_scale_factor = new_value
	update_label()


func update_label():
	valueLabel.text = str(roundi(value * 100.0)) + "%"
