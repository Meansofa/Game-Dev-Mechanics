extends HBoxContainer

@onready var input_remap_button_group : ButtonGroup = preload("res://addons/modded_settings/input_remap_button_group.tres")

var waiting_for_input := false #when button is toggled
var button_action_name : String #Jump/left/right, etc. depends on what action is passed
var key_event_name : String

func _ready() -> void:
	%key.button_group = input_remap_button_group

func _input(event: InputEvent) -> void:
	if waiting_for_input and event is InputEventKey and event.pressed:
		var new_event : InputEventKey = event
		waiting_for_input = false
		%key.button_pressed = false
		
		remap_action(button_action_name, new_event)
		update_input_remap(button_action_name, new_event.as_text_key_label())
		print(name, ">Remapped ", button_action_name, " to ", new_event.as_text_key_label())

#assign this button as a certain input remap
func update_input_remap(action_name : String, key_name : String):
	#Assign self
	button_action_name = action_name
	key_event_name = key_name

	#Replace the label
	%action.text = button_action_name
	%key.text = key_event_name

#remap the action to a new event
func remap_action(action_name: String, new_event: InputEvent) -> void:
	# Remove old bindings
	InputMap.action_erase_events(action_name)
	# Add the new binding
	InputMap.action_add_event(action_name, new_event)

func _on_key_toggled(toggled_on: bool) -> void:
	waiting_for_input = toggled_on
