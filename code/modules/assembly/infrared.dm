/obj/item/device/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	m_amt = 1000
	g_amt = 500
	w_amt = 100
	origin_tech = "magnets=2"

	wires = WIRE_PULSE

	secured = 0

	var/on = 0
	var/visible = 0
	var/obj/effect/beam/i_beam/first = null
	var/obj/effect/beam/i_beam/last = null


/obj/item/device/assembly/infra/Destroy()
	if(first)
		qdel(first)
	return ..()

/obj/item/device/assembly/infra/activate()
	if(!..())
		return 0//Cooldown check
	on = !on
	update_icon()
	return 1

/obj/item/device/assembly/infra/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		on = 0
		if(first)
			qdel(first)
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured

/obj/item/device/assembly/infra/attach_assembly(obj/item/device/assembly/A, mob/user)
	. = ..()
	message_admins("[key_name_admin(user)] attached \the [A] to \the [src]. [ADMIN_JMP(user)]")
	log_game("[key_name(user)] attached \the [A] to \the [src].")

/obj/item/device/assembly/infra/update_icon()
	cut_overlays()
	attached_overlays = list()
	if(on)
		add_overlay("infrared_on")
		attached_overlays += "infrared_on"

	if(holder)
		holder.update_icon()
	return

/obj/item/device/assembly/infra/process()//Old code
	if(!on)
		if(first)
			qdel(first)
		return
	if(!secured)
		return
	if(first && last)
		last.process()
		return
	var/turf/T = get_turf(src)
	if(T && holder && isturf(holder.loc))
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(T)
		I.master = src
		I.density = 1
		I.dir = dir
		first = I
		step(I, I.dir)
		if(first)
			I.density = 0
			I.vis_spread(visible)
			I.limit = 8
			I.process()

/obj/item/device/assembly/infra/attack_hand()
	qdel(first)
	..()
	return

/obj/item/device/assembly/infra/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	var/t = dir
	. = ..()
	dir = t
	qdel(first)

/obj/item/device/assembly/infra/holder_movement()
	if(!holder)
		return 0
//	dir = holder.dir
	qdel(first)
	return 1

/obj/item/device/assembly/infra/proc/trigger_beam()
	if((!secured)||(!on)||(cooldown > 0))
		return 0
	pulse(0)
	if(!holder)
		visible_message("[bicon(src)] *beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()
	var/time_pulse = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	lastsignalers.Add("[time_pulse] <B>:</B> [src] activated  @ location ([T.x],[T.y],[T.z])")
	message_admins("[src] activated  @ location ([T.x],[T.y],[T.z]) [ADMIN_JMP(T)]")
	log_game("[src] activated  @ location ([T.x],[T.y],[T.z])")
	return

/obj/item/device/assembly/infra/interact(mob/user)//TODO: change this this to the wire control panel
	if(is_secured(user))
		user.set_machine(src)
		var/dat = "<TT><B>Infrared Laser</B>\n<B>Status</B>: [on ? "<A href='?src=\ref[src];state=0'>On</A>" : "<A href='?src=\ref[src];state=1'>Off</A>"]<BR>\n<B>Visibility</B>: [visible ? "<A href='?src=\ref[src];visible=0'>Visible</A>" : "<A href='?src=\ref[src];visible=1'>Invisible</A>"]<BR>\n</TT>"
		dat += "<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"
		user << browse(dat, "window=infra")
		onclose(user, "infra")
		return

/obj/item/device/assembly/infra/Topic(href, href_list)
	..()
	if(usr.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return

	if(href_list["state"])
		on = !(on)
		update_icon()
		var/time_start = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		if(usr)
			lastsignalers.Add("[time_start] <B>:</B> [usr.key] set [src] [on?"On":"Off"] @ location ([T.x],[T.y],[T.z])")
			message_admins("[key_name_admin(usr)] set [src] [on?"On":"Off"], location ([T.x],[T.y],[T.z]) [ADMIN_JMP(usr)]")
			log_game("[usr.ckey]([usr]) set [src] [on?"On":"Off"], location ([T.x],[T.y],[T.z])")
		else
			lastsignalers.Add("[time_start] <B>:</B> (NO USER FOUND) set [src] [on?"On":"Off"] @ location ([T.x],[T.y],[T.z])")
			message_admins("( NO USER FOUND) set [src] [on?"On":"Off"], location ([T.x],[T.y],[T.z])")
			log_game("(NO USER FOUND) set [src] [on?"On":"Off"], location ([T.x],[T.y],[T.z])")

	if(href_list["visible"])
		visible = !(visible)
		if(first)
			first.vis_spread(visible)

	if(href_list["close"])
		usr << browse(null, "window=infra")
		return
	if(usr)
		attack_self(usr)

/obj/item/device/assembly/infra/verb/rotate()//This could likely be better
	set name = "Rotate Infrared Laser"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	dir = turn(dir, 90)
	return



/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "infrared beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/effect/beam/i_beam/previous = null
	var/obj/item/device/assembly/infra/master = null
	var/limit = null
	var/visible = 0
	var/left = null
	anchored = 1

/obj/effect/beam/i_beam/proc/hit()
	if(master)
		master.trigger_beam()
	qdel(src)
	return

/obj/effect/beam/i_beam/proc/vis_spread(v)
	visible = v
	if(next)
		next.vis_spread(v)

/obj/effect/beam/i_beam/process()
	if((loc.density || !(master)))
		qdel(src)
		return
	if(left > 0)
		left--
	if(left < 1)
		if(!(visible))
			invisibility = 101
		else
			invisibility = 0
	else
		invisibility = 0

	if(!next && (limit > 0))
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(loc)
		I.master = master
		I.density = 1
		I.dir = dir
		I.previous = src
		next = I
		step(I, I.dir)
		if(next)
			I.density = 0
			I.vis_spread(visible)
			I.limit = limit - 1
			master.last = I
			I.process()

/obj/effect/beam/i_beam/Bump()
	qdel(src)
	return

/obj/effect/beam/i_beam/Bumped()
	hit()

/obj/effect/beam/i_beam/Crossed(atom/movable/AM)
	. = ..()
	if(istype(AM, /obj/effect/beam))
		return
	hit()

/obj/effect/beam/i_beam/Destroy()
	if(master.first == src)
		master.first = null
	if(next)
		qdel(next)
		next = null
	if(previous)
		previous.next = null
		master.last = previous
	return ..()
