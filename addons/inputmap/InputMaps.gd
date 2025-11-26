@tool
extends EditorPlugin
#Button at top right, clicking it will instantiate Inputs to the Project Settings

enum INPUT_TYPE { KEY, MOUSE_BUTTON, JOY_BUTTON, JOY_AXIS }

const INPUT_MAP: Dictionary = {
	"jump": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_Z },
		{ "type": INPUT_TYPE.KEY, "value": KEY_SPACE },
		{ "type": INPUT_TYPE.JOY_AXIS, "value": JOY_AXIS_LEFT_Y },
		{ "type": INPUT_TYPE.JOY_BUTTON, "value": JOY_BUTTON_DPAD_UP }
		],
	"left": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_A },
		{ "type": INPUT_TYPE.KEY, "value": KEY_LEFT }
		],
	"right": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_D },
		{ "type": INPUT_TYPE.KEY, "value": KEY_RIGHT}
		],
	"up": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_W },
		{ "type": INPUT_TYPE.KEY, "value": KEY_UP}
		],
	"down": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_S },
		{ "type": INPUT_TYPE.KEY, "value": KEY_DOWN}
		],
	"interact": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_E }
		],
	"attack": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_F },
		{ "type": INPUT_TYPE.KEY, "value": KEY_X }
		],
	"dash": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_C }
		],
	"escape": [
		{ "type": INPUT_TYPE.KEY, "value": KEY_ESCAPE }
		]
	}

var seed_button: Button

func _enter_tree():
	seed_button = Button.new()
	seed_button.text = "Seed InputMap"
	seed_button.pressed.connect(_on_seed_pressed)
	add_control_to_container(CONTAINER_TOOLBAR, seed_button)

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, seed_button)
	seed_button = null

func _on_seed_pressed():
	_update_input_map()
	ProjectSettings.save()
	print(name, ": ✅Inputs now instantiated")

func _read_input_event_from_code(event_data: Dictionary) -> InputEvent:
	var event_type = event_data.type
	var event_value = event_data.value

	match event_type:
		INPUT_TYPE.KEY:
			var key_event: InputEventKey = InputEventKey.new()
			key_event.keycode = event_value
			return key_event
		INPUT_TYPE.MOUSE_BUTTON:
			var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
			mouse_event.button_index = event_value
			return mouse_event
		INPUT_TYPE.JOY_BUTTON:
			var joy_button_event: InputEventJoypadButton = InputEventJoypadButton.new()
			joy_button_event.button_index = event_value
			return joy_button_event
		INPUT_TYPE.JOY_AXIS:
			var joy_axis_event: InputEventJoypadMotion = InputEventJoypadMotion.new()
			joy_axis_event.axis = event_value
			return joy_axis_event

	return null

func _update_input_map() -> void: 
	for key in INPUT_MAP.keys():
		_update_action(key)

func _update_action(action_name: StringName) -> void:
	var new_events: Array
	var new_input_events: Array
	var input_action: String= "input/" + action_name

	if !ProjectSettings.get_setting(input_action) == null: 
		return

	new_events = INPUT_MAP[action_name]

	for event in new_events:
		new_input_events.append(_read_input_event_from_code(event))

	ProjectSettings.set_setting( #Most important
		input_action, #name of the action, must start with "input/"
		{
		"deadzone": 0.5, #controller related
		"events": new_input_events}) #events that triggers the input action, like pressing SPACE
