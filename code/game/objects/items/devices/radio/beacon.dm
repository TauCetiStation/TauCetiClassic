/obj/item/device/radio/beacon
	name = "Tracking Beacon"
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"
	origin_tech = "bluespace=1"

/obj/item/device/radio/beacon/hear_talk()
	return


/obj/item/device/radio/beacon/send_hear()
	return null


/obj/item/device/radio/beacon/verb/alter_signal(t as text)
	set name = "Alter Beacon's Signal"
	set category = "Object"
	set src in usr

	if ((usr.canmove && !( usr.restrained() )))
		src.code = t
	if (!( src.code ))
		src.code = "beacon"
	src.add_fingerprint(usr)
	return


/obj/item/device/radio/beacon/bacon //Probably a better way of doing this, I'm lazy.
	proc/digest_delay()
		spawn(600)
			qdel(src)


// SINGULO BEACON SPAWNER

/obj/item/device/radio/beacon/syndicate
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Activate to have a singularity beacon teleported to your location</i>."
	origin_tech = "bluespace=1;syndicate=7"

/obj/item/device/radio/beacon/syndicate/attack_self(mob/user as mob)
	if(user)
		user << "\blue Locked In"
		new /obj/machinery/singularity_beacon/syndicate( user.loc )
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
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

/obj/item/weapon/medical/teleporter
	name = "Body Teleporter"
	desc = "A device used for teleporting injured(critical) or dead people."
	gender = PLURAL
	icon = 'icons/obj/device.dmi'
	icon_state = "medicon"
	item_state = "signaler"
	flags = FPRINT | TABLEPASS | NOBLUDGEON
	origin_tech = "bluespace=1"
	var/timer = 10
	var/atom/target = null

/obj/item/weapon/medical/teleporter/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (!ishuman(target))
		user << "\blue Can only be planted on human."
		return
	var/found = 0
	var/target_beacon
	for(var/obj/item/device/beacon/medical/medical in world)
		if(medical)
			if(isturf(medical.loc))
				var/area/A = get_area(medical)
				if(istype(A, /area/medical/sleeper))
					target_beacon = medical
					found = 1
					break
	if(!found)
		user << "\red No beacon located in medical treatment centre."
		return

	var/mob/living/carbon/human/H = target
	if(H.health >= config.health_threshold_crit)
		user << "\blue [H.name] is in good condition."
		return
	user << "Planting..."

	user.visible_message("\red [user.name] is trying to plant some kind of device on [target.name]!")

	if(do_after(user, 50) && in_range(user, H))
		user.drop_item()
		target = H
		loc = null
		//var/location
		H.attack_log += "\[[time_stamp()]\]<font color='blue'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
		playsound(H.loc, 'tauceti/sounds/items/timer.ogg', 5, 0)
		user.visible_message("\red [user.name] finished planting an [name] on [H.name]!")

		H.overlays += image('icons/obj/device.dmi', "medicon")
		user << "Device has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			if(H)
				if(target_beacon)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					var/datum/effect/effect/system/spark_spread/s2 = new /datum/effect/effect/system/spark_spread
					s.set_up(3, 1, H)
					s2.set_up(3, 1, target_beacon)
					s.start()
					s2.start()
					H.loc = get_turf(target_beacon)
				if (src)
					qdel(src)

/obj/item/weapon/medical/teleporter/attack(mob/M as mob, mob/user as mob, def_zone)
	return
