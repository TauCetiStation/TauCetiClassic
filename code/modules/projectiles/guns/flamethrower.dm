

//FLAMETHROWER
/obj/item/weapon/gun/projectile/flamer
	name = "\improper core flamer item"
	desc = "You shouldn't have this, report how you got this item on GitHub."
/*


	icon = 'icons/obj/items/weapons/guns/guns_by_faction/USCM/flamers.dmi'
	icon_state = "m240"
	item_state = "m240"
	/*item_icons = list(
		WEAR_BACK = 'icons/mob/humans/onmob/clothing/back/guns_by_type/flamers.dmi',
		WEAR_WAIST = 'icons/mob/humans/onmob/clothing/belts/guns.dmi',
		WEAR_J_STORE = 'icons/mob/humans/onmob/clothing/suit_storage/guns_by_type/flamers.dmi',
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/weapons/guns/flamers_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/weapons/guns/flamers_righthand.dmi'
	)
	mouse_pointer = 'icons/effects/mouse_pointer/flamer_mouse.dmi'

	unload_sound = 'sound/weapons/handling/flamer_unload.ogg'
	reload_sound = 'sound/weapons/handling/flamer_reload.ogg'
	dry_fire_sound = list('sound/weapons/flamer_dryfire1.ogg', 'sound/weapons/flamer_dryfire2.ogg')*/
	fire_sound = ""

	var/ignite_sound = 'sound/weapons/handling/flamer_ignition.ogg'
	var/extinguish_sound = 'sound/weapons/handling/flamer_ignition.ogg'

	slot_flags = SLOT_BACK//flags_equip_slot = SLOT_BACK
	w_class = SIZE_LARGE
	force = 15
	//aim_slowdown = SLOWDOWN_ADS_INCINERATOR
	initial_mag = /obj/item/ammo_magazine/flamer_tank
	var/fuel_pressure = 1 //Pressure setting of the attached fueltank, controls how much fuel is used per tile
	var/max_range = 9 //9 tiles, 7 is screen range, controlled by the type of napalm in the canister. We max at 9 since diagonal bullshit.
	fire_delay = 2 SECONDS
	var/lit = FALSE

	/*attachable_allowed = list( //give it some flexibility.
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/extinguisher,
		/obj/item/attachable/attached_gun/flamer_nozzle
	)
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_TRIGGER_SAFETY
	gun_category = GUN_CATEGORY_HEAVY
*/

/obj/item/weapon/gun/projectile/flamer/atom_init()
	. = ..()
	update_icon()
/*
/obj/item/weapon/gun/projectile/flamer/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 0, "muzzle_y" = 0, "rail_x" = 11, "rail_y" = 20, "under_x" = 21, "under_y" = 14, "stock_x" = 0, "stock_y" = 0)

/obj/item/weapon/gun/projectile/flamer/x_offset_by_attachment_type(attachment_type)
	switch(attachment_type)
		if(/obj/item/attachable/flashlight)
			return 8
	return 0

/obj/item/weapon/gun/projectile/flamer/y_offset_by_attachment_type(attachment_type)
	switch(attachment_type)
		if(/obj/item/attachable/flashlight)
			return -1
	return 0

/obj/item/weapon/gun/projectile/flamer/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_5 * 5)
*/
/obj/item/weapon/gun/projectile/flamer/unique_action(mob/user)
	toggle_gun_safety()

/obj/item/weapon/gun/projectile/flamer/gun_safety_handle(mob/user)
	to_chat(user, "<span class='notice'>You <b>[lit ? "extinguish" : "ignite"]</b> the pilot light.</span>")
	playsound(user, lit ? extinguish_sound : ignite_sound, 25, 1)
	update_icon()

/obj/item/weapon/gun/projectile/flamer/get_examine_text(mob/user)
	. = ..()
	if(magazine)
		. += "The fuel gauge shows the current tank is [floor(magazine.reagents ? 100 * (magazine.reagents.total_volume / magazine.max_rounds) : 0)]% full!"
	else
		. += "There's no tank in [src]!"

/obj/item/weapon/gun/projectile/flamer/update_icon(mob/user)
	..()

	// Have to redo this here because we don't want the empty sprite when the tank is empty (just when it's not in the gun)
	var/new_icon_state = initial(icon_state)

	if(!magazine)
		new_icon_state += "_e"
	icon_state = new_icon_state

	if(magazine && magazine.reagents)
		var/obj/item/ammo_magazine/flamer_tank/flamtank = magazine
		if(flamtank.stripe_icon)
			var/image/I = image(icon, icon_state="flametank_strip")
			I.color = mix_color_from_reagents(magazine.reagents.reagent_list)
			overlays += I
/*
	if(!(lit))
		var/obj/item/attachable/attached_gun/flamer_nozzle/nozzle = locate() in contents
		var/image/I = image(icon, src, "+lit")
		I.pixel_x += nozzle && nozzle == active_attachable ? 6 : 1
		overlays += I
*/
/obj/item/weapon/gun/projectile/flamer/proc/get_fire_sound()
	var/list/fire_sounds = list(
		'sound/weapons/gun_flamethrower1.ogg',
		'sound/weapons/gun_flamethrower2.ogg',
		'sound/weapons/gun_flamethrower3.ogg')
	return pick(fire_sounds)

