#define LOG_BURN_TIMER 300
#define PAPER_BURN_TIMER 5
#define MAXIMUM_BURN_TIMER 6000

/obj/structure/fireplace
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	density = FALSE
	anchored = TRUE
	pixel_x = -16
	var/lit = FALSE

	var/managed_overlays

	var/fuel_added = 0
	var/flame_expiry_timer

	light_color = LIGHT_COLOR_FIREPLACE
	light_power = 3

	var/heating_temperature = T20C + 5
	var/heating_power

/obj/structure/fireplace/atom_init(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/fireplace/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/fireplace/proc/try_light(obj/item/O, mob/user)
	if(lit)
		to_chat(user, "<span class='warning'>It's already lit!</span>")
		return FALSE
	if(!fuel_added)
		to_chat(user, "<span class='warning'>[src] needs some fuel to burn!</span>")
		return FALSE
	if(O.get_current_temperature() > 300)
		ignite()
		return TRUE
	return FALSE

/obj/structure/fireplace/attackby(obj/item/T, mob/user)
	if(istype(T, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/wood = T
		var/space_remaining = MAXIMUM_BURN_TIMER - burn_time_remaining()
		var/space_for_logs = round(space_remaining / LOG_BURN_TIMER)
		if(space_for_logs < 1)
			to_chat(user, "<span class='warning'>You can't fit any more of [T] in [src]!</span>")
			return
		var/logs_used = min(space_for_logs, wood.amount)
		wood.use(logs_used)
		adjust_fuel_timer(LOG_BURN_TIMER * logs_used)
		user.visible_message("<span class='notice'>[user] tosses some \
			wood into [src].</span>", "<span class='notice'>You add \
			some fuel to [src].</span>")
	else if(istype(T, /obj/item/weapon/paper_bin))
		var/obj/item/weapon/paper_bin/paper_bin = T
		user.visible_message("<span class='notice'>[user] throws [T] into \
			[src].</span>", "<span class='notice'>You add [T] to [src].\
			</span>")
		adjust_fuel_timer(PAPER_BURN_TIMER * paper_bin.amount)
		qdel(paper_bin)
	else if(istype(T, /obj/item/weapon/paper))
		user.visible_message("<span class='notice'>[user] throws [T] into \
			[src].</span>", "<span class='notice'>You throw [T] into [src].\
			</span>")
		adjust_fuel_timer(PAPER_BURN_TIMER)
		qdel(T)
	else if(try_light(T,user))
		return
	else
		. = ..()

/obj/structure/fireplace/proc/update_appearance()
	if(managed_overlays)
		cut_overlay(managed_overlays)
		managed_overlays = null
	
	var/list/new_overlays = update_overlays()

	if(length(new_overlays))
		managed_overlays = new_overlays
		add_overlay(managed_overlays)

/obj/structure/fireplace/proc/update_overlays()
	. = list()
	if(!lit)
		return

	switch(burn_time_remaining())
		if(0 to 500)
			. += "fireplace_fire0"
		if(500 to 1000)
			. += "fireplace_fire1"
		if(1000 to 1500)
			. += "fireplace_fire2"
		if(1500 to 2000)
			. += "fireplace_fire3"
		if(2000 to MAXIMUM_BURN_TIMER)
			. += "fireplace_fire4"
	. += "fireplace_glow"

/obj/structure/fireplace/proc/adjust_fire()
	if(!lit)
		set_light(0)
		return

	var/power = 0

	switch(burn_time_remaining())
		if(0 to 500)
			power = 1
		if(500 to 1000)
			power = 2
		if(1000 to 1500)
			power = 3
		if(1500 to 2000)
			power = 4
		if(2000 to MAXIMUM_BURN_TIMER)
			power = 6

	set_light(power)
	heating_power = power * 20000

/obj/structure/fireplace/proc/process_heating()
	if(!lit)
		return

	var/datum/gas_mixture/env = loc.return_air()

	if(env && (env.temperature - heating_temperature) >= 0.1)
		return

	var/heat_transfer = 0.25 * env.get_thermal_energy_change(heating_temperature)

	if(heat_transfer > 0)	//heating air
		heat_transfer = min(heat_transfer, heating_power)

		env.add_thermal_energy(heat_transfer)

/obj/structure/fireplace/process()
	if(!lit)
		return
	if(world.time > flame_expiry_timer)
		put_out()
		return

	playsound(src, 'sound/effects/comfyfire.ogg', VOL_AMBIENT, vol=50, vary=FALSE, extrarange=0, falloff=1)
	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 25)
	update_appearance()
	adjust_fire()
	process_heating()

/obj/structure/fireplace/proc/extinguish()
	if(lit)
		var/fuel = burn_time_remaining()
		flame_expiry_timer = 0
		put_out()
		adjust_fuel_timer(fuel)

/obj/structure/fireplace/water_act()
	extinguish()

/obj/structure/fireplace/proc/adjust_fuel_timer(amount)
	if(lit)
		flame_expiry_timer += amount
		if(burn_time_remaining() < MAXIMUM_BURN_TIMER)
			flame_expiry_timer = world.time + MAXIMUM_BURN_TIMER
	else
		fuel_added = clamp(fuel_added + amount, 0, MAXIMUM_BURN_TIMER)

/obj/structure/fireplace/proc/burn_time_remaining()
	if(lit)
		return max(0, flame_expiry_timer - world.time)
	else
		return max(0, fuel_added)

/obj/structure/fireplace/proc/ignite()
	lit = TRUE
	desc = "A large stone brick fireplace, warm and cozy."
	flame_expiry_timer = world.time + fuel_added
	fuel_added = 0
	update_appearance()
	adjust_fire()

/obj/structure/fireplace/proc/put_out()
	lit = FALSE
	update_appearance()
	adjust_fire()
	desc = initial(desc)
