extends CharacterBody2D

const GRAVITY = 60
const JUMP_POWER = -600
const SPEED = 500

var DASHCNT: int = 0
var DASHSPEED:int = 2500
var JUMPCNT: int = 0
var JUMPCNTMX: int = 10
var PLeft: bool = false
var PRight: bool = false
var PDown: bool = false
var PJump: bool = false
var PTeleport: bool = false
var PDash: bool = false

var NEXTLV: bool = false
var ONLEFTWALL: bool = false
var ONRIGHTWALL: bool = false
var LAND: bool = true

func _dash():
	if(PDash && DASHCNT < 1):
		DASHCNT = 1
		var horz: bool = false
		var vert: bool = false
		if(PLeft && !PRight):
			velocity.x = -DASHSPEED
			velocity.y = 0
			horz = true
		elif(PRight && !PLeft):
			velocity.x = DASHSPEED
			velocity.y = 0
			horz = true
			
		if(PJump && !PDown):
			velocity.y = -DASHSPEED+200
			if(horz):
				if(velocity.x > 0):
					velocity.x -= 200
				else:
					velocity.x += 200
			vert = true
		elif(!PJump && PDown):
			velocity.y = DASHSPEED-200
			if(horz):
				if(velocity.x > 0):
					velocity.x -= 200
				else:
					velocity.x += 200
			vert = true
		if(horz || vert):
			$Sounds/DashWind.play()
			
func _set_key_presses_on():
	if(Input.is_action_pressed("Jump") || Input.is_action_pressed("Teleport")):
		PJump = true
	if(Input.is_action_pressed("Left")):
		PLeft = true
	if(Input.is_action_pressed("Right")):
		PRight = true
	if(Input.is_action_pressed("Down")):
		PDown = true
	#if(Input.is_action_pressed("Teleport")):
	#	PTeleport = true
	if(Input.is_action_just_pressed("Dash")):
		PDash = true

func _set_key_presses_off():
	if(Input.is_action_just_released("Jump") || Input.is_action_just_released("Teleport")):
		PJump = false
		JUMPCNT = 10000
		PJump = false
	if(Input.is_action_just_released("Left")):
		PLeft = false
	if(Input.is_action_just_released("Right")):
		PRight = false
	if(Input.is_action_just_released("Down")):
		PDown = false
	#if(Input.is_action_just_released("Teleport")):
	#	PTeleport = false
	if(Input.is_action_pressed("Dash")):
		PDash = false

func _check_on_wall():
	ONLEFTWALL = ($LeftRayCasts/LeftTop.is_colliding() || $LeftRayCasts/LeftMid.is_colliding() || $LeftRayCasts/LeftBot.is_colliding())
	ONRIGHTWALL = ($RightRayCasts/RightTop.is_colliding() || $RightRayCasts/RightMid.is_colliding() || $RightRayCasts/RightBot.is_colliding())

func _ready():
	position = get_parent().get_node("Spawn").get_position()
	
func _process(delta):
	_set_key_presses_on()
	_check_on_wall()
	if(is_on_floor()):
		JUMPCNT = 0
		DASHCNT = 0

func _physics_process(delta):
	#print(velocity.y)
	if(abs(velocity.x) <= SPEED && velocity.y >= JUMP_POWER):
		velocity.y += GRAVITY
	
	if(abs(velocity.x) > SPEED):
		if(velocity.x > 0):
			velocity.x -= 200
		else:
			velocity.x += 200
	if(velocity.y < JUMP_POWER):
		#print(velocity.y)
		velocity.y += 200
		
	if(((PLeft && ONLEFTWALL) || (PRight && ONRIGHTWALL)) && !PJump):
		JUMPCNT = 0
		velocity.y = 0

	if(PJump):
		if(JUMPCNT == 0):
			$Sounds/Jump.play()
		if(JUMPCNT < JUMPCNTMX):
			velocity.y = min(JUMP_POWER, velocity.y)
			JUMPCNT += 1
		
	if((PLeft && PRight) || (!PLeft && !PRight)):
		velocity.x = 0
		
	elif(PLeft):
		if(abs(velocity.x) <= SPEED):
			velocity.x = -SPEED

	elif(PRight):
		if(abs(velocity.x) <= SPEED):
			velocity.x = SPEED

			
	_dash()
	_set_key_presses_off()
	move_and_slide()


func _on_death_box_body_entered(body):
	if(body.name == "Player"):
		print(position)
		$Sounds/LavaDeath.play()
		position = get_parent().get_node("Spawn").get_position()
		velocity = Vector2(0, 0)
		get_parent().get_node("Exit").get_child(0).texture = load("res://ExitClosed.png")
		NEXTLV = false
		get_parent().get_node("ExitOrb").get_child(0).visible = true
		
		for ExOrb in get_parent().get_node("DashResets").get_children():
			ExOrb.visible = true

func _on_exit_orb_area_body_entered(body):
	if(body.name == "Player"):
		get_parent().get_node("Exit").get_child(0).texture = load("res://ExitOpen.png")
		get_parent().get_node("ExitOrb").get_child(0).visible = false
		NEXTLV = true

func _on_exit_area_body_entered(body):
	if(NEXTLV && body.name == "Player"):
		if(get_parent().name == "lv_1"):
			get_tree().change_scene_to_file("res://Levels//lv_2.tscn")
		elif(get_parent().name == "lv_2"):
			get_tree().change_scene_to_file("res://Levels//lv_3.tscn")
		elif(get_parent().name == "lv_3"):
			get_tree().change_scene_to_file("res://Levels//lv_4.tscn")
		elif(get_parent().name == "lv_4"):
			get_tree().change_scene_to_file("res://Levels//lv_5.tscn")
		elif(get_parent().name == "lv_5"):
			get_tree().change_scene_to_file("res://Levels//lv_6.tscn")
		elif(get_parent().name == "lv_6"):
			get_tree().change_scene_to_file("res://Levels//lv_7.tscn")
		elif(get_parent().name == "lv_7"):
			get_tree().change_scene_to_file("res://Levels//lv_8.tscn")
		elif(get_parent().name == "lv_8"):
			get_tree().change_scene_to_file("res://Levels//lv_9.tscn")
		else:
			get_tree().change_scene_to_file("res://Levels//youwin.tscn")
