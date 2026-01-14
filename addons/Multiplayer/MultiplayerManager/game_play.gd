extends Node2D

var curr_round := 1

var opponent_scene : Node2D
const rows := 6
const cols := 4

var board : Array = []

var player_cards = []

var player_name : String
var enemy_name : String

func next_round():
	curr_round += 1
	%round_label.text = "[b][center]Round " + str(curr_round) +  " Go!!!"
	%round_label2.visible = false
	
	new_round()
	await get_tree().create_timer(2).timeout
	%Round.visible = false

func new_round():
	%Choices.new_round()
	%CardStash.new_round()
	%Player.new_round()
	opponent_scene.new_round()
	%PickCards.visible = true
	%PickCards.new_round()

func round_won(winner : piece.teams):
	%BlockInputs.visible = true
	%Round.visible = true
	if winner == piece.teams.player:
		%round_label.text = "[b][center]Round " + str(curr_round) +  " Win"
	else:
		%round_label.text = "[b][center]Round " + str(curr_round) +  " Lost"
	await get_tree().create_timer(3).timeout
	next_round()

#Called when pressing restart by main.gd
func restart():
	get_tree().reload_current_scene()

#Called from main.gd after instantiating this scene to transfer name entered, etc.
@rpc("any_peer")
func transfer_data(new_name : String, player_id):
	if multiplayer.get_unique_id() == player_id:
		player_name = new_name
		print("player_name = ", new_name)
		%Player.player_tag(player_name) #changes the player tag
	else:
		enemy_name = new_name
		print("enemy_name = ", new_name)

#called from slot.gd >>>>>>>>>>>>>>>>>>>>>>>>>>>>
func place_piece(slot_number : int, card_name : String):
	var player_id = multiplayer.get_unique_id()
	
	who_placed_piece(slot_number, card_name, player_id)
	rpc("who_placed_piece", slot_number, card_name, player_id) #This updates for the other players

#rpc doesn't allow object passed from a function like passing a pawn/piece that's why we have to get it insied a function
func get_card_with_name(card_name : String) -> piece:
	for card in %AllCards.cards:
		if card_name == card.name:
			return card.duplicate()
	var error = piece.new()
	error.name = "ERROR CARD"
	return error

@rpc("any_peer")
func who_placed_piece(slot_number : int, card_name : String, player_id):
	#print(player_id, ": placed a piece")
	var card = get_card_with_name(card_name) #rpc doesn't allow object passed from a function
	
	if multiplayer.get_unique_id() == player_id: #If you are the player on this networkd
		card.team = piece.teams.player #assign piece to player
		board[rows - 1][slot_number] = card
	else: #If the player id was the opponent
		card.team = piece.teams.opponent #assign piece to opponent
		board[0][slot_number] = card
	
	update_simulation()
	view_board()
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

func calculate_index(x:int, y:int) -> int:
	return (x*cols) + y

func simulate_attack():
	for x in range(rows):
		for y in range(cols):
			var pawn = board[x][y]
			if pawn is piece:
				var square : Area2D = %Board.get_node("Square" + str(calculate_index(x, y))) #the node in game corresponding to an index in the board
				var front_piece = null #piece in front of the pawn
				var front_square : Area2D #square in front of the pawn
				if pawn.team == piece.teams.player:
					if x - pawn.attack_direction >= 0: #If not on edge
						front_piece = board[x - pawn.attack_direction][y] #assign a var to the piece/square infront of this pawn 
						if pawn.special_skill == piece.special_skills.attack_adjacent:
							var front_left_piece = null
							var front_right_piece = null
							var front_left_square : Area2D
							var front_right_square : Area2D
							if y - 1 >= 0:
								front_left_piece = board[x - pawn.attack_direction][y - 1]
								if front_left_piece is piece and front_left_piece.team == piece.teams.opponent:
									front_left_square = %Board.get_node("Square" + str(calculate_index(x - pawn.attack_direction, y - 1)))
									await attack(pawn, square, front_left_piece, front_left_square, piece.side_directions.left)
							if y + 1 < cols:
								front_right_piece = board[x - pawn.attack_direction][y + 1]
								if front_right_piece is piece and front_right_piece.team == piece.teams.opponent:
									front_right_square = %Board.get_node("Square" + str(calculate_index(x - pawn.attack_direction, y + 1)))
									await attack(pawn, square, front_right_piece, front_right_square, piece.side_directions.right)
							continue


					if front_piece is piece: #This makes sure to only get piece while not needing to check if it is on edge
						front_square = %Board.get_node("Square" + str(calculate_index(x - pawn.attack_direction, y))) #the node in game corresponding to an index in the board
						if front_piece.team == piece.teams.opponent:
							await attack(pawn, square, front_piece, front_square, piece.side_directions.nothing)
				elif pawn.team == piece.teams.opponent:
					if x + pawn.attack_direction < rows: #If not on edge
						front_piece = board[x + pawn.attack_direction][y] #assign a var to the piece/square infront of this pawn
						if pawn.special_skill == piece.special_skills.attack_adjacent:
							var front_left_piece = null
							var front_right_piece = null
							var front_left_square : Area2D
							var front_right_square : Area2D
							if y - 1 >= 0:
								front_left_piece = board[x + pawn.attack_direction][y - 1]
								if front_left_piece is piece and front_left_piece.team == piece.teams.player:
									front_left_square = %Board.get_node("Square" + str(calculate_index(x - pawn.attack_direction, y - 1)))
									await attack(pawn, square, front_left_piece, front_left_square, piece.side_directions.left)
							if y + 1 < cols:
								front_right_piece = board[x + pawn.attack_direction][y + 1]
								if front_right_piece is piece and front_right_piece.team == piece.teams.player:
									front_right_square = %Board.get_node("Square" + str(calculate_index(x - pawn.attack_direction, y + 1)))
									await attack(pawn, square, front_right_piece, front_right_square, piece.side_directions.right)
							continue


					if front_piece is piece: #This makes sure to only get piece while not needing to check if it is on edge
						front_square = %Board.get_node("Square" + str(calculate_index(x + pawn.attack_direction, y))) #the node in game corresponding to an index in the board
						if front_piece.team == piece.teams.player:
							await attack(pawn, square, front_piece, front_square, piece.side_directions.nothing)
	print(name, "> attack phase finished")

	#ATTACK------------------------------------------------------------
