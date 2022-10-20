/obj/item/weapon/particles_battery
	name = "Exotic particles power battery"
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "particles_battery0"
	w_class = SIZE_TINY
	var/datum/artifact_effect/battery_effect
	var/capacity = 200
	var/effect_id = ""
	var/touch_cost = 3
	var/aura_cost = 1
	var/pulse_cost = 10

/obj/item/weapon/particles_battery/update_icon()
	var/power_stored = (battery_effect?.current_charge / capacity) * 100
	power_stored = min(power_stored, 100)
	icon_state = "particles_battery[round(power_stored, 25)]"

/obj/item/weapon/xenoarch_utilizer
	name = "Exotic particles power utilizer"
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "utilizer"
	w_class = SIZE_TINY
	var/next_interact
	var/activated = FALSE
	var/obj/item/weapon/particles_battery/inserted_battery
	var/turf/archived_loc

/obj/item/weapon/xenoarch_utilizer/attackby(obj/item/weapon/particles_battery/Battery, mob/user, params)
	if(!istype(Battery))
		return ..()
	if(inserted_battery)
		return ..()
	if(!user.drop_from_inventory(Battery, src))
		return ..()
	to_chat(user, "<span class='notice'>You have inserted the battery into \the [src].</span>")
	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
	inserted_battery = Battery
	update_icon()

/obj/item/weapon/xenoarch_utilizer/attack_self(mob/user)
	if(!Adjacent(user))
		return
	tgui_interact(user)

/obj/item/weapon/xenoarch_utilizer/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParticlesPowerBattery", name)
		ui.open()

/obj/item/weapon/xenoarch_utilizer/tgui_data(mob/user)
	var/list/data = list()
	data["isActivated"] = activated
	data["insertedBattery"] = inserted_battery
	data["batteryEnergy"] = inserted_battery ? inserted_battery.battery_effect?.current_charge : 0
	data["batteryMaxEnergy"] = inserted_battery ? inserted_battery.battery_effect?.maximum_charges : 0
	return data

/obj/item/weapon/xenoarch_utilizer/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	switch(action)
		if("turnOn")
			. = TRUE
			turn_on(usr)
		if("turnOff")
			. = TRUE
			turn_off(usr)
		if("ejectBattery")
			. = TRUE
			if(!inserted_battery)
				return
			turn_off()
			inserted_battery.update_icon()
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.put_in_hands(inserted_battery)
			else inserted_battery.forceMove(get_turf(src))
			inserted_battery = null
			update_icon()
	if(.)
		add_fingerprint(usr)

/obj/item/weapon/xenoarch_utilizer/proc/turn_on(mob/user)
	if(activated)
		return
	if(!inserted_battery)
		return
	if(inserted_battery.battery_effect == null || !inserted_battery.battery_effect?.current_charge)
		return
	START_PROCESSING(SSobj, src)
	activated = TRUE
	update_icon()
	message_admins("anomaly battery [inserted_battery.battery_effect.artifact_id]([inserted_battery.battery_effect]) emission started by [key_name(usr)]")

/obj/item/weapon/xenoarch_utilizer/proc/turn_off(mob/user)
	if(!activated)
		return
	STOP_PROCESSING(SSobj, src)
	activated = FALSE
	update_icon()
	visible_message("<span class='notice'>[bicon(src)] [src] buzzes.</span>", "[bicon(src)]<span class='notice'>You hear something buzz.</span>")

/obj/item/weapon/xenoarch_utilizer/process()
	if(world.time <= next_interact)
		return
	next_interact = world.time + 10 SECONDS
	visible_message("<span class='notice'>[bicon(src)] [src] chimes.</span>", "<span class='notice'>[bicon(src)] You hear something chime.</span>")
	if(inserted_battery.battery_effect.trigger == TRIGGER_PROXY)
		var/turf/T = get_turf(src)
		if(T != archived_loc)
			archived_loc = T
			inserted_battery.battery_effect.UpdateMove()
	switch(inserted_battery.battery_effect.release_method)
		if(ARTIFACT_EFFECT_TOUCH)
			. = TRUE
			if(!ismob(loc))
				return
			inserted_battery.battery_effect.DoEffectTouch(loc, inserted_battery.touch_cost)
			if(inserted_battery.battery_effect.current_charge < inserted_battery.touch_cost)
				turn_off()
		if(ARTIFACT_EFFECT_AURA)
			. = TRUE
			inserted_battery.battery_effect.DoEffectAura(inserted_battery.aura_cost)
			if(inserted_battery.battery_effect.current_charge < inserted_battery.aura_cost)
				turn_off()
		if(ARTIFACT_EFFECT_PULSE)
			. = TRUE
			inserted_battery.battery_effect.DoEffectPulse(inserted_battery.pulse_cost)
			if(inserted_battery.battery_effect.current_charge < inserted_battery.pulse_cost)
				turn_off()
	if(inserted_battery.battery_effect.current_charge <= 0)
		turn_off()
		QDEL_NULL(inserted_battery.battery_effect)
	update_icon()

/obj/item/weapon/xenoarch_utilizer/update_icon()
	if(!inserted_battery)
		icon_state = "utilizer"
		return
	activated ? set_light(2, 1, "#8f66f4") : set_light(0)
	var/power_battery = (inserted_battery.battery_effect?.current_charge / inserted_battery.capacity) * 100
	power_battery = min(power_battery, 100)
	icon_state = "utilizer[round(power_battery, 25)][activated ? "_on" : "_off"]"

/obj/item/weapon/xenoarch_utilizer/Destroy()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/xenoarch_utilizer/attack(mob/living/M, mob/living/user, def_zone)
	if(!istype(M))
		return ..()
	if(!inserted_battery?.battery_effect?.release_method == ARTIFACT_EFFECT_TOUCH )
		return ..()
	inserted_battery.battery_effect.DoEffectTouch(M)
	user.visible_message("<span class='notice'>[user] taps [M] with [src], and it shudders on contact.</span>")
	// admin logging
	M.set_lastattacker_info(user)
	if(inserted_battery?.battery_effect)
		M.log_combat(user, "tapped with [name] (EFFECT: [inserted_battery.battery_effect.log_name]) ")
