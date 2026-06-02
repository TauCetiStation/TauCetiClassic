#define FOOD_METABOLISM 0.4
#define DRINK_METABOLISM 0.8
#define REAGENTS_OVERDOSE 30
#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/diet_flags = DIET_ALL
	var/custom_metabolism = REAGENTS_METABOLISM // todo: rename as reagent_metabolism
	var/taste_strength = 1 //how easy it is to taste - the more the easier
	var/taste_message = "bitterness" //life's bitter by default. Cool points for using a span class for when you're tasting <span class='userdanger'>LIQUID FUCKING DEATH</span>
	var/list/flags = list()

	var/overdose = 0 // if var/overdose = 0, reagent has no overdose
	var/overdose_dam = 1
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/color_weight = 1

	// Whether this reagent can produce an allergy.
	var/list/allergen = list(
		ALLERGY_SKIN = TRUE,
		ALLERGY_INGESTION = TRUE,
	)

	// Is used to determine which religion could find this reagent "holy".
	// "holy" means that this reagent will convert turfs into holy turfs,
	var/list/needed_aspects

	var/datum/religion/religion

	var/toxin_absorption = 0.0

	// By how much should mob's permeability be multiplied.
	var/permeability_multiplier = 1.0

/datum/reagent/proc/reaction_mob(mob/M, method=TOUCH, volume) //By default we have a chance to transfer some
	if(!isliving(M))
		return FALSE

	var/datum/reagent/self = src
	src = null //of the reagent to the mob on TOUCHING it.

	//for catching rare runtimes // hello, why is this here? ~Luduk
	if(!self.holder)
		return
	if(!self.holder.my_atom)
		return

	// If the chemicals are in a smoke cloud or a cryo cell, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl
	// hey, so how was it? did it help? ~Luduk
	if(istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
		return
	if(istype(self.holder.my_atom.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	if(method != TOUCH)
		return

	if(!M.reagents)
		return

	var/chance = 1
	var/block  = FALSE

	for(var/obj/item/clothing/C in M.get_equipped_items())
		if(C.permeability_coefficient < chance)
			chance = C.permeability_coefficient
		if(istype(C, /obj/item/clothing/suit/bio_suit))
			// bio suits are just about completely fool-proof - Doohl
			// kind of a hacky way of making bio suits more resistant to chemicals but w/e
			if(prob(75))
				block = TRUE

		if(istype(C, /obj/item/clothing/head/bio_hood))
			if(prob(75))
				block = TRUE

	if(block)
		return

	chance = self.permeability_multiplier * chance * 100

	if(!prob(chance))
		return

	if(self.allergen && self.allergen[ALLERGY_SKIN] && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.trigger_allergy(self.id, self.volume)

	M.reagents.add_reagent(self.id, self.volume * 0.5)

	return TRUE

/datum/reagent/proc/reaction_obj(obj/O, volume) //By default we transfer a small part of the reagent to the object
	src = null //if it can hold reagents. nope!
	//if(O.reagents)
	//	O.reagents.add_reagent(id,volume/3)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_REAGENT_REACTION_TURF, T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	if(!M || !holder)
		return
	//Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
	// hey, so, how is your ghost runtime doing? ~Luduk
	if(!isliving(M))
		return
	if(!on_general_digest(M)) // You can't overdose on what you can't digest
		return FALSE

	if((overdose > 0) && (volume >= overdose))//Overdosing, wooo
		M.adjustToxLoss(overdose_dam)

	if(allergen && allergen[ALLERGY_INGESTION] && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.trigger_allergy(id, custom_metabolism * H.mob_metabolism_mod.Get())
		return FALSE

	return TRUE

/datum/reagent/proc/on_move(mob/M)
	return

// This doesn't even work, start EUGH

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new()
	handle_religions()
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_update(atom/A)
	return

/datum/reagent/proc/on_general_digest(mob/living/M)
	SHOULD_CALL_PARENT(TRUE)

	// todo: legacy code, rewrite these individual handlers to allergies, general traits, and maybe (like on tg) organs with signals
	// if you want to fully disable metabolism for some species - just add them zero metabolism_mod
	switch(M.get_species())
		if(SKRELL)
			. = on_skrell_digest(M)
		if(UNATHI)
			. = on_unathi_digest(M)
		if(DIONA)
			. = on_diona_digest(M)
		if(VOX, VOX_ARMALIS)
			. = on_vox_digest(M)
		if(SERPENTID)
			. = on_serpentid_digest(M)
		else
			return TRUE
	return .

/datum/reagent/proc/on_skrell_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_unathi_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_diona_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_vox_digest(mob/living/M)
	return TRUE

// huh, serpentids can digest only one reagent
// we probably should move it somewhere else and disable species metabolism
/datum/reagent/proc/on_serpentid_digest(mob/living/M)
	return FALSE

// Handles holy reagents.
/datum/reagent/proc/handle_religions()
	if(!religion)
		return
	if(!religion.holy_reagents[name])
		return

	religion.on_holy_reagent_created(src)

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	data = null
	return ..()

/proc/pretty_string_from_reagent_list(list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/result = "| "
	for (var/datum/reagent/R in reagent_list)
		result += "[R.name], [R.volume] | "

	return result
