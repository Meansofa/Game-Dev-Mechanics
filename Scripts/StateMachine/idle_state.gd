extends State
class_name IdleState

func enter(_owner: CharacterPlatformer) -> void:
	state_name = "Idle"
	print(state_name, " State")

func update(owner: CharacterPlatformer, delta: float) -> void:
	owner.velocity.x = move_toward(owner.velocity.x, 0, owner.ACCELERATION * (delta * fps))
	
	if Input.get_axis("left", "right"):
		owner.change_state(RunState.new())
	elif Input.is_action_pressed("jump"):
		owner.change_state(JumpState.new())
	if not owner.is_on_floor():
		owner.change_state(FallingState.new())
		
	
	owner.move_and_slide()
