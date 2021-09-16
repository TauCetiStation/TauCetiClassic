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
	if(!Adjacent(user) || !over.Adjacent(user))
		return FALSE // should stop you from dragging through windows
	return TRUE


/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!usr || !over)
		return FALSE
	var/obj/item/I = usr.get_active_hand()
	if(I && (SEND_SIGNAL(I, COMSIG_ITEM_MOUSEDROP_ONTO, over, src, usr) & COMPONENT_NO_MOUSEDROP))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOUSEDROP_ONTO, over, usr) & COMPONENT_NO_MOUSEDROP) //Whatever is receiving will verify themselves for adjacency.
		return FALSE
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return FALSE // should stop you from dragging through windows

	INVOKE_ASYNC(over, /atom.proc/MouseDrop_T, src, usr)
	return TRUE

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	SEND_SIGNAL(src, COMSIG_MOUSEDROPPED_ONTO, dropping, user)