/obj/item/weapon/gun/projectile/flamer/Fire(atom/target, mob/living/user, params, reflex)
	set waitfor = FALSE

	if(!can_fire(user))
		return NONE

	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if (!targloc || !curloc)
		return NONE //Something has gone wrong...

	/*if(active_attachable && active_attachable.flags_attach_features & ATTACH_WEAPON) //Attachment activated and is a weapon.
		if(active_attachable.flags_attach_features & ATTACH_PROJECTILE)
			return
		if((active_attachable.current_rounds <= 0) && !(active_attachable.flags_attach_features & ATTACH_IGNORE_EMPTY))
			click_empty(user) //If it's empty, let them know.
			to_chat(user, "<span class='warning'>[active_attachable] is empty!</span>")
			to_chat(user, "<span class='notice'>You disable [active_attachable].</span>")
			active_attachable.activate_attachment(src, null, TRUE)
		else
			active_attachable.fire_attachment(target, src, user) //Fire it.
			active_attachable.last_fired = world.time
		return NONE*/

	if(lit)
		to_chat(user, "<span class='warning'>\The [src] isn't lit!</span>")
		return NONE

	if(!magazine)
		click_empty(user)
		return NONE

	if(magazine.current_rounds <= 0)
		click_empty(user)
	else
		user.track_shot(initial(name))
		if(istype(magazine, /obj/item/ammo_magazine/flamer_tank/smoke))
			unleash_smoke(target, user)
		else
			if(magazine.reagents.has_reagent("stablefoam"))
				unleash_foam(target, user)
			else
				unleash_flame(target, user)
		return AUTOFIRE_CONTINUE
	return NONE

/obj/item/weapon/gun/projectile/flamer/reload(mob/user, obj/item/ammo_magazine/new_magazine)
	if(!new_magazine || !istype(new_magazine))
		to_chat(user, "<span class='warning'>That's not a magazine!</span>")
		return

	if(new_magazine.current_rounds <= 0)
		to_chat(user, "<span class='warning'>That [magazine.name] is empty!</span>")
		return

	if(!istype(src, new_magazine.gun_type))
		to_chat(user, "<span class='warning'>That magazine doesn't fit in there!</span>")
		return

	if(!QDELETED(magazine) && magazine.loc == src)
		to_chat(user, "<span class='warning'>It's still got something loaded!</span>")
		return

	else
		if(user)
			if(new_magazine.reload_delay > 1)
				to_chat(user, "<span class='notice'>You begin reloading [src]. Hold still...</span>")
				if(do_after(user,new_magazine.reload_delay, INTERRUPT_ALL, BUSY_ICON_FRIENDLY))
					replace_magazine(user)
				else
					to_chat(user, "<span class='warning'>Your reload was interrupted!</span>")
					return
			else
				replace_magazine(user, new_magazine)
		else
			magazine = new_magazine
			new_magazine.forceMove(src)
			replace_ammo(,new_magazine)
	var/obj/item/ammo_magazine/flamer_tank/tank = magazine
	fuel_pressure = tank.fuel_pressure
	update_icon()
	return 1

/obj/item/weapon/gun/projectile/flamer/unload(mob/user, reload_override = 0, drop_override = 0)
	if(!magazine)
		return //no magazine to unload
	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		magazine.forceMove(get_turf(src)) //Drop it on the ground.
	else if (user)
		user.put_in_hands(magazine)

	if (user)
		playsound(user, unload_sound, 25, 1)
		user.visible_message("<span class='notice'>[user] unloads [magazine] from [src].</span>",
		"<span class='notice'>You unload [magazine] from [src].</span>")

	magazine.update_icon()
	magazine = null
	fuel_pressure = 1

	update_icon()

/obj/item/weapon/gun/projectile/flamer/proc/unleash_flame(atom/target, mob/living/user)
	set waitfor = 0
	last_fired = world.time
	if(!magazine || !magazine.reagents || !length(magazine.reagents.reagent_list))
		click_empty(user)
		return

	var/datum/reagent/chem = magazine.reagents.reagent_list[1]

	var/flameshape = chem.flameshape
	var/fire_type = chem.fire_type

	chem.intensityfire = clamp(chem.intensityfire, magazine.reagents.min_fire_int, magazine.reagents.max_fire_int)
	chem.durationfire = clamp(chem.durationfire, magazine.reagents.min_fire_dur, magazine.reagents.max_fire_dur)

	// COMMENTING THESE OUT BUT NOT DELETING, THERE IS CURRENTLY NO ITERATION OF FLAMERS THAT NECESSITATES THE CODE BELOW
		//atleast until circa 2030 CM with scoped flamers
	//if (max_range < fuel_pressure) //Used for custom tanks, allows for higher ranges
	//	max_range = clamp(fuel_pressure, 0, magazine.reagents.max_fire_rad)

	var/max_range = chem.rangefire
	if(chem.rangefire == -1)
		max_range = magazine.reagents.max_fire_rad
	var/distance = 0

	var/turf/temp[] = get_line(get_turf(user), get_turf(target))
	process_flame_tiles(temp, target, user, chem, max_range, flameshape, fire_type, distance, null, FALSE)

/obj/item/weapon/gun/projectile/flamer/proc/process_flame_tiles(list/turfs, atom/target, mob/living/user, datum/reagent/chem, max_range, flameshape, fire_type, distance, turf/prev_turf, stop_at_turf)
	if(!length(turfs))
		return

	var/turf/current_turf = turfs[1]
	turfs.Cut(1, 2)

	if(current_turf == user.loc)
		prev_turf = current_turf
		addtimer(CALLBACK(src, PROC_REF(process_flame_tiles), turfs, target, user, chem, max_range, flameshape, fire_type, distance, prev_turf, stop_at_turf), 1, TIMER_UNIQUE)
		return

	if(distance >= max_range)
		return

	if(current_turf.density)
		stop_at_turf = TRUE
	else if(prev_turf)
		var/atom/movable/temp = new /obj/flamer_fire()
		var/atom/movable/blocked = LinkBlocked(temp, prev_turf, current_turf)
		qdel(temp)

		if(blocked)
			if(blocked.flags_atom & ON_BORDER)
				return
			stop_at_turf = TRUE

	if(stop_at_turf)
		flame_adjacent(current_turf, user, chem)
		playsound(current_turf, src.get_fire_sound(), 50, TRUE)
		show_percentage(user)
		return

	distance++
	prev_turf = current_turf

	playsound(current_turf, src.get_fire_sound(), 50, TRUE)

	new /obj/flamer_fire(current_turf, create_cause_data(initial(name), user), chem, max_range, magazine.reagents, flameshape, target, CALLBACK(src, PROC_REF(show_percentage), user), fuel_pressure, fire_type)

