class_name bob extends CharacterBody3D
#
### Effects
#var activeEffects : Array[Dictionary] = []
#var addictions : Dictionary[String, Dictionary] = {}
#
#var speedMultiplier : float = 1.0
#var staminaMultiplier : float = 1.0
#var throwStrengthMultiplier : float = 1.0
#var vitalityMultiplier : float = 1.0
#var universalMultiplier : float = 1.0
#
#var cameraTarget : Node3D = null
#
#var hidden = false
#var chalkTimer = .2
#var zoomOffset : float = 0.0
#
#var regionID : String = "dl_region_surface"
#
#var selectedHotbar : int = -1
#var heldItemsData = [null, null, null]
#
#var itemInteracting = false
#
#@export var dialogue : RichTextLabel
#@export var staminaBar : ProgressBar
#@export var hotbarContainer : HBoxContainer
#var hotbarSlotCount = 4:
	#set(val):
		#hotbarSlotCount = val
		#update_hotbar()
#var hotbarSlots : Array[Control] = []
#
#func add_effect(effectID, days : int = -1, time : float = -1.0):
	#var effectData = Global.effectsTable.get(effectID)
	#
	#activeEffects.push_back({
		#"ID": effectID,
		#"Days": days,
		#"Time": time,
		#"SpeedMultiplier": effectData.get("SpeedMultiplier", 1.0),
		#"StaminaMultiplier": effectData.get("StaminaMultiplier", 1.0),
		#"ThrowStrengthMultiplier": effectData.get("ThrowStrengthMultiplier", 1.0),
		#"VitalityMultiplier": effectData.get("VitalityMultiplier", 1.0),
		#"UniversalMultiplier": effectData.get("UniversalMultiplier", 1.0),
	#})
#
#
#func update_hotbar():
	#for i in hotbarSlots:
		#i.queue_free()
	#
	#get_viewport().get_texture()
	#
	#for i in range(heldItemsData.size()-1, -1, -1):
		#if i > hotbarSlotCount-1:
			#create_hotbar_item(i)
	#
	#heldItemsData.resize(hotbarSlotCount)
	#hotbarSlots.clear()
	#selectedHotbar = 0
	#
	#for i in range(hotbarSlotCount):
		#var slot : HotbarSlot = preload("res://Scenes/hotbar_slot.tscn").instantiate()
		#hotbarSlots.push_back(slot)
		#slot.label.text = str(i+1)
		#hotbarContainer.add_child(slot) 
		#set_hotbar(i)
	#
	#set_hotbar(0)
#
#
#func get_effect_count(effectID) -> int:
	#var count = 0
	#for i in range(activeEffects.size()-1, -1, -1):
		#if activeEffects[i].ID == effectID:
			#count += 1
	#return count
#
#
#func remove_effect(effectID):
	#for i in range(activeEffects.size()-1, -1, -1):
		#if activeEffects[i].ID == effectID:
			#activeEffects.remove_at(i)
			#break
#
#
#func remove_all_effect(effectID):
	#for i in range(activeEffects.size()-1, -1, -1):
		#if activeEffects[i].ID == effectID:
			#activeEffects.remove_at(i)
#
#
#func refresh_addiction(itemID):
	#if Global.player.addictions.has(itemID):
		#Global.player.addictions[itemID].Days = 0
	#else:
		#Global.player.addictions[itemID] = {"Days": 0}
#
#
### Camera
#var targetFOV = 90.0
#@export var camera : Camera3D
#@onready var cameraStartY = camera.position.y
#var cameraSensitivity = 0.01
#var cameraShake = 0.0
#var cameraOffset = Vector3.ZERO
#var maxSpeed : float = 3.0
#
#enum STATES{WALKING, IDLE, RUNNING, CROUCHING}
#@export var currentState = STATES.IDLE
#
### Movement
#var moveSpeed = 256.0
#var inAir = false
#var bobbing = 0.0
#
#var maxHP = 10.0
#var hp = 10.0
#var maxStamina = 1.0
#var stamina = 1.0
#var staminaRegenDelay = 2.0
#var curStaminaRegenDelay = 0.0
#
#var isSprinting = false
#
#var dead = false
#var canTakeDamage = true
#
#var interactHover = true
#var interactOffset = 0.0
#
#var moving = false
#
#var inputBlocks = {}
#var input : Vector2
#var canInput = true
#
#signal air_entered
#signal landed
#signal awoken
#
#var heldItem : Item
#var heldItemOffset = Vector2.ZERO
#var throwPower = 0.0
#var limpValue = 1.0
#var inTablet = false
#
#var targetEyesOpen = 1.0
#var eyesOpen = 0.0
#
#var footstepSounds = [
	#preload("res://Sounds/Effects/footstep_1.wav"),
	#preload("res://Sounds/Effects/footstep_2.wav"),
	#preload("res://Sounds/Effects/footstep_3.wav"),
	#preload("res://Sounds/Effects/footstep_4.wav"),
	#preload("res://Sounds/Effects/footstep_5.wav"),
