extends Node

@export var in_game_music : AudioStreamMP3

@export var player_packed_scene : PackedScene
@export var opponent_packed_scene : PackedScene

@export var rock_paper_scissors_scene : PackedScene

var peer = NodeTunnelPeer.new()
var localpeer = ENetMultiplayerPeer.new()
const PORT := 9998 #port to use, Nodetunnel only has this node available
const ADDRESS := "relay.nodetunnel.io" #IP address (change to the host's ip adress if you want to test with other devices), "local host" if you want to test locally
const localADDRESS := "localhost"

var player_side : Node2D
var opponent_side : Node2D

var use_local_multiplayer := false

func _ready() -> void:
	print_debug("Server Connecting")
	%Loading.visible = false
	%required.visible = false
	%PlayerDisconnected.visible = false

	multiplayer.multiplayer_peer = peer
	peer.connect_to_relay(ADDRESS, PORT)
	
	await peer.relay_connected
	
	%OnlineID.text = "Room ID: [i]" + peer.online_id

func _on_host_pressed() -> void:
	_disable_buttons()
	if use_local_multiplayer:
		localpeer.create_server(PORT)
		multiplayer.multiplayer_peer = localpeer
	else:
		peer.host()
	
		%Loading.visible = true
		await peer.hosting
		%Loading.visible = false
		
		DisplayServer.clipboard_set(peer.online_id) #copy the online id to the clipboard
	
	#connect a signal to when a peer connects
	multiplayer.peer_connected.connect(_on_peer_connected)
	%WaitingForPlayer.visible = true
	var player_scene = player_packed_scene.instantiate()
	add_child(player_scene)
	transfer_data(player_scene)
	
	player_side = player_scene

func _on_join_pressed() -> void:
	if use_local_multiplayer:
		localpeer.create_client(localADDRESS, PORT)
		multiplayer.multiplayer_peer = localpeer
		%Loading.visible = true
		_disable_buttons()
		
		multiplayer.connected_to_server.connect(_on_connected_to_server) #Before adding children must check if joined from someone's hot)
	else:
		if %JoinID.text == "":
			%required.visible = true
			return

		%required.visible = false
		peer.join(%JoinID.text)
	
		%Loading.visible = true
		await peer.joined
		#AFTER JOINING>>>>>>>>>>>>>>>>>
		_disable_buttons()
		_on_connected_to_server()
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

#If you pressed join and you got connected
func _on_connected_to_server():
	%BackgroundMusic.stream = in_game_music
	%BackgroundMusic.play()
	var player_scene = player_packed_scene.instantiate()
	add_child(player_scene)
	
	var opponent_scene = opponent_packed_scene.instantiate()
	add_child(opponent_scene)
	
	player_side = player_scene
	opponent_side = opponent_scene
	
	player_side.opponent_joined(opponent_side) #For player_scene to get access to opponent_scene
	
	%Loading.visible = false
	var rock_paper_scissors = rock_paper_scissors_scene.instantiate()
	player_scene.add_child(rock_paper_scissors)
	
	transfer_data(player_scene)

func transfer_data(player_scene : Node2D):
	var player_id = multiplayer.get_unique_id()
	if %PlayerName.text == "":
		%PlayerName.text = "Player " + str(player_id)
	
	player_scene.transfer_data(%PlayerName.text, player_id)

#This only shows if you're the host
func _on_peer_connected(peer_id):
	print("Player: ", peer_id, " joined!")
	%BackgroundMusic.stream = in_game_music
	%BackgroundMusic.play()
	%WaitingForPlayer.visible = false
	
	var rock_paper_scissors = rock_paper_scissors_scene.instantiate()
	player_side.add_child(rock_paper_scissors)
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	var opponent_scene = opponent_packed_scene.instantiate()
	add_child(opponent_scene)
	
	opponent_side = opponent_scene
	player_side.opponent_joined(opponent_side) #For player_scene to get access to opponent_scene
	

func _on_peer_disconnected(peer_id):
	print("Player: ", peer_id, " disconnected!")
	%PlayerDisconnected.visible = true
	$%disconnected_label.text = "[b]Player " + str(peer_id) + " DISCONNECTED."

func _disable_buttons():
	pass
	%Menu.visible = false
	%Host.visible = false
	%Host.disabled = true
	%Join.visible = false
	%Join.disabled = true
	%OnlineID.visible = false
	%JoinID.visible = false
	%local_checkbox.visible = false
	%Credits.visible = false

func _enable_buttons():
	pass
	%Menu.visible = true
	%Host.visible = true
	%Host.disabled = false
	%Join.visible = true
	%Join.disabled = false
	%OnlineID.visible = true
	%JoinID.visible = true
	%local_checkbox.visible = true
	%Credits.visible = true

func restart():
	get_tree().reload_current_scene()

func _disable_non_local_buttons():
	pass
	%OnlineID.visible = false
	%JoinID.visible = false

func enable_non_local_buttons():
	pass
	%OnlineID.visible = true
	%JoinID.visible = true

func _on_check_button_toggled(toggled_on: bool) -> void:
	use_local_multiplayer = toggled_on
	if use_local_multiplayer:
		_disable_non_local_buttons()
	else:
		enable_non_local_buttons()