/obj/item/weapon/gun/projectile/flamer/proc/flame_adjacent(turf/turfed, mob/living/user, datum/reagent/chem)
	if(!istype(turfed))
		return

	if(!locate(/obj/flamer_fire) in turfed) // Prevent stacking flames
		if(magazine && magazine.reagents && length(magazine.reagents.reagent_list)) // Ensure reagents exist

			chem.intensityfire = clamp(chem.intensityfire, magazine.reagents.min_fire_int, magazine.reagents.max_fire_int)
			chem.durationfire = clamp(chem.durationfire, magazine.reagents.min_fire_dur, magazine.reagents.max_fire_dur)

			new /obj/flamer_fire(turfed, create_cause_data(initial(name), user), chem)
			magazine.reagents.remove_reagent(chem.id, 1)

/obj/item/weapon/gun/projectile/flamer/proc/unleash_smoke(atom/target, mob/living/user)
	last_fired = world.time
	if(!magazine || !magazine.reagents || !length(magazine.reagents.reagent_list))
		return

	var/source_turf = get_turf(user)
	var/smoke_range = 5 // the max range the smoke will travel
	var/distance = 0 // the distance traveled
	var/use_multiplier = 3 // if you want to increase the ammount of units drained from the tank
	var/units_in_smoke = 35 // the smoke overlaps a little so this much is probably already good

	var/datum/reagent/chemical = magazine.reagents.reagent_list[1]
	var/datum/reagents/to_disperse = new() // this is the chemholder that will be used by the chemsmoke
	to_disperse.add_reagent(chemical.id, units_in_smoke)
	to_disperse.my_atom = src

	var/turf/turfs[] = get_line(user, target, FALSE)
	var/turf/first_turf = turfs[1]
	var/turf/second_turf = turfs[2]
	var/ammount_required = (min(length(turfs), smoke_range) * use_multiplier) // the ammount of units that this click requires
	for(var/turf/turf in turfs)

		if(chemical.volume < ammount_required)
			smoke_range = floor(chemical.volume / use_multiplier)

		if(distance >= smoke_range)
			break

		if(turf.density)
			break
		else
			var/obj/effect/effect/smoke/chem/checker = new()
			if (!T.CanPass(checker, T))
				break

		playsound(turf, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, 25)
		if(turf != first_turf && turf != second_turf) // we skip the first tile and make it small on the second so the smoke doesn't touch the user
			var/datum/effect/effect/system/smoke_spread/chem/S = new ()
			S.attach(location)
			S.set_up(to_disperse, units_in_smoke, 5, loca = turf)
			S.start()
		if(turf == second_turf)
			var/datum/effect/effect/system/smoke_spread/chem/S = new ()
			S.attach(location)
			S.set_up(to_disperse, units_in_smoke, 1, loca = turf)
			S.start()
		sleep(4)

		distance++

	var/ammount_used = distance * use_multiplier // the actual ammount of units that we used

	chemical.volume = max(chemical.volume - ammount_used, 0)

	magazine.reagents.total_volume = chemical.volume // this is needed for show_percentage to work

	if(chemical.volume < use_multiplier) // there aren't enough units left for a single tile of smoke, empty the tank
		magazine.reagents.clear_reagents()

	show_percentage(user)
/*
/obj/item/weapon/gun/projectile/flamer/proc/unleash_foam(atom/target, mob/living/user)
	last_fired = world.time
	if(!magazine || !magazine.reagents || !length(magazine.reagents.reagent_list))
		return

	var/source_turf = get_turf(user)
	var/foam_range = 6 // the max range the foam will travel
	var/distance = 0 // the distance traveled
	var/use_multiplier = 3 // if you want to increase the ammount of foam drained from the tank
	var/datum/reagent/chemical = magazine.reagents.reagent_list[1]

	var/turf/turfs[] = get_line(user, target, FALSE)
	var/turf/first_turf = turfs[1]
	var/ammount_required = (min(length(turfs), foam_range) * use_multiplier) // the ammount of units that this click requires
	for(var/turf/turf in turfs)

		if(chemical.volume < ammount_required)
			foam_range = floor(chemical.volume / use_multiplier)

		if(distance >= foam_range)
			break

		// Then check the turf itself
		if (!T.CanPass(mover, T))
			break
		/*if(turf.density)
			break
		else
			var/obj/effect/particle_effect/foam/checker = new()
			var/atom/blocked = LinkBlocked(checker, source_turf, turf)
			if(blocked)
				break*/

		if(turf == first_turf) // this is so the first foam tile doesn't expand and touch the user
			var/datum/effect_system/foam_spread/foam = new()
			foam.set_up(0.5, turf, metal_foam = FOAM_METAL_TYPE_IRON)
			foam.start()
		else
			var/datum/effect_system/foam_spread/foam = new()
			foam.set_up(1, turf, metal_foam = FOAM_METAL_TYPE_IRON)
			foam.start()
		sleep(2)

		distance++

	var/ammount_used = distance * use_multiplier // the actual ammount of units that we used

	chemical.volume = max(chemical.volume - ammount_used, 0)

	magazine.reagents.total_volume = chemical.volume // this is needed for show_percentage to work

	if(chemical.volume < use_multiplier) // there aren't enough units left for a single tile of foam, empty the tank
		magazine.reagents.clear_reagents()

	show_percentage(user)