#]
#
#func _enter_tree() -> void:
	#Global.player = self
#
#
#func _ready() -> void:
	#if !Global.settings.get("ShowTutorial", true):
		#$CanvasLayer/MarginContainer.visible = false
	#
	#heldCameraTexture = $CameraView.get_texture()
	#$CanvasLayer/CameraScreen/HBoxContainer/MarginContainer/TextureRect.texture = heldCameraTexture
	#
	#finish_task("")
	#update_hotbar()
	#
	#$Dialogue.char_displayed.connect(func(c): dialogue.text += c)
	#
	#$CanvasLayer/Red.visible = true
	#camera.current = true
	#Global.activeCamera = camera
	#speak("Finally, I've found it")
	#Global.world.day_passed.connect(update_days)
	#$CanvasLayer/Eyes.visible = true
	##take_damage(2.0)
	##take_damage(2.0)
	##take_damage(2.0)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Global.world.power_out.connect(func():
		#if Global.world.level == 1:
			#speak("Damn, no power. Gotta be a breaker somewhere.")
	#)
#
#
#func new_day_message():
	#await get_tree().create_timer(1.0).timeout
	#
	#if get_effect_count("mg.effect.hunger") > 1:
		#speak("Im so hungry, I feel weak.")
	#elif get_effect_count("mg.effect.thirst") > 1:
		#speak("Im so thirsty, I feel weak.")
	#elif addictions.size() > 0:
		#var list = []
		#for i in addictions:
			#if addictions[i].Days > 0:
				#list.push_back(i)
		#
		#if list.size() > 0:
			#var addictionID = list.pick_random()
			#var itemData = Global.itemsTable.get(addictionID)
			#speak("I'm really craving a {0}".format([itemData.Name]))
#
#
#func take_damage(severity : float):
	#if Global.debug: return
	#
	#var damage = randfn(severity, 0.5)
	#
	#if damage >= 2:
		#cameraShake = 20.0
		#add_effect(Global.majorInjuries.pick_random())
	#else:
		#cameraShake = 5.0
		#add_effect(Global.minorInjuries.pick_random(), randi_range(1, 3))
	#
	#$PlayerHurt.play()
	#Global.create_audio_event(global_position, 1.0, true)
#
#
#func update_days():
	#for i in range(activeEffects.size()-1, -1, -1):
		#var effect = activeEffects[i]
		#if effect.Days > 0:
			#effect.Days = clampi(effect.Days - 1, 0, 99999999)
	#
	#remove_all_effect("mg.effect.withdrawl")
	#for i in addictions:
		#if addictions[i].Days > 0:
			#add_effect("mg.effect.withdrawl")
#
#
#var dialogueTween
#
#
#func speak(text : String):
	#dialogue.text = "[color=yellow]"
	#$Dialogue.speak(text)
	#$CanvasLayer/VBoxContainer/CloseDialogue.visible = true
	#dialogue.modulate.a = 0.0
	#
	#if dialogueTween:
		#dialogueTween.kill()
	#
	#dialogueTween = create_tween()
	#dialogueTween.set_parallel(true)
	#dialogueTween.tween_property(dialogue, "modulate:a", 1.0, 0.1)
	#dialogueTween.tween_property($CanvasLayer/VBoxContainer/CloseDialogue, "modulate:a", 0.5, 1.0)
#
#
#func fall_asleep(length = 0.0):
	#inputBlocks["Asleep"] = true
	#
	#if Global.debug:
		#await get_tree().physics_frame
		#inputBlocks["Asleep"] = false
		#awoken.emit()
		#return
	#
	#var sleepTween : Tween = create_tween()
	#sleepTween.set_parallel(true)
	#sleepTween.set_trans(Tween.TRANS_BOUNCE)
	#sleepTween.tween_property(self, "targetEyesOpen", 0.0, 1.0)
	#sleepTween.tween_method(set_world_volume, 1.0, 0.0, 1.0)
	#sleepTween.chain().tween_interval(length)
	#sleepTween.chain().tween_callback(func(): 
		#inputBlocks["Asleep"] = false
		#awoken.emit()
	#)
	#sleepTween.tween_method(set_world_volume, 0.0, 1.0, 3.0)
	#sleepTween.tween_property(self, "targetEyesOpen", 1.0, 6.0)
