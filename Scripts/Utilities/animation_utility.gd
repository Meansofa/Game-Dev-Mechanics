class_name AnimationUtility

#flip the sprite based on where the player is facing
static func change_facing_direction(player_sprite : Node):
	var dir = Input.get_axis("left", "right")
	if dir >= 1:
		player_sprite.flip_h = false
	if dir <= -1:
		player_sprite.flip_h = true
