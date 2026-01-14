extends CharacterBody2D
class_name CharacterPlatformer

@export var skin : Sprite2D #Sprite of the player

var current_state: State

var SPEED := 160 #used by States by owner.SPEED
var JUMP_VELOCITY := -320 #used by States by owner.JUMP

var ACCELERATION := 30 #Running Accelereation
var FRICTION := 40 #Stopping Acceleration

var DASH_SPEED  := 640

func _ready():
	change_state(IdleState.new())

func _physics_process(delta):
	#For the update function of the state, which should work same as _physics_process or _process
	if current_state: #just so it is not null incase it is
		current_state.update(self, delta) #for the current state update it

	#DASH
	if Input.is_action_just_pressed("dash") and MovementUtility.can_dash:
		MovementUtility.dash_utility(self)
	elif MovementUtility.is_dashing: #When dashing there should be no gravity
		velocity.y = 0
	elif not is_on_floor():
		velocity += get_gravity() * delta

#Called by the current state if it wants to change state by: owner.change_state(state_name.new())
func change_state(new_state: State):
	if current_state:
		current_state.exit(self)
	current_state = new_state
	current_state.enter(self)
	%State.text = current_state.state_name

func _process(_delta: float) -> void:
	AnimationUtility.change_facing_direction(skin) #change sprite direction based on where facing
