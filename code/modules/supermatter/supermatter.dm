
#define NITROGEN_RETARDATION_FACTOR 4   //Higher == N2 slows reaction more
#define PHORON_RELEASE_MODIFIER 1500    //Higher == less phoron released by reaction
#define THERMAL_RELEASE_MODIFIER 750    //Higher == more heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500    //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 1500    //Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1     //Higher == more overall power


//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 30 		//seconds between warnings.

// These are used by supermatter and supermatter monitor program, mostly for UI updating purposes. Higher should always be worse!
#define SUPERMATTER_ERROR -1		// Unknown status, shouldn't happen but just in case.
#define SUPERMATTER_INACTIVE 0		// No or minimal energy
#define SUPERMATTER_NORMAL 1		// Normal operation
#define SUPERMATTER_NOTIFY 2		// Ambient temp > 80% of CRITICAL_TEMPERATURE
#define SUPERMATTER_WARNING 3		// Ambient temp > CRITICAL_TEMPERATURE OR integrity damaged
#define SUPERMATTER_DANGER 4		// Integrity < 50%
#define SUPERMATTER_EMERGENCY 5		// Integrity < 25%
#define SUPERMATTER_DELAMINATING 6	// Pretty obvious.

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define SUPERMATTER_DELAM_PERCENT 100
#define SUPERMATTER_EMERGENCY_PERCENT 50
#define SUPERMATTER_DANGER_PERCENT 25
#define SUPERMATTER_WARNING_PERCENT 5


/obj/machinery/power/supermatter
	name = "Supermatter"
	desc = "A strangely translucent and iridescent crystal. <span class='warning'>You get headaches just from looking at it.</span>"
	icon = 'icons/obj/engine.dmi'
	icon_state = "darkmatter"
	density = TRUE
	anchored = FALSE
	light_range = 4

	appearance_flags = PIXEL_SCALE // no tile bound to allow distortion to render outside of direct view
	///Effect holder for the displacement filter to distort the SM based on its activity level
	var/atom/movable/distortion_effect/distort
	var/last_status

	resistance_flags = FULL_INDESTRUCTIBLE

	var/gasefficency = 0.25

	var/base_icon_state = "darkmatter"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystaline hyperstructure returning to safe operating levels."
	var/warning_point = 100
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 700
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	var/explosion_point = 1000

	light_color = "#8a8a00"

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0                        // Time in 1/10th of seconds since the last sent warning
	var/power = 0

	var/oxygen = 0				  // Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//        var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio

/obj/machinery/power/supermatter/shard //Small subtype, less efficient and more sensitive, but less boom.
	name = "Supermatter Shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. <span class='warning'>You get headaches just from looking at it.</span>"
	icon_state = "darkmatter_shard"
	base_icon_state = "darkmatter_shard"

	warning_point = 50
	emergency_point = 500
	explosion_point = 900

	gasefficency = 0.125

	explosion_power = 3 //3,6,9,12? Or is that too small?


/obj/machinery/power/supermatter/atom_init()
	. = ..()
	radio = new (src)
	distort = new(src)

/obj/machinery/power/supermatter/Destroy()
	qdel(radio)
	QDEL_NULL(distort)
	. = ..()

/obj/machinery/power/supermatter/proc/get_status()
	var/turf/T = get_turf(src)
	if(!T)
		return SUPERMATTER_ERROR
	var/datum/gas_mixture/air = T.return_air()
	if(!air)
		return SUPERMATTER_ERROR

	var/integrity = round((damage / explosion_point) * 100)

	if(integrity > SUPERMATTER_DELAM_PERCENT)
		return SUPERMATTER_DELAMINATING

	else if(integrity > SUPERMATTER_EMERGENCY_PERCENT)
		return SUPERMATTER_EMERGENCY

	else if(integrity > SUPERMATTER_DANGER_PERCENT)
		return SUPERMATTER_DANGER

	else if(integrity > SUPERMATTER_WARNING_PERCENT)
		return SUPERMATTER_WARNING

	else if(power < 5)
		return SUPERMATTER_NORMAL
	return SUPERMATTER_INACTIVE

/obj/machinery/power/supermatter/proc/update_displacement()
	cut_overlays()
	switch(last_status)
		if(SUPERMATTER_INACTIVE)
			distort.icon = 'icons/effects/96x96.dmi'
			distort.icon_state = "SM_base"
			distort.pixel_x = -32
			distort.pixel_y = -32
		if(SUPERMATTER_NORMAL, SUPERMATTER_NOTIFY, SUPERMATTER_WARNING)
			distort.icon = 'icons/effects/96x96.dmi'
			distort.icon_state = "SM_base_active"
			distort.pixel_x = -32
			distort.pixel_y = -32
		if(SUPERMATTER_DANGER)
			distort.icon = 'icons/effects/160x160.dmi'
			distort.icon_state = "SM_delam_1"
			distort.pixel_x = -64
			distort.pixel_y = -64
		if(SUPERMATTER_EMERGENCY)
			distort.icon = 'icons/effects/224x224.dmi'
			distort.icon_state = "SM_delam_2"
			distort.pixel_x = -96
			distort.pixel_y = -96
		if(SUPERMATTER_DELAMINATING)
			distort.icon = 'icons/effects/288x288.dmi'
			distort.icon_state = "SM_delam_3"
			distort.pixel_x = -128
			distort.pixel_y = -128
	add_overlay(distort)

