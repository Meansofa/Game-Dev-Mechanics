extends CanvasLayer

@onready var volume_display_scene : PackedScene = preload("res://addons/modded_settings/volume_display.tscn")
var volume_display : PanelContainer = null

@onready var controls_display_scene : PackedScene = preload("res://addons/modded_settings/controls_display.tscn")
var controls_display : PanelContainer = null

var current_display_showing : PanelContainer #The current setting that is displayed, that is not the pause menu like Volume Displayy

func _ready() -> void:
	%back.visible = false
	%PauseDisplay.visible = false
	
	#Instantiate Volume Display
	volume_display = volume_display_scene.instantiate()
	add_child(volume_display)
	volume_display.visible = false
	
	#Instantiate Controls Display
	controls_display = controls_display_scene.instantiate()
	add_child(controls_display)
	controls_display.visible = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape"):
		show_pause_menu()

func _on_settings_pressed() -> void:
	show_pause_menu()
	get_parent().release_focus() #Assuming the parent is the settings button, get rid of focus after pressing since when pressing space, it activates if it's on focuss

func _on_close_pressed() -> void:
	toggle_pause_menu_visibility()

func show_pause_menu():
	if current_display_showing: #Incase a display is showing and you pressed pause, it will display both the pause and the displayy
		toggle_display_visibility_menu() #stop displaying the current display
		current_display_showing = null #erase the current display
	else:
		toggle_pause_menu_visibility()

func toggle_pause_menu_visibility(): #PAUSE MENU
	%PauseDisplay.visible = !%PauseDisplay.visible
	if %PauseDisplay.visible or current_display_showing: #If any other display is showing
		get_tree().paused = true
	else: #If paused display is not showing and other display is not showing
		get_tree().paused = false
	print(name, ">get_tree().paused: ", get_tree().paused)

func _on_volume_pressed() -> void: #VOLUME MENU
	current_display_showing = volume_display
	toggle_display_visibility_menu()

func _on_controls_pressed() -> void: #CONTROLS MENU
	current_display_showing = controls_display
	toggle_display_visibility_menu()

func toggle_display_visibility_menu():
	current_display_showing.visible = !current_display_showing.visible 
	%back.visible = !%back.visible 
	toggle_pause_menu_visibility()

func _on_back_pressed() -> void:
	show_pause_menu()
