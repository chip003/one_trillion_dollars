extends Sign

var itemCount : int = 0

func _ready() -> void:
	super()
	Global.player.inventory_changed.connect(update_item_count)
	update_item_count()


func update_item_count():
	itemCount = 0
	if Global.player.inventory.has("dumbell_left"): itemCount += 1
	if Global.player.inventory.has("dumbell_middle"): itemCount += 1
	if Global.player.inventory.has("dumbell_right"): itemCount += 1
	objectName = "{0}/3 Parts".format([itemCount])
	if itemCount >= 3:
		objectName = "3/3 Parts, End Game?"


func interact() -> void:
	if itemCount < 3: return
	Global.world.game_win()
