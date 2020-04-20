/mob/living/carbon/human/var/list/obj/item/organ/external/bodyparts = list()
/mob/living/carbon/human/var/list/obj/item/organ/external/bodyparts_by_name = list()
/mob/living/carbon/human/var/list/obj/item/organ/internal/organs = list()
/mob/living/carbon/human/var/list/obj/item/organ/internal/organs_by_name = list()

/obj/item/organ
	name = "organ"
	germ_level = 0

	// Strings.
	var/parent_bodypart                // Bodypart holding this object.

	// Status tracking.
	var/status = 0                     // Various status flags (such as robotic)
	var/vital                          // Lose a vital organ, die immediately.

	// Reference data.
	var/mob/living/carbon/human/owner  // Current mob owning the organ.
	var/list/autopsy_data = list()     // Trauma data for forensics.
	var/list/trace_chemicals = list()  // Traces of chemicals in the organ.
	var/obj/item/organ/external/parent // Master-limb.

	// Damage vars.
	var/min_broken_damage = 30         // Damage before becoming broken

/obj/item/organ/atom_init(mapload, mob/living/carbon/human/H)
	if(istype(H))
		insert_organ(H)

	return ..()

/obj/item/organ/proc/insert_organ(mob/living/carbon/human/H, surgically = FALSE)
	STOP_PROCESSING(SSobj, src)

	loc = null
	owner = H

	if(parent_bodypart)
		parent = owner.bodyparts_by_name[parent_bodypart]

/obj/item/organ/process()
	return 0

/obj/item/organ/proc/receive_chem(chemical)
	return 0

/obj/item/organ/proc/get_icon(icon/race_icon, icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")

//Germs
/obj/item/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

/obj/item/organ/proc/is_preserved()
	if(istype(loc,/obj/item/organ))
		var/obj/item/organ/O = loc
		return O.is_preserved()
	else
		return (istype(loc,/obj/structure/closet/secure_closet/freezer) || istype(loc,/obj/structure/closet/crate/freezer))

/obj/item/organ/examine(mob/user)
	. = ..(user)
	show_decay_status(user)

/obj/item/organ/proc/show_decay_status(mob/user)
	if(status & ORGAN_DEAD)
		to_chat(user, "<span class='notice'>The decay has set into \the [src].</span>")

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random bodyparts.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/obj/item/organ/external/BP = pick(bodyparts)
		BP.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon. Use type damage: brute, burn, mixed, bruise (weak punch, e.g. fist punch)
/obj/item/organ/proc/add_autopsy_data(used_weapon, damage, type_damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon + worldtime2text()]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon + worldtime2text()] = W

	var/time = W.time_inflicted
	if(time != worldtime2text())
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon + worldtime2text()] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = worldtime2text()
	W.type_damage = type_damage

// Takes care of bodypart and their organs related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_bodyparts()
	number_wounds = 0
	var/force_process = 0
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick
	if(force_process)
		bad_bodyparts.Cut()
		for(var/obj/item/organ/external/BP in bodyparts)
			bad_bodyparts += BP

	//processing organs is pretty cheap, do that first.
	for(var/obj/item/organ/internal/IO in organs)
		IO.process()

	handle_stance()

	if(!force_process && !bad_bodyparts.len)
		return

	for(var/obj/item/organ/external/BP in bad_bodyparts)
		if(!BP || QDELETED(BP))
			bad_bodyparts -= BP
			continue
		if(!BP.need_process())
			bad_bodyparts -= BP
			continue
		else
			BP.process()
			number_wounds += BP.number_wounds

			if (!lying && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if (BP.is_broken() && BP.bodypart_organs.len && prob(15))
					var/obj/item/organ/internal/IO = pick(BP.bodypart_organs)
					custom_pain("You feel broken bones moving in your [BP.name]!", 1)
					IO.take_damage(rand(3, 5))

				//Moving makes open wounds get infected much faster
				if (BP.wounds.len)
					for(var/datum/wound/W in BP.wounds)
						if (W.infection_check())
							W.germ_level += 1

/mob/living/carbon/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if(!stance_damage && (lying || resting) && (life_tick % 4) != 0)
		return

	stance_damage = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	if(istype(buckled, /obj/structure/stool))
		return

	for(var/limb_tag in list(BP_L_LEG, BP_R_LEG))
		var/obj/item/organ/external/E = bodyparts_by_name[limb_tag]
		if(!E || !E.is_usable())
			stance_damage += 2 // let it fail even if just foot&leg
		else if(E.is_malfunctioning())
			//malfunctioning only happens intermittently so treat it as a missing limb when it procs
			stance_damage += 2
			if(prob(10))
				visible_message("\The [src]'s [E.name] [pick("twitches", "shudders")] and sparks!")
				var/datum/effect/effect/system/spark_spread/spark_system = new ()
				spark_system.set_up(5, 0, src)
				spark_system.attach(src)
				spark_system.start()
				spawn(10)
					qdel(spark_system)
		else if(E.is_broken())
			if(!(E.status & ORGAN_SPLINTED))
				stance_damage += 1
			else
				stance_damage += 0.5

	// Canes and crutches help you stand (if the latter is ever added)
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs, canes aren't gonna help you.
	if (l_hand && istype(l_hand, /obj/item/weapon/cane))
		stance_damage -= 2
	if (r_hand && istype(r_hand, /obj/item/weapon/cane))
		stance_damage -= 2

	// standing is poor
	if(stance_damage >= 4 || (stance_damage >= 2 && prob(5)))
		if(iszombie(src)) //zombies crawl when they can't stand
			if(!crawling && !lying && !resting)
				if(crawl_can_use())
					crawl()
				else
					emote("collapse")
					Weaken(5)

			var/has_arm = FALSE
			for(var/limb_tag in list(BP_L_ARM, BP_R_ARM))
				var/obj/item/organ/external/E = bodyparts_by_name[limb_tag]
				if(E && E.is_usable())
					has_arm = TRUE
					break
			if(!has_arm) //need atleast one hand to crawl
				Weaken(5)
			return

		if(!(lying || resting))
			if(species && !species.flags[NO_PAIN])
				var/turf/T = get_turf(src)
				var/do_we_scream = 1
				for(var/obj/O in T.contents)
					if(!(istype(O, /obj/structure/stool/bed/chair)))
						do_we_scream = 0
				if(do_we_scream)
					emote("scream")
			emote("collapse")
		Weaken(5) //can't emote while weakened, apparently.
