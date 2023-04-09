/obj/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	if(!(resistance_flags & CAN_BE_HIT))
		return
	var/throwdamage
	if(isobj(AM))
		var/obj/O = AM
		throwdamage = O.throwforce
	else if(ismob(AM)) // TODO add throwforce to atom movable
		throwdamage = 10
	//Let everyone know we've been hit!
	visible_message(
		"<span class='warning'>[src] was hit by [AM].</span>",
		viewing_distance = COMBAT_MESSAGE_RANGE
	)
	if(!throwdamage)
		return
	take_damage(throwdamage, BRUTE, MELEE, 1, get_dir(src, AM))

/obj/ex_act(severity)
	if(resistance_flags & INDESTRUCTIBLE)
		return
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
	if(QDELING(src)) //Bullet on_hit effect might have already destroyed this object
		return
	// TODO playsound(src, P.hitsound, VOL_EFFECTS_MASTER, 50, TRUE)
	var/damage = take_damage(P.damage, P.damage_type, P.flag, TRUE, turn(P.dir, 180)) // TODO flag -> armor_flag
	visible_message(
		"<span class='danger'>[src] is hit by \a [P][damage ? "" : ", without leaving a mark"]!</span>",
		viewing_distance = COMBAT_MESSAGE_RANGE
	)

/obj/attack_hulk(mob/living/user)
	..()
	if(user.a_intent != INTENT_HARM)
		return FALSE
	if(density)
		playsound(loc, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	else
		playsound(loc, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
	var/damage = take_damage(hulk_damage(), BRUTE, MELEE, 0, get_dir(src, user))
	user.visible_message(
		"<span class='danger'>[user] smashes [src][damage ? "" : ", without leaving a mark"]!</span>",
		"<span class='danger'>You smash [src][damage ? "" : ", without leaving a mark"]!</span>",
		viewing_distance = COMBAT_MESSAGE_RANGE
	)
	return TRUE

/obj/blob_act(obj/structure/blob/B)
	take_damage(400, BRUTE, MELEE, 0, get_dir(src, B))

/obj/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	if(!istype(user) || user.a_intent != INTENT_HARM)
		return ..()
	if(attack_generic(user, 25, BRUTE, MELEE, 0))
		playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/attack_animal(mob/living/simple_animal/user)
	if(!user.melee_damage) // TODO obj damage
		user.me_emote("[user.friendly] [src].")
		return FALSE

	var/play_soundeffect = TRUE
	var/damage = user.melee_damage
	if(user.environment_smash)
		play_soundeffect = FALSE
		damage *= 10
	. = attack_generic(user, damage, user.melee_damtype, MELEE, play_soundeffect)
	if(. && !play_soundeffect)
		playsound(loc, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/attack_slime(mob/living/simple_animal/slime/user)
	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15), BRUTE, MELEE, TRUE)

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
	VARSET_IN(src, being_shocked, FALSE, 1 SECOND)

///the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	qdel(src)

///what happens when the obj's integrity reaches zero.
/obj/atom_destruction(damage_flag)
	. = ..()
	switch(damage_flag)
		//if(ACID) TODO ACID SS
		if(FIRE)
			burn()
		else
			deconstruct(FALSE)

