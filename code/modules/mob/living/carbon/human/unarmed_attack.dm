var/global/list/sparring_attack_cache = list()

//Species unarmed attacks
/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/attack_noun = list("fist")
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/shredding = 0 // Calls the old attack_alien() behavior on objects/mobs when on harm intent.
	var/sharp = 0
	var/edge = 0

	var/deal_halloss
	var/sparring_variant_type = /datum/unarmed_attack/light_strike

	var/eye_attack_text
	var/eye_attack_text_victim

/datum/unarmed_attack/proc/get_sparring_variant()
	if(sparring_variant_type)
		if(!sparring_attack_cache[sparring_variant_type])
			sparring_attack_cache[sparring_variant_type] = new sparring_variant_type()
		return sparring_attack_cache[sparring_variant_type]

/datum/unarmed_attack/proc/is_usable(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)
	if(user.restrained())
		return 0

	// Check if they have a functioning hand.
	var/obj/item/bodypart/BP = user.bodyparts_by_name[BP_L_ARM]
	if(BP && !BP.is_stump())
		return 1

	BP = user.bodyparts_by_name[BP_R_ARM]
	if(BP && !BP.is_stump())
		return 1

	return 0

/datum/unarmed_attack/proc/get_unarmed_damage()
	return damage

/datum/unarmed_attack/proc/apply_effects(mob/living/carbon/human/user, mob/living/carbon/human/target, armour, attack_damage, zone)

	if(target.stat == DEAD)
		return

	var/stun_chance = rand(0, 100)

	if(attack_damage >= 5 && armour < 100 && !(target == user) && stun_chance <= attack_damage * 5) // 25% standard chance
		switch(zone) // strong punches can have effects depending on where they hit
			if(BP_HEAD, BP_EYES, BP_MOUTH)
				// Induce blurriness
				target.visible_message("<span class='danger'>[target] looks momentarily disoriented.</span>", "<span class='danger'>You see stars.</span>")
				target.apply_effect(attack_damage*2, EYE_BLUR, armour)
			if(BP_L_ARM)
				if (target.l_hand)
					// Disarm left hand
					//Urist McAssistant dropped the macguffin with a scream just sounds odd.
					target.visible_message("<span class='danger'>\The [target.l_hand] was knocked right out of [target]'s grasp!</span>")
					target.drop_l_hand()
			if(BP_R_ARM)
				if (target.r_hand)
					// Disarm right hand
					target.visible_message("<span class='danger'>\The [target.r_hand] was knocked right out of [target]'s grasp!</span>")
					target.drop_r_hand()
			if(BP_CHEST)
				if(!target.lying)
					var/turf/T = get_step(get_turf(target), get_dir(get_turf(user), get_turf(target)))
					if(!T.density)
						step(target, get_dir(get_turf(user), get_turf(target)))
						target.visible_message("<span class='danger'>[pick("[target] was sent flying backward!", "[target] staggers back from the impact!")]</span>")
					else
						target.visible_message("<span class='danger'>[target] slams into [T]!</span>")
					if(prob(50))
						target.set_dir(reverse_dir[target.dir])
					target.apply_effect(attack_damage * 0.4, WEAKEN, armour)
			if(BP_GROIN)
				target.visible_message("<span class='warning'>[target] looks like \he is in pain!</span>", "<span class='warning'>[(target.gender=="female") ? "Oh god that hurt!" : "Oh no, not your[pick("testicles", "crown jewels", "clockweights", "family jewels", "marbles", "bean bags", "teabags", "sweetmeats", "goolies")]!"]</span>")
				target.apply_effects(stutter = attack_damage * 2, agony = attack_damage* 3, blocked = armour)
			if(BP_L_LEG, BP_R_LEG)
				if(!target.lying)
					target.visible_message("<span class='warning'>[target] gives way slightly.</span>")
					target.apply_effect(attack_damage*3, HALLOSS, armour)
	else if(attack_damage >= 5 && !(target == user) && (stun_chance + attack_damage * 5 >= 100) && armour < 100) // Chance to get the usual throwdown as well (25% standard chance)
		if(!target.lying)
			target.visible_message("<span class='danger'>[target] [pick("slumps", "falls", "drops")] down to the ground!</span>")
		else
			target.visible_message("<span class='danger'>[target] has been weakened!</span>")
		target.apply_effect(3, WEAKEN, armour)

