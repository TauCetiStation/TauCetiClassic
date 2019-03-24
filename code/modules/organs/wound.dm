
/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	var/current_stage = 0      // number representing the current stage
	var/desc = "wound"         // description of the wound. default in case something borks
	var/damage = 0             // amount of damage this wound causes
	var/bleed_timer = 0        // ticks of bleeding left.
	var/bleed_threshold = 30   // Above this amount wounds you will need to treat the wound to stop bleeding, regardless of bleed_timer
	var/min_damage = 0         // amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/bandaged = FALSE       // is the wound bandaged?
	var/clamped = FALSE        // Similar to bandaged, but works differently
	var/salved = FALSE         // is the wound salved?
	var/disinfected = FALSE    // is the wound disinfected?
	var/created = 0
	var/amount = 1             // number of wounds of this type
	var/germ_level = 0         // amount of germs in the wound

	/*  These are defined by the wound type and should not be changed */
	var/list/stages            // stages such as "cut", "deep cut", etc.
	var/max_bleeding_stage = 0 // maximum stage at which bleeding should still happen. Beyond this stage bleeding is prevented.
	var/damage_type = CUT      // one of CUT, PIERCE, BRUISE, BURN
	var/autoheal_cutoff = 15   // the maximum amount of damage that this wound can have and still autoheal

	// helper lists
	var/tmp/list/embedded_objects = list()
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()

/datum/wound/New(init_damage)

	created = world.time

	// reading from a list("stage" = damage) is pretty difficult, so build two separate
	// lists from them instead
	for(var/V in stages)
		desc_list += V
		damage_list += stages[V]

	damage = init_damage

	// initialize with the appropriate stage
	init_stage(damage)

	bleed_timer += damage

/datum/wound/proc/init_stage(initial_damage)
	current_stage = stages.len

	while(current_stage > 1 && damage_list[current_stage-1] <= initial_damage / amount)
		current_stage--

	min_damage = damage_list[current_stage]
	desc = desc_list[current_stage]

// the amount of damage per wound
/datum/wound/proc/wound_damage()
	return damage / amount

/datum/wound/proc/can_autoheal()
	for(var/obj/item/thing in embedded_objects)
		if(thing.w_class > ITEM_SIZE_SMALL)
			return FALSE
	return (wound_damage() <= autoheal_cutoff) ? 1 : is_treated()

// checks whether the wound has been appropriately treated
/datum/wound/proc/is_treated()
	if(!embedded_objects.len)
		switch(damage_type)
			if(BRUISE, CUT, PIERCE)
				return bandaged
			if(BURN)
				return salved

// Checks whether other other can be merged into src.
/datum/wound/proc/can_merge(datum/wound/W)
	if (W.type != type)
		return FALSE

	if (W.current_stage != current_stage)
		return FALSE

	if (W.damage_type != damage_type)
		return FALSE

	if (!(W.can_autoheal()) != !(can_autoheal()))
		return FALSE

	if (!(W.bandaged) != !(bandaged))
		return FALSE

	if (!(W.clamped) != !(clamped))
		return FALSE

	if (!(W.salved) != !(salved))
		return FALSE

	if (!(W.disinfected) != !(disinfected))
		return FALSE

	return TRUE

/datum/wound/proc/merge_wound(datum/wound/W)
	embedded_objects |= W.embedded_objects
	damage += W.damage
	amount += W.amount
	bleed_timer += W.bleed_timer
	germ_level = max(germ_level, W.germ_level)
	created = max(created, W.created) // take the newer created time

// checks if wound is considered open for external infections
// untreated cuts (and bleeding bruises) and burns are possibly infectable, chance higher if wound is bigger
/datum/wound/proc/infection_check()
	if (damage < 10) // small cuts, tiny bruises, and moderate burns shouldn't be infectable.
		return FALSE
	if (is_treated() && damage < 25) // anything less than a flesh wound (or equivalent) isn't infectable if treated properly
		return FALSE
	if (disinfected)
		germ_level = 0 // reset this, just in case
		return FALSE

	if (damage_type == BRUISE && !bleeding()) // bruises only infectable if bleeding
		return FALSE

	var/dam_coef = round(damage / 10)
	switch(damage_type)
		if(BRUISE)
			return prob(dam_coef * 5)
		if(BURN)
			return prob(dam_coef * 10)
		if(CUT)
			return prob(dam_coef * 20)

	return FALSE

