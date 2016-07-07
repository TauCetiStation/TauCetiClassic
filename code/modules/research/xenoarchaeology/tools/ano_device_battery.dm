
/obj/item/weapon/anobattery
	name = "Anomaly power battery"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anobattery0"
	var/datum/artifact_effect/battery_effect
	var/capacity = 300
	var/stored_charge = 0
	var/effect_id = ""

/obj/item/weapon/anobattery/New()
	battery_effect = new()

/obj/item/weapon/anobattery/proc/UpdateSprite()
	var/p = (stored_charge/capacity)*100
	p = min(p, 100)
	icon_state = "anobattery[round(p,25)]"

/obj/item/weapon/anobattery/proc/use_power(var/amount)
	stored_charge = max(0, stored_charge - amount)

/obj/item/weapon/anodevice
	name = "Anomaly power utilizer"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anodev"
	var/activated = 0
	var/duration = 0
	var/duration_max = 300 //30 sec max duration
	var/interval = 0
	var/interval_max = 100 //10 sec max interval
	var/time_end = 0
	var/last_activation = 0
	var/last_process = 0
	var/obj/item/weapon/anobattery/inserted_battery
	var/turf/archived_loc
	var/energy_consumed_on_touch = 100

/obj/item/weapon/anodevice/New()
	..()
	SSobj.processing |= src

/obj/item/weapon/anodevice/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/anobattery))
		if(!inserted_battery)
			user << "\blue You insert the battery."
			user.drop_item()
			I.loc = src
			inserted_battery = I
			UpdateSprite()
	else
		return ..()

/obj/item/weapon/anodevice/attack_self(var/mob/user as mob)
	ui_interact(user)

/obj/item/weapon/anodevice/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	var/data[0]

	data["status"] = activated
	if(inserted_battery)
		data["is_battery"] = 1
		data["ano_id"] = inserted_battery.battery_effect ? (inserted_battery.battery_effect.artifact_id == "" ? "???" : "[inserted_battery.battery_effect.artifact_id]") : "NA" //inserted_battery.battery_effect.artifact_id ? inserted_battery.battery_effect.artifact_id : "NA"
		data["charge"] = round(inserted_battery.stored_charge,1)
		data["capacity"] = inserted_battery.capacity
		data["times_left"] = round(max((time_end - last_process) / 10, 0))
		data["duration"] = duration
		data["interval"] = interval
	else
		data["is_battery"] = 0

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "anodevice.tmpl", "Anomalous Materials Energy Utiliser", 550, 350)
		ui.set_initial_data(data)
		ui.open()

/obj/item/weapon/anodevice/process()
	if(activated)
		if(inserted_battery && inserted_battery.battery_effect && (inserted_battery.stored_charge > 0) )
			//make sure the effect is active
			if(!inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate(1)

			//update the effect loc
			var/turf/T = get_turf(src)
			if(T != archived_loc)
				archived_loc = T
				inserted_battery.battery_effect.UpdateMove()

			//if someone is holding the device, do the effect on them
			var/mob/holder
			if(ismob(src.loc))
				holder = src.loc

			//handle charge
			if(world.time - last_activation > interval)
				if(inserted_battery.battery_effect.effect == EFFECT_TOUCH)
					if(interval > 0)
						//apply the touch effect to the holder
						if(holder)
							holder << "the \icon[src] [src] held by [holder] shudders in your grasp."
						else
							src.loc.visible_message("the \icon[src] [src] shudders.")
						inserted_battery.battery_effect.DoEffectTouch(holder)

						//consume power
						inserted_battery.use_power(energy_consumed_on_touch)
					else
						//consume power equal to time passed
						inserted_battery.use_power(world.time - last_process)

				else if(inserted_battery.battery_effect.effect == EFFECT_PULSE)
					inserted_battery.battery_effect.chargelevel = inserted_battery.battery_effect.chargelevelmax

					//consume power relative to the time the artifact takes to charge and the effect range
					inserted_battery.use_power(inserted_battery.battery_effect.effectrange * inserted_battery.battery_effect.effectrange * inserted_battery.battery_effect.chargelevelmax)

				else
					//consume power equal to time passed
					inserted_battery.use_power(world.time - last_process)

				last_activation = world.time

			//process the effect
			inserted_battery.battery_effect.process()

			//work out if we need to shutdown
			if(inserted_battery.stored_charge <= 0)
				src.loc.visible_message("\blue \icon[src] [src] buzzes.", "\blue \icon[src] You hear something buzz.")
				shutdown_emission()
			else if(world.time > time_end)
				src.loc.visible_message("\blue \icon[src] [src] chimes.", "\blue \icon[src] You hear something chime.")
				shutdown_emission()
		else
			src.visible_message("\blue \icon[src] [src] buzzes.", "\blue \icon[src] You hear something buzz.")
			shutdown_emission()
		last_process = world.time


/obj/item/weapon/anodevice/Topic(href, href_list)
	if(..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	if(href_list["change_duration"])
		var/timedif = text2num(href_list["change_duration"])
		duration += timedif
		duration = min(max(duration, 0), duration_max)
		if(activated)
			time_end += timedif
		return 1

	if(href_list["change_interval"])
		var/timedif = text2num(href_list["change_interval"])
		interval += timedif
		interval = min(max(interval, 0), interval_max)
		return 1

	if(href_list["startup"])
		if(inserted_battery && inserted_battery.battery_effect && (inserted_battery.stored_charge > 0) )
			activated = 1
			src.visible_message("\blue \icon[src] [src] whirrs.", "\icon[src]\blue You hear something whirr.")
			if(!inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate(1)
			time_end = world.time + duration
		return 1

	if(href_list["shutdown"])
		activated = 0
		return 1

	if(href_list["ejectbattery"])
		if(inserted_battery)
			shutdown_emission()
			inserted_battery.loc = get_turf(src)
			inserted_battery = null
			UpdateSprite()
		return 1

	if(href_list["refresh"])
		ui_interact(user)
		return 1

	if(href_list["close"])
		ui.close()
		return 0

	return 0

/obj/item/weapon/anodevice/proc/shutdown_emission()
	if(activated)
		activated = 0
		if(inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(1)

/obj/item/weapon/anodevice/proc/UpdateSprite()
	if(!inserted_battery)
		icon_state = "anodev"
		return
	var/p = (inserted_battery.stored_charge/inserted_battery.capacity)*100
	p = min(p, 100)
	icon_state = "anodev[round(p,25)]"

/obj/item/weapon/anodevice/Destroy()
	SSobj.processing.Remove(src)
	return ..()

/obj/item/weapon/anodevice/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if (!istype(M))
		return

	if(activated && inserted_battery.battery_effect.effect == EFFECT_TOUCH && !isnull(inserted_battery))
		inserted_battery.battery_effect.DoEffectTouch(M)
		inserted_battery.use_power(energy_consumed_on_touch)
		user.visible_message("\blue [user] taps [M] with [src], and it shudders on contact.")
	else
		user.visible_message("\blue [user] taps [M] with [src], but nothing happens.")

	//admin logging
	user.lastattacked = M
	M.lastattacker = user

	if(inserted_battery.battery_effect)
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Tapped [M.name] ([M.ckey]) with [name] (EFFECT: [inserted_battery.battery_effect.effecttype])</font>"
		M.attack_log += "\[[time_stamp()]\]<font color='orange'> Tapped by [user.name] ([user.ckey]) with [name] (EFFECT: [inserted_battery.battery_effect.effecttype])</font>"
		msg_admin_attack("[key_name(user)] tapped [key_name(M)] with [name] (EFFECT: [inserted_battery.battery_effect.effecttype])" )
