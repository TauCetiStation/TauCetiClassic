//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = ITEM_SIZE_LARGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = 10 //The sum of the w_classes of all the items in this storage item.
	req_access = list(access_armory)
	var/locked = TRUE
	var/broken = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"


/obj/item/weapon/storage/lockbox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		if(broken)
			to_chat(user, "<span class='warning'>It appears to be broken.</span>")
			return
		if(allowed(user))
			locked = !( locked )
			if(locked)
				icon_state = icon_locked
				to_chat(user, "<span class='warning'>You lock the [src]!</span>")
				return
			else
				icon_state = icon_closed
				to_chat(user, "<span class='warning'>You unlock the [src]!</span>")
				return
		else
			to_chat(user, "<span class='warning'>Access Denied</span>")

	else if(istype(I, /obj/item/weapon/melee/energy/blade) && !broken)
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		icon_state = icon_broken
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)

		user.visible_message("<span class='warning'>The locker has been sliced open by [user] with an energy blade!</span>", blind_message = "<span class='warning'>You hear metal being sliced and sparks flying.</span>", viewing_distance = 3)

	if(!locked)
		return ..()
	else
		to_chat(user, "<span class='warning'>Its locked!</span>")

/obj/item/weapon/storage/lockbox/emag_act(mob/user)
	if(broken)
		return FALSE
	broken = TRUE
	locked = FALSE
	desc = "It appears to be broken."
	icon_state = icon_broken
	user.visible_message("<span class='warning'>The locker has been broken by [] with an electromagnetic card!</span>", blind_message = "<span class='warning'>You hear a faint electrical spark.</span>", viewing_distance = 3)
	return TRUE

/obj/item/weapon/storage/lockbox/open(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>Its locked!</span>")
	else
		..()
	return


/obj/item/weapon/storage/lockbox/mind_shields
	name = "lockbox of Mind Shields implants"
	req_access = list(access_brig)

/obj/item/weapon/storage/lockbox/mind_shields/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/weapon/implantcase/mindshield(src)
	new /obj/item/weapon/implanter/mindshield(src)

/obj/item/weapon/storage/lockbox/loyalty
	name = "lockbox of Loyalty implants"
	req_access = list(access_brig)

/obj/item/weapon/storage/lockbox/loyalty/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implanter/loyalty(src)


/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(access_security)

/obj/item/weapon/storage/lockbox/clusterbang/atom_init()
	. = ..()
	new /obj/item/weapon/grenade/clusterbuster(src)