#
#
#func set_world_volume(val):
	#var index = AudioServer.get_bus_index("WorldSFX")
	#AudioServer.set_bus_volume_linear(index, val)
#
#
#func use_stamina(amount) -> bool:
	#if amount <= stamina:
		#stamina -= amount/staminaMultiplier
		#curStaminaRegenDelay = 1.0
		#return true
	#return false
#
#
#var flashlightActive = true
#var canStand = true
#var redVignette = 0.0
#var hiddenVignette = 0.0
#
#var lastCamRotation : Vector3 = Vector3.ZERO
#
#var heldCameraTexture : Texture2D
#
#func _process(delta: float) -> void:
	#speedMultiplier = 1.0
	#staminaMultiplier = 1.0
	#throwStrengthMultiplier = 1.0
	#vitalityMultiplier = 1.0
	#universalMultiplier = 1.0
	#
	#$CameraView/HeldCamera.global_position = camera.global_position
	#$CameraView/HeldCamera.global_rotation = camera.global_rotation
	#
#
	#
	##if Input.is_action_just_pressed("test"):
		##if hotbarSlotCount < 5:
			##hotbarSlotCount = 5
		##else:
			##hotbarSlotCount = 2
	#
	#var staminaAlpha = 0.0
	#if stamina < maxStamina:
		#staminaAlpha = 0.5
	#
	#$CanvasLayer/VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer.modulate.a = lerpf($CanvasLayer/VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer.modulate.a, staminaAlpha, 3*delta)
	#staminaBar.value = stamina
	#staminaBar.max_value = maxStamina
	#
	#$Camera3D/Flashlight.spot_angle = 40
	#$Camera3D/Flashlight.spot_range = 14
	#$Camera3D/Flashlight.light_energy = 0.75
	#
	#if heldItem:
		#if heldItem.itemID == "mg.item.improved_flashlight":
			#$Camera3D/Flashlight.spot_range = 18
			#$Camera3D/Flashlight.spot_angle = 60
			#$Camera3D/Flashlight.light_energy = 1.25
#
	#if Input.is_action_just_pressed("dismiss_dialogue"):
		#if dialogue.modulate.a >= 1.0:
			#$Dialogue.cancel_dialogue()
			#if dialogueTween: dialogueTween.kill()
			#dialogueTween = create_tween()
			#dialogueTween.set_parallel(true)
			#dialogueTween.tween_property($CanvasLayer/VBoxContainer/CloseDialogue, "modulate:a", 0.0, 0.5)
			#dialogueTween.tween_property(dialogue, "modulate:a", 0.0, 0.5)
	#
	#if Input.is_action_just_pressed("scroll_left"):
		#set_hotbar(clampi(selectedHotbar - 1, 0, hotbarSlotCount-1))
		#
	#if Input.is_action_just_pressed("scroll_right"):
		#set_hotbar(clampi(selectedHotbar + 1, 0, hotbarSlotCount-1))
	#
	#if Input.is_action_just_pressed("hotbar_1"):
		#set_hotbar(0)
	#elif Input.is_action_just_pressed("hotbar_2"):
		#set_hotbar(1)
	#elif Input.is_action_just_pressed("hotbar_3"):
		#set_hotbar(2)
