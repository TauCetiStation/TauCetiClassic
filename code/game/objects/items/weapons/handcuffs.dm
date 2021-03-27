/obj/item/weapon/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 5
	m_amt = 500
	origin_tech = "materials=1"
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes
	var/cuff_sound = 'sound/weapons/handcuffs.ogg'

/obj/item/weapon/handcuffs/attack(mob/living/carbon/C, mob/user)
	if (!ishuman(user) && !isIAN(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(C))
		return
	if ((CLUMSY in usr.mutations) && prob(50))
		to_chat(user, "<span class='warning'>Uh ... how do those things work?!</span>")
		place_handcuffs(user, user)
		return
	if(!C.handcuffed)
		if (C == user || isIAN(user))
			place_handcuffs(C, user)
			return

		//check for an aggressive grab
		for (var/obj/item/weapon/grab/G in C.grabbed_by)
			if (G.loc == user && G.state >= GRAB_AGGRESSIVE)
				place_handcuffs(C, user)
				return
		to_chat(user, "<span class='warning'>You need to have a firm grip on [C] before you can put \the [src] on!</span>")

/obj/item/weapon/handcuffs/proc/place_handcuffs(mob/living/carbon/target, mob/user)
	if(user.is_busy(target))
		return

	playsound(src, cuff_sound, VOL_EFFECTS_MASTER, 30, null, -2)

	if (ishuman(target) || isIAN(target) || ismonkey(target))
		target.log_combat(user, "handcuffed (attempt) with [name]")

		if(do_mob(user, target, HUMAN_STRIP_DELAY) && mob_can_equip(target, SLOT_HANDCUFFED))
			if(!isrobot(user) && !isIAN(user) && user != target)
				var/grabbing = FALSE
				for (var/obj/item/weapon/grab/G in target.grabbed_by)
					if (G.loc == user && G.state >= GRAB_AGGRESSIVE)
						grabbing = TRUE
						break
				if (!grabbing)
					to_chat(user, "<span class='warning'>Your grasp was broken before you could restrain [target]!</span>")
					return

			var/obj/item/weapon/handcuffs/cuffs = src
			if(!dispenser)
				user.remove_from_mob(cuffs)
			else
				cuffs = new type

			target.equip_to_slot(cuffs, SLOT_HANDCUFFED, TRUE)
			target.attack_log += "\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) placed on our [target.slot_id_to_name(SLOT_HANDCUFFED)] ([cuffs])</font>"
			user.attack_log += "\[[time_stamp()]\] <font color='red'>Placed on [target.name]'s ([target.ckey]) [target.slot_id_to_name(SLOT_HANDCUFFED)] ([cuffs])</font>"

/obj/item/weapon/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_white"
	breakouttime = 300 //Deciseconds = 30s
	cuff_sound = 'sound/weapons/cablecuff.ogg'

/obj/item/weapon/handcuffs/cable/CheckParts(list/parts_list)
	..()
	for(var/obj/item/stack/cable_coil/C in contents)
		color = C.color

/obj/item/weapon/handcuffs/cable/red
	color = "#dd0000"

/obj/item/weapon/handcuffs/cable/yellow
	color = "#dddd00"

/obj/item/weapon/handcuffs/cable/blue
	color = "#0000dd"

/obj/item/weapon/handcuffs/cable/green
	color = "#00dd00"

/obj/item/weapon/handcuffs/cable/pink
	color = "#dd00dd"

/obj/item/weapon/handcuffs/cable/orange
	color = "#dd8800"

/obj/item/weapon/handcuffs/cable/cyan
	color = "#00dddd"

/obj/item/weapon/handcuffs/cable/white
	color = "#ffffff"

/obj/item/weapon/handcuffs/cyborg
	dispenser = 1

/obj/item/weapon/handcuffs/cyborg/attack(mob/living/carbon/C, mob/user)
	if(!C.handcuffed)
		place_handcuffs(C, user)
