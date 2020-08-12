/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure1"
	density = 1
	opened = 0
	locked = 1
	var/large = 1
	icon_closed = "secure"
	var/icon_locked = "secure1"
	icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"
	wall_mounted = 0 //never solid (You can always pass over it)
	health = 200

/obj/structure/closet/secure_closet/can_open()
	if(src.locked || src.welded)
		return 0
	return ..()

/obj/structure/closet/secure_closet/close()
	if(..())
		if(broken)
			icon_state = src.icon_off
		return 1
	else
		return 0

/obj/structure/closet/secure_closet/AltClick(mob/user)
	if(!user.incapacitated() && in_range(user, src) && user.IsAdvancedToolUser())
		src.togglelock(user)
	..()

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emplode(severity)
	if(!broken)
		if(prob(50/severity))
			src.locked = !src.locked
			src.update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/user)
	if(src.opened)
		to_chat(user, "<span class='notice'>Close the locker first.</span>")
		return
	if(src.broken)
		to_chat(user, "<span class='warning'>The locker appears to be broken.</span>")
		return
	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return
	if(src.allowed(user))
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				to_chat(O, "<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/secure_closet/attackby(obj/item/weapon/W, mob/user)
	if(opened  || istype(W, /obj/item/weapon/grab))
		return ..()
	else if((istype(W, /obj/item/weapon/melee/energy/blade)||istype(W, /obj/item/weapon/twohanded/dualsaber)) && !src.broken)
		broken = 1
		locked = 0
		user.SetNextMove(CLICK_CD_MELEE)
		desc = "It appears to be broken."
		icon_state = icon_off
		flick(icon_broken, src)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		visible_message("<span class='notice'>The locker has been sliced open by [user] with an [W.name]!</span>", blind_message = "<span class='warning'>You hear metal being sliced and sparks flying.</span>", viewing_distance = 3)

	else if(istype(W,/obj/item/weapon/packageWrap) || iswelder(W))
		return ..(W,user)
	else
		togglelock(user)

/obj/structure/closet/secure_closet/emag_act(mob/user)
	if(broken)
		return FALSE
	broken = 1
	locked = 0
	user.SetNextMove(CLICK_CD_MELEE)
	desc = "It appears to be broken."
	icon_state = icon_off
	flick(icon_broken, src)
	visible_message("<span class='notice'>The locker has been sliced open by [user] with an electromagnetic card!</span>", blind_message = "<span class='warning'>You hear a faint electrical spark.</span>", viewing_distance = 3)
	return TRUE

/obj/structure/closet/secure_closet/attack_hand(mob/user)
	src.add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if(src.locked)
		src.togglelock(user)
	else
		src.toggle(user)

/obj/structure/closet/secure_closet/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.togglelock(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/secure_closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	cut_overlays()
	if(!opened)
		if(locked)
			icon_state = icon_locked
		else
			icon_state = icon_closed
		if(welded)
			add_overlay("welded")
	else
		icon_state = icon_opened
