/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/proc/CanMouseDrop(atom/over, mob/user = usr)
	if(!user || !over)
		return FALSE
	if(user.incapacitated())
		return FALSE
	if((TK in user.mutations) && Adjacent(over)) // So we don't check if we're near, if we are doing telekinesis.
		return TRUE
	if(!src.Adjacent(user) || !over.Adjacent(user))
		return FALSE // should stop you from dragging through windows

/atom/MouseDrop(atom/over)
	if(!CanMouseDrop(over, usr))
		return // should stop you from dragging through windows

	INVOKE_ASYNC(over, /atom.proc/MouseDrop_T, src, usr)

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return