/obj/machinery/power/supermatter/proc/explode()
	explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, ignorecap = TRUE)
	qdel(src)
	return

/obj/machinery/power/supermatter/process()

	var/turf/L = loc

	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(isenvironmentturf(L))	// Stop processing this stuff if we've been ejected.
		return

	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			var/stability = num2text(round((damage / explosion_point) * 100))

			if(damage > emergency_point)

				radio.autosay(addtext(emergency_alert, " Instability: ",stability,"%"), "Supermatter Monitor")
				lastwarning = world.timeofday

			else if(damage >= damage_archived) // The damage is still going up
				radio.autosay(addtext(warning_alert," Instability: ",stability,"%"), "Supermatter Monitor")
				lastwarning = world.timeofday - 150

			else                                                 // Phew, we're safe
				radio.autosay(safe_alert, "Supermatter Monitor")
				lastwarning = world.timeofday

		if(damage > explosion_point)
			var/rads = DETONATION_RADS
			for(var/mob/living/mob in alive_mob_list)
				if(ishuman(mob))
					//Hilariously enough, running into a closet should make you get hit the hardest.
					mob:hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
				rads *=  sqrt(1 / (get_dist(mob, src) + 1))
				mob.apply_effect(rads, IRRADIATE)
			for(var/obj/item/device/analyzer/counter as anything in global.geiger_items_list)
				var/distance_rad_signal = get_dist(counter, src)
				rads *= sqrt(1 / (distance_rad_signal + 1))
				counter.recieve_rad_signal(rads, distance_rad_signal)
			explode()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()

	//Remove gas from surrounding area
	var/datum/gas_mixture/removed = env.remove(gasefficency * env.total_moles)

	if(!removed || !removed.total_moles)
		damage += max((power-1600)/10, 0)
		power = min(power, 1600)
		return 1

	if (!removed)
		return 1

	damage_archived = damage
	damage = max( damage + ( (removed.temperature - 800) / 150 ) , 0 )
	//Ok, 100% oxygen atmosphere = best reaction
	//Maxes out at 100% oxygen pressure
	oxygen = max(min((removed.gas["oxygen"] - (removed.gas["nitrogen"] * NITROGEN_RETARDATION_FACTOR)) / MOLES_CELLSTANDARD, 1), 0)

	var/temp_factor = 100

	if(oxygen > 0.8)
		// with a perfect gas mix, make the power less based on heat
		icon_state = "[base_icon_state]_glow"
	else
		// in normal mode, base the produced energy around the heat
		temp_factor = 60
		icon_state = base_icon_state

	// Checks if the status has changed, in order to update the displacement effect
	var/current_status = get_status()
	if(current_status != last_status)
		last_status = current_status
		update_displacement()

	power = max( (removed.temperature * temp_factor / T0C) * oxygen + power, 0) //Total laser power plus an overload

	//We've generated power, now let's transfer it to the collectors for storing/usage
	transfer_energy()

	var/device_energy = power * REACTION_POWER_MODIFIER

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.

	var/thermal_power = THERMAL_RELEASE_MODIFIER
	if(removed.total_moles < 35) thermal_power += 750   //If you don't add coolant, you are going to have a bad time.

	removed.temperature += ((device_energy * thermal_power) / max(1, removed.heat_capacity()))

	removed.temperature = max(0, min(removed.temperature, 10000))

	//Calculate how much gas to release
	removed.gas["phoron"] += max(device_energy / PHORON_RELEASE_MODIFIER, 0)

	removed.gas["oxygen"] += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	removed.update_values()

	env.merge(removed)

	for(var/mob/living/carbon/human/l in view(src, min(7, round(power ** 0.25)))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			l.hallucination = max(0, min(200, l.hallucination + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)) ) ) )
	irradiate_in_dist(get_turf(src), power / 10, 8)
	power -= (power/500)**3

	return 1


/obj/machinery/power/supermatter/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != BULLET)
		power += Proj.damage * config_bullet_energy
	else
		damage += Proj.damage * config_bullet_energy

/obj/machinery/power/supermatter/attack_robot(mob/user)
	if(Adjacent(user))
		return attack_hand(user)
	else
		to_chat(user, "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>")
	return

/obj/machinery/power/supermatter/attack_ai(mob/user)
	to_chat(user, "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>")

/obj/machinery/power/supermatter/attack_ghost(mob/user)
	return

/obj/machinery/power/supermatter/attack_hand(mob/user)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")

	Consume(user)

/obj/machinery/power/supermatter/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if(get_dist(R, src) <= 15) // Better than using orange() every process
			R.receive_pulse(power)
	return

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W, mob/living/user)
	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	user.drop_from_inventory(W)
	user.SetNextMove(CLICK_CD_MELEE)
	Consume(W)
	irradiate_one_mob(user, 150)

/obj/machinery/power/supermatter/Bumped(atom/AM)
	if(isliving(AM))
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
	else
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	Consume(AM)


/obj/machinery/power/supermatter/proc/Consume(mob/living/user)
	if(istype(user))
		user.dust()
		power += 200
	else
		qdel(user)

	power += 200

		//Some poor sod got eaten, go ahead and irradiate people nearby.
	irradiate_in_dist(get_turf(src), 500, 10)

/atom/movable/distortion_effect
	name = ""
	plane = ANOMALY_PLANE
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/96x96.dmi'
	icon_state = "SM_base"
	pixel_x = -32
	pixel_y = -32
