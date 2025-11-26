extends RefCounted #Ref counted automatically releases reference once not used, saving memory
class_name State
#Other states will inherit this

var state_name : String = "Unnamed State" #Used by the owner to know what state they are currently in
var fps := 64 #Used for delta time, so when lagging it is still consistent

#NOTE : the owner should have a class_name, and replace the CharacterPlatformer with the class_name of your character

#When the state was initialized by the owner by current_state.enter, this will be called
func enter(owner: CharacterPlatformer) -> void:
	pass

func update(owner: CharacterPlatformer, delta: float) -> void:
	pass

func exit(owner: CharacterPlatformer) -> void:
	pass
