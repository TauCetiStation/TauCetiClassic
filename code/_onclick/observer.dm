/client/var/inquisitive_ghost = TRUE
/mob/dead/observer/verb/toggle_inquisition() // warning: unexpected inquisition
	set name = "Toggle Inquisitiveness"
	set desc = "Sets whether your ghost examines everything on click by default."
	set category = "Ghost"
	if(!client)
		return
	client.inquisitive_ghost = !client.inquisitive_ghost
	if(client.inquisitive_ghost)
		to_chat(src, "<span class='notice'>You will now examine everything you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer examine things you click on.</span>")

/client/var/machine_interactive_ghost = FALSE
/mob/dead/observer/verb/toggle_interactive_machines() // warning: unexpected inquisition
	set name = "Toggle Interactive Machines"
	set desc = "Sets whether your ghost interact with machines on click by default."
	set category = "Ghost"
	if(!client)
		return
	client.machine_interactive_ghost = !client.machine_interactive_ghost
	if(client.machine_interactive_ghost)
		to_chat(src, "<span class='notice'>You will now interact with machines you click on.</span>")
	else
		to_chat(src, "<span class='notice'>You will no longer interact with machines you click on.</span>")

/mob/dead/observer/DblClickOn(atom/A, params)
	if(client.buildmode || istype(A, /obj/effect/statclick) || istype(A, /obj/screen)) // handled in normal click.
		return
	if(can_reenter_corpse && mind && mind.current)
		if(A == mind.current || (mind.current in A)) // double click your corpse or whatever holds it
			reenter_corpse()						// (cloning scanner, body bag, closet, mech, etc)
			return									// seems legit.

	// Things you might plausibly want to follow
	if(istype(A, /atom/movable))
		ManualFollow(A)

	// Otherwise jump
	else
		loc = get_turf(A)
		update_parallax_contents()

/mob/dead/observer/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		ShiftClickOn(A)
		return

	if(world.time <= next_move)
		return
	next_move = world.time + 8

	// You are responsible for checking config.ghost_interaction when you override this function
	// Not all of them require checking, see below
	A.attack_ghost(src)

// Oh by the way this didn't work with old click code which is why clicking shit didn't spam you
/atom/proc/attack_ghost(mob/dead/observer/user)
	if(user.client)
		if(IsAdminGhost(user))
			attack_ai(user)
		if(user.client.inquisitive_ghost)
			user.examinate(src)

// ---------------------------------------
// And here are some good things for free:
// Now you can click through portals, wormholes, gateways, and teleporters while observing. -Sayu

/obj/machinery/teleport/hub/attack_ghost(mob/user)
	var/atom/l = loc
	var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(l.x - 2, l.y, l.z))
	if(com.locked)
		user.loc = get_turf(com.locked)

/obj/effect/portal/attack_ghost(mob/user)
	if(target)
		user.loc = get_turf(target)

/obj/machinery/gateway/center/attack_ghost(mob/user)
	if(destination)
		user.loc = destination.loc
	else
		to_chat(user, "[src] has no destination.")

// -------------------------------------------
// This was supposed to be used by adminghosts
// I think it is a *terrible* idea
// but I'm leaving it here anyway
// commented out, of course.
/*
/atom/proc/attack_admin(mob/user)
	if(!user || !user.client || !user.client.holder)
		return
	attack_hand(user)

*/
