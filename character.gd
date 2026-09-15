class_name Player extends RigidBody3D

@onready var camera : Camera3D = $Rotation/Camera3D
@onready var rotator = $Rotation
@onready var interactRay = $Rotation/Camera3D/Interact

@onready var startPos : Vector3 = global_position

signal joy_changed

enum State {IDLE, WALKING, SPRINTING}

var inventory : Array[String] = []
@warning_ignore("unused_signal") signal inventory_changed

var inAir : bool = false
var isCrouching : bool = false
var state : State = State.WALKING
var targetMoveSpeed : Vector3 = Vector3.ZERO
var inputForce : Vector3
var jumpReady : bool = true

var joyCount : int = 0
var stamina : float = maxStamina
var maxStamina : float = 10.0
var usingStamina : bool = false

var staminaRecharge = 0.0
var staminaRechargeTime = 0.5

var wallClimbingRecharge = 0.0
var wallClimbingRechargeTime = 0.5

var forward : Vector2

func _enter_tree() -> void:
	Global.player = self


func _ready() -> void:
	$Falling.volume_linear = 0.0


func grab_item(item):
	$Pickup.pitch_scale = randf_range(0.8, 1.2)
	$Pickup.play()
	
	if item.itemID == "joy":
		joyCount += 1
		if item.original:
			Global.world.joyFound += 1
	else:
		inventory.push_back(item.itemID)
		inventory_changed.emit()
	
	var specialPickup = Global.items[item.itemID].get("SpecialPickup")
	if specialPickup:
		$SpecialPickup.stream = specialPickup
		$SpecialPickup.play()
	
	item.queue_free()


var shake : float = 0.0

func _process(delta: float) -> void:
	var input : Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var preInput = input.rotated(-rotator.rotation.y)
	
	forward = Vector2.UP.rotated(rotator.rotation.y)
	
	var cameraDirection : Vector3 = camera.global_position.direction_to(interactRay.to_global(interactRay.target_position))
	
	if Input.is_action_just_pressed("drop") && joyCount > 0:
		joyCount -= 1
		shake = 0.02
		var item : Item = preload("res://item.tscn").instantiate()
		item.itemID = "joy"
		item.original = false
		Global.world.add_child(item)
		item.global_position = camera.global_position + cameraDirection*.5
		item.linear_velocity = cameraDirection*5.0
		$ThrowItem.pitch_scale = randf_range(0.8, 1.2)
		$ThrowItem.play()
	
	#print(preInput)
	
	var wallVector = cameraDirection.cross(Vector3.UP).normalized() * Input.get_axis("move_left", "move_right")
	
	if onWall:
		inputForce = (Vector3(wallVector.x, -input.y*1.5, wallVector.z)*100.0) + (Vector3(-forward.x, 0, forward.y)*10.0)
	else:
		#if stamina > 0:
		inputForce = Vector3(preInput.x, 0, preInput.y)*100.0
		#else:
			#inputForce = Vector3.ZERO
	
	state = State.IDLE
	
	if input != Vector2.ZERO:
		state = State.WALKING
		$FootstepTimer.wait_time = PI/6.0
		
	if Input.is_action_pressed("sprint") && state == State.WALKING && stamina > 0 && !inAir:
		state = State.SPRINTING
		$FootstepTimer.wait_time = 0.3
	
	if isCrouching:
		$FootstepTimer.wait_time = PI/3.0
	
	var bobStrength = 0.05
	var bobSpeed = 1.5
	
	if state == State.WALKING:
		bobStrength = 0.2
		bobSpeed = 8.0
	
	#prints(onWall, inAir)
	
	if onWall:
		bobSpeed = 8.0
		bobStrength = 0.3
	elif inAir:
		bobStrength = 0.0
		if linear_velocity.y < 0.0:
			$Falling.volume_linear = abs(linear_velocity.y/150.0)
	
	if !inAir || onWall:
		$Falling.volume_linear = 0.0
	
	var bobAmount = bobStrength*sin((Time.get_ticks_msec()/1000.0)*bobSpeed)
	
	var baseCam = 1.8
	if isCrouching:
		baseCam = 0.5
	
	camera.position.x = randf_range(-shake, shake)
	camera.position.y = lerp(camera.position.y, baseCam + bobAmount, delta*5.0)
	
	shake = lerpf(shake, 0.0, delta*7.0)
	
	if usingStamina:
		staminaRecharge = staminaRechargeTime
	else:
		staminaRecharge -= delta
	
	if wallClimbingRecharge > 0.0:
		wallClimbingRecharge -= delta
		
	if Input.is_action_pressed("crouch") && (state == State.WALKING || state == State.IDLE):
		if !isCrouching:
			isCrouching = true
			$CollisionShape3D.shape.height = 1.0
			$CollisionShape3D.position.y = 0.5
	elif isCrouching:
		isCrouching = false
		$CollisionShape3D.shape.height = 2.0
		$CollisionShape3D.position.y = 1.0
		