#
	#if !Global.world.doorsOpen && Global.player:
		#if Global.player.global_position.z > 0:
			#Global.player.global_position.z = 0
	#
	#var tilePos = Global.global_to_map(global_position)
	#
	#
	#var tileData = Global.world.mapCoords.get(Vector2i(tilePos.x, tilePos.z))
	#if Global.world.surface:
		#regionID = "dl_region_surface"
	#else:
		#if tileData:
			#regionID = tileData.RegionID
		#else:
			#regionID = "dl_region_elevator"
	#
	#for i in range(activeEffects.size()-1, -1, -1):
		#var effect = activeEffects[i]
		#if effect.Time > 0.0:
			#effect.Time = clampf(effect.Time - delta, 0.0, INF)
		#
		#if effect.Days == 0 || effect.Time == 0.0:
			#activeEffects.remove_at(i)
			#continue
		#
		#universalMultiplier -= (1-effect.UniversalMultiplier)
		#speedMultiplier -= (1-effect.SpeedMultiplier)
		#staminaMultiplier -= (1-effect.StaminaMultiplier)
		#throwStrengthMultiplier -= (1-effect.ThrowStrengthMultiplier)
		#vitalityMultiplier -= (1-effect.VitalityMultiplier)
	#
	#universalMultiplier = max(0.0, universalMultiplier)
	#speedMultiplier = max(0.1, speedMultiplier*universalMultiplier)
	#staminaMultiplier = max(0.0, staminaMultiplier*universalMultiplier)
	#throwStrengthMultiplier = max(0.1, throwStrengthMultiplier*universalMultiplier)
	#vitalityMultiplier = max(0.0, vitalityMultiplier*universalMultiplier)
	#
	#if vitalityMultiplier <= 0.0:
		#die()
	#
	#interactOffset = lerpf(interactOffset, 0.0, 10.0*delta)
	#interactHover = false
	#
	#eyesOpen = lerpf(eyesOpen, targetEyesOpen, 10*delta)
	#$CanvasLayer/Eyes.material.set_shader_parameter("open_amount", eyesOpen)
	#
	#redVignette = lerpf(redVignette, (1-vitalityMultiplier)*1.1, 1*delta)
	#$CanvasLayer/Red.material.set_shader_parameter("radius", redVignette)
	#
	#var breathingVol = clampf(pow(maxStamina-stamina, 8.0), 0.0, 1.0)
	#$Breathing.set_volume_linear(breathingVol)
	#
	#if hidden:
		#$CanvasLayer/Hidden.visible = true
		#hiddenVignette = lerpf(hiddenVignette, 0.3, 1*delta)
	#else:
		#hiddenVignette = lerpf(hiddenVignette, 1.0, 1*delta)
		#$CanvasLayer/Hidden.visible = false
	#
	#$CanvasLayer/HiddenVignette.material.set_shader_parameter("radius", hiddenVignette)
	#
	#if Global.world.travelling:
		#cameraShake = 0.5
	#
	#if inTablet && Global.tablet.activeRover:
		#Global.activeCamera = Global.tablet.activeRover.cameraAnchor
	#else:
		#Global.activeCamera = camera
	#
	#if is_on_floor():
		#if inAir:
			#inAir = false
			#landed.emit()
			#cameraOffset.y = -1
	#elif !inAir:
		#inAir = true
		#air_entered.emit()
		#cameraOffset.y = 1
	#
	#if dead:
		#if rotation.z > -PI/2:
			#rotation.z -= 2*delta
		#else:
			#Global.world.open_death_menu()
		#inputBlocks["Dead"] = true
	#else:
		#var hungerCount = 0
		#var thirstCount = 0
		#for i in activeEffects:
			#if i.ID == "mg.effect.hunger":
				#hungerCount += 1
			#if i.ID == "mg.effect.thirst":
				#thirstCount += 1
		#
		#if hungerCount > 2 || thirstCount > 2:
			#die()
		#
		#canInput = true
		#for i in inputBlocks:
			#if inputBlocks[i]:
				#canInput = false
