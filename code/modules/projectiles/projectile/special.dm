/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	light_color = "#a9e2f3"
	light_power = 2
	light_range = 2
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"

/obj/item/projectile/ion/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	empulse(target, 1, 1)
	return 1



/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"
	sharp = 1
	edge = 1

/obj/item/projectile/bullet/gyro/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	explosion(target, -1, 0, 2)
	return 1



/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	light_color = "#00ffff"
	light_power = 2
	light_range = 2
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	var/temperature = 100


/obj/item/projectile/temp/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0) //These two could likely check temp protection on the mob
	if(istype(target, /mob/living))
		var/mob/M = target
		M.bodytemperature = temperature
	return 1

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400



/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	light_color = "#ffffff"
	light_power = 2
	light_range = 2
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"

/obj/item/projectile/meteor/Bump(atom/A)
	if(A == firer)
		loc = A.loc
		return

	sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

	if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
		if(A)

			A.ex_act(2)
			playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER, 40)

			for(var/mob/M in range(10, src))
				if(!M.stat && !istype(M, /mob/living/silicon/ai))\
					shake_camera(M, 3, 1)
			qdel(src)
			return 1
	else
		return 0



/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/energy/floramut/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	var/mob/living/M = target
//	if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
	if(ishuman(target))
		var/mob/living/carbon/human/H = M
		if((H.species.flags[IS_PLANT]) && (M.nutrition < 500))
			if(prob(15))
				M.apply_effect((rand(30,80)),IRRADIATE)
				M.Weaken(5)
				visible_message("<span class='warning'>[M] writhes in pain as \his vacuoles boil.</span>", blind_message = "<span class='warning'>You hear the crunching of leaves.</span>")
			if(prob(35))
			//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
			//		V.show_messageold("<span class='warning'>[M] is mutated by the radiation beam.</span>", 3, "<span class='warning'>You hear the snapping of twigs.</span>", 2)
				if(prob(80))
					randmutb(M)
					domutcheck(M,null)
				else
					randmutg(M)
					domutcheck(M,null)
			else
				M.adjustFireLoss(rand(5,15))
				to_chat(M, "<span class='warning'>The radiation beam singes you!</span>")
			//	for (var/mob/V in viewers(src))
			//		V.show_messageold("<span class='warning'>[M] is singed by the radiation beam.</span>", 3, "<span class='warning'>You hear the crackle of burning leaves.</span>", 2)
	else if(istype(target, /mob/living/carbon))
	//	for (var/mob/V in viewers(src))
	//		V.show_messageold("The radiation beam dissipates harmlessly through [M]", 3)
		to_chat(M, "<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1



/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/energy/florayield/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	var/mob/M = target
//	if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //These rays make plantmen fat.
	if(ishuman(target)) //These rays make plantmen fat.
		var/mob/living/carbon/human/H = M
		if((H.species.flags[IS_PLANT]) && (M.nutrition < 500))
			M.nutrition += 30
	else if (istype(target, /mob/living/carbon))
		to_chat(M, "<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
	else
		return 1



/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20

/obj/item/projectile/beam/mindflayer/atom_init()
	. = ..()
	proj_act_sound = null

/obj/item/projectile/missile
	name ="rocket"
	icon_state= "rocket"
	light_color = "#ffffff"
	light_power = 2
	light_range = 2
	damage = 20
	flag = "bullet"
	sharp = 0
	edge = 0

/obj/item/projectile/missile/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	explosion(target, 1,2,4,5)
	return 1

/obj/item/projectile/missile/emp
	damage = 10

/obj/item/projectile/missile/emp/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	empulse(target, 4, 10)
	return 1


/obj/item/projectile/neurotoxin
	name = "neurotoxin"
	icon_state = "energy2"
	damage = 5
	stun = 10
	damage_type = TOX
	flag = "bullet"

/obj/item/projectile/acid_special
	name = "acid"
	icon_state = "neurotoxin"
	damage = 25
	damage_type = TOX
	flag = "bullet"

/obj/item/projectile/acid_special/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_ACIDACT

/obj/item/projectile/acid_special/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(issilicon(target))
		var/mob/living/silicon/S = target
		S.take_bodypart_damage(damage)//+10=30

	if(istype(target,/obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(damage)

	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/BP = H.get_bodypart(def_zone) // We're checking the outside, buddy!
		var/list/body_parts = list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.gloves, H.shoes) // What all are we checking?
		for(var/bp in body_parts) //Make an unregulated var to pass around.
			if(istype(bp ,/obj/item/clothing)) // If it exists, and it's clothed
				var/obj/item/clothing/C = bp // Then call an argument C to be that clothing!
				if(C.body_parts_covered & BP.body_part) // Is that body part being targeted covered?
					if(prob(75))
						C.make_old()
						if(bp == H.head)
							H.update_inv_head()
						if(bp == H.wear_mask)
							H.update_inv_wear_mask()
						if(bp == H.wear_suit)
							H.update_inv_wear_suit()
						if(bp == H.w_uniform)
							H.update_inv_w_uniform()
						if(bp == H.gloves)
							H.update_inv_gloves()
						if(bp == H.shoes)
							H.update_inv_shoes()
					visible_message("<span class='warning'>The [target.name] gets absorbed by [H]'s [C.name]!</span>")
					return
			else
				continue //Does this thing we're shooting even exist?

		var/obj/item/organ/external/organ = H.get_bodypart(check_zone(def_zone))
		var/armorblock = H.run_armor_check(organ, "bio")
		H.apply_damage(damage, damage_type, organ, armorblock, null, src)
		H.apply_effects(stun,weaken,0,0,stutter,0,0,armorblock)
		H.flash_pain()
		to_chat(H, "<span class='warning'>You feel the acid on your skin!</span>")
		return
	..()


/obj/item/projectile/bullet/scrap //
	icon_state = "scrap_shot"
	damage = 35
	stoping_power = 8
	kill_count = 14

/obj/item/projectile/plasma
	name = "plasma"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "plasma_bolt"
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	light_color = LIGHT_COLOR_PLASMA
	light_power = 2
	light_range = 2
	damage = 18
	damage_type = BURN
	flag = "energy"
	eyeblur = 4
	sharp = 0
	edge = 0

	muzzle_type = /obj/effect/projectile/plasma/muzzle

/obj/item/projectile/plasma/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_LASERACT

/obj/item/projectile/plasma/overcharge
	icon_state = "plasma_bolt_oc"
	light_color = LIGHT_COLOR_PLASMA_OC
	damage = 25

	muzzle_type = /obj/effect/projectile/plasma/muzzle/overcharge

/obj/item/projectile/plasma/overcharge/massive
	icon_state = "plasma_massive_oc"
	light_range = 3
	damage = 110
	impact_force = 20 // massive punch
	step_delay = 3 // slow moving, provides time to dodge it.
	proj_impact_sound = 'sound/weapons/guns/plasma10_hit.ogg'

	impact_type = /obj/effect/projectile/plasma/impact/overcharge

/obj/item/projectile/pyrometer
	name = "laser"
	icon_state = "pyrometer"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSMOB

	damage = 0
	nodamage = TRUE
	fake = TRUE // This thing can't hurt, there's no reason to log it.

	kill_count = 13

	flag = "laser"
	hitscan = TRUE
	// eyeblur = 3

	tracer_list = list()

	muzzle_type = /obj/effect/projectile/pyrometer/muzzle
	tracer_type = /obj/effect/projectile/pyrometer/tracer
	impact_type = /obj/effect/projectile/pyrometer/impact

	var/display_celsium = TRUE
	var/display_fahrenheit = TRUE
	var/display_kelvin = FALSE

/obj/item/projectile/pyrometer/on_impact(atom/A)
	return

/obj/item/projectile/pyrometer/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	. = ..()
	if(!firer)
		return

	if(istype(target, /turf/space))
		return

	if(iscarbon(target) && def_zone == O_EYES)
		var/mob/living/carbon/C = target
		C.apply_effect(3, EYE_BLUR, blocked)

	var/temp = measure_temperature(target)
	if(temp == "NONE")
		return

	var/term_col = get_term_color(target, temp)
	if(!term_col)
		return

	impact_effect(effect_transform)		// generate impact effect
	if(proj_impact_sound)
		playsound(src, proj_impact_sound, VOL_EFFECTS_MASTER)

	for(var/atom/A in tracer_list)
		A.color = term_col
		A.set_light(1, 1, l_color=term_col)
		A.alpha = 128


// Return temperature if it was possible to measure,
// "NONE" otherwise.
/obj/item/projectile/pyrometer/proc/measure_temperature(atom/target)
	var/datum/gas_mixture/env = target.return_air()
	var/temp_celsium = 0.0

	if(isobj(target))
		var/obj/O = target
		temp_celsium = (env.temperature + O.get_current_temperature()) - T0C

	else if(isliving(target))
		var/mob/living/L = target
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/obj/item/organ/external/BP = H.get_bodypart(firer.zone_sel.selecting)
			if(!BP)
				return "NONE"

			temp_celsium = (H.bodytemperature - T0C) * BP.temp_coeff
		else
			temp_celsium = L.bodytemperature - T0C

	else
		temp_celsium = env.temperature - T0C

	var/obj/item/weapon/gun/energy/pyrometer/pyro = shot_from

	var/dist = get_dist(firer, target)
	var/delta = (dist - 1) * 0.05 / pyro.ML.rating

	if(delta > 1.0)
		firer.visible_message("[bicon(shot_from)]<b>[shot_from]</b> boops, \"<span class='warning'>Measurement impossible: Error too high.</span>\"")
		return "NONE"
	if(delta > 0.0)
		temp_celsium = round(rand((temp_celsium - temp_celsium * delta) * 100, (temp_celsium + temp_celsium * delta) * 100) * 0.01, 1)

	var/temp_string = "[bicon(shot_from)]<b>[shot_from]</b> beeps, \"<span class='notice'>Temperature:"
	if(display_celsium)
		temp_string += " [temp_celsium]&deg;C"
	if(display_fahrenheit)
		temp_string += " [(temp_celsium * 1.8) + 32]&deg;F"
	if(display_kelvin)
		temp_string += " [temp_celsium + T0C] K"
	temp_string += "</span>\""

	firer.visible_message(temp_string)
	return temp_celsium

/obj/item/projectile/pyrometer/proc/get_term_color(atom/target, temperature)
	return COLOR_RED

/obj/item/projectile/pyrometer/emagged
	nodamage = FALSE
	fake = FALSE

	damage = 10
	damage_type = BURN
	sharp = TRUE // concentrated burns
	flag = "laser"

/obj/item/projectile/pyrometer/emagged

/obj/item/projectile/pyrometer/emagged/measure_temperature(atom/target)
	firer.visible_message("[bicon(shot_from)]<b>[shot_from]</b> boops, \"<span class='warning'>Measurement impossible: Safety protocol violated.</span>\"")
	return PHORON_FLASHPOINT

/obj/item/projectile/pyrometer/science_phoron
	display_celsium = FALSE
	display_fahrenheit = FALSE
	display_kelvin = TRUE

/obj/item/projectile/pyrometer/science_phoron/get_term_color(atom/target, temperature)
	var/term_color
	var/temp_kelvin = temperature + T0C

	if(temp_kelvin == T20C)
		term_color = COLOR_LIME
	else
		var/h = TRANSLATE_RANGE(temp_kelvin, 0, PHORON_FLASHPOINT, 0, 360)
		var/s = 100
		var/v = 100
		if(temp_kelvin > PHORON_MINIMUM_BURN_TEMPERATURE)
			s = 255
			v = 255
		term_color = HSVtoRGB(hsv(AngleToHue(h), s, v))
	return term_color

/obj/item/projectile/pyrometer/engineering
	display_celsium = TRUE
	display_fahrenheit = FALSE
	display_kelvin = TRUE

/obj/item/projectile/pyrometer/engineering/get_term_color(atom/target, temperature)
	var/term_color
	var/temp_kelvin = temperature + T0C

	// Most machinery is at least 5 degrees hotter. If it's not - it's considered not working.
	if(temp_kelvin < T20C + 5)
		term_color = COLOR_BLUE
	// Most machinery operates at *air* + 10 degrees, if it's higher - it's borked, or emagged.
	else if(temp_kelvin > T20C + 10)
		term_color = COLOR_RED
	else
		term_color = COLOR_LIME

	return term_color

/obj/item/projectile/pyrometer/atmospherics
	display_celsium = TRUE
	display_fahrenheit = TRUE
	display_kelvin = TRUE

/obj/item/projectile/pyrometer/atmospherics/get_term_color(atom/target, temperature)
	var/term_color
	var/temp_kelvin = temperature + T0C

	var/datum/species/H = all_species[HUMAN]

	// These temperatures are from species.dm, the human cold, heat level damages as used as
	// delimeters. Since, these devices were mostly invented for and by humans.
	if(temp_kelvin < H.cold_level_3)
		term_color = COLOR_PURPLE
	else if(temp_kelvin < H.cold_level_2)
		term_color = COLOR_BLUE
	else if(temp_kelvin < H.cold_level_1)
		term_color = COLOR_CYAN
	else if(temp_kelvin < H.heat_level_1)
		term_color = COLOR_LIME
	else if(temp_kelvin < H.heat_level_2)
		term_color = COLOR_YELLOW
	else if(temp_kelvin < H.heat_level_3)
		term_color = COLOR_ORANGE
	else
		term_color = COLOR_RED

	return term_color

/obj/item/projectile/pyrometer/medical
	display_celsium = TRUE
	display_fahrenheit = TRUE
	display_kelvin = FALSE

/obj/item/projectile/pyrometer/medical/get_term_color(atom/target, temperature)
	var/term_color

	// Temperature is in celsius, temperatures here are with all regards to
	// human biology. Screw the xeno scum!
	if(temperature < 34)
		term_color = COLOR_PURPLE
	else if(temperature < 36.1)
		term_color = COLOR_BLUE
	else if(temperature < 37.1)
		term_color = COLOR_LIME
	else if(temperature < 38)
		term_color = COLOR_YELLOW
	else if(temperature < 40)
		term_color = COLOR_ORANGE
	else
		term_color = COLOR_RED

	return term_color
