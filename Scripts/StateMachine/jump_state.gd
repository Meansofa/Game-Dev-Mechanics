extends State
class_name JumpState

var max_jump := 1 #replace with 1 if you don't want more jumps, change to 2 for double jump, etc.
var jump_count := 0

func enter(owner: CharacterPlatformer) -> void:
	state_name = "Jump"
	print(state_name, " State")

	owner.velocity.y = owner.JUMP_VELOCITY
	jump_count += 1 #firat jump

func update(owner: CharacterPlatformer, delta: float) -> void:
	var low_jump = owner.JUMP_VELOCITY / 2.0
	if Input.is_action_just_released("jump") and owner.velocity.y < low_jump: #Low Jump
		owner.velocity.y = low_jump
	elif Input.is_action_just_pressed("jump") and jump_count < max_jump: #High Jump, but if released earlier will do low jump
		owner.velocity.y = owner.JUMP_VELOCITY
		jump_count += 1 #corresponding jumps 
	
	MovementUtility.horizontal_movement_utility(owner, delta, fps) #Allows horizontal movement
	
	owner.move_and_slide()
	if not owner.is_on_floor() and not owner.velocity.y < 0 and jump_count >= max_jump:
		owner.change_state(FallingState.new())
	elif owner.is_on_floor():
		owner.change_state(IdleState.new())
	