#
		#input = Vector2.ZERO
		#if canInput && !Global.paused:
			#input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").rotated(-rotation.y)/5.0
		#
		#if input != Vector2.ZERO:
			#finish_task("move")
			#currentState = STATES.WALKING
			#moving = true
		#else:
			#currentState = STATES.IDLE
			#moving = false
		#
		#isSprinting = false
		#
		#if (Input.is_action_pressed("crouch") && !Global.paused) || !canStand:
			#finish_task("crouch")
			#currentState = STATES.CROUCHING
			#$CollisionCrouch.disabled = false
			#$CollisionStand.disabled = true
			#$CrouchCheck.enabled = true
		#else:
			#$CollisionCrouch.disabled = true
			#$CollisionStand.disabled = false
			#$CrouchCheck.enabled = false
		#
		#var bobRate = 40
		#if !Global.paused:
			#if Input.is_action_pressed("sprint") && input != Vector2.ZERO && canInput && currentState != STATES.CROUCHING:
				#if use_stamina(0.1*delta):
					#currentState = STATES.RUNNING
					#isSprinting = true
		#
		#if isSprinting:
			#targetFOV = Global.settings.get("FOV") + 10
			#bobbing += 16.0*delta
			#bobRate = 20
		#elif inputBlocks.get("Terminal", false):
			#targetFOV = 50.0
		#else:
			#bobbing += 4.0*delta
			#targetFOV = Global.settings.get("FOV")
			#if heldItem:
				#if heldItem is Tablet:
					#targetFOV = 40.0
		#
		#limpValue = Global.sin_range(speedMultiplier, min(1.0, speedMultiplier*3.0), bobbing)
		#
		#if !dead:
			#if moving:
				#var limpTarget = 0.0
				#var limpAngleLimit = (1-speedMultiplier)/3.0
				#if currentState == STATES.RUNNING:
					#limpTarget = Global.sin_range(-limpAngleLimit, limpAngleLimit, bobbing/2.0)
				#else:
					#limpTarget = Global.sin_range(-limpAngleLimit, limpAngleLimit, bobbing)
				#rotation.z = lerpf(rotation.z, limpTarget, 2*delta)
			#else:
				#rotation.z = lerpf(rotation.z, 0, 1*delta)
		#
		#zoomOffset = 0.0
		#if !Global.paused:
			#if Input.is_action_pressed("zoom"):
				#if is_instance_valid(heldItem) && heldItem is Tablet:
					#zoomOffset = 20.0
				#else:
					#zoomOffset = targetFOV/1.5
		#
		#cameraShake = lerpf(cameraShake, 0, 10*delta)
		#camera.fov = lerpf(camera.fov, targetFOV-zoomOffset, 10*delta)
		#cameraOffset = cameraOffset.lerp(Vector3.ZERO, 10*delta)
		#var bobbingModifier = 4*int(isSprinting)
		#var bobOffset = Global.sin_range(bobbingModifier-1, bobbingModifier+1, bobbing)/bobRate
		#
		#
		#if currentState == STATES.CROUCHING:
			#cameraOffset.y = -1
		#
		#if cameraTarget:
			#camera.global_position = lerp(camera.global_position, cameraTarget.global_position, 10*delta)
			#camera.global_rotation = lerp(camera.global_rotation, cameraTarget.global_rotation, 10*delta)
		#else:
			#camera.position = camera.position.lerp(Vector3(randf_range(-cameraShake, cameraShake),cameraStartY + bobOffset, -0.1) + cameraOffset, 10*delta)
		#
		#if curStaminaRegenDelay <= 0:
			### stamina can be regen
			#if stamina <= maxStamina:
				#stamina += 0.2*delta
		#elif is_on_floor():
			#curStaminaRegenDelay -= 1*delta
	#
		#if !Global.paused:
			#if Input.is_action_just_pressed("flashlight"):
				#finish_task("flashlight")
				#if flashlightActive:
					#flashlightActive = false
					#$Camera3D/Flashlight.visible = false
				#else:
					#flashlightActive = true
					#$Camera3D/Flashlight.visible = true
				#$FlashlightClick.play()
		#
		#if currentState == STATES.WALKING:
			#$FootstepTimer.wait_time = 0.75
		#elif currentState == STATES.RUNNING:
			#$FootstepTimer.wait_time = 0.3
		#elif currentState == STATES.CROUCHING:
			#$FootstepTimer.wait_time = 1.0
#
#
#func set_camera_target(target : Node3D):
	#cameraTarget = target
	#
	#if !target:
		#camera.global_rotation = lastCamRotation
	#else:
		#lastCamRotation = camera.global_rotation
#
#
#func set_hotbar(hotbarIndex : int):
	#if hotbarIndex == selectedHotbar: return
	#if selectedHotbar > -1:
		#var lastHotBar : PanelContainer = hotbarSlots[selectedHotbar]
		#lastHotBar.set_custom_minimum_size(Vector2.ZERO)
		#lastHotBar.size = Vector2.ZERO
		#lastHotBar.self_modulate = Color("000000aa")
		#lastHotBar.modulate.a = 0.25
#
		#if heldItem:
			#heldItem.queue_free()
	#
	#var hotBarSlot : PanelContainer = hotbarSlots[hotbarIndex]
	#hotBarSlot.custom_minimum_size = Vector2(80, 80)
	#hotBarSlot.size = Vector2(80, 80)
	#selectedHotbar = hotbarIndex
	#hotBarSlot.self_modulate = Color("3d3d3daa")
	#hotBarSlot.modulate.a = 1.0
	#
	#var item = create_hotbar_item(hotbarIndex)
	#if item != null:
		#pickup_item(item)
#
#
#func create_hotbar_item(index : int) -> Node3D:
	#var item
	#if heldItemsData[index] != null:
		#var itemData = heldItemsData[index]
		#item = Global.world.create_item(itemData.ID, global_position + Vector3(0.0, 0.5, 0.0), itemData.Data)
		#item.set_physics_process(true)
	#return item
#
#func die():
	#if !dead:
		#axis_lock_angular_y = false
		#dead = true
		#velocity = Vector3.ZERO
		#input = Vector2.ZERO
		#cameraShake = 2.0
		#print("Youch!")
		#$Breathing.stop()
