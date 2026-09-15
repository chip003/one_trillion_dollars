extends HSlider

@export var setting : String = "mouseXY"
@export var valueLabel : Label
var index : int

func _ready() -> void:
	value = Global.get(setting)
	update_label()


func _value_changed(new_value: float) -> void:
	Global.set(setting, new_value)
	update_label()


func update_label():
	valueLabel.text = str(roundi(value * 100.0)) + "%"
