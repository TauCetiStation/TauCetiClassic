ADD_TO_POI_LIST(/obj/structure/sensor_tower)
ADD_TO_GLOBAL_LIST(/obj/structure/sensor_tower, sensor_towers)
/obj/structure/sensor_tower
	name = "experimental sensor tower"
	desc = "A tower with a lot of delicate sensors made to track weather conditions. This one has been adjusted to track biosignatures. This one is heavily damaged. Use a blowtorch, wirecutters, then a wrench to repair it."
	icon = 'icons/obj/structures/motion_sensor_v2.dmi'
	icon_state = "sensor_disabled"
	density = TRUE
	anchored = TRUE
	uses_integrity = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE | CAN_BE_HIT
	unacidable = TRUE
	var/enabled = FALSE
	var/broken = FALSE
	var/obj/item/device/gps/inserted_gps
	//Tick updater
	var/cur_tick = 0
	//Check for failure every this many ticks
	var/fail_check_ticks = 300
	//% chance of failure each fail_tick check
	var/fail_rate = 15

/obj/structure/sensor_tower/proc/enable_tower()
	if(broken)
		return
	if(enabled)
		return
	enabled = TRUE
	SSmapping.update_sensors()
	update_icon()
	reset_current_ticks()
	START_PROCESSING(SSobj, src)

/obj/structure/sensor_tower/proc/create_gps_inside()
	inserted_gps = new(src)
	inserted_gps.tracking = TRUE
	inserted_gps.gpstag = "ST[global.count_of_sensor_towers]"

/obj/structure/sensor_tower/atom_init()
	. = ..()
	global.count_of_sensor_towers++
	name = "experimental sensor tower [global.count_of_sensor_towers]"
	create_gps_inside()
	enable_tower()

/obj/structure/sensor_tower/ex_act(severity)
	return

/obj/structure/sensor_tower/proc/reset_current_ticks()
	cur_tick = 0

/obj/structure/sensor_tower/proc/checkfailure()
	cur_tick++
	//Nope, not time for it yet
	if(cur_tick < fail_check_ticks)
		return FALSE
	//Went past with no fail, reset the timer
	else if(cur_tick > fail_check_ticks)
		reset_current_ticks()
		return FALSE
	//Oh snap, we failed! Shut it down!
	if(rand(1,100) < fail_rate)
		disable_tower()
		return TRUE
	return FALSE

/obj/structure/sensor_tower/process()
	checkfailure()

/obj/structure/sensor_tower/update_icon()
	cut_overlays()
	if(broken)
		icon_state = "sensor_broken"
		desc = "A tower with a lot of delicate sensors made to track weather conditions. This one has been adjusted to track biosignatures. This one is heavily damaged. Use a welder to repair it."
	else
		icon_state = "sensor_disabled"
		desc = "A tower with a lot of delicate sensors made to track weather conditions. This one has been adjusted to track biosignatures. It looks like it is offline."
	if(enabled)
		var/image/green_lights = image(icon, "sensor_enabled")
		add_overlay(green_lights)
		desc = "A tower with a lot of delicate sensors made to track weather conditions. This one has been adjusted to track biosignatures. It looks like it is online."

/obj/structure/sensor_tower/attack_hand(mob/user)
	if(broken)
		return FALSE
	if(!iscarbon(user))
		to_chat(user, "<span class='danger'>You have no idea how to use that.</span>")
		return FALSE
	add_fingerprint(user)
	if(!do_skilled(user, src,  SKILL_TASK_DIFFICULT, list(/datum/skill/engineering = SKILL_LEVEL_PRO), -0.25))
		to_chat(user, "<span class='warning'>How this thing works...</span>")
		return FALSE
	if(enabled)
		visible_message("<span class='warning'><b>\The [src]</b> goes dark as [user] shuts the power off.</span>")
		disable_tower()
		return TRUE
	visible_message("<span class='warning'><b>\The [src]</b> lights up as [user] turns the power on.</span>")
	enable_tower()
	return TRUE

/obj/structure/sensor_tower/attacked_by(obj/item/attacking_item, mob/living/user, def_zone, power)
	if(broken)
		return ..()
	var/force_with_melee_skill = apply_skill_bonus(user, attacking_item.force, list(/datum/skill/melee = SKILL_LEVEL_NOVICE), 0.15)
	if(force_with_melee_skill < 15)
		force_with_melee_skill /= 3
	var/broken_attack_success = prob(force_with_melee_skill)
	if(broken_attack_success)
		broke_tower()
	user.visible_message("<span class='danger'>[user] hits [src] with [attacking_item][broken_attack_success ? " and break it." : ", but fails to break it!"]</span>",
							"<span class='danger'>You hit [src] with [attacking_item][broken_attack_success ? " and break it." : ", but fails to break it!"]</span>",
							viewing_distance = COMBAT_MESSAGE_RANGE)

/obj/structure/sensor_tower/attackby(obj/item/W, mob/user, params)
	if(iswelding(W) && broken)
		if(user.is_busy(src))
			return FALSE
		//can only operate with existing tools
		if(!istype(W, /obj/item/weapon/weldingtool))
			return FALSE
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			to_chat(user, "<span class='notice'>The welding tool needs to be on to start this task.</span>")
			return FALSE
		if(!WT.use(3, user))
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>Now welding \the [src].</span>")
		if(!WT.use_tool(src, user, apply_skill_bonus(user, 7 SECONDS, list(/datum/skill/engineering = SKILL_LEVEL_NOVICE)), volume = 50))
			to_chat(user, "<span class='notice'>You must remain close to finish this task.</span>")
			return FALSE
		if(!WT.isOn())
			to_chat(user, "<span class='notice'>The welding tool needs to be on to finish this task.</span>")
			return FALSE
		repair_tower()
		user.visible_message("<span class='notice'>\The [user] repairs \the [src].</span>", \
							 "<span class='notice'>You are repair \the [src].</span>", \
							 "You hear welding.")
	return ..()

/obj/structure/sensor_tower/proc/disable_tower()
	if(!enabled)
		return
	enabled = FALSE
	SSmapping.update_sensors()
	update_icon()
	reset_current_ticks()
	STOP_PROCESSING(SSobj, src)

/obj/structure/sensor_tower/proc/broke_tower()
	if(broken)
		return
	broken = TRUE
	if(!enabled)
		update_icon()
		return
	disable_tower()

/obj/structure/sensor_tower/proc/repair_tower()
	if(!broken)
		return
	if(enabled)
		return
	broken = FALSE
	update_icon()

/obj/structure/sensor_tower/Destroy()
	QDEL_NULL(inserted_gps)
	enabled = FALSE
	broken = TRUE
	SSmapping.update_sensors()
	return ..()
