/****************************************************
				INTERNAL ORGANS
****************************************************/
/obj/item/organ/internal
	parent_bodypart = BP_CHEST

	// Strings.
	var/organ_tag   = null      // Unique identifier.
	var/list/organ_races =  list() // for species (human, tajaran, vox, etc.)
	var/mob/living/carbon/brain/brainmob = null // will be moved

	// Damage vars.
	var/min_bruised_damage = 10 // Damage before considered bruised
	var/damage = 0              // Amount of damage to the organ

	// Will be moved, removed or refactored.
	var/process_accuracy = 0    // Damage multiplier for organs, that have damage values.
	// 0 - normal
	// 1 - assisted
	// 2 - mechanical
	var/robotic = 0             // For being a robot

/obj/item/organ/internal/Destroy()
	if(parent)
		parent.bodypart_organs -= src
		parent = null
	if(owner)
		owner.organs -= src
		if(owner.organs_by_name[organ_tag] == src)
			owner.organs_by_name -= organ_tag
	return ..()

/obj/item/organ/internal/insert_organ(mob/living/carbon/human/H, surgically = FALSE, datum/species/S)
	..()

	owner.organs += src
	owner.organs_by_name[organ_tag] = src

	if(parent)
		parent.bodypart_organs += src

/obj/item/organ/internal/remove_organ(mob/living/carbon/human/H, surgically = FALSE, datum/species/S)

	owner.organs -= src
	owner.organs_by_name[organ_tag] = null

	if(parent)
		parent.bodypart_organs -= src
	..()



/obj/item/organ/internal/proc/rejuvenate()
	damage = 0

/obj/item/organ/internal/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/internal/proc/is_broken()
	return damage >= min_broken_damage

/obj/item/organ/internal/process()
	//Process infections

	if (robotic >= 2 || (owner.species && owner.species.flags[IS_PLANT]))	//TODO make robotic organs and bodyparts separate types instead of a flag
		germ_level = 0
		return

	if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()

		//** Handle the effects of infections
		var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")
		var/prev_organ_races = organ_races

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

		if(organ_races != prev_organ_races)
			to_chat(owner, "<span class='warning'>You feel distortion inside body...</span>")
			owner.adjustToxLoss(1.5)

			if (prob(3))	//about once every 30 seconds
				take_damage(1,silent=prob(30))

/obj/item/organ/internal/take_damage(amount, silent=0)
	if(!isnum(silent))
		return // prevent basic take_damage usage (TODO remove workaround)
	if(src.robotic == 2)
		src.damage += (amount * 0.8)
	else
		src.damage += amount

	if (!silent)
		owner.custom_pain("What a pain! My [name]!", 1)

/obj/item/organ/internal/emp_act(severity)
	switch(robotic)
		if(0)
			return
		if(1)
			switch (severity)
				if (1.0)
					take_damage(20,0)
					return
				if (2.0)
					take_damage(7,0)
					return
				if(3.0)
					take_damage(3,0)
					return
		if(2)
			switch (severity)
				if (1.0)
					take_damage(40,0)
					return
				if (2.0)
					take_damage(15,0)
					return
				if(3.0)
					take_damage(10,0)
					return

/obj/item/organ/internal/proc/mechanize() //Being used to make robutt hearts, etc
	robotic = 2

/obj/item/organ/internal/proc/mechassist() //Used to add things like pacemakers, etc
	robotic = 1
	min_bruised_damage = 15
	min_broken_damage = 35

/****************************************************
				ORGANS DEFINES
****************************************************/

/obj/item/organ/internal/heart
	name = "heart"
	organ_races = list(HUMAN, VOX, SKRELL, DIONA)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart"
	organ_tag = O_HEART
	parent_bodypart = BP_CHEST
	var/heart_status = HEART_NORMAL
	var/fibrillation_timer_id = null
	var/failing_interval = 1 MINUTE
	force = 1.0
	w_class = SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

/obj/item/organ/internal/heart/insert_organ()
	..()
	owner.metabolism_factor.AddModifier("Heart", multiple = 1.0)