#
#
#var lastHover
#
#
#var chalkTextures = [
	#preload("res://Sprites/chalk_blob.png"),
	#preload("res://Sprites/chalk_blob_2.png"),
	#preload("res://Sprites/chalk_blob_3.png"),
#]
#
#var lastChalkCollision : Vector3 = Vector3.ZERO
#
#func _physics_process(delta: float) -> void:
	#var sprintMod = 2.5 if isSprinting else 1.0
	#var moveChange = Vector3.ZERO
	#
	#$CanvasLayer/CameraScreen.visible = false
	#
	#$CanvasLayer/VBoxContainer/HBoxContainer/Prompt.modulate.a = clampf(float(heldItem != null), 0.0, 0.25)
	#
	#if Global.debug:
		#maxSpeed = 10
	#else:
		#maxSpeed = 3.0
	#
	#hidden = $SneakCheck.get_overlapping_areas().size() > 0 && currentState
	#
	#canStand = true
	#if $CrouchCheck.enabled:
		#if $CrouchCheck.get_collision_count() > 0:
			#canStand = false
	#
	#if currentState == STATES.CROUCHING:
		#moveChange = Vector3(input.x, 0, input.y)*delta*moveSpeed/5.0 * limpValue
	#else:
		#moveChange = Vector3(input.x, 0, input.y)*delta*moveSpeed*sprintMod*limpValue
	#
	#if (velocity + moveChange).length() < maxSpeed * sprintMod * limpValue:
		#velocity += moveChange
	#velocity.y -= 15*delta
	#velocity = velocity.lerp(Vector3(0,velocity.y,0), 1-pow(0.001,delta))
		#
	#$CanvasLayer/ThrowProgress.visible = false
	#$CanvasLayer/ColorRect/Label.visible = false
	#$CanvasLayer/ColorRect/InteractPrompt.visible = false
	#$CanvasLayer/ColorRect/InteractPrompt.position.x = -($CanvasLayer/ColorRect/InteractPrompt.size/2.0).x + 2
	#var objectFound = false
	#itemInteracting = false
	#if !Global.paused && canInput:
		#var promptText = ""
		#var result = $Camera3D/RayCast3D.get_collider()
		#if result:
			#var colPoint : Vector3 = $Camera3D/RayCast3D.get_collision_point()
			#var colNormal : Vector3 = $Camera3D/RayCast3D.get_collision_normal()
			#if result is Interactable:
				#if lastHover:
					#if is_instance_valid(lastHover):
						#lastHover.hovered = false
						#lastHover = null
				#
				#if result.can_interact():
					#lastHover = result
					#result.hovered = true
					#objectFound = true
					#
					#$CanvasLayer/ColorRect/InteractPrompt.visible = true
					#$CanvasLayer/ColorRect/InteractPrompt.text = result.prompt
					#$CanvasLayer/ColorRect/Label.visible = true
					#if Input.is_action_just_pressed("interact"):
						#result.interact()
			#elif result is Item && !heldItem && result.canGrab:
				#if lastHover:
					#if is_instance_valid(lastHover):
						#lastHover.hovered = false
						#lastHover = null
						#
				#if result is Item2D:
					#lastHover = result
					#result.hovered = true
					#objectFound = true
				#
				#$CanvasLayer/ColorRect/InteractPrompt.visible = true
				#$CanvasLayer/ColorRect/InteractPrompt.text = result.prompt
				#$CanvasLayer/ColorRect/Label.visible = true
				#if Input.is_action_just_pressed("interact"):
					#pickup_item(result)
			#
			#elif result.get_collision_layer_value(8):
				#if heldItem && heldItem.itemID == "mg.item.note":
					#promptText += "Pin Note [LMB]\n"
					#if Input.is_action_just_pressed("interact_click"):
						#var item = heldItem
						#drop_item()
						#item.global_position = colPoint + ((colNormal/10.0) * randf_range(0.9, 1.1))
						#item.look_at(colPoint + colNormal, Vector3.UP, true)
						#item.pin(true)
			#elif throwPower <= 0.0:
				#if heldItem && heldItem.itemData.HeldAction:
					#if Input.is_action_just_pressed("interact_click"):
						#lastChalkCollision = Vector3.ZERO
						#
					#var chalkReady = colPoint.distance_squared_to(lastChalkCollision) > 0.01
					#
					#if heldItem.itemID == "mg.item.chalk":
						#promptText += "Use Chalk [LMB]\n"
						#if Input.is_action_pressed("interact_click"):
							#itemInteracting = true
							#if chalkReady:
								#var chalk : Decal = preload("res://Scenes/chalk_mark.tscn").instantiate()
								#chalk.texture_albedo = chalkTextures.pick_random()
								#Global.world.add_child(chalk)
								#chalk.global_position = colPoint
								#lastChalkCollision = colPoint
								#itemInteracting = true
								#
								#if !colNormal.is_equal_approx(Vector3.UP):
									#chalk.look_at(colPoint + colNormal, Vector3.UP)
									#chalk.transform = chalk.transform.rotated_local(Vector3.RIGHT, PI/2.0)
								#chalk.rotate(colNormal, randf_range(-TAU, TAU))
						#
					#elif heldItem.itemID == "mg.item.chalk_eraser":
						#promptText += "Use Chalk Eraser[LMB]\n"
						#if Input.is_action_pressed("interact_click"):
							#itemInteracting = true
							#if chalkReady:
								#var eraser : Area3D = preload("res://Scenes/chalk_erase.tscn").instantiate()
								#Global.world.add_child(eraser)
								#eraser.global_position = colPoint
								#lastChalkCollision = colPoint