/datum/unarmed_attack/proc/show_attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone, attack_damage)
	var/obj/item/bodypart/BP = target.get_bodypart(zone)
	user.visible_message("<span class='warning'>[user] [pick(attack_verb)] [target] in the [BP.name]!</span>")
	//playsound(user.loc, attack_sound, 25, 1, -1) <- sounds double

/datum/unarmed_attack/proc/handle_eye_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	var/obj/item/organ/eyes/eyes = target.organs_by_name[BP_EYES]
	if(eyes)
		eyes.take_damage(rand(3,4), 1)
		user.visible_message("<span class='danger'>[user] presses \his [eye_attack_text] into [target]'s [eyes.name]!</span>")
		var/eye_pain = eyes.can_feel_pain()
		to_chat(target, "<span class='danger'>You experience[(eye_pain) ? "" : " immense pain as you feel" ] [eye_attack_text_victim] being pressed into your [eyes.name][(eye_pain)? "." : "!"]</span>")
		return
	user.visible_message("<span class='danger'>[user] attempts to press \his [eye_attack_text] into [target]'s eyes, but they don't have any!</span>")

/datum/unarmed_attack/proc/damage_flags()
	return (src.sharp? DAM_SHARP : 0)|(src.edge? DAM_EDGE : 0)

/datum/unarmed_attack/bite
	attack_verb = list("bit")
	attack_sound = 'sound/weapons/bite.ogg'
	shredding = 0
	damage = 0
	sharp = 0
	edge = 0

/datum/unarmed_attack/bite/is_usable(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)

	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		return 0
	for(var/obj/item/clothing/C in list(user.wear_mask, user.head, user.wear_suit))
		if(C && (C.body_parts_covered & FACE) && (C.flags & THICKMATERIAL))
			return 0 //prevent biting through a space helmet or similar
	if (user == target && (zone == BP_HEAD || zone == BP_EYES || zone == BP_MOUTH))
		return 0 //how do you bite yourself in the head?
	return 1

/datum/unarmed_attack/punch
	attack_verb = list("punched")
	attack_noun = list("fist")
	eye_attack_text = "fingers"
	eye_attack_text_victim = "digits"
	damage = 0

/datum/unarmed_attack/punch/show_attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone, attack_damage)
	var/obj/item/bodypart/BP = target.get_bodypart(zone)
	var/bodypart = BP.name

	attack_damage = Clamp(attack_damage, 1, 5) // We expect damage input of 1 to 5 for this proc. But we leave this check juuust in case.

	if(target == user)
		user.visible_message("<span class='danger'>[user] [pick(attack_verb)] \himself in the [bodypart]!</span>")
		return 0

	if(!target.lying)
		switch(zone)
			if(BP_HEAD, BP_MOUTH, BP_EYES)
				// ----- HEAD ----- //
				switch(attack_damage)
					if(1 to 2)
						user.visible_message("<span class='danger'>[user] slapped [target] across \his cheek!</span>")
					if(3 to 4)
						user.visible_message(pick(
							80; "<span class='danger'>[user] [pick(attack_verb)] [target] in the head!</span>",
							20; "<span class='danger'>[user] struck [target] in the head[pick("", " with a closed fist")]!</span>",
							50; "<span class='danger'>[user] threw a hook against [target]'s head!</span>"
							))
					if(5)
						user.visible_message(pick(
							10; "<span class='danger'>[user] gave [target] a solid slap across \his face!</span>",
							90; "<span class='danger'>[user] smashed \his [pick(attack_noun)] into [target]'s [pick("[bodypart]", "face", "jaw")]!</span>"
							))
			else
				// ----- BODY ----- //
				switch(attack_damage)
					if(1 to 2)	user.visible_message("<span class='danger'>[user] threw a glancing punch at [target]'s [bodypart]!</span>")
					if(1 to 4)	user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [target] in \his [bodypart]!</span>")
					if(5)		user.visible_message("<span class='danger'>[user] smashed \his [pick(attack_noun)] into [target]'s [bodypart]!</span>")
	else
		user.visible_message("<span class='danger'>[user] [pick("punched", "threw a punch at", "struck", "slammed their [pick(attack_noun)] into")] [target]'s [bodypart]!</span>") //why do we have a separate set of verbs for lying targets?