*/
/obj/item/weapon/gun/projectile/flamer/proc/show_percentage(mob/living/user)
	if(magazine)
		to_chat(user, "<span class='warning'>The gauge reads: <b>[floor(magazine.reagents ? 100 * (magazine.reagents.total_volume / magazine.max_rounds) : 0)]</b>% fuel remains!</span>")










/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/effects.dmi'
	icon_state = "dynamic_2"
	layer = BELOW_OBJ_LAYER

	light_system = STATIC_LIGHT
	light_on = TRUE
	light_range = 3
	light_power = 3
	light_color = "#f88818"

	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.

	/// After the fire is created, for 0.5 seconds this variable will be TRUE.
	var/initial_burst = TRUE

	var/flame_icon = "dynamic"
	var/flameshape = FLAMESHAPE_DEFAULT // diagonal square shape
	var/datum/cause_data/weapon_cause_data
	var/turf/target_clicked

	var/datum/reagent/tied_reagent
	var/datum/reagents/tied_reagents
	var/datum/callback/to_call

	var/fire_variant = FIRE_VARIANT_DEFAULT

	var/weather_smothering_strength = 0

/obj/flamer_fire/atom_init(mapload, datum/cause_data/cause_data, datum/reagent/R, fire_spread_amount = 0, datum/reagents/obj_reagents = null, new_flameshape = FLAMESHAPE_DEFAULT, atom/target = null, datum/callback/C, fuel_pressure = 1, fire_type = FIRE_VARIANT_DEFAULT)
	. = ..()
	if(!R)
		R = new /datum/reagent/napalm/ut()

	if(!tied_reagents)
		create_reagents(100) // So that the expanding flames are all linked together by 1 tied_reagents object
		tied_reagents = reagents
		tied_reagents.locked = TRUE

	flameshape = new_flameshape

	fire_variant = fire_type

	//non-dynamic flame is already colored
	if(R.burn_sprite == "dynamic")
		color = R.burncolor
	else
		flame_icon = R.burn_sprite

	set_light(l_color = R.burncolor)

	tied_reagent = new R.type() // Can't get deleted this way
	tied_reagent.make_alike(R)

	if(obj_reagents)
		tied_reagents = obj_reagents

	target_clicked = target

	if(istype(cause_data))
		weapon_cause_data = cause_data
	else if(cause_data)
		weapon_cause_data = create_cause_data(cause_data)
	else
		weapon_cause_data = create_cause_data(initial(name), null)

	icon_state = "[flame_icon]_2"

	//Fire duration increases with fuel usage
	firelevel = R.durationfire + fuel_pressure*R.durationmod
	burnlevel = R.intensityfire

	//are we in weather??
	update_in_weather_status()

	update_flame()

	addtimer(CALLBACK(src, PROC_REF(un_burst_flame)), 0.5 SECONDS)
	START_PROCESSING(SSobj, src)

	to_call = C

	var/burn_dam = burnlevel*FIRE_DAMAGE_PER_LEVEL

	if(tied_reagents && !tied_reagents.locked)
		var/removed = tied_reagents.remove_reagent(tied_reagent.id, FLAME_REAGENT_USE_AMOUNT * fuel_pressure)
		if(removed)
			qdel(src)
			return

	if(fire_spread_amount > 0)
		var/datum/flameshape/FS = GLOB.flameshapes[flameshape]
		if(!FS)
			CRASH("Invalid flameshape passed to /obj/flamer_fire. (Expected /datum/flameshape, got [FS] (id: [flameshape]))")

		INVOKE_ASYNC(FS, TYPE_PROC_REF(/datum/flameshape, handle_fire_spread), src, fire_spread_amount, burn_dam, fuel_pressure)
	//Apply fire effects onto everyone in the fire

	/*//scorch mah grass HNNGGG and muh SNOW hhhhGGG
	if (istype(loc, /turf/open))
		var/turf/open/scorch_turf_target = loc
		if(scorch_turf_target.scorchable)
			scorch_turf_target.scorch(burnlevel)

	if (istype(loc, /turf/open/auto_turf/snow))
		var/turf/open/auto_turf/snow/S = loc
		if(S.bleed_layer > 0)
			var/new_layer = S.bleed_layer - 1
			S.changing_layer(new_layer)
*/
	for(var/mob/living/ignited_morb in loc) //Deal bonus damage if someone's caught directly in initial stream
		if(ignited_morb.stat == DEAD)
			continue

		/*if(ishuman(ignited_morb))
			var/mob/living/carbon/human/target_human = ignited_morb //fixed :s

			if(weapon_cause_data)
				var/mob/user = weapon_cause_data.resolve_mob()
				if(user)
					var/area/thearea = get_area(user)
					if(user.faction == target_human.faction && !thearea?.statistic_exempt)
						target_human.attack_log += "\[[time_stamp()]\] <b>[key_name(user)]</b> shot <b>[key_name(target_human)]</b> with \a <b>[name]</b> in [get_area(user)]."
						user.attack_log += "\[[time_stamp()]\] <b>[key_name(user)]</b> shot <b>[key_name(target_human)]</b> with \a <b>[name]</b> in [get_area(user)]."
						if(weapon_cause_data.cause_name)
							target_human.track_friendly_fire(weapon_cause_data.cause_name)
						var/ff_msg = "[key_name(user)] shot [key_name(target_human)] with \a [name] in [get_area(user)] [ADMIN_JMP(user)] [ADMIN_PM(user)]"
						var/ff_living = TRUE
						if(target_human.stat == DEAD)
							ff_living = FALSE
						if(!((user.mob_flags & MUTINY_MUTINEER) && (target_human.mob_flags & MUTINY_LOYALIST)) && ((user.mob_flags & MUTINY_LOYALIST) && (target_human.mob_flags & MUTINY_MUTINEER)))
							msg_admin_ff(ff_msg, ff_living)
					else
						target_human.attack_log += "\[[time_stamp()]\] <b>[key_name(user)]</b> shot <b>[key_name(target_human)]</b> with \a <b>[name]</b> in [get_area(user)]."
						user.attack_log += "\[[time_stamp()]\] <b>[key_name(user)]</b> shot <b>[key_name(target_human)]</b> with \a <b>[name]</b> in [get_area(user)]."
						msg_admin_attack("[key_name(user)] shot [key_name(target_human)] with \a [name] in [get_area(user)] ([user.loc.x],[user.loc.y],[user.loc.z]).", user.loc.x, user.loc.y, user.loc.z)
				if(weapon_cause_data.cause_name)
					target_human.track_shot_hit(weapon_cause_data.cause_name, target_human)
					*/

		var/fire_intensity_resistance = ignited_morb.check_fire_intensity_resistance()
		var/firedamage = max(burn_dam - fire_intensity_resistance, 0)
		if(!firedamage)
			continue

		var/sig_result = SEND_SIGNAL(ignited_morb, COMSIG_LIVING_FLAMER_FLAMED, tied_reagent)

		if(!(sig_result & COMPONENT_NO_IGNITE))
			switch(fire_variant)
				if(FIRE_VARIANT_TYPE_B) //Armor Shredding Greenfire, super easy to pat out. 50 duration -> 10 stacks (1 pat/resist)
					ignited_morb.TryIgniteMob(floor(tied_reagent.durationfire / 5), tied_reagent)
				else
					ignited_morb.TryIgniteMob(tied_reagent.durationfire, tied_reagent)

		if(sig_result & COMPONENT_NO_BURN)
			continue

		ignited_morb.last_damage_data = weapon_cause_data
		ignited_morb.apply_damage(firedamage, BURN)
		animation_flash_color(ignited_morb, tied_reagent.burncolor) //pain hit flicker

		to_chat(ignited_morb, "<span class='userdanger'>Augh! You are roasted by the flames!</span>)")

		if(weapon_cause_data)
			var/mob/SM = weapon_cause_data.resolve_mob()
			if(istype(SM))
				SM.track_shot_hit(weapon_cause_data.cause_name)

	RegisterSignal(SSdcs, COMSIG_GLOB_WEATHER_CHANGE, PROC_REF(update_in_weather_status))

	var/turf/current_turf = get_turf(src)
	if(istype(current_turf, /turf/open_space))
		var/turf/open_space/current_open_turf = current_turf
		current_open_turf.check_fall(src)

