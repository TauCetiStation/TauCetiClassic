/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(access_all_personal_lockers)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/PopulateContents()
	if(prob(50))
		new /obj/item/weapon/storage/backpack(src)
	else
		new /obj/item/weapon/storage/backpack/satchel/norm(src)
	new /obj/item/device/radio/headset(src)

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/PopulateContents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/white(src)

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/personal/cabinet/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/personal/cabinet/PopulateContents()
	new /obj/item/weapon/storage/backpack/satchel/withwallet(src)
	new /obj/item/device/radio/headset(src)

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user)
	if(opened  || istype(W, /obj/item/weapon/grab))
		return ..()
	else if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		var/user_registered_name = null
		if(src.broken)
			to_chat(user, "<span class='warning'>It appears to be broken.</span>")
			return
		if(istype(W, /obj/item/device/pda))
			var/obj/item/device/pda/pda = W
			user_registered_name = pda?.id?.registered_name
			if(isnull(user_registered_name))
				to_chat(user, "<span class='red'> You need ID card in PDA for this.</span>")
				return
		else if(istype(W, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/id = W
			user_registered_name = id.registered_name
		if(src.allowed(user) || !src.registered_name || (src.registered_name == user_registered_name))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			if(src.locked)	src.icon_state = src.icon_locked
			else	src.icon_state = src.icon_closed

			if(!src.registered_name && user_registered_name)
				src.registered_name = user_registered_name
				src.desc = "Owned by [user_registered_name]."
		else
			to_chat(user, "<span class='warning'>Access Denied</span>")
	else if((istype(W, /obj/item/weapon/melee/energy/blade)||istype(W, /obj/item/weapon/twohanded/dualsaber)) && !src.broken)
		emag_act(user)
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
		visible_message("<span class='notice'>The locker has been sliced open by [user] with an [W.name]!</span>", blind_message = "<span class='warning'>You hear metal being sliced and sparks flying.</span>", viewing_distance = 3)
	else
		to_chat(user, "<span class='warning'>Access Denied</span>")
	return

/obj/structure/closet/secure_closet/personal/emag_act(mob/user)
	if(src.broken)
		return FALSE
	broken = 1
	locked = 0
	user.SetNextMove(CLICK_CD_MELEE)
	desc = "It appears to be broken."
	icon_state = src.icon_broken
	return TRUE

/obj/structure/closet/secure_closet/personal/verb/reset()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Reset Lock"
	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return
	if(ishuman(usr))
		src.add_fingerprint(usr)
		if (src.locked || !src.registered_name)
			to_chat(usr, "<span class='warning'>You need to unlock it first.</span>")
		else if (src.broken)
			to_chat(usr, "<span class='warning'>It appears to be broken.</span>")
		else
			if (src.opened)
				if(!src.close())
					return
			src.locked = 1
			src.icon_state = src.icon_locked
			src.registered_name = null
			src.desc = "It's a secure locker for personnel. The first card swiped gains control."
	return
