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
	if(Input.is_action_pressed("Jump2")):
		PJump = true
	if(Input.is_action_pressed("Left2")):
		PLeft = true
	if(Input.is_action_pressed("Right2")):
		PRight = true
	if(Input.is_action_pressed("Down2")):
		PDown = true
	if(Input.is_action_pressed("Teleport2")):
		PTeleport = true
	if(Input.is_action_just_pressed("Dash2")):
		PDash = true

func _set_key_presses_off():
	if(Input.is_action_just_released("Jump2")):
		PJump = false
		JUMPCNT = 10000
		PJump = false
	if(Input.is_action_just_released("Left2")):
		PLeft = false
	if(Input.is_action_just_released("Right2")):
		PRight = false
	if(Input.is_action_just_released("Down2")):
		PDown = false
	if(Input.is_action_just_released("Teleport2")):
		PTeleport = false
	if(Input.is_action_pressed("Dash2")):
		PDash = false

func _ready():
	pass#position = get_parent().get_node("Spawn").get_position()
	
func _process(delta):
	_set_key_presses_on()

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
	if(is_on_wall() && !PJump):
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