/datum/wound/proc/bandage()
	bandaged = TRUE

/datum/wound/proc/salve()
	salved = TRUE

/datum/wound/proc/disinfect()
	disinfected = TRUE

// heal the given amount of damage, and if the given amount of damage was more
// than what needed to be healed, return how much heal was left
/datum/wound/proc/heal_damage(amount)
	if(embedded_objects.len)
		return amount // heal nothing

	var/healed_damage = min(damage, amount)
	amount -= healed_damage
	damage -= healed_damage

	while(wound_damage() < damage_list[current_stage] && current_stage < desc_list.len)
		current_stage++
	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

	// return amount of healing still leftover, can be used for other wounds
	return amount

// opens the wound again
/datum/wound/proc/open_wound(damage)
	src.damage += damage
	bleed_timer += damage

	while(current_stage > 1 && damage_list[current_stage - 1] <= src.damage / amount)
		current_stage--

	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

// returns whether this wound can absorb the given amount of damage.
// this will prevent large amounts of damage being trapped in less severe wound types
/datum/wound/proc/can_worsen(damage_type, damage)
	if (src.damage_type != damage_type)
		return FALSE // incompatible damage types

	if (src.amount > 1)
		return FALSE

	//with 1.5*, a shallow cut will be able to carry at most 30 damage,
	//37.5 for a deep cut
	//52.5 for a flesh wound, etc.
	var/max_wound_damage = 1.5 * damage_list[1]
	if (src.damage + damage > max_wound_damage)
		return FALSE

	return TRUE

/datum/wound/proc/bleeding()
	if(bandaged || clamped)
		return FALSE

	if(embedded_objects.len)
		for(var/obj/item/thing in embedded_objects)
			if(thing.w_class > ITEM_SIZE_SMALL)
				return FALSE

	return bleed_timer > 0 || wound_damage() > bleed_threshold

/** WOUND DEFINITIONS **/

//Note that the MINIMUM damage before a wound can be applied should correspond to
//the damage amount for the stage with the same name as the wound.
//e.g. /datum/wound/cut/deep should only be applied for 15 damage and up,
//because in it's stages list, "deep cut" = 15.
/proc/get_wound_type(type = CUT, damage)
	switch(type)
		if(CUT)
			switch(damage)
				if(70 to INFINITY)
					return /datum/wound/cut/massive
				if(60 to 70)
					return /datum/wound/cut/gaping_big
				if(50 to 60)
					return /datum/wound/cut/gaping
				if(25 to 50)
					return /datum/wound/cut/flesh
				if(15 to 25)
					return /datum/wound/cut/deep
				if(0 to 15)
					return /datum/wound/cut/small
		if(PIERCE)
			switch(damage)
				if(60 to INFINITY)
					return /datum/wound/puncture/massive
				if(50 to 60)
					return /datum/wound/puncture/gaping_big
				if(30 to 50)
					return /datum/wound/puncture/gaping
				if(15 to 30)
					return /datum/wound/puncture/flesh
				if(0 to 15)
					return /datum/wound/puncture/small
		if(BRUISE)
			return /datum/wound/bruise
		if(BURN, LASER)
			switch(damage)
				if(50 to INFINITY)
					return /datum/wound/burn/carbonised
				if(40 to 50)
					return /datum/wound/burn/deep
				if(30 to 40)
					return /datum/wound/burn/severe
				if(15 to 30)
					return /datum/wound/burn/large
				if(0 to 15)
					return /datum/wound/burn/moderate
	return null //no wound

/** CUTS **/
/datum/wound/cut
	bleed_threshold = 5
	damage_type = CUT

/datum/wound/cut/small
	// link wound descriptions to amounts of damage
	// Minor cuts have max_bleeding_stage set to the stage that bears the wound type's name.
	// The major cut types have the max_bleeding_stage set to the clot stage (which is accordingly given the "blood soaked" descriptor).
	max_bleeding_stage = 3
	stages = list(
		"ugly ripped cut" = 20,
		"ripped cut" = 10,
		"cut" = 5,
		"healing cut" = 2,
		"small scab" = 0
		)

