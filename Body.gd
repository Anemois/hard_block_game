extends RigidBody2D

const GRAVITY = 10
const JUMP_POWER = -300

var velocity = Vector2(0, 0)

func _physics_process(delta):
	velocity.y += GRAVITY
	if(Input.is_action_just_pressed("ui_accept")):
		velocity.y = JUMP_POWER
	
	move_and_collide(velocity)
