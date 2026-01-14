extends State
class_name RunState

var coyote_time := 0.2

func enter(_owner: CharacterPlatformer) -> void:
	state_name = "Run"
	print(state_name, " State")

func update(owner, delta):
	MovementUtility.horizontal_movement_utility(owner, delta, fps) #Allows horizontal movement
	
	if owner.velocity.x == 0:
		owner.change_state(IdleState.new())
	
	if not owner.is_on_floor():
		if Input.is_action_just_pressed("jump") and can_coyote_jump:
			owner.change_state(JumpState.new())
	elif owner.is_on_floor() and Input.is_action_pressed("jump"):
		owner.change_state(JumpState.new())
		
	var was_on_floor = owner.is_on_floor()
	owner.move_and_slide() #Move the body
	
	#After the body was moved:
	if was_on_floor and not owner.is_on_floor():
		start_coyote_timer(owner)

#COYOTE JUMP
var can_coyote_jump : bool
func start_coyote_timer(owner: CharacterPlatformer):
	can_coyote_jump = true
	await owner.get_tree().create_timer(coyote_time).timeout
	can_coyote_jump = false