func attack(pawn : piece, square : Area2D, front_piece : piece, front_square : Area2D, side_direction : piece.side_directions):
	pawn.attack_mode = true
	square.attack_mode(true)
	front_square.attack_mode(true)
	if pawn.damage <= 0:
		return
	if pawn.attack_mode:
		if pawn.special_skill == piece.special_skills.instant_kill:
			front_piece.health -= 25
		else:
			front_piece.health -= pawn.damage
		if pawn.special_skill == piece.special_skills.attack_adjacent:
			await square.attack_adjacent_pawn(front_square, front_piece, side_direction)
		else:
			await square.attack_pawn(front_square, front_piece) #IMPORTANT using await, only this function will wait, other functions will keep on going, so this will get delayed
		print("front_piece.health: ", front_piece.health)
		if front_piece.health <= 0: #if pawn killed it's opponent disable attack_mode
			pawn.attack_mode = false
			square.attack_mode(false)
			front_square.attack_mode(false)


#IMPORTANT-only runs if end turn is pressed---------------------------------------------
func simulate():
	var player_id = multiplayer.get_unique_id()
	who_clicked_end_turn(player_id)
	rpc("who_clicked_end_turn", player_id)

@rpc("any_peer")#even if you're not using player_id, 
func who_clicked_end_turn(player_id): #you still need to put it as a parameter of the function
	if %TutorialTurns.visible:
		%TutorialTurns.visible = false
	%EndTurn.disabled = true
	if multiplayer.get_unique_id() == player_id: #If you clicked end turn
		await simulate_order() #Simulate first before ebabling end turn
		%EndTurn.disabled = true  #disable your end turn so opponent can use end turn
		%PickCard.disable_monitoring()
		%PickCard2.disable_monitoring()
		%PickCard3.disable_monitoring()
		%PickCard4.disable_monitoring()
	else: #If the player id was the opponent
		await simulate_order()
		%EndTurn.disabled = false #if opponent clicked end turn it's your turn to click it
		%PickCard.enable_monitoring()
		%PickCard2.enable_monitoring()
		%PickCard3.enable_monitoring()
		%PickCard4.enable_monitoring()

func simulate_order():
	await simulate_attack() #simulate attacks
	player_move() #move the player first
	opponent_move() #move the opponent's pieces
	await update_simulation() #change animation
	view_board()
#IMPORTANT----------------------------------------------

@rpc("any_peer")
func update_simulation():
	for y in range(cols):
		for x in range(rows):
			var pawn = board[x][y]
			var index := calculate_index(x, y)
			var square : Area2D = %Board.get_node("Square" + str(index)) #the node in game corresponding to an index in the board
			if pawn is piece:
				square.visible = true #show the pawn
				if await square.is_pawn_dead(pawn): #run animiation pawn dead if true
					board[x][y] = index #replace the cell with index
					square.visible = false
				else: #if false 
					square.update_visuals(pawn)
			else:
				square.visible = false

@rpc("any_peer")
func player_move():
	print("player_move")
	for x in range(rows):
		for y in range(cols):
			if board[x][y] is piece and board[x][y].team == piece.teams.player:
				var player_piece = board[x][y]
				if x - 1 < 0: #check if on edge
					board[x][y] = calculate_index(x, y)#return the index number
					damage_opponent()
					continue
				if board[x - 1][y] is piece: #check if forward is a piece(this will decide if pawn will move forward)
					continue #skip the next lines of code and move to the next loop
				
				#there's a logical problem where opponent and player has to share 1 square, and always the player side takes that place because player_move() is run before opponent_move()
				#this negates it by prioritizing the pawn that is closest to the other player's end
				if board[x - 2][y] is piece and board[x-2][y].team == piece.teams.opponent: #check 2 piece in front
					if x <= cols -1:
						move_forward(x , y, player_piece)
				else:
					move_forward(x , y, player_piece)

