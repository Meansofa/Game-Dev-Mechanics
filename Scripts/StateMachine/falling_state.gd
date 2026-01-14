extends State
class_name FallingState
#Other states will inherit this

#When the state was initialized by the owner by current_state.enter, this will be called
func enter(_owner: CharacterPlatformer) -> void:
	state_name = "Falling"
	print(state_name, " State")

func update(owner: CharacterPlatformer, delta: float) -> void:
	if not owner.is_on_floor(): #If in the air
		#Since the player already has this function below
		#owner.velocity += owner.get_gravity() * delta
		
		MovementUtility.horizontal_movement_utility(owner, delta, fps) #Allows horizontal movement
	else:
		owner.change_state(IdleState.new())
	
	owner.move_and_slide()

func exit(_owner: CharacterPlatformer) -> void:
	pass
