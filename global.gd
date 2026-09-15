extends Node

var canInput : bool = true
var world : World
var player : Player
var activeMenu : Control

var mouseXY = 0.5

var items : Dictionary = {
	"dog": {
		"Name": "Dog",
		"Sprite": preload("res://dog.png"),
		"SpecialPickup": preload("res://VoiceLines/dog_bark.wav"),
	},
	"cowboy_hat": {
		"Name": "Cowboy Hat",
		"Sprite": preload("res://cowboy_hat.png"),
		"SpecialPickup": preload("res://VoiceLines/yeehaw.wav"),
	},
	"diamond": {
		"Name": "Diamond",
		"Sprite": preload("res://diamond.png"),
		"SpecialPickup": preload("res://VoiceLines/kaching.wav"),
	},
	"joy": {
		"Name": "JOY™",
		"Sprite": preload("res://joy_can.png"),
	},
}

var textTable = {
	"intro": {
		"Text": "Hey, I'm the Sign Man! Welcome to ONE TRILLION DOLLARS!\n\nUse WASD to walk around.",
		"Sound": preload("res://VoiceLines/intro.wav"),
		"Title": "Welcome!",
	},
	"wall": {
		"Text": "Oh boy, looks like that wall is in the way.\n\nJump into the wall with SPACE, and hold W to climb over it.",
		"Sound": preload("res://VoiceLines/wall.wav"),
		"Title": "Uh Oh!",
	},
	"joy": {
		"Text": "This is called JOY™, and it's important.\n\nTap E to pick one up, and hold E to eat one for a stamina boost.\n\nThey're heavy, so careful not to carry too much at once.",
		"Sound": preload("res://VoiceLines/joy.wav"),
		"Title": "JOY™",
	},
	"great_work": {
		"Text": "Great work! Climb the money pile and reach the top.\n\nTread Lightly.",
		"Sound": preload("res://VoiceLines/great_work.wav"),
		"Title": "Amazing!",
	},
	"a_casket": {
		"Text": "What do you call this in English? A casket. A coffin. Mmmm.\n\nWhat about this? A ghoul. A ghost. Mmm.\n\nWhat about this? A cadaver. A skeleton. Mmmmhh.\n\nAnd this? The cranium. A skull. Mmm.\n\nWhat about this? A manor. A haunted house. MMMm.\n\nAnd this? A cemetary. A graveyard. Mmm.\n\nWhat about this? Arachnid. A spider. Mh, Mh, mhmhmhmh.",
		"Sound": preload("res://VoiceLines/a_manor.wav"),
		"Title": "Easter Egg!",
	},
	"doghouse": {
		"Text": "Good evening sir. My dog has seemingly gone missing. Would you fetch him for me? I last saw him near a pile of bones.",
		"Title": "Missing Dog",
		"Sound": preload("res://VoiceLines/doghouse_greeting.wav"),
	},
	"doghouse_complete": {
		"Text": "Thank you so much! Looks like he found some new bones on his travels. You can take his old one.",
		"Title": "Safe at Last",
		"Sound": preload("res://VoiceLines/doghouse_complete.wav"),
	},
	"man_quest": {
		"Text": "What's GOOD my main man. This headwear is REALLY weighing me down. I need some NEW threads. Could you find one for me? Check out the OBELISK.",
		"Title": "New Threads",
		"Sound": preload("res://VoiceLines/man_greeting.wav"),
	},
	"man_complete": {
		"Text": "Rad, I knew you were cool dude. Here, take my old hat. SOOOOOEY!",
		"Title": "Sooey",
		"Sound": preload("res://VoiceLines/man_complete.wav"),
	},
	"quest_sewer": {
		"Text": "I hate not having everything I could ever imagine. I really need something shiny to flex with. Only a jewel of great danger suits me. Please?",
		"Title": "A Jewel?",
		"Sound": preload("res://VoiceLines/sewer_man_greeting.wav"),
	},
	"sewer_complete": {
		"Text": "Wow, that manhole was really muffling my voice. Thank you so much. You can take the lid.",
		"Title": "A New Man",
		"Sound": preload("res://VoiceLines/sewer_complete.wav"),
	},
}
func _enter_tree() -> void:
	get_tree().node_added.connect(connect_audio)


func connect_audio(node : Node):
	if node is Button:
		node.pivot_offset_ratio = Vector2(0.5, 0.5)
		node.pressed.connect(func(): $UIClick.play())
		node.mouse_entered.connect(func():
			node.scale = Vector2(1.1, 1.1)
			$UIHover.play()
		)
		node.mouse_exited.connect(func():
			node.scale = Vector2(1.0, 1.0)
		)
	
	if node is Menu:
		node.active_changed.connect(func(): $UIOpen.play())
	
	if node is Slider:
		node.pivot_offset_ratio = Vector2(0.5, 0.5)
		node.mouse_entered.connect(func():
			node.scale = Vector2(1.0, 1.25)
			$UIHover.play()
		)
		node.mouse_exited.connect(func():
			node.scale = Vector2.ONE
		)
		node.drag_started.connect(func(): $UIClick.play())
		node.drag_ended.connect(func(_val): $UIClick.play())


func play_success():
	$Success.play()


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)

signal menu_closed


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT || what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if Global.world:
			if canInput:
				Global.world.get_node("CanvasLayer/EscapeMenu").open()


func change_can_input(newState):
	canInput = newState
	
	if canInput:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
		if activeMenu:
			activeMenu.visible = false
			activeMenu = null
			menu_closed.emit()
	else:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