#DAMAGE the player directly not between pawns>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Damage happens when either opponent or player's pieces reaches the other side's edge
func damage_opponent():#If the player's pieces reaches the opponent's edge
	var health = opponent_scene.take_damage()
	if health <= 0:
		round_won(piece.teams.player)
		%Player.round_win() 
		%BlockInputs.visible = true
		if %Player.get_crown() >= 3:
			%OverallWin.visible = true
			%Round.visible = false
			%AfterRounds.visible = false
			%winner_label.text = "[b][center]YOU WON!👑"

func damage_player(): #If the opponent's pieces reaches the player's edge
	var health = %Player.take_damage()
	if health <= 0:
		round_won(piece.teams.opponent)
		opponent_scene.round_win()
		%BlockInputs.visible = true
		if opponent_scene.get_crown() >= 3:
			%OverallWin.visible = true
			%Round.visible = false
			%AfterRounds.visible = false
			%winner_label.text = "[b][center]YOU LOST!😒"
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

func move_forward(x : int, y: int, pawn : piece):
	#if not on edge move forward
	board[x][y] = calculate_index(x, y)#return the index number
	if pawn.health <= 0:
		return
	board[x - 1][y] = pawn #move up by reducing x axis

@rpc("any_peer")
func opponent_move():
	print("opponent_move")
	#since the 0 index is at the top and last index is at the bottom, if the piece goes down it will keep on going down 
	#we gotta start from the last index to the top to not counter this logical bug
	for x in range(rows):
		for y in range(cols):
			var reverse_x = rows - (x + 1) #first index(0) becomes last index(23)
			var reverse_y = cols - (y + 1) #first index(0) becomes last index(23)
			if board[reverse_x][reverse_y] is piece and board[reverse_x][reverse_y].team == piece.teams.opponent:
				var opponent_piece = board[reverse_x][reverse_y]
				if reverse_x + 1 >= rows: #check if on edge
					board[reverse_x][reverse_y] = calculate_index(reverse_x, reverse_y)#return the index number
					damage_player()
					continue 
				if board[reverse_x + 1][reverse_y] is piece: #check if forward is a piece 
					continue #skip the next lines of code and move to the next loop
				#Move if possible
				move_downward(reverse_x, reverse_y, opponent_piece) 

func move_downward(x:int, y:int, pawn : piece):
	#if not on edge move forward
	board[x][y] = calculate_index(x, y)#return the index number
	if pawn.health <= 0:
		return
	board[x + 1][y] = pawn #move down by reducing x axis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%EndTurn.connect("pressed", simulate)
	instantiate_board()

func instantiate_board():
	for x in range(rows):
		var row := []
		for y in range(cols):
			row.append((x * cols) + y)
		board.append(row)

func view_board():
	pass
	#print(">>>>>>>>>>>>>>>>>>>>>>>>>>")
	#var player_id = multiplayer.get_unique_id()
	#print(" view_board() player_id: ", player_id)
	#for x in range(rows):
		#var line := ""
		#for y in range(cols):
			#if board[x][y]is piece:
				#line += str(board[x][y].team) + str(board[x][y].name) + " "
			#else:
				#line += str(board[x][y]) + " "
		#print(line)
	#print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")

#Called from RockPaperScissors.gd after determining who gets to go first by rock paper scissors
func who_goes_first(player_id):
	first_move(player_id)
	rpc("first_move", player_id)

@rpc("any_peer")
func first_move(player_id):
	print(name, "FIRST MOVE: ", player_id)
	%FirstTurn.visible = true
	%TutorialTurns.visible = true
	
	if multiplayer.get_unique_id() == player_id:
		%EndTurn.disabled = false
		%FirstTurn.first_turn_name(player_name)
		%PickCard.enable_monitoring()
		%PickCard2.enable_monitoring()
		%PickCard3.enable_monitoring()
		%PickCard4.enable_monitoring()
	else:
		%EndTurn.disabled = true
		%FirstTurn.enemy_first_turn()
		%PickCard.disable_monitoring()
		%PickCard2.disable_monitoring()
		%PickCard3.disable_monitoring()
		%PickCard4.disable_monitoring()

	await get_tree().create_timer(3).timeout
	%FirstTurn.visible = false

func opponent_joined(the_opponent_scene : Node2D):
	opponent_scene = the_opponent_scene
	
	var player_id = multiplayer.get_unique_id()
	
	if player_id == 1:
		opponent_scene.change_player_frame("host")
		%Player.change_player_frame("join")
	else:
		opponent_scene.change_player_frame("join")
		%Player.change_player_frame("host")