/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list(
		"ugly deep ripped cut" = 25,
		"deep ripped cut" = 20,
		"deep cut" = 15,
		"clotted cut" = 8,
		"scab" = 2,
		"fresh skin" = 0
		)

/datum/wound/cut/flesh
	max_bleeding_stage = 4
	stages = list(
		"ugly ripped flesh wound" = 35,
		"ugly flesh wound" = 30,
		"flesh wound" = 25,
		"blood soaked clot" = 15,
		"large scab" = 5,
		"fresh skin" = 0
		)

/datum/wound/cut/gaping
	max_bleeding_stage = 3
	stages = list(
		"gaping wound" = 50,
		"large blood soaked clot" = 25,
		"large clot" = 15,
		"small angry scar" = 5,
		"small straight scar" = 0
		)

/datum/wound/cut/gaping_big
	max_bleeding_stage = 3
	stages = list(
		"big gaping wound" = 60,
		"healing gaping wound" = 40,
		"large blood soaked clot" = 25,
		"large angry scar" = 10,
		"large straight scar" = 0
		)

/datum/wound/cut/massive
	max_bleeding_stage = 3
	stages = list(
		"massive wound" = 70,
		"massive healing wound" = 50,
		"massive angry scar" = 10,
		"massive jagged scar" = 0
		)

/** PUNCTURES **/
/datum/wound/puncture
	bleed_threshold = 10
	damage_type = PIERCE

/datum/wound/puncture/can_worsen(damage_type, damage)
	return FALSE // puncture wounds cannot be enlargened

/datum/wound/puncture/small
	max_bleeding_stage = 2
	stages = list(
		"puncture" = 5,
		"healing puncture" = 2,
		"small scab" = 0
		)

/datum/wound/puncture/flesh
	max_bleeding_stage = 2
	stages = list(
		"puncture wound" = 15,
		"blood soaked clot" = 5,
		"large scab" = 2,
		"small round scar" = 0
		)

/datum/wound/puncture/gaping
	max_bleeding_stage = 3
	stages = list(
		"gaping hole" = 30,
		"large blood soaked clot" = 15,
		"blood soaked clot" = 10,
		"small angry scar" = 5,
		"small round scar" = 0
		)

/datum/wound/puncture/gaping_big
	max_bleeding_stage = 3
	stages = list(
		"big gaping hole" = 50,
		"healing gaping hole" = 20,
		"large blood soaked clot" = 15,
		"large angry scar" = 10,
		"large round scar" = 0
		)

/datum/wound/puncture/massive
	max_bleeding_stage = 3
	stages = list(
		"massive wound" = 60,
		"massive healing wound" = 30,
		"massive blood soaked clot" = 25,
		"massive angry scar" = 10,
		"massive jagged scar" = 0
		)

/** BRUISES **/
/datum/wound/bruise
	stages = list(
		"monumental bruise" = 80,
		"huge bruise" = 50,
		"large bruise" = 30,
		"moderate bruise" = 20,
		"small bruise" = 10,
		"tiny bruise" = 5
		)

	bleed_threshold = 20
	max_bleeding_stage = 3
	autoheal_cutoff = 30
	damage_type = BRUISE

/** BURNS **/
/datum/wound/burn
	damage_type = BURN
	max_bleeding_stage = 0

/datum/wound/burn/bleeding()
	return FALSE

/datum/wound/burn/moderate
	stages = list(
		"ripped burn" = 10,
		"moderate burn" = 5,
		"healing moderate burn" = 2,
		"fresh skin" = 0
		)

/datum/wound/burn/large
	stages = list(
		"ripped large burn" = 20,
		"large burn" = 15,
		"healing large burn" = 5,
		"fresh skin" = 0
		)

/datum/wound/burn/severe
	stages = list(
		"ripped severe burn" = 35,
		"severe burn" = 30,
		"healing severe burn" = 10,
		"burn scar" = 0
		)

/datum/wound/burn/deep
	stages = list(
		"ripped deep burn" = 45,
		"deep burn" = 40,
		"healing deep burn" = 15,
		"large burn scar" = 0
		)

/datum/wound/burn/carbonised
	stages = list(
		"carbonised area" = 50,
		"healing carbonised area" = 20,
		"massive burn scar" = 0
		)
