extends KinematicBody2D

const MAX_SPEED = 200
const ACCELERATION = 10
const FRICTION = 200

#Creates a factor variable, so that we can use something that guides our switch
enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)



func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized() 
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/run/blend_position", input_vector)
		animationTree.set("parameters/idle/blend_position", input_vector) #can hover over blend position in animationTree to find exactly location
		animationTree.set("parameters/attack/blend_position", input_vector)
		# note that we should only update here, so that we remember which position we were at before stopping movement
		animationState.travel("run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED,ACCELERATION )
	else:
		animationState.travel("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION )  
	velocity = move_and_slide(velocity) # by multiplying velcity by delta, the movement scales to framerate
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("attack")
	
func roll_state(delta):
	pass

func attack_animation_finised():
	state = MOVE
