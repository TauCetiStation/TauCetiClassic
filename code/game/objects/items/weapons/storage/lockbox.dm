/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = SIZE_NORMAL
	max_w_class = SIZE_SMALL
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
				close_all() // close the content window for all mobs, when lock lockbox
				return
			else
				icon_state = icon_closed
				to_chat(user, "<span class='warning'>You unlock the [src]!</span>")
				return
		else
			to_chat(user, "<span class='warning'>Access Denied</span>")
			return

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

/obj/item/weapon/storage/lockbox/attack_hand(mob/user)
	if ((loc == user) && locked)
		to_chat(user, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if ((loc == user) && !locked)
		open(user)
	else
		..()
	add_fingerprint(user)

/obj/item/weapon/storage/lockbox/emag_act(mob/user)
	if(broken)
		return FALSE
	broken = TRUE
	locked = FALSE
	desc = "It appears to be broken."
	icon_state = icon_broken
	user.visible_message("<span class='warning'>The locker has been broken by [] with an electromagnetic card!</span>", blind_message = "<span class='warning'>You hear a faint electrical spark.</span>", viewing_distance = 3)
	return TRUE

/obj/item/weapon/storage/lockbox/try_open(mob/user)
	if(locked && !broken)
		if(user.in_interaction_vicinity(src))
			to_chat(user, "<span class='warning'>[src] is locked and cannot be opened!</span>")
		return FALSE
	else
		return ..()

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

/obj/item/weapon/storage/lockbox/anti_singulo
	name = "singularity buster kit"
	desc = "Lockbox containing experimental rocket launcher to deal with little problems."
	req_access = list(access_engine_equip)

/obj/item/weapon/storage/lockbox/anti_singulo/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/ammo_casing/caseless/rocket/anti_singulo(src)
	new /obj/item/weapon/gun/projectile/revolver/rocketlauncher/anti_singulo(src)
	make_exact_fit()

/obj/item/weapon/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	req_access = list(access_captain)
	icon_state = "medalbox+l"
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

	max_w_class = SIZE_TINY
	max_storage_space = null
	storage_slots = 10
	can_hold = list(/obj/item/clothing/accessory/medal)

	var/open = FALSE // used for overlays

/obj/item/weapon/storage/lockbox/medal/open(mob/user)
	..()
	open = TRUE
	update_icon()

/obj/item/weapon/storage/lockbox/medal/close(mob/user)
	..()
	open = FALSE
	update_icon()

/obj/item/weapon/storage/lockbox/medal/update_icon()
	if(locked)
		icon_state = "medalbox+l"
		return

	icon_state = "medalbox"
	if(open)
		icon_state += "open"
	if(broken)
		icon_state += "+b"

	update_overlays()

/obj/item/weapon/storage/lockbox/medal/proc/update_overlays()
	cut_overlays()

	if(!contents || !open || locked)
		return

	for(var/i in 1 to contents.len)
		var/obj/item/clothing/accessory/medal/M = contents[i]
		var/mutable_appearance/medalicon = mutable_appearance(initial(icon), M.medaltype)
		if(i > 1 && i <= 5)
			medalicon.pixel_x += ((i-1)*3)
		else if(i > 5)
			medalicon.pixel_y -= 7
			medalicon.pixel_x -= 2
			medalicon.pixel_x += ((i-6)*3)
		add_overlay(medalicon)

/obj/item/weapon/storage/lockbox/medal/captain
	name = "Captain medal box"
	desc = "A locked box used to store medals to be given to crew."

	startswith = list(
		/obj/item/clothing/accessory/medal/conduct,
		/obj/item/clothing/accessory/medal/conduct,
		/obj/item/clothing/accessory/medal/conduct,
		/obj/item/clothing/accessory/medal/bronze_heart,
		/obj/item/clothing/accessory/medal/silver/security,
		/obj/item/clothing/accessory/medal/silver/valor,
		/obj/item/clothing/accessory/medal/silver/valor,
		/obj/item/clothing/accessory/medal/plasma/nobel_science,
		/obj/item/clothing/accessory/medal/plasma/nobel_science,
		/obj/item/clothing/accessory/medal/gold/captain)

/obj/item/weapon/storage/lockbox/medal/hop
	name = "Head of Personnel medal box"
	desc = "A locked box used to store medals to be given to those exhibiting excellence in management."
	req_access = list(access_hop)

	startswith = list(
		/obj/item/clothing/accessory/medal/gold/bureaucracy,
		/obj/item/clothing/accessory/medal/gold/bureaucracy,
		/obj/item/clothing/accessory/medal/gold/bureaucracy,
		/obj/item/clothing/accessory/medal/silver/excellence)

/obj/item/weapon/storage/lockbox/medal/hos
	name = "security medal box"
	desc = "A locked box used to store medals to be given to members of the security department."
	req_access = list(access_hos)

	startswith = list(
		/obj/item/clothing/accessory/medal/silver/security,
		/obj/item/clothing/accessory/medal/silver/security,
		/obj/item/clothing/accessory/medal/silver/security)

/obj/item/weapon/storage/lockbox/medal/cmo
	name = "medical medal box"
	desc = "A locked box used to store medals to be given to members of the medical department."
	req_access = list(access_cmo)

	startswith = list(
		/obj/item/clothing/accessory/medal/silver/med_medal,
		/obj/item/clothing/accessory/medal/silver/med_medal2)

/obj/item/weapon/storage/lockbox/medal/rd
	name = "science medal box"
	desc = "A locked box used to store medals to be given to members of the science department."
	req_access = list(access_rd)

	startswith = list(
		/obj/item/clothing/accessory/medal/plasma/nobel_science,
		/obj/item/clothing/accessory/medal/plasma/nobel_science,
		/obj/item/clothing/accessory/medal/plasma/nobel_science)

/obj/item/weapon/storage/lockbox/medal/nanotrasen
	name = "NanoTrasen medal box"
	desc = "A locked box used to store all awards to be given to stationeers."
	req_access = list(access_cent_captain)
	storage_slots = 13

	startswith = list(
		/obj/item/clothing/accessory/medal/cargo,
		/obj/item/clothing/accessory/medal/conduct,
		/obj/item/clothing/accessory/medal/bronze_heart,
		/obj/item/clothing/accessory/medal/silver/med_medal,
		/obj/item/clothing/accessory/medal/silver/med_medal2,
		/obj/item/clothing/accessory/medal/silver/security,
		/obj/item/clothing/accessory/medal/silver/valor,
		/obj/item/clothing/accessory/medal/silver/excellence,
		/obj/item/clothing/accessory/medal/plasma/nobel_science,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/accessory/medal/gold/heroism,
		/obj/item/clothing/accessory/medal/gold/bureaucracy,
		/obj/item/clothing/accessory/medal/gold/nanotrasen)

/obj/item/weapon/storage/lockbox/medal/nanotrasen/update_overlays()
	return
