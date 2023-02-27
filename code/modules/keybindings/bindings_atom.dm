// You might be wondering why this isn't client level. If focus is null, we don't want you to move.
// Only way to do that is to tie the behavior into the focus's keyLoop().

/atom/movable/keyLoop(client/user)
	var/movement_dir = NONE
	if(length(user.keys_held) > 0)
		var/_key = user.keys_held[1]
		movement_dir = user.movement_keys[_key]

	if(movement_dir) //If we're not moving, don't compensate, as byond will auto-fill dir otherwise
		movement_dir = turn(movement_dir, -dir2angle(user.dir)) //By doing this we ensure that our input direction is offset by the client (camera) direction

	if(user.movement_locked)
		keybind_face_direction(movement_dir)
	else
		user.Move(get_step(src, movement_dir), movement_dir)