#
		#if heldItem:
			#if throwPower <= 0.0:
				#if heldItem.itemID == "mg.item.camera":
					#if Input.is_action_pressed("click_right"):
						#$CanvasLayer/CameraScreen.visible = true
				#elif heldItem.itemID == "mg.item.bandage":
					#var validEffects : Array[String] = []
					#for i in activeEffects:
						#if Global.effectsTable.get(i.ID).Groups.has("MinorInjury"):
							#validEffects.push_back(i.ID)
					#
					#if validEffects.size() > 0:
						#promptText += "Use Bandage [LMB]\n"
						#if Input.is_action_just_pressed("interact_click"):
							#for i in range(2):
								#if validEffects.size() > 0:
									#var effectID = validEffects.pick_random()
									#validEffects.erase(effectID)
									#remove_effect(effectID)
							#destroy_held_item(true)
				#elif heldItem.itemID == "mg.item.medkit":
					#var validEffects : Array[String] = []
					#for i in activeEffects:
						#if Global.effectsTable.get(i.ID).Groups.has("MinorInjury"): validEffects.push_back(i.ID)
						#if Global.effectsTable.get(i.ID).Groups.has("MajorInjury"): validEffects.push_back(i.ID)
					#
					#if validEffects.size() > 0:
						#promptText += "Use Medkit [LMB]\n"
						#if Input.is_action_just_pressed("interact_click"):
							#for i in validEffects:
								#remove_effect(i)
							#destroy_held_item(true)
				#elif heldItem.itemID == "mg.item.inhaler":
					#if stamina < maxStamina:
						#promptText += "Use Inhaler [LMB]\n"
						#if Input.is_action_just_pressed("interact_click"):
							#stamina = maxStamina
							#destroy_held_item(true)
			#
			#promptText += "Throw Item [Q]\n"
		#
		#$CanvasLayer/VBoxContainer/HBoxContainer/Prompt.text = promptText
		#
		#if heldItem:
			#if Input.is_action_pressed("drop"):
				#throwPower += delta
				#$CanvasLayer/ThrowProgress.visible = true
				#$CanvasLayer/ThrowProgress.value = throwPower
				#
			#if Input.is_action_just_released("drop") || throwPower >= 1.0:
				#drop_item()
		#
	#if heldItem:
		#heldItem.global_rotation.x = lerp_angle(heldItem.global_rotation.x, $Camera3D/Hand.global_rotation.x, 100*delta)
		#heldItem.global_rotation.y = lerp_angle(heldItem.global_rotation.y, $Camera3D/Hand.global_rotation.y, 100*delta)
		#heldItem.global_rotation.z = lerp_angle(heldItem.global_rotation.z, $Camera3D/Hand.global_rotation.z, 100*delta)
		#
		#if heldItem.freeze:
			#$Camera3D/Hand.position = heldItem.positionOffset
			#heldItem.global_position = $Camera3D/Hand.global_position#heldItem.global_position.lerp($Camera3D/Hand.global_position, 10*delta)
		#else:
			#if itemInteracting:
				#$Camera3D/Hand.position = heldItem.positionOffset
				#$Camera3D/Hand.position.x /= 2.0
				#$Camera3D/Hand.position.y /= 2.0
			#elif throwPower > 0 || (heldItem.itemID == "mg.item.note" && zoomOffset > 0.0):
				#$Camera3D/Hand.position = Vector3.FORWARD
			#else:
				#$Camera3D/Hand.position = heldItem.positionOffset
				#
			#var distPow = heldItem.global_position.distance_to($Camera3D/Hand.global_position)/6.0
			#heldItem.linear_velocity = heldItem.global_position.direction_to($Camera3D/Hand.global_position)*10000.0*distPow*delta*throwStrengthMultiplier
			#heldItem.angular_velocity = Vector3.ZERO