/obj/flamer_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	to_call = null
	tied_reagent = null
	tied_reagents = null
	. = ..()

/obj/flamer_fire/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if (PF)
		PF.flags_pass = PASS_FLAGS_FLAME

/obj/flamer_fire/Crossed(atom/movable/atom_movable)
	atom_movable.handle_flamer_fire_crossed(src)
/*
/obj/flamer_fire/proc/type_b_debuff_xeno_armor(mob/living/carbon/xenomorph/X)
	var/sig_result = SEND_SIGNAL(X, COMSIG_LIVING_FLAMER_CROSSED, tied_reagent)
	. = 1
	if(sig_result & COMPONENT_XENO_FRENZY)
		. = 0.8
	if(sig_result & COMPONENT_NO_IGNITE)
		. = 0.6
	X.armor_deflection_debuff = (X.armor_deflection + X.armor_deflection_buff) * 0.5 * . //At the moment this just directly sets the debuff var since it's the only interaction with it. In the future if the var is used more, usages of type_b_debuff_armor may need to be refactored (or just make them mutually exclusive and have the highest overwrite).

/mob/living/carbon/xenomorph/proc/reset_xeno_armor_debuff_after_time(mob/living/carbon/xenomorph/X, wait_ticks) //Linked onto Xenos instead of the fire so it doesn't cancel on fire deletion.
	spawn(wait_ticks)
	if(X.armor_deflection_debuff)
		X.armor_deflection_debuff = 0
*/
/obj/flamer_fire/proc/set_on_fire(mob/living/M)
	if(!istype(M))
		return

	var/sig_result = SEND_SIGNAL(M, COMSIG_LIVING_FLAMER_CROSSED, tied_reagent)
	var/burn_damage = floor(burnlevel * 0.5)
	switch(fire_variant)
		if(FIRE_VARIANT_TYPE_B) //Armor Shredding Greenfire, 2x tile damage (Equiavlent to UT)
			burn_damage = burnlevel
	var/fire_intensity_resistance = M.check_fire_intensity_resistance()

	if(!tied_reagent.fire_penetrating)
		burn_damage = max(burn_damage - fire_intensity_resistance * 0.5, 0)

	if(sig_result & COMPONENT_XENO_FRENZY)
		var/mob/living/carbon/xenomorph/X = M
		if(X.plasma_stored != X.plasma_max) //limit num of noise
			to_chat(X, "<span class='danger'>The heat of the fire roars in your veins! KILL! CHARGE! DESTROY!</span>")
			X.emote("roar")
		X.plasma_stored = X.plasma_max

	if(!(sig_result & COMPONENT_NO_IGNITE) && burn_damage)
		switch(fire_variant)
			if(FIRE_VARIANT_TYPE_B) //Armor Shredding Greenfire, super easy to pat out. 50 duration -> 10 stacks (1 pat/resist)
				M.TryIgniteMob(floor(tied_reagent.durationfire / 5), tied_reagent)
			else
				M.TryIgniteMob(tied_reagent.durationfire, tied_reagent)

	if(sig_result & COMPONENT_NO_BURN && !tied_reagent.fire_penetrating)
		burn_damage = 0

	if(!burn_damage)
		if(HAS_TRAIT(M, TRAIT_HAULED))
			M.visible_message("<span class='warning'>[M] is shielded from the flames!</span>", "<span class='warning'>You are shielded from the flames!</span>")
		else
			to_chat(M, "<span class='danger'>[isxeno(M) ? "We" : "You"] step over the flames.</span>")
		return

	M.last_damage_data = weapon_cause_data
	M.apply_damage(burn_damage, BURN) //This makes fire stronk.

	var/variant_burn_msg = null
	switch(fire_variant) //Fire variant special message appends.
		if(FIRE_VARIANT_TYPE_B)
			if(isxeno(M))
				var/mob/living/carbon/xenomorph/X = M
				X.armor_deflection?(variant_burn_msg=" We feel the flames weakening our exoskeleton!"):(variant_burn_msg=" You feel the flaming chemicals eating into your body!")
	to_chat(M, "<span class='danger'>You are burned![variant_burn_msg?"[variant_burn_msg]":""]</span>")
	M.updatehealth()