/obj/item/organ/internal/heart/proc/heart_stop()
	if(!owner.reagents.has_reagent("inaprovaline") || owner.stat == DEAD)
		heart_status = HEART_FAILURE
		deltimer(fibrillation_timer_id)
		fibrillation_timer_id = null
		owner.metabolism_factor.AddModifier("Heart", multiple = 0.0)
	else
		take_damage(1, 0)
		fibrillation_timer_id = addtimer(CALLBACK(src, PROC_REF(heart_stop)), 10 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/item/organ/internal/heart/proc/heart_fibrillate()
	heart_status = HEART_FIBR
	if(HAS_TRAIT(owner, TRAIT_FAT))
		failing_interval = 30 SECONDS
	fibrillation_timer_id = addtimer(CALLBACK(src, PROC_REF(heart_stop)), failing_interval, TIMER_UNIQUE|TIMER_STOPPABLE)
	owner.metabolism_factor.AddModifier("Heart", multiple = 0.5)

/obj/item/organ/internal/heart/proc/heart_normalize()
	heart_status = HEART_NORMAL
	deltimer(fibrillation_timer_id)
	fibrillation_timer_id = null
	owner.metabolism_factor.AddModifier("Heart", multiple = 1.0)

/obj/item/organ/internal/heart/ipc
	name = "cooling pump"
	organ_races = list(IPC)
	icon_state = "prosthetic heart"

	var/pumping_rate = 5
	var/bruised_loss = 3

/obj/item/organ/internal/heart/ipc/process()
	if(owner.nutrition < 1)
		return
	if(is_broken())
		return

	var/obj/item/organ/internal/lungs/ipc/lungs = owner.organs_by_name[O_LUNGS]
	if(!istype(lungs))
		return

	var/pumping_volume = pumping_rate
	if(is_bruised())
		pumping_volume -= bruised_loss

	if(pumping_volume > 0)
		lungs.add_refrigerant(pumping_volume)

/obj/item/organ/internal/heart/vox
	name = "vox heart"
	organ_races = list(VOX)
	icon_state = "vox heart"
	parent_bodypart = BP_GROIN

/obj/item/organ/internal/lungs
	name = "lungs"
	organ_races = list(HUMAN)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "lungs"
	organ_tag = O_LUNGS
	parent_bodypart = BP_CHEST
	force = 1.0
	w_class = SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

	var/has_gills = FALSE

/obj/item/organ/internal/lungs/vox
	name = "air capillary sack"
	organ_races = list(VOX)
	icon_state = "vox lungs"
	parent_bodypart = BP_GROIN

/obj/item/organ/internal/lungs/skrell
	name = "respiration sac"
	organ_races = list(SKRELL)
	icon_state = "skrell lungs"
	has_gills = TRUE

/obj/item/organ/internal/lungs/diona
	name = "virga inopinatus"
	organ_races = list(DIONA)
	icon_state = "diona lungs"
	process_accuracy = 10

/obj/item/organ/internal/lungs/ipc
	name = "cooling element"
	organ_races = list(IPC)
	icon_state = "robotic lungs"

	var/refrigerant_max = 50
	var/refrigerant = 50
	var/refrigerant_rate = 5
	var/bruised_loss = 3

/obj/item/organ/internal/lungs/process()
	..()
	if (owner.species && owner.species.flags[NO_BREATHE])
		return
	if (germ_level > INFECTION_LEVEL_ONE)
		if(!owner.reagents.has_reagent("dextromethorphan") && prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			owner.emote("cough")
			owner.drip(10)
		if(prob(4)  && !HAS_TRAIT(owner, TRAIT_AV))
			owner.emote("gasp")
			owner.losebreath += 15

/obj/item/organ/internal/lungs/ipc/process()
	if(owner.nutrition < 1)
		return
	var/temp_gain = owner.species.synth_temp_gain

	if(refrigerant > 0 && !is_broken())
		var/refrigerant_spent = refrigerant_rate
		refrigerant -= refrigerant_rate
		if(refrigerant < 0)
			refrigerant_spent += refrigerant
			refrigerant = 0

		if(is_bruised())
			refrigerant_spent -= bruised_loss

		if(refrigerant_spent > 0)
			temp_gain -= refrigerant_spent

	if(HAS_TRAIT(owner, TRAIT_COOLED) & owner.bodytemperature > 290)
		owner.adjust_bodytemperature(-50)

	if(temp_gain > 0)
		owner.adjust_bodytemperature(temp_gain, max_temp = owner.species.synth_temp_max)

/obj/item/organ/internal/lungs/ipc/proc/add_refrigerant(volume)
	if(refrigerant < refrigerant_max)
		refrigerant += volume
		if(refrigerant > refrigerant_max)
			refrigerant = refrigerant_max

/obj/item/organ/internal/liver
	name = "liver"
	organ_races = list(HUMAN)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "liver"
	organ_tag = O_LIVER
	parent_bodypart = BP_CHEST
	process_accuracy = 10
	force = 1.0
	w_class = SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

/obj/item/organ/internal/liver/diona
	name = "chlorophyll sac"
	organ_races = list(DIONA)
	icon_state = "diona liver"

/obj/item/organ/internal/liver/vox
	name = "waste tract"
	organ_races = list(VOX)
	icon_state = "vox liver"

/obj/item/organ/internal/liver/ipc
	name = "accumulator"
	organ_races = list(IPC)
	icon_state = "robotic liver"
	var/accumulator_warning = 0

/obj/item/organ/internal/liver/ipc/set_owner(mob/living/carbon/human/H, datum/species/S)
	..()
	new/obj/item/weapon/stock_parts/cell/crap(src)
	RegisterSignal(owner, COMSIG_ATOM_ELECTROCUTE_ACT, PROC_REF(ipc_cell_explode))

/obj/item/organ/internal/liver/proc/handle_liver_infection()
	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='warning'>Your skin itches.</span>")
	if(germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, vomit))

/obj/item/organ/internal/liver/proc/handle_liver_life()
	if(owner.life_tick % process_accuracy != 0)
		return

	if(src.damage < 0)
		src.damage = 0

	//High toxins levels are dangerous
	if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
		//Healthy liver suffers on its own
		if (src.damage < min_broken_damage)
			src.damage += 0.2 * process_accuracy
		//Damaged one shares the fun
		else
			var/obj/item/organ/internal/IO = pick(owner.organs)
			if(IO)
				IO.damage += 0.2 * process_accuracy

	//Detox can heal small amounts of damage
	if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
		src.damage -= 0.2 * process_accuracy

	// Damaged liver means some chemicals are very dangerous
	if(src.damage >= src.min_bruised_damage)
		for(var/datum/reagent/R in owner.reagents.reagent_list)
			// Ethanol and all drinks are bad
			if(istype(R, /datum/reagent/consumable/ethanol))
				owner.adjustToxLoss(0.1 * process_accuracy)
			// Can't cope with toxins at all
			if(istype(R, /datum/reagent/toxin))
				owner.adjustToxLoss(0.3 * process_accuracy)

/obj/item/organ/internal/liver/process()
	..()
	handle_liver_infection()
	handle_liver_life()

/obj/item/organ/internal/liver/ipc/process()
	var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in src

	if(!C)
		if(!owner.is_bruised_organ(O_KIDNEYS) && prob(2))
			to_chat(owner, "<span class='warning bold'>%ACCUMULATOR% DAMAGED BEYOND FUNCTION. SHUTTING DOWN.</span>")
		owner.SetParalysis(2)
		owner.blurEyes(2)
		owner.silent = 2
		return
	if(damage)
		C.charge = owner.nutrition
		if(owner.nutrition > (C.maxcharge - damage * 5))
			owner.nutrition = C.maxcharge - damage * 5
	if(owner.nutrition < 1)
		owner.SetParalysis(2)
		if(accumulator_warning < world.time)
			to_chat(owner, "<span class='warning bold'>%ACCUMULATOR% LOW CHARGE. SHUTTING DOWN.</span>")
			accumulator_warning = world.time + 15 SECONDS

/obj/item/organ/internal/liver/ipc/proc/ipc_cell_explode()
	var/obj/item/weapon/stock_parts/cell/C = locate() in src
	if(!C)
		return
	var/turf/T = get_turf(owner.loc)
	if(owner.nutrition > (C.maxcharge * 1.2))
		explosion(T, 0, 1, 2)
		C.ex_act(EXPLODE_DEVASTATE)

/obj/item/organ/internal/kidneys
	name = "kidneys"
	organ_races = list(HUMAN)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "kidneys"
	organ_tag = O_KIDNEYS
	parent_bodypart = BP_CHEST
	force = 1.0
	w_class = SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

/obj/item/organ/internal/kidneys/vox
	name = "filtration bladder"
	icon_state = "vox kidneys"
	organ_races = list(VOX)

/obj/item/organ/internal/kidneys/diona
	name = "vacuole"
	icon_state = "diona kidneys"
	organ_races = list(DIONA)
	parent_bodypart = BP_GROIN

/obj/item/organ/internal/kidneys/ipc
	name = "self-diagnosis unit"
	icon_state = "prosthetic kidneys"
	organ_races = list(HUMAN, IPC)
	parent_bodypart = BP_GROIN

	var/next_warning = 0

/obj/item/organ/internal/kidneys/ipc/process()
	if(owner.nutrition < 1)
		return
	if(next_warning > world.time)
		return
	next_warning = world.time + 10 SECONDS

	var/damage_report = ""
	var/first = TRUE

	for(var/obj/item/organ/internal/IO in owner.organs)
		if(IO.is_bruised())
			if(!first)
				damage_report += "\n"
			first = FALSE
			damage_report += "<span class='warning'><b>%[uppertext(IO.name)]%</b> INJURY DETECTED. CEASE DAMAGE TO <b>%[uppertext(IO.name)]%</b>. REQUEST ASSISTANCE.</span>"

	if(damage_report != "")
		to_chat(owner, damage_report)

/obj/item/organ/internal/brain
	name = "brain"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain2"
	organ_tag = O_BRAIN
	parent_bodypart = BP_HEAD
	force = 1.0
	w_class = SIZE_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")

/obj/item/organ/internal/brain/proc/transfer_identity(mob/living/carbon/H)
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>")

/obj/item/organ/internal/brain/atom_init()
	. = ..()
	//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
	//WASSSSSUUUPPPP /N
	spawn(5)
		brainmob?.client?.screen.len = null //clear the hud

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	..()
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		to_chat(user, "You can feel the small spark of life still left in this one.")
	else
		to_chat(user, "This one seems particularly lifeless. Perhaps it will regain some of its luster later..")


/obj/item/organ/internal/brain/diona
	name = "main node nymph"
	organ_races = list(DIONA)
	icon_state = "diona brain"
	parent_bodypart = BP_CHEST

/obj/item/organ/internal/brain/ipc
	name = "positronic brain"
	organ_races = list(IPC)
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "posibrain"
	parent_bodypart = BP_CHEST

/obj/item/organ/internal/brain/abomination
	name = "deformed brain"
	parent_bodypart = BP_CHEST

/obj/item/organ/internal/eyes
	name = "eyes"
	organ_races = list(HUMAN, VOX, SKRELL, DIONA)
	icon = 'icons/obj/surgery.dmi'
	icon_state = "eyes"
	organ_tag = O_EYES
	parent_bodypart = BP_HEAD

/obj/item/organ/internal/eyes/ipc
	name = "cameras"
	organ_races = list(HUMAN, VOX, SKRELL, DIONA, IPC)
	icon_state = "biomechanical eyes"
	robotic = 2

/obj/item/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(is_bruised())
		owner.blurEyes(20)
	if(is_broken())
		owner.eye_blind = 20