#
	#if !objectFound:
		#if lastHover:
			#if is_instance_valid(lastHover):
				#lastHover.hovered = false
				#lastHover = null
#
	#move_and_slide()
#
#
#func destroy_held_item(consumed : bool = false):
	#var item = heldItem
	#drop_item()
	#item.queue_free()
	#if consumed:
		#Global.world.itemsConsumed += 1
#
#
#func pickup_item(item : Item):
	#if item is Tablet:
		#inTablet = true
	#
	#item.pin(false)
	#
	#heldItemsData[selectedHotbar] = {
		#"ID": item.itemID,
		#"Data": item.data,
	#}
	#var itemData = Global.itemsTable.get(item.itemID)
	#var hotBarSlot : PanelContainer = hotbarSlots[selectedHotbar]
	#hotBarSlot.get_node("TextureRect").texture = itemData.Sprite
	#
	#heldItem = item
	#item.pickup()
	#throwPower = 0.0
	#finish_task("pickup")
#
#
#var taskList = {
	#"move": "- [WASD] move",
	#"crouch": "- [CTRL] crouch/hide",
	#"pickup": "- [E] interact/pickup",
	#"throw": "- [Q] throw",
	#"flashlight": "- [F] flashlight",
#}
#
#var tasksFinished = []
#var taskTween : Tween
#
#func finish_task(taskID : String):
	#if !tasksFinished.has(taskID):
		#if taskList.has(taskID):
			#tasksFinished.push_back(taskID)
	#
		#$CanvasLayer/MarginContainer/RichTextLabel.text = ""
		#
		#$CanvasLayer/MarginContainer/RichTextLabel.append_text("[center]Controls[/center]\n")
		#for i in taskList:
			#var string = taskList.get(i)
			#if tasksFinished.has(i):
				#$CanvasLayer/MarginContainer/RichTextLabel.append_text("[s][color=gray]" + string + "[/color][/s]")
			#else:
				#$CanvasLayer/MarginContainer/RichTextLabel.append_text(string)
			#$CanvasLayer/MarginContainer/RichTextLabel.append_text("\n")
			#
	#if tasksFinished.size() >= taskList.size():
		#if !taskTween:
			#taskTween = create_tween()
			#taskTween.tween_property($CanvasLayer/MarginContainer/RichTextLabel, "modulate:a", 0.0, 1.0)
#
#
#func drop_item():
	#if heldItem:
		#finish_task("throw")
		#inTablet = false
		##heldItem.global_position = camera.global_position
		#heldItem.drop()
		#heldItem.linear_velocity = Vector3.ZERO
		#var target = $Camera3D/RayCast3D.to_global($Camera3D/RayCast3D.target_position)
		#heldItem.apply_impulse(($Camera3D/Hand.global_position.direction_to(target)*12*throwPower*throwStrengthMultiplier) + (velocity/1.5), global_position)
		#heldItem.angular_velocity = Vector3.ZERO
		#heldItem = null
		#
		#heldItemsData[selectedHotbar] = null
		#var hotBarSlot : PanelContainer = hotbarSlots[selectedHotbar]
		#hotBarSlot.get_node("TextureRect").texture = null
#
#
#func _input(event: InputEvent) -> void:
	#if !Global.paused && !dead:
		#if event is InputEventMouseMotion && canInput:
			#var sensitivity = cameraSensitivity * Global.settings.get("CameraSensitivity", 1)
			#
			#rotate(Vector3.DOWN, event.relative.x * sensitivity)
			#camera.rotate(Vector3.LEFT, event.relative.y * sensitivity)
			#camera.rotation.x = clampf(camera.rotation.x, -PI/2 + 0.01, PI/2 - 0.01)
#
#
#func _on_footstep_timer_timeout() -> void:
	#if Vector2(velocity.x, velocity.z).length() > 0.5:
		#$Footstep.stream = footstepSounds.pick_random()
		#$Footstep.pitch_scale = randf_range(0.75,1.25)
		#$Footstep.play()
		#
		#if currentState != STATES.CROUCHING:
			#if currentState == STATES.RUNNING:
				#Global.create_audio_event(global_position, 0.5, true)
			#else:
				#Global.create_audio_event(global_position, 0.2, true)