/obj/flamer_fire/proc/update_flame()
	if(burnlevel < 15 && flame_icon != "dynamic")
		color = "#c1c1c1" //make it darker to make show its weaker.
	var/flame_level = 1
	switch(firelevel)
		if(1 to 9)
			flame_level = 1
		if(10 to 25)
			flame_level = 2
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			flame_level = 3

	if(initial_burst)
		flame_level++ //the initial flame burst is 1 level higher for a small time

	icon_state = "[flame_icon]_[flame_level]"
	set_light(flame_level * 2)

/obj/flamer_fire/proc/un_burst_flame()
	initial_burst = FALSE
	update_flame()

/obj/flamer_fire/process(delta_time)
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf? Has to be on a floor
		qdel(src)
		return PROCESS_KILL
	var/damage = burnlevel*delta_time
	T.flamer_fire_act(damage)

	if(!firelevel)
		qdel(src)
		return

	update_flame()

	for(var/atom/thing in loc)
		thing.handle_flamer_fire(src, damage, delta_time)

	//This has been made a simple loop, for the most part flamer_fire_act() just does return, but for specific items it'll cause other effects.

	firelevel -= 2 + weather_smothering_strength //reduce the intensity by 2 as default or more if in weather ---- weather_smothering_strength is set as /datum/weather_event's fire_smothering_strength

	return

/obj/flamer_fire/proc/update_in_weather_status()
	SIGNAL_HANDLER
	var/area/A = get_area(src)
	if(!A)
		return
	if(SSweather.is_weather_event && locate(A) in SSweather.weather_areas)
		weather_smothering_strength = SSweather.weather_event_instance.fire_smothering_strength
	else
		weather_smothering_strength = 0

/proc/fire_spread_recur(turf/target, datum/cause_data/cause_data, remaining_distance, direction, fire_lvl, burn_lvl, f_color, burn_sprite = "dynamic", aerial_flame_level)
	var/direction_angle = dir2angle(direction)
	var/obj/flamer_fire/foundflame = locate() in target
	if(!foundflame)
		var/datum/reagent/fire_reag = new()
		fire_reag.intensityfire = burn_lvl
		fire_reag.durationfire = fire_lvl
		fire_reag.burn_sprite = burn_sprite
		fire_reag.burncolor = f_color
		new/obj/flamer_fire(target, cause_data, fire_reag)
	if(target.density)
		return

	for(var/spread_direction in global.alldirs)

		var/spread_power = remaining_distance

		var/spread_direction_angle = dir2angle(spread_direction)

		var/angle = 180 - abs( abs( direction_angle - spread_direction_angle ) - 180 ) // the angle difference between the spread direction and initial direction

		switch(angle) //this reduces power when the explosion is going around corners
			if (45)
				spread_power *= 0.75
			if (90 to 180) //turns out angles greater than 90 degrees almost never happen. This bit also prevents trying to spread backwards
				continue

		switch(spread_direction)
			if(NORTH,SOUTH,EAST,WEST)
				spread_power--
			else
				spread_power -= 1.414 //diagonal spreading

		if (spread_power < 1)
			continue

		var/turf/picked_turf = get_step(target, spread_direction)

		if(!picked_turf) //prevents trying to spread into "null" (edge of the map?)
			continue

		/*if(aerial_flame_level)
			if(picked_turf.get_pylon_protection_level() >= aerial_flame_level)
				break
			var/area/picked_area = get_area(picked_turf)
			if(CEILING_IS_PROTECTED(picked_area?.ceiling, get_ceiling_protection_level(aerial_flame_level)))
				break
*/
		spawn(0)
			fire_spread_recur(picked_turf, cause_data, spread_power, spread_direction, fire_lvl, burn_lvl, f_color, burn_sprite, aerial_flame_level)

