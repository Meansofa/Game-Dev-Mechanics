extends Node

var peer = NodeTunnelPeer.new() #Online Multiplayer
var localpeer = ENetMultiplayerPeer.new() #Local Multiplayer
const PORT := 9998 #port to use, Nodetunnel only has this node available
const ADDRESS := "relay.nodetunnel.io" #IP address (change to the host's ip adress if you want to test with other devices), "local host" if you want to test locally
const localADDRESS := "localhost"

var use_local_multiplayer := false #if true uses the Local Adress, if you want to use this make sure you also have a toggle button that toggles between local or not

func _ready() -> void:
	print_debug("Connecting to Server")

	multiplayer.multiplayer_peer = peer
	peer.connect_to_relay(ADDRESS, PORT)
	
	await peer.relay_connected
	
	%HostID.text = "Room ID: " + peer.online_id
	print_debug(":D Connected to Server, with Server id: ", peer.online_id)

## Create a button named host and attach the signal on press, make sure this function will run
func _on_host_pressed() -> void:
	if use_local_multiplayer:
		%Messages.text += "\n: Hosting Locally, No Room id needed"
		localpeer.create_server(PORT)
		multiplayer.multiplayer_peer = localpeer
	else:
		%Messages.text += "\n:Hosting Server, Room id: " + peer.online_id 
		peer.host()
	
		await peer.hosting
		
		%Messages.text += "\n:D Room finished loading, guests can join now"
		
		DisplayServer.clipboard_set(peer.online_id) #copy the online id to the clipboard
	
	#connect a signal to when a peer connects
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	## Waiting for Joiners
	%Messages.text += "\n: You are hosting at Room " + str(peer.online_id)
	%Messages.text += "\n: Waiting for players.."

## Create a button named join and attach the signal on press, make sure this function will run
func _on_join_pressed() -> void:
	if use_local_multiplayer:
		localpeer.create_client(localADDRESS, PORT)
		multiplayer.multiplayer_peer = localpeer
		
		%Messages.text += "\n: Connecting to Local Room"
		
		multiplayer.connected_to_server.connect(_on_connected_to_server) #connect a signal that checks when finished connecting to the room
	else:
		##JoinID should be the ID of the room you are connecting to
		if %JoinID.text == "": #Check if the JoinID is empty
			%Messages.text += "\n: No Join ID inputted"
			
			return

		peer.join(%JoinID.text)
		%Messages.text += "\n: Connecting to Room: " + %JoinID.text
	
		await peer.joined
		#AFTER JOINING>>>>>>>>>>>>>>>>>
		
		_on_connected_to_server()
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected) #Connect a signal that Notifies all other clients when you disconnect

# this only works if you're NOT the host, If you pressed join and you got connected
func _on_connected_to_server():
	##Instantiate all the scenes here >>>>>>>>>>>>>>>>>>
	
	%Messages.text += "\n: Successfully connected to Room"


#This only works if you're the host , checks if someone joins your room
func _on_peer_connected(peer_id):
	%Messages.text += "\n: Player " + str(peer_id) + " joined!"

	multiplayer.peer_disconnected.connect(_on_peer_disconnected) #Connect a signal that Notifies all other clients when you disconnect
	
	## Instantiate the other player's scene or something that represents the other player/s here >>>>>>>>>

func _on_peer_disconnected(peer_id):
	%Messages.text += "\n: Player " + str(peer_id) + " disconnected"

##This is for chatting, you can delete this if you want
func _on_send_button_pressed() -> void:
	if %SendMessage.text != "":
		var player_id = multiplayer.get_unique_id()
		relay_message(player_id, %SendMessage.text)
		
		#if multiplayer.is_server(): # multiplayer.is_server() Checks if you're hosting a server, disregarded since doesnt apply to joiners
		if multiplayer.get_peers().size() > 0: #checks if there are multiple players, example two players, the host peers size is 2 while the joiner has 1
			rpc("relay_message", player_id, %SendMessage.text)

		%SendMessage.text = ""

@rpc("any_peer")
func relay_message(player_id, new_message : String): 
	print_debug("message relayed: ", new_message)
	if multiplayer.get_unique_id() == player_id: #If you sent the message
		%Messages.text += "\n: " + new_message
	else: #If someone sent a message
		%Messages.text += "\n: " + new_message
