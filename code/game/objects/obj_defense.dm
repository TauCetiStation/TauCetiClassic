/obj/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, MELEE, 1, get_dir(src, AM))

/obj/ex_act(severity)
	if(resistance_flags & INDESTRUCTIBLE)
		return

	. = ..() //contents explosion
	if(QDELETED(src))
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)

/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	// TODO playsound(src, P.hitsound, 50, TRUE)
	var/damage
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		damage = take_damage(P.damage, P.damage_type, P.flag, 0, turn(P.dir, 180)) // TODO flag -> armor_flag
	//if(P.suppressed != SUPPRESSED_VERY)
	visible_message(span_danger("[src] is hit by \a [P][damage ? "" : ", without leaving a mark"]!"), null, null, COMBAT_MESSAGE_RANGE)

/obj/attack_hulk(mob/living/carbon/human/user)
	..()
	if(density)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
	var/damage = take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
	user.visible_message(span_danger("[user] smashes [src][damage ? "" : ", without leaving a mark"]!"), span_danger("You smash [src][damage ? "" : ", without leaving a mark"]!"), null, COMBAT_MESSAGE_RANGE)
	return TRUE

/obj/blob_act(obj/effect/blob/B) // TODO blob to structure
	if (!..())
		return
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(attack_generic(user, 60, BRUTE, MELEE, 0))
		playsound(src.loc, 'sound/weapons/slash.ogg', 100, TRUE)

/obj/attack_animal(mob/living/simple_animal/user)
	if(!user.melee_damage) // TODO obj damage
		user.emote("custom", message = "[user.friendly] [src].")
		return FALSE

	var/play_soundeffect = TRUE
	if(user.environment_smash)
		play_soundeffect = FALSE
	//if(user.obj_damage)
	//	. = attack_generic(user, user.obj_damage, user.melee_damtype, MELEE, play_soundeffect)
	//else
	. = attack_generic(user, user.melee_damage, user.melee_damtype, MELEE, play_soundeffect)
	if(. && !play_soundeffect)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	if(user.client)
		log_combat(user, "[user] attacked [src]")

/obj/attack_slime(mob/living/simple_animal/slime/user)
	if(!isslimeadult(user))
		return
	if(attack_generic(user, rand(10, 15), BRUTE, MELEE, 1))
		log_combat(user, "[user] attacked [src]")

/obj/singularity_act()
	ex_act(EXPLODE_DEVASTATE)
	if(!QDELETED(src))
		qdel(src)
	return 2

//// FIRE

///Called when the obj is exposed to fire.
/obj/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature && !(resistance_flags & FIRE_PROOF)) // TODO resistance flags
		take_damage(clamp(0.02 * exposed_temperature, 0, 20), BURN, FIRE, 0)
	return ..()

///called when the obj is destroyed by fire
/obj/proc/burn()
	deconstruct(FALSE)

///Called when the obj is hit by a tesla bolt.
/obj/proc/tesla_act(power)
	if(QDELETED(src))
		return 0
	being_shocked = TRUE
	var/power_bounced = power / 2
	tesla_zap(src, 3, power_bounced)
	VARSET_IN(src, being_shocked, FALSE, 10)

///the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	qdel(src)

///what happens when the obj's integrity reaches zero.
/obj/atom_destruction(damage_flag)
	. = ..()
	if(damage_flag == FIRE)
		burn()
	else
		deconstruct(FALSE)

