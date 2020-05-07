/*
	This component is used with anything that needs
	to check if a user should have access to stuff.
*/
/datum/component/authentication
	var/authenticate_memory // The memory stack ID used.
	var/password_combos     // Is used to determine how hard it would be to crack.

	var/datum/callback/get_password

/datum/component/authentication/Initialize(auth_memory, pass_combos, datum/callback/password_callback)
	authenticate_memory = auth_memory
	password_combos = pass_combos
	get_password = password_callback
	RegisterSignal(parent, list(COMSIG_AUTHENTICATE), .proc/authenticate)

/datum/component/authentication/proc/authenticate(datum/source, mob/user)
	var/datum/meme/memory/password/P = user.handle_appropriate_memories(authenticate_memory, "Please choose the appropriate password memory.")

	if(P && P.try_remember(user) && P.password == get_password.Invoke())
		return COMPONENT_ACCESS_GRANTED

	else if(crack_password(user))
		return COMPONENT_ACCESS_GRANTED

	return COMPONENT_ACCESS_DENIED

/datum/component/authentication/proc/crack_password(datum/source, mob/user)
	if(prob(1 / password_combos))
		user.attach_meme(authenticate_memory + "_" + get_password.Invoke())
		return TRUE
	return FALSE