@onready var floorRays = [
	$FloorCast,
	$FloorCast2,
	$FloorCast3,
	$FloorCast4,
]

@onready var wallRays = [
	$Rotation/WallCast2,
	$Rotation/WallCast,
	$Rotation/WallCast3,
]

var onWall : bool = false
var landed : bool = false

var hoverObject : Node3D

var interactTime = 0.0
var joyBoost : float = 0.0

func _physics_process(delta: float) -> void:
	var interactObject = interactRay.get_collider()
	var interacting : bool = false
	hoverObject = interactObject
	
	if hoverObject is Item:
		if hoverObject.itemID == "joy":
			if Input.is_action_pressed("interact"):
				interactTime += delta
				interacting = true
	
			if interactTime > 1.0:
				hoverObject.queue_free()
				joyBoost += 10.0
				shake = 0.4
				$JoyBoostSound.play()
				$JoyActive.play()
				joy_changed.emit()
	
	if Input.is_action_just_released("interact"):
		if hoverObject is Item:
			grab_item(interactObject)
		elif hoverObject is Sign:
			if hoverObject.can_interact():
				interactObject.interact()
				#Global.change_can_input(false)
	
	if joyBoost > 0.0:
		if joyBoost-delta > 0.0:
			joyBoost -= delta
		else:
			joyBoost = 0.0
			joy_changed.emit()
	
	if !interacting:
		interactTime = 0.0
	
	inAir = true
	#for i in floorRays:
		#if i.is_colliding():
			#inAir = false
			#break
	
	if $FloorRay.is_colliding():
		var normal : Vector3 = $FloorRay.get_collision_normal()
		var angle : float = normal.angle_to(Vector3.UP)
		#print(angle)
		if angle < 0.7:
			inAir = false
	
	if inAir:
		landed = false
	
	if !landed && !inAir:
		landed = true
		$JumpLand.pitch_scale = randf_range(0.9, 1.1)
		$JumpLand.play()
		$Dust.emitting = true
	
	var wallColliding = false
	for i in wallRays:
		if i.is_colliding():
			wallColliding = true
			break
	
	onWall = wallColliding && state == State.WALKING && stamina > 0 && inAir && wallClimbingRecharge <= 0
	
	if inAir:
		linear_damp = 0.0
	else:
		linear_damp = 2.0
	
	if onWall:
		gravity_scale = 0
		linear_damp = 10.0
	else:
		gravity_scale = 2.0
	
	usingStamina = onWall || state == State.SPRINTING || (inAir && state == State.WALKING)
	
	if usingStamina:
		if stamina > 0:
			if joyBoost > 0.0:
				stamina = maxStamina
			else:
				stamina -= delta * (1.0 + (joyCount/10.0))
		else:
			stamina = 0.0
	elif staminaRecharge <= 0:
		if stamina < maxStamina:
			stamina += delta*4.0
		else:
			stamina = maxStamina
	
	var maxSpeed = 5.0
	if state == State.SPRINTING:
		maxSpeed = 10.0
	if isCrouching:
		maxSpeed = 2.5
	
	if Vector2(linear_velocity.x, linear_velocity.z).length() < maxSpeed:
		if inAir:
			apply_central_force(inputForce*0.2)
		else:
			apply_central_force(inputForce)
	
	if jumpReady && stamina > 0.5:
		if onWall && Input.is_action_just_pressed("jump"):
			jumpReady = false
			apply_central_impulse(Vector3(-forward.x*1.0, 8, -forward.y*1.0))
			stamina -= 0.5
			wallClimbingRecharge = wallClimbingRechargeTime
			get_tree().create_timer(0.1).timeout.connect(func(): jumpReady = true)
			$JumpStart.pitch_scale = randf_range(0.9, 1.1)
			$JumpStart.play()
		elif !inAir && Input.is_action_just_pressed("jump"):
			jumpReady = false
			apply_central_impulse(Vector3(0, 8, 0))
			stamina -= 0.5
			get_tree().create_timer(0.1).timeout.connect(func(): jumpReady = true)
			$JumpStart.pitch_scale = randf_range(0.9, 1.1)
			$JumpStart.play()


func _input(event: InputEvent) -> void:
	if !Global.canInput: return
	if !event is InputEventMouseMotion: return
	
	var sensitivity : float = 0.01 * Global.mouseXY
	
	rotator.rotate_y(-event.screen_relative.x * sensitivity)
	camera.rotate_x(-event.screen_relative.y * sensitivity)
	camera.rotation.x = clampf(camera.rotation.x, -PI/2.0 + 0.01, PI/2.0 - 0.01)


func _on_footstep_timer_timeout() -> void:
	if state == State.IDLE || (inAir && !onWall): return
	
	if onWall:
		$Climbing.play()
	else:
		$Footstep.play()
		$DollarStep.emitting = true


func _on_body_entered(body: Node) -> void:
	if body.collision_layer == 8:
		$Soaked.play()
		global_position = startPos
		Global.world.splash()
	if body.collision_layer == 16:
		global_position = startPos
		$Burnt.play()
		Global.world.burn()