/datum/unarmed_attack/kick
	attack_verb = list("kicked", "kicked", "kicked", "kneed")
	attack_noun = list("kick", "kick", "kick", "knee strike")
	attack_sound = "swing_hit"
	damage = 0

/datum/unarmed_attack/kick/is_usable(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)
	if(!(zone in list(BP_L_LEG, BP_R_LEG, BP_GROIN)))
		return 0

	var/obj/item/bodypart/BP = user.bodyparts_by_name[BP_L_LEG]
	if(BP && !BP.is_stump())
		return 1

	BP = user.bodyparts_by_name[BP_R_LEG]
	if(BP && !BP.is_stump())
		return 1

	return 0

/datum/unarmed_attack/kick/get_unarmed_damage(mob/living/carbon/human/user)
	var/obj/item/clothing/shoes = user.shoes
	if(!istype(shoes))
		return damage
	return damage + (shoes ? shoes.force : 0)

/datum/unarmed_attack/kick/show_attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone, attack_damage)
	var/obj/item/bodypart/BP = target.get_bodypart(zone)
	var/organ = BP.name

	attack_damage = Clamp(attack_damage, 1, 5)

	switch(attack_damage)
		if(1 to 2)	user.visible_message("<span class='danger'>[user] threw [target] a glancing [pick(attack_noun)] to the [organ]!</span>") //it's not that they're kicking lightly, it's that the kick didn't quite connect
		if(3 to 4)	user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [target] in \his [organ]!</span>")
		if(5)		user.visible_message("<span class='danger'>[user] landed a strong [pick(attack_noun)] against [target]'s [organ]!</span>")

/datum/unarmed_attack/stomp
	attack_verb = list("stomped on")
	attack_noun = list("stomp")
	attack_sound = "swing_hit"
	damage = 0

/datum/unarmed_attack/stomp/is_usable(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)
	if(!istype(target))
		return 0

	if (!user.lying && (target.lying || (zone in list(BP_L_LEG, BP_R_LEG))))
		if(target.grabbed_by == user && target.lying)
			return 0
		var/obj/item/bodypart/BP = user.bodyparts_by_name[BP_L_LEG]
		if(BP && !BP.is_stump())
			return 1

		BP = user.bodyparts_by_name[BP_R_LEG]
		if(BP && !BP.is_stump())
			return 1

		return 0

/datum/unarmed_attack/stomp/get_unarmed_damage(mob/living/carbon/human/user)
	var/obj/item/clothing/shoes = user.shoes
	return damage + (shoes ? shoes.force : 0)

/datum/unarmed_attack/stomp/show_attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone, attack_damage)
	var/obj/item/bodypart/BP = target.get_bodypart(zone)
	var/organ = BP.name
	var/obj/item/clothing/shoes = user.shoes

	attack_damage = Clamp(attack_damage, 1, 5)

	var/shoe_text = shoes ? copytext(shoes.name, 1, -1) : "foot"
	switch(attack_damage)
		if(1 to 4)
			user.visible_message(pick(
				"<span class='danger'>[user] stomped on [target]'s [organ][pick("", "with their [shoe_text]")]!</span>",
				"<span class='danger'>[user] stomped \his [shoe_text] down onto [target]'s [organ]!</span>"))
		if(5)
			user.visible_message(pick(
				"<span class='danger'>[user] stomped down hard onto [target]'s [organ][pick("", "with their [shoe_text]")]!</span>",
				"<span class='danger'>[user] slammed \his [shoe_text] down onto [target]'s [organ]!</span>"))

