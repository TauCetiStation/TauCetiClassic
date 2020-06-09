/obj/item/device/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "beacon"
	var/code = "electronic"
	origin_tech = "bluespace=1"

/obj/item/device/radio/beacon/atom_init()
	. = ..()
	radio_beacon_list += src

/obj/item/device/radio/beacon/Destroy()
	radio_beacon_list -= src
	return ..()

/obj/item/device/radio/beacon/hear_talk()
	return


/obj/item/device/radio/beacon/send_hear()
	return null

/obj/item/device/radio/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	code = t
	if(!code)
		code = "beacon"
	add_fingerprint(usr)

/obj/item/device/radio/beacon/bacon/proc/digest_delay() //Probably a better way of doing this, I'm lazy.
	spawn(600)
		qdel(src)


// SINGULO BEACON SPAWNER

/obj/item/device/radio/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/device/radio/beacon/syndicate/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In</span>")
		new /obj/machinery/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER)
		qdel(src)
	return

//Medical beacon stuff
/obj/item/device/beacon/medical
	name = "Medical Tracking Beacon"
	desc = "A beacon used by a body teleporter."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon_med"
	item_state = "signaler"
	origin_tech = "bluespace=1"

/obj/item/device/beacon/medical/atom_init()
	. = ..()
	beacon_medical_list += src


/obj/item/device/beacon/medical/Destroy()
	beacon_medical_list -= src
	return ..()

/obj/item/weapon/medical/teleporter
	name = "Body Teleporter"
	desc = "A device used for teleporting injured(critical) or dead people."
	w_class = ITEM_SIZE_SMALL
	gender = PLURAL
	icon = 'icons/obj/device.dmi'
	icon_state = "medicon"
	item_state = "signaler"
	flags = NOBLUDGEON
	origin_tech = "bluespace=1"
	var/timer = 10
	var/atom/target = null

/obj/item/weapon/medical/teleporter/afterattack(atom/target, mob/user, proximity, params)
	if (!proximity)
		return
	if (!ishuman(target))
		to_chat(user, "<span class='notice'>Can only be planted on human.</span>")
		return
	var/found = 0
	var/target_beacon
	for(var/obj/item/device/beacon/medical/medical in beacon_medical_list)
		if(medical)
			if(isturf(medical.loc))
				var/area/A = get_area(medical)
				if(istype(A, /area/station/medical/sleeper))
					target_beacon = medical
					found = 1
					break
	if(!found)
		to_chat(user, "<span class='warning'>No beacon located in medical treatment centre.</span>")
		return

	var/mob/living/carbon/human/H = target
	if(H.health >= config.health_threshold_crit && H.stat != DEAD)
		to_chat(user, "<span class='notice'>[H.name] is in good condition.</span>")
		return
	if(user.is_busy())
		return
	to_chat(user, "<span class='notice'>Planting...</span>")

	user.visible_message("<span class='warning'>[user.name] is trying to plant some kind of device on [target.name]!</span>")

	if(do_after(user, 50, target = target) && in_range(user, H))
		user.drop_item()
		target = H
		loc = null
		//var/location
		H.attack_log += "\[[time_stamp()]\]<font color='blue'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
		playsound(H, 'sound/items/timer.ogg', VOL_EFFECTS_MASTER, 5, FALSE)
		user.visible_message("<span class='warning'>[user.name] finished planting an [name] on [H.name]!</span>")
		var/I = image('icons/obj/device.dmi', "medicon")
		H.add_overlay(I)
		to_chat(user, "<span class='notice'>Device has been planted. Timer counting down from [timer].</span>")
		addtimer(CALLBACK(src, .proc/teleport, H, target_beacon, I), timer * 10)

/obj/item/weapon/medical/teleporter/attack(mob/M, mob/user, def_zone)
	return

/obj/item/weapon/medical/teleporter/proc/teleport(mob/H, obj/beacon, I)
	if(H)
		if(beacon)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			var/datum/effect/effect/system/spark_spread/s2 = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, H)
			s2.set_up(3, 1, beacon)
			s.start()
			s2.start()
			H.loc = get_turf(beacon)
		if (src)
			qdel(src)
		H.cut_overlay(I)
		qdel(I)





