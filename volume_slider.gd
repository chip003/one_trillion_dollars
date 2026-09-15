extends HSlider

@export var bus : String = "Master"
@export var valueLabel : Label
var index : int

func _ready() -> void:
	index = AudioServer.get_bus_index(bus)
	value = AudioServer.get_bus_volume_linear(index)
	update_label()


func _value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_linear(index, new_value)
	update_label()


func update_label():
	valueLabel.text = str(roundi(value * 100.0))