/datum/unarmed_attack/light_strike
	deal_halloss = 3
	attack_noun = list("tap","light strike")
	attack_verb = list("tapped", "lightly struck")
	damage = 2
	shredding = 0
	damage = 0
	sharp = 0
	edge = 0

// ************** \\
// SPECIES ATTACK \\
/datum/unarmed_attack/bite/sharp //eye teeth
	attack_verb = list("bit", "chomped on")
	attack_sound = 'sound/weapons/bite.ogg'
	shredding = 0
	sharp = 1
	edge = 1

/datum/unarmed_attack/diona
	attack_verb = list("lashed", "bludgeoned")
	attack_noun = list("tendril")
	eye_attack_text = "a tendril"
	eye_attack_text_victim = "a tendril"

/datum/unarmed_attack/claws
	attack_verb = list("scratched", "clawed", "slashed")
	attack_noun = list("claws")
	eye_attack_text = "claws"
	eye_attack_text_victim = "sharp claws"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	sharp = 1
	edge = 1

/datum/unarmed_attack/claws/show_attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone, attack_damage)
	//var/skill = user.skills["combat"] we have no skills at this moment.
	var/obj/item/bodypart/BP = target.get_bodypart(zone)

	//if(!skill)	skill = 1
	attack_damage = Clamp(attack_damage, 1, 5)

	if(target == user)
		user.visible_message("<span class='danger'>[user] [pick(attack_verb)] \himself in the [BP.name]!</span>")
		return 0

	switch(zone)
		if(BP_HEAD, BP_MOUTH, BP_EYES)
			// ----- HEAD ----- //
			switch(attack_damage)
				if(1 to 2) user.visible_message("<span class='danger'>[user] scratched [target] across \his cheek!</span>")
				if(3 to 4)
					user.visible_message(pick(
						80; user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [target]'s [pick("face", "neck", BP.name)]!</span>"),
						20; user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [pick("[target] in the [BP.name]", "[target] across \his [pick("face", "neck", BP.name)]")]!</span>"),
						))
				if(5)
					user.visible_message(pick(
						"<span class='danger'>[user] rakes \his [pick(attack_noun)] across [target]'s [pick("face", "neck", BP.name)]!</span>",
						"<span class='danger'>[user] tears \his [pick(attack_noun)] into [target]'s [pick("face", "neck", BP.name)]!</span>",
						))
		else
			// ----- BODY ----- //
			switch(attack_damage)
				if(1 to 2)	user.visible_message("<span class='danger'>[user] [pick("scratched", "grazed")] [target]'s [BP.name]!</span>")
				if(3 to 4)
					user.visible_message(pick(
						80; user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [target]'s [BP.name]!</span>"),
						20; user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [pick("[target] in the [BP.name]", "[target] across \his [BP.name]")]!</span>"),
						))
				if(5)		user.visible_message("<span class='danger'>[user] tears \his [pick(attack_noun)] [pick("deep into", "into", "across")] [target]'s [BP.name]!</span>")

/datum/unarmed_attack/claws/strong
	attack_verb = list("slashed")
	damage = 5
	shredding = 1

/datum/unarmed_attack/bite/strong
	attack_verb = list("mauled")
	damage = 8
	shredding = 1

/datum/unarmed_attack/slime_glomp
	attack_verb = list("glomped")
	attack_noun = list("body")
	damage = 2

/datum/unarmed_attack/slime_glomp/apply_effects(mob/living/carbon/human/user, mob/living/carbon/human/target, armour, attack_damage,zone)
	..()
	//user.apply_stored_shock_to(target)
	target.electrocute_act(10, user)

/datum/unarmed_attack/stomp/weak
	attack_verb = list("jumped on")

/datum/unarmed_attack/stomp/weak/get_unarmed_damage()
	return damage

/datum/unarmed_attack/stomp/weak/show_attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone, attack_damage)
	var/obj/item/bodypart/BP = target.get_bodypart(zone)
	user.visible_message("<span class='warning'>[user] jumped up and down on \the [target]'s [BP.name]!</span>")
	//playsound(user.loc, attack_sound, 25, 1, -1)