/proc/fire_spread(turf/target, datum/cause_data/cause_data, range, fire_lvl, burn_lvl, f_color, burn_sprite = "dynamic", aerial_flame_level = TURF_PROTECTION_NONE)
	var/datum/reagent/fire_reag = new()
	fire_reag.intensityfire = burn_lvl
	fire_reag.durationfire = fire_lvl
	fire_reag.burn_sprite = burn_sprite
	fire_reag.burncolor = f_color

	new/obj/flamer_fire(target, cause_data, fire_reag)
	for(var/direction in global.alldirs)
		var/spread_power = range
		switch(direction)
			if(NORTH,SOUTH,EAST,WEST)
				spread_power--
			else
				spread_power -= 1.414 //diagonal spreading
		var/turf/picked_turf = get_step(target, direction)
		/*if(aerial_flame_level)
			if(picked_turf.get_pylon_protection_level() >= aerial_flame_level)
				continue
			var/area/picked_area = get_area(picked_turf)
			if(CEILING_IS_PROTECTED(picked_area?.ceiling, get_ceiling_protection_level(aerial_flame_level)))
				continue*/
		fire_spread_recur(picked_turf, cause_data, spread_power, direction, fire_lvl, burn_lvl, f_color, burn_sprite, aerial_flame_level)























//Flame thrower.

/obj/item/ammo_box/magazine/flamer_tank
	name = "M240 incinerator tank"
	desc = "A fuel tank for use in the M240 incinerator unit. Handle with care."
	icon = 'icons/obj/items/weapons/guns/ammo_by_faction/USCM/flamers.dmi'
	icon_state = "flametank_custom"
	item_state = "flametank"
	/*item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/inhands/weapons/ammo_lefthand.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/inhands/weapons/ammo_righthand.dmi'
		)*/
	var/max_units = 100
	//default_ammo = /datum/ammo/flamethrower //doesn't actually need bullets. But we'll get null ammo error messages if we don't
	w_class = SIZE_NORMAL //making sure you can't sneak this onto your belt.
	//gun_type = /obj/item/weapon/gun/projectile/flamer/m240
	caliber = "UT-Napthal Fuel" //Ultra Thick Napthal Fuel, from the lore book.
	var/custom = FALSE //accepts custom fuels if true

	var/flamer_chem = "utnapthal"
	//flags_magazine = AMMUNITION_HIDE_AMMO

	var/max_intensity = 40
	var/max_range = 5
	var/max_duration = 30

	var/fuel_pressure = 1 //How much fuel is used per tile fired
	var/max_pressure = 10

	var/stripe_icon = TRUE

/obj/item/ammo_box/magazine/flamer_tank/empty
	flamer_chem = null

/obj/item/ammo_box/magazine/flamer_tank/atom_init()
	. = ..()
	create_reagents(max_units)

	if(flamer_chem)
		reagents.add_reagent(flamer_chem, max_units)

	reagents.min_fire_dur = 1
	reagents.min_fire_int = 1
	reagents.min_fire_rad = 1

	reagents.max_fire_dur = max_duration
	reagents.max_fire_rad = max_range
	reagents.max_fire_int = max_intensity

	update_icon()

/obj/item/ammo_box/magazine/flamer_tank/verb/remove_reagents()
	set name = "Empty canister"
	set category = "Object"

	set src in usr

	if(usr.get_active_hand() != src)
		return

	if(alert(usr, "Do you really want to empty out [src]?", "Empty canister", "Yes", "No") != "Yes")
		return

	reagents.clear_reagents()

	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(usr, "<span class='notice'>You empty out [src]</span>")
	update_icon()

