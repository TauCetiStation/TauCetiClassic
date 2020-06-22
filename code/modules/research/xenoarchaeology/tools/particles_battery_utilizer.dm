/obj/item/weapon/particles_battery
	name = "Exotic particles power battery"
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "particles_battery0"
	w_class = ITEM_SIZE_SMALL
	var/datum/artifact_effect/battery_effect
	var/capacity = 200
	var/stored_charge = 0
	var/effect_id = ""

/obj/item/weapon/particles_battery/atom_init()
	. = ..()
	battery_effect = new()

/obj/item/weapon/particles_battery/update_icon()
	var/power_stored = (stored_charge / capacity) * 100
	power_stored = min(power_stored, 100)
	icon_state = "particles_battery[round(power_stored, 25)]"

/obj/item/weapon/xenoarch_utilizer
	name = "Exotic particles power utilizer"
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "utilizer"
	w_class = ITEM_SIZE_SMALL
	var/cooldown = 0
	var/activated = FALSE
	var/timing = FALSE
	var/time = 50
	var/archived_time = 50
	var/obj/item/weapon/particles_battery/inserted_battery
	var/turf/archived_loc
	var/cooldown_to_start = 0

/obj/item/weapon/xenoarch_utilizer/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/xenoarch_utilizer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/particles_battery))
		if(!inserted_battery)
			if(user.drop_from_inventory(I, src))
				to_chat(user, "<span class='notice'>You insert the battery.</span>")
				playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
				inserted_battery = I
				update_icon()
	else
		return ..()

/obj/item/weapon/xenoarch_utilizer/attack_self(mob/user)
	if(in_range(src, user))
		return src.interact(user)

