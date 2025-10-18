/****************************************************
				INTERNAL ORGANS
****************************************************/
/obj/item/organ/internal
	parent_bodypart = BP_CHEST

	// Strings.
	var/organ_tag   = null      // Unique identifier.

	// Damage vars.
	var/min_bruised_damage = 10 // Damage before considered bruised
	var/damage = 0              // Amount of damage to the organ


	var/process_accuracy = 0

	var/tough = FALSE //can organ be easily die?
	var/list/compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL) // races with which organs are compatible
	var/requires_robotic_bodypart = FALSE
	var/sterile = FALSE
	var/durability = 1 // Damage multiplier for organs, that have damage values.
	var/can_relocate = FALSE

/obj/item/organ/internal/New(mob/living/carbon/holder)
	if(istype(holder))
		insert_organ(holder)
	..()

/obj/item/organ/internal/Destroy()
	if(parent)
		parent.bodypart_organs -= src
		parent = null
	if(owner)
		owner.organs -= src
		if(owner.organs_by_name[organ_tag] == src)
			owner.organs_by_name -= organ_tag
	return ..()

/obj/item/organ/internal/proc/die()
	if(tough)
		return
	if(is_robotic())
		return
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(owner && vital)
		owner.death()

/obj/item/organ/internal/remove(mob/living/carbon/human/M)
	owner = null

	if(M)
		M.organs -= src
		if(M.organs_by_name[organ_tag] == src)
			M.organs_by_name -= organ_tag

		if(vital)
			if(M.stat != DEAD)//safety check!
				M.death()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/parent = H.get_bodypart(check_zone(parent_bodypart))
		if(!istype(parent))
			return
		else
			parent.bodypart_organs -= src

	..()

/obj/item/organ/internal/insert_organ(mob/living/carbon/human/H, surgically = FALSE, datum/species/S)
	..()

	var/obj/item/organ/internal/replaced = H.organs_by_name[organ_tag]
	if(replaced)
		replaced.remove(H)
		qdel(replaced)


	owner.organs += src
	owner.organs_by_name[organ_tag] = src

	if(parent)
		parent.bodypart_organs += src

/obj/item/organ/internal/take_damage(amount, silent=0)
	if(durability)
		damage += (amount * durability)
	else
		damage += amount

	//only show this if the organ is not robotic
	if(owner && parent_bodypart && amount > 0)
		var/obj/item/organ/external/parent = owner.get_bodypart(parent_bodypart)
		if(parent && !silent)
			owner.custom_pain("Something inside your [parent.name] hurts a lot.", 1)
	if(damage >= max_damage)
		die()

/obj/item/organ/internal/proc/rejuvenate()
	damage = 0

/obj/item/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/internal/proc/is_broken()
	return damage >= min_broken_damage

/mob/living/carbon/human/proc/get_int_organ(typepath)
	return (locate(typepath) in organs)

/obj/item/organ/internal/process()
	//Process infections

	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	if (is_robotic() || (owner && owner.species && owner.species.flags[IS_PLANT]))	//TODO make robotic organs and bodyparts separate types instead of a flag
		germ_level = 0
		return

	if(!owner)
		if(is_preserved())
			return
		// Maybe scale it down a bit, have it REALLY kick in once past the basic infection threshold
		// Another mercy for surgeons preparing transplant organs
		germ_level++
		if(germ_level >= INFECTION_LEVEL_ONE)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			die()

	else if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

		if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
			germ_level--

		if (germ_level >= INFECTION_LEVEL_ONE/2)
			//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
			if(antibiotics < 5 && prob(round(germ_level/6)))
				germ_level++

		if (germ_level >= INFECTION_LEVEL_TWO)
			var/obj/item/organ/external/BP = owner.bodyparts_by_name[parent_bodypart]
			//spread germs
			if (antibiotics < 5 && BP.germ_level < germ_level && ( BP.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30) ))
				BP.germ_level++

			if (prob(3))	//about once every 30 seconds
				take_damage(1,silent=prob(30))
		if(germ_level >= INFECTION_LEVEL_THREE)
			die()

/obj/item/organ/internal/emp_act(severity)
	if(!is_robotic())
		return

	switch(severity)
		if(1)
			take_damage(20, 1)
		if(2)
			take_damage(7, 1)

/obj/item/organ/internal/proc/toggle_parent_bodypart(mob/living/user)
	if(!is_robotic())
		return
	if(parent_bodypart == BP_CHEST)
		parent_bodypart = BP_GROIN
		compability = list(VOX)
		to_chat(user, "<span class='notice'>You reconfigure this organ for groin placement.</span>")
	else
		parent_bodypart = BP_CHEST
		compability = list(HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)
		to_chat(user, "<span class='notice'>You reconfigure this organ for chest placement.</span>")

/obj/item/organ/internal/attackby(obj/item/I, mob/living/user, params)

	if(!is_robotic())
		return

	if(iswrenching(I) && can_relocate)
		toggle_parent_bodypart(user)

	return ..()

/obj/item/organ/internal/proc/bruise()
	damage = max(damage, min_bruised_damage)