/obj/item/ammo_magazine/flamer_tank/on_reagent_change()
	. = ..()
	update_icon()

	if(istype(loc, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/G = loc
		if(G.magazine == src)
			G.update_icon()

/obj/item/ammo_magazine/flamer_tank/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.
	if(get_dist(user,target) > 1)
		return ..()
	//if(!istype(target, /obj/structure/reagent_dispensers/fueltank) && !istype(target, /obj/item/tool/weldpack) && !istype(target, /obj/item/storage/backpack/marine/engineerpack))
	//	return ..()

	if(!target.reagents || length(target.reagents.reagent_list) < 1)
		to_chat(user, "<span class='warning'>[target] is empty!</span>")
		return

	if(!reagents)
		create_reagents(max_units)

	var/datum/reagent/to_add = target.reagents.reagent_list[1]

	if(!istype(to_add) || (length(reagents.reagent_list) && flamer_chem != to_add.id) || length(target.reagents.reagent_list) > 1)
		to_chat(user, "<span class='warning'>You can't mix fuel mixtures!</span>")
		return

	if(istype(to_add, /datum/reagent/generated) && !custom)
		to_chat(user, "<span class='warning'>[src] cannot accept custom fuels!</span>")
		return

	if(!to_add.intensityfire && to_add.id != "stablefoam" && !istype(src, /obj/item/ammo_magazine/flamer_tank/smoke))
		to_chat(user, "<span class='warning'>This chemical is not potent enough to be used in a flamethrower!</span>")
		return

	var/fuel_amt_to_remove = clamp(to_add.volume, 0, max_rounds - reagents.get_reagent_amount(to_add.id))
	if(!fuel_amt_to_remove)
		if(!max_units)
			to_chat(user, "<span class='warning'>[target] is empty!</span>")
		return

	target.reagents.remove_reagent(to_add.id, fuel_amt_to_remove)
	reagents.add_reagent(to_add.id, fuel_amt_to_remove)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	flamer_chem = to_add.id
	to_chat(user, "<span class='notice'>You refill [src] with [to_add.name].</span>")
	update_icon()

/obj/item/ammo_magazine/flamer_tank/update_icon()
	if(!stripe_icon)
		return

	overlays.Cut()

	var/image/I = image(icon, icon_state="[icon_state]_strip")

	if(reagents)
		I.color = mix_color_from_reagents(reagents.reagent_list)

	overlays += I

/obj/item/ammo_magazine/flamer_tank/get_examine_text(mob/user)
	. = ..()
	. += "<span class='notice'>It contains:"
	if(reagents && length(reagents.reagent_list))
		for(var/datum/reagent/R in reagents.reagent_list)
			. += "<span class='notice'> [R.volume] units of [R.name]."
	else
		. += "<span class='notice'>Nothing."

// This is gellie fuel. Green Flames.
/obj/item/ammo_magazine/flamer_tank/gellied
	name = "M240 incinerator tank (B-Gel)"
	desc = "A fuel tank full of specialized Ultra Thick Napthal Fuel type B-Gel, a gelled variant of napalm that is easily extinguished, but shoots further and lingers for longer. Handle with exceptional care."
//	desc_lore = "Unlike its liquid contemporaries, this gelled variant of napalm is easily extinguished, but shoots far and lingers on the ground in a viscous mess. The gel reacts violently with inorganic materials to break them down, forming an extremely sticky crytallized goo."
	//caliber = "Napalm Gel"
	flamer_chem = "napalmgel"
	max_rounds = 200

	max_range = 7
	max_duration = 50
/*
/obj/item/ammo_magazine/flamer_tank/custom
	name = "M240 custom incinerator tank"
	desc = "A fuel tank for use in the M240 incinerator unit. This one has been modified with a pressure regulator and an internal propellant tank."
	materials = list("metal" = 3750)
	flamer_chem = null
	max_rounds = 100
	max_range = 5
	fuel_pressure = 1
	custom = TRUE

/obj/item/ammo_magazine/flamer_tank/custom/verb/set_fuel_pressure()
	set name = "Change Fuel Pressure"
	set category = "Object"

	set src in usr

	if(usr.get_active_hand() != src)
		return

	var/set_pressure = clamp(tgui_input_number(usr, "Change fuel pressure to: (max: [max_pressure])", "Fuel pressure", fuel_pressure, 10, 1), 1 ,max_pressure)
	if(!set_pressure)
		to_chat(usr, "<span class='warning'>You can't find that setting on the regulator!</span>")
	else
		to_chat(usr, "<span class='notice'>You set the pressure regulator to [set_pressure] U/t</span>")
		fuel_pressure = set_pressure

/obj/item/ammo_magazine/flamer_tank/custom/get_examine_text(mob/user)
	. = ..()
	. += "<span class='notice'>The pressure regulator is set to: [src.fuel_pressure] U/t"
*/
// Pyro regular flamer tank just bigger than the base flamer tank.
/obj/item/ammo_magazine/flamer_tank/large
	name = "M240 large incinerator tank"
	desc = "A large fuel tank for use in the M240-T incinerator unit. Handle with extreme caution."
	icon_state = "flametank_large_custom"
	item_state = "flametank_large"
	max_units = 250
	gun_type = /obj/item/weapon/gun/projectile/flamer/m240/spec

	max_intensity = 80
	max_range = 5
	max_duration = 50

/obj/item/ammo_magazine/flamer_tank/large/empty
	flamer_chem = null


/*
// This is the green flamer fuel for the pyro.
/obj/item/ammo_magazine/flamer_tank/large/B
	name = "M240 large incinerator tank (B)"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel type B, a special variant of napalm that is easily extinguished, but disperses over a wide area while burning slowly."
	desc_lore = "Unlike its thinner contemporaries, this special ultra-thick variant of napalm is easily extinguished, but disperses over a wide area and lingers on the ground in a viscous mess. The composition reacts violently with inorganic materials to break them down, causing severe structural damage. Handle with extreme caution."
	caliber = "Napalm B"
	flamer_chem = "napalmb"

	max_range = 6

// This is the blue flamer fuel for the pyro.
/obj/item/ammo_magazine/flamer_tank/large/X
	name = "M240 large incinerator tank (X)"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel type X, a sticky combustible liquid chemical that burns extremely hot, for use in the M240-T incinerator unit. Handle with extreme caution."
	caliber = "Napalm X"
	flamer_chem = "napalmx"

	max_range = 6

/obj/item/ammo_magazine/flamer_tank/large/EX
	name = "M240 large incinerator tank (EX)"
	desc = "A large fuel tank of Ultra Thick Napthal Fuel type EX, a sticky combustible liquid chemical that burns so hot it melts straight through most flame-resistant materials, for use in the M240-T incinerator unit. Handle with extreme caution."
	caliber = "Napalm EX"
	flamer_chem = "napalmex"

	max_range = 7

//Custom pyro tanks
/obj/item/ammo_magazine/flamer_tank/custom/large
	name = "M240 large custom incinerator tank"
	desc = "A large fuel tank for use in the M240-T incinerator unit. This one has been modified with a pressure regulator and a large internal propellant tank. Must be manually attached."
	gun_type = /obj/item/weapon/gun/projectile/flamer/m240/spec
	max_rounds = 250

	max_intensity = 60
	max_range = 8
	max_duration = 50

/obj/item/ammo_magazine/flamer_tank/smoke
	name = "M240 custom incinerator smoke tank"
	desc = "A tank holding powdered smoke that expands when exposed to an open flame and carries any chemicals along with it."
	matter = list("metal" = 3750)
	flamer_chem = null
	custom = TRUE

//tanks printable by the research biomass machine
/obj/item/ammo_magazine/flamer_tank/custom/upgraded
	name = "M240 upgraded custom incinerator tank"
	desc = "A fuel tank for use in the M240 incinerator unit. This one has been modified with a larger and more sophisticated internal propellant tank, allowing for larger capacity and stronger fuels."
	matter = list("metal" = 50) // no free metal
	flamer_chem = null
	max_rounds = 200
	max_range = 7
	fuel_pressure = 1
	max_duration = 50
	max_intensity = 60
	custom = TRUE
*/
*/