/obj/item/weapon/xenoarch_utilizer/interact(mob/user)

	var/dat = "<b>Exotic Particles Energy Utilizer</b><br>"
	if(inserted_battery)
		if(cooldown)
			dat += "Cooldown in progress, please wait.<br>"
		else if(activated)
			if(timing)
				dat += "Device active.<br>"
			else
				dat += "Device active in timed mode.<br>"

		dat += "[inserted_battery] inserted, exotic wave ID: [inserted_battery.battery_effect.artifact_id ? inserted_battery.battery_effect.artifact_id : "NA"]<BR>"
		dat += "<b>Total Power:</b> [round(inserted_battery.stored_charge, 1)]/[inserted_battery.capacity]<BR><BR>"
		dat += "<b>Timed activation:</b> <A href='?src=\ref[src];neg_changetime_max=-100'>--</a> <A href='?src=\ref[src];neg_changetime=-10'>-</a> [time >= 1000 ? "[time/10]" : time >= 100 ? " [time/10]" : "  [time/10]" ] <A href='?src=\ref[src];changetime=10'>+</a> <A href='?src=\ref[src];changetime_max=100'>++</a><BR>"
		if(cooldown)
			dat += "<font color=red>Cooldown in progress.</font><BR>"
			dat += "<br>"
		else if(!activated && world.time >= cooldown_to_start)
			dat += "<A href='?src=\ref[src];startup=1'>Start</a><BR>"
			dat += "<A href='?src=\ref[src];startup=1;starttimer=1'>Start in timed mode</a><BR>"
		else
			dat += "<a href='?src=\ref[src];shutdown=1'>Shutdown emission</a><br>"
			dat += "<br>"
		dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
	else
		dat += "Please insert battery<br>"

		dat += "<br>"
		dat += "<br>"
		dat += "<br>"

		dat += "<br>"
		dat += "<br>"
		dat += "<br>"

	dat += "<hr>"
	dat += "<a href='?src=\ref[src]'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "utilizer", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/xenoarch_utilizer/process()
	update_icon()
	if(cooldown > 0)
		cooldown -= 1
		if(cooldown <= 0)
			cooldown = 0
			src.visible_message("<span class='notice'>[bicon(src)] [src] chimes.</span>", "<span class='notice'>[bicon(src)] You hear something chime.</span>")
	else if(activated)
		if(inserted_battery && inserted_battery.battery_effect)
			// make sure the effect is active
			if(!inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate(1)

			// update the effect loc
			var/turf/T = get_turf(src)
			if(T != archived_loc)
				archived_loc = T
				inserted_battery.battery_effect.UpdateMove()

			// process the effect
			inserted_battery.battery_effect.process()
			// if someone is holding the device, do the effect on them
			if(inserted_battery.battery_effect.effect == ARTIFACT_EFFECT_TOUCH && ismob(src.loc))
				inserted_battery.battery_effect.DoEffectTouch(src.loc)

			// handle charge
			inserted_battery.stored_charge -= 1
			if(inserted_battery.stored_charge <= 0)
				shutdown_emission()

			// handle timed mode
			if(timing)
				time -= 1
				if(time <= 0)
					shutdown_emission()
		else
			shutdown()

/obj/item/weapon/xenoarch_utilizer/proc/shutdown_emission()
	if(activated)
		activated = FALSE
		timing = FALSE
		src.visible_message("<span class='notice'>[bicon(src)] [src] buzzes.</span>", "[bicon(src)]<span class='notice'>You hear something buzz.</span>")

		cooldown = archived_time / 2

		if(inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(1)
	updateDialog()

/obj/item/weapon/xenoarch_utilizer/Topic(href, href_list)

	if((get_dist(src, usr) > 1))
		return
	usr.set_machine(src)
	if(href_list["neg_changetime_max"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		time += -100
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["neg_changetime"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		time += -10
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["changetime"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		time += 10
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["changetime_max"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		time += 100
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["startup"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		activated = TRUE
		timing = FALSE
		cooldown_to_start = world.time + 10 // so we cant abuse the startup button
		update_icon()
		if(!inserted_battery.battery_effect.activated)
			message_admins("anomaly battery [inserted_battery.battery_effect.artifact_id]([inserted_battery.battery_effect]) emission started by [key_name(usr)]")
			inserted_battery.battery_effect.ToggleActivate(1)
	if(href_list["shutdown"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		activated = FALSE
	if(href_list["starttimer"])
		timing = TRUE
		archived_time = time
	if(href_list["ejectbattery"])
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
		shutdown_emission()
		inserted_battery.update_icon()
		inserted_battery.forceMove(get_turf(src))
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(!H.get_active_hand())
				H.put_in_hands(inserted_battery)
		inserted_battery = null
		update_icon()
	if(href_list["close"])
		usr << browse(null, "window=utilizer")
		usr.unset_machine(src)
		return
	src.interact(usr)
	..()
	updateDialog()
	update_icon()

/obj/item/weapon/xenoarch_utilizer/update_icon()
	if(!inserted_battery)
		icon_state = "utilizer"
		return
	var/is_emitting = "_off"
	if(activated && inserted_battery && inserted_battery.battery_effect)
		is_emitting = "_on"
		set_light(2, 1, "#8f66f4")
	else
		set_light(0)
	var/power_battery = (inserted_battery.stored_charge / inserted_battery.capacity) * 100
	power_battery = min(power_battery, 100)
	icon_state = "utilizer[round(power_battery, 25)][is_emitting]"

/obj/item/weapon/xenoarch_utilizer/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/xenoarch_utilizer/attack(mob/living/M, mob/living/user, def_zone)
	if (!istype(M))
		return

	if(!isnull(inserted_battery) && activated && inserted_battery.battery_effect && inserted_battery.battery_effect.effect == ARTIFACT_EFFECT_TOUCH )
		inserted_battery.battery_effect.DoEffectTouch(M)
		inserted_battery.stored_charge -= min(inserted_battery.stored_charge, 20) // we are spending quite a big amount of energy doing this
		user.visible_message("<span class='notice'>[user] taps [M] with [src], and it shudders on contact.</span>")
	else
		user.visible_message("<span class='notice'>[user] taps [M] with [src], but nothing happens.</span>")

	// admin logging
	user.lastattacked = M
	M.lastattacker = user

	if(inserted_battery.battery_effect)
		M.log_combat(user, "tapped with [name] (EFFECT: [inserted_battery.battery_effect.effect_name]) ")
