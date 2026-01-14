# movement_utility.gd
# skills for player, can be used by States or directly reference by player
class_name MovementUtility

static var last_faced_direction : float #to know where the player was last facing

# Allow horizontal control >>>>>>>>>>>>>
static func horizontal_movement_utility(owner: Node, delta: float, fps: float) -> void:
	var dir: float = Input.get_axis("left", "right")
	if dir != 0:
		owner.velocity.x = move_toward(owner.velocity.x, owner.SPEED * dir, owner.ACCELERATION * (delta * fps))
		last_faced_direction = dir
	else:
		owner.velocity.x = move_toward(owner.velocity.x, 0, owner.FRICTION * (delta * fps))

#DASH >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
static var can_dash : bool = true #To manage spamming dash
static var is_dashing : bool #After pressing dash
static func dash_utility(owner: Node):
	var dir_x = Input.get_axis("left", "right")
	var dir_y = Input.get_axis("up", "down")
	
	if dir_y >= 1: # DOWNWARD DASH
		owner.velocity.x = 0
		owner.velocity.y = -owner.JUMP_VELOCITY
	elif dir_x == 0: #if player pressed dash but didnt press any ASWD keys
		dir_x = last_faced_direction #use the last direction the player was facing as the dash direction
	
	owner.velocity.x = owner.DASH_SPEED * dir_x
	owner.velocity.y = 0

	print("Dash direction: :", dir_x)
	start_dash_cooldown(owner) #Cooldown for dash
	start_air_time(owner) #To know if player is still dashing, to stop gravity

static var dash_cooldown_timer := 0.3 #after dash, disable for a short amount of time
static func start_dash_cooldown(owner: Node):
	can_dash = false
	await owner.get_tree().create_timer(dash_cooldown_timer).timeout
	can_dash = true

static var dash_air_time := 0.1
static func start_air_time(owner: Node):
	is_dashing = true
	await owner.get_tree().create_timer(dash_air_time).timeout
	is_dashing = false

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
