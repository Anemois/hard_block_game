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

func _dash():
	if(PDash && DASHCNT < 1):
		DASHCNT = 1
		var horz: bool = false
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
		elif(!PJump && PDown):
			velocity.y = DASHSPEED-200
			if(horz):
				if(velocity.x > 0):
					velocity.x -= 200
				else:
					velocity.x += 200
					
func _set_key_presses_on():
	if(Input.is_action_pressed("Jump")):
		PJump = true
	if(Input.is_action_pressed("Left")):
		PLeft = true
	if(Input.is_action_pressed("Right")):
		PRight = true
	if(Input.is_action_pressed("Down")):
		PDown = true
	if(Input.is_action_pressed("Teleport")):
		PTeleport = true
	if(Input.is_action_just_pressed("Dash")):
		PDash = true

func _set_key_presses_off():
	if(Input.is_action_just_released("Jump")):
		PJump = false
		JUMPCNT = 10000
		PJump = false
	if(Input.is_action_just_released("Left")):
		PLeft = false
	if(Input.is_action_just_released("Right")):
		PRight = false
	if(Input.is_action_just_released("Down")):
		PDown = false
	if(Input.is_action_just_released("Teleport")):
		PTeleport = false
	if(Input.is_action_pressed("Dash")):
		PDash = false

func _check_on_wall():
	var lray = get_node("LeftRayCasts")
	ONLEFTWALL = (lray.get_child(0).is_colliding() || lray.get_child(1).is_colliding() || lray.get_child(2).is_colliding())
	var rray = get_node("RightRayCasts")
	ONRIGHTWALL = (rray.get_child(0).is_colliding() || rray.get_child(1).is_colliding() || rray.get_child(2).is_colliding())


func _ready():
	position = get_parent().get_node("Spawn").get_position()
	
func _process(delta):
	_set_key_presses_on()
	_check_on_wall()

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
		
	if(is_on_floor()):
		JUMPCNT = 0
		DASHCNT = 0
	if(PJump):
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
	#print("hi")
	position = get_parent().get_node("Spawn").get_position()
	velocity = Vector2(0, 0)
	get_parent().get_node("Exit").get_child(0).texture = load("res://ExitClosed.png")
	NEXTLV = false
	get_parent().get_node("ExitOrb").get_child(0).visible = true
	
	for ExOrb in get_parent().get_node("DashResets").get_children():
		ExOrb.visible = true

func _on_exit_orb_area_body_entered(body):
	get_parent().get_node("Exit").get_child(0).texture = load("res://ExitOpen.png")
	get_parent().get_node("ExitOrb").get_child(0).visible = false
	NEXTLV = true

func _on_exit_area_body_entered(body):
	if(NEXTLV):
		if(get_parent().name == "lv_1"):
			get_tree().change_scene_to_file("res://lv_6.tscn")
		elif(get_parent().name == "lv_2"):
			get_tree().change_scene_to_file("res://lv_3.tscn")
		elif(get_parent().name == "lv_3"):
			get_tree().change_scene_to_file("res://lv_4.tscn")
		elif(get_parent().name == "lv_4"):
			get_tree().change_scene_to_file("res://lv_5.tscn")
		elif(get_parent().name == "lv_5"):
			get_tree().change_scene_to_file("res://lv_6.tscn")
