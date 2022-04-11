/*
	This component is used with anything that needs
	to check if a user is who they claim to be? this also serves as authorization, kinda
*/
/datum/component/authentication
	// Key Memory used as password for authentication
	var/authenticate_key_memory
	// The "entropy" of password options, is used to determine how hard it would be to crack/guess the password randomly.
	var/password_combos

	var/datum/callback/get_input
	var/datum/callback/get_password

/datum/component/authentication/Initialize(auth_memory, pass_combos, datum/callback/input_callback, datum/callback/password_callback)
	authenticate_memory = auth_memory
	get_input = input_callback

	password_combos = pass_combos
	get_password = password_callback

	RegisterSignal(parent, list(COMSIG_AUTHENTICATE), .proc/authenticate)

/datum/component/authentication/proc/authenticate(datum/source, mob/user)
	if(!user.can_remember())
		return COMPONENT_ACCESS_DENIED

	var/password = get_password.Invoke()

	if(user.try_remember(authenticate_memory) == password)
		return COMPONENT_ACCESS_GRANTED

	if(input_callback.Invoke(user) == password)
		return COMPONENT_ACCESS_GRANTED

	if(crack_password(user))
		return COMPONENT_ACCESS_GRANTED

	return COMPONENT_ACCESS_DENIED

/datum/component/authentication/proc/crack_password(datum/source, mob/user)
	if(prob(1 / password_combos) &&  user.can_remember())
		user.mind.add_key_memory(authenticate_key_memory, get_password.Invoke())
		return TRUE
	return FALSE
