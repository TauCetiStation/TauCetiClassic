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
	if(!src.Adjacent(user) || !over.Adjacent(user))
		return FALSE // should stop you from dragging through windows
	return TRUE


/atom/MouseDrop(atom/over)
	if(!usr || !over)
		return

	INVOKE_ASYNC(usr, /mob.proc/onMouseDrop, over, src)

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return

/mob/proc/canMouseDrop_T(atom/dropping, atom/target)
	return target.Adjacent(src) && dropping.Adjacent(src)

// Call the MouseDrop_T here if you must.
/mob/proc/onMouseDrop(atom/target, atom/dropping)
	if(!canMouseDrop_T(target, dropping))
		return // should stop you from dragging through windows

	INVOKE_ASYNC(target, /atom.proc/MouseDrop_T, dropping, src)

/mob/living/onMouseDrop(atom/target, atom/dropping)
	var/obj/item/I = get_active_hand()
	if(I && I.onUserMouseDrop(target, dropping, src))
		return

	if(!canMouseDrop_T(target, dropping))
		return // should stop you from dragging through windows

	INVOKE_ASYNC(target, /atom.proc/MouseDrop_T, dropping, src)
