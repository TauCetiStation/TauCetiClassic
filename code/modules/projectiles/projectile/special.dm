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

/obj/item/projectile/ion/on_hit(atom/target, blocked = 0)
	empulse(target, 1, 1)
	return 1



/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"
	sharp = 1
	edge = 1

/obj/item/projectile/bullet/gyro/on_hit(atom/target, blocked = 0)
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


/obj/item/projectile/temp/on_hit(atom/target, blocked = 0)//These two could likely check temp protection on the mob
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

			A.meteorhit(src)
			playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

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

/obj/item/projectile/energy/floramut/on_hit(atom/target, blocked = 0)
	var/mob/living/M = target
//	if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
	if(ishuman(target))
		var/mob/living/carbon/human/H = M
		if((H.species.flags[IS_PLANT]) && (M.nutrition < 500))
			if(prob(15))
				M.apply_effect((rand(30,80)),IRRADIATE)
				M.Weaken(5)
				for (var/mob/V in viewers(src))
					V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
			if(prob(35))
			//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
			//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
				if(prob(80))
					randmutb(M)
					domutcheck(M,null)
				else
					randmutg(M)
					domutcheck(M,null)
			else
				M.adjustFireLoss(rand(5,15))
				M.show_message("\red The radiation beam singes you!")
			//	for (var/mob/V in viewers(src))
			//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
	else if(istype(target, /mob/living/carbon/))
	//	for (var/mob/V in viewers(src))
	//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
		M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
	else
		return 1



/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"

/obj/item/projectile/energy/florayield/on_hit(atom/target, blocked = 0)
	var/mob/M = target
//	if(ishuman(target) && M.dna && M.dna.mutantrace == "plant") //These rays make plantmen fat.
	if(ishuman(target)) //These rays make plantmen fat.
		var/mob/living/carbon/human/H = M
		if((H.species.flags[IS_PLANT]) && (M.nutrition < 500))
			M.nutrition += 30
	else if (istype(target, /mob/living/carbon/))
		M.show_message("\blue The radiation beam dissipates harmlessly through your body.")
	else
		return 1



/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0)
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 20



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

/obj/item/projectile/missile/on_hit(atom/target, blocked = 0)
	target.ex_act(1)
	explosion(target, 1,2,4,5)
	return 1



/obj/item/projectile/missile/emp
	damage = 10

/obj/item/projectile/missile/emp/on_hit(atom/target, blocked = 0)
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

/obj/item/projectile/acid_special/on_hit(atom/target, blocked = 0)
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
					visible_message("\red The [target.name] gets absorbed by [H]'s [C.name]!")
					return
			else
				continue //Does this thing we're shooting even exist?

		var/obj/item/organ/external/organ = H.get_bodypart(check_zone(def_zone))
		var/armorblock = H.run_armor_check(organ, "bio")
		H.apply_damage(damage, damage_type, organ, armorblock, null, src)
		H.apply_effects(stun,weaken,0,0,stutter,0,0,armorblock)
		H.flash_pain()
		to_chat(H, "\red You feel the acid on your skin!")
		return
	..()


/obj/item/projectile/bullet/scrap //
	icon_state = "scrap_shot"
	damage = 35
	stoping_power = 8
	kill_count = 14