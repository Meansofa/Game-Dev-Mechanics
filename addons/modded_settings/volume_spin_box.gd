extends SpinBox

# Adjust this to match the bus you want to control
@export var BUS_NAME : String

func _ready():
	self.emit_signal("value_changed") #Emit to get the current set values
	
	# Connect the signal
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value: float) -> void:
	if new_value == 0: #Mute the BUS
		AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_NAME), true)
	else:
		if AudioServer.is_bus_mute(AudioServer.get_bus_index(BUS_NAME)): #If BUS was muted
			AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_NAME), false) #Unmute bus
	
		var db = (new_value - 8) * 2.0 #Adjust volumen base on spinbox value, 8 as the normal volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS_NAME), db)

	print(name, "> ", BUS_NAME, ": ", AudioServer.get_bus_volume_db(AudioServer.get_bus_index(BUS_NAME)))
