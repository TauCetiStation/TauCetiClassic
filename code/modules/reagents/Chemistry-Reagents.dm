#define SOLID 1
#define LIQUID 2
#define GAS 3
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
	var/custom_metabolism = REAGENTS_METABOLISM
	var/taste_strength = 1 //how easy it is to taste - the more the easier
	var/taste_message = "bitterness" //life's bitter by default. Cool points for using a span class for when you're tasting <span class='userdanger'>LIQUID FUCKING DEATH</span>
	var/list/restrict_species = list(IPC) // Species that simply can not digest this reagent.

	var/addiction_chance = 0
	var/addiction_stage = 1
	var/last_addiction_dose = 0
	var/overdosed = FALSE // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	//var/current_cycle = 1
	var/overdose = 0
	var/overdose_dam = 1
	//var/list/viruses = list()
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/color_weight = 1
	//var/shock_reduction = 0
	//var/heart_rate_increase = 0
	//var/heart_rate_decrease = 0
	//var/heart_rate_stop = 0

/datum/reagent/proc/reaction_mob(mob/M, method=TOUCH, volume) //By default we have a chance to transfer some
	if(!istype(M, /mob/living))
		return FALSE
	var/datum/reagent/self = src
	src = null //of the reagent to the mob on TOUCHING it.

	if(self.holder) //for catching rare runtimes
		if(!istype(self.holder.my_atom, /obj/effect/effect/smoke/chem))
			// If the chemicals are in a smoke cloud, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl
			if(method == TOUCH)
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

				chance = chance * 100

				if(prob(chance) && !block)
					if(M.reagents)
						M.reagents.add_reagent(self.id,self.volume/2)
	return TRUE

/datum/reagent/proc/reaction_obj(obj/O, volume) //By default we transfer a small part of the reagent to the object
	src = null //if it can hold reagents. nope!
	//if(O.reagents)
	//	O.reagents.add_reagent(id,volume/3)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	src = null
	return

/datum/reagent/proc/on_mob_life(mob/living/M, alien)
	if(!M || !holder)
		return
	if(!isliving(M))
		return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
	if(!check_digesting(M, alien)) // You can't overdose on what you can't digest
		return
	if((overdose > 0) && (volume >= overdose))//Overdosing, wooo
		M.adjustToxLoss(overdose_dam)
	return TRUE

/datum/reagent/proc/on_move(mob/M)
	return

// This doesn't even work, start EUGH

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_update(atom/A)
	return

/*// Called every time reagent containers process.
/datum/reagent/proc/on_tick(data)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return
*/

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M, severity)
	var/effect = rand(1, 100) - severity
	var/update_flags = STATUS_UPDATE_NONE
	if(effect <= 8)
		update_flags |= (M.adjustToxLoss(severity, FALSE) ? STATUS_UPDATE_HEALTH : STATUS_UPDATE_NONE)
	return list(effect, update_flags)

/datum/reagent/proc/overdose_start(mob/living/M)
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	if(prob(8))
		M.emote("shiver")
	if(prob(8))
		M.emote("sneeze")
	if(prob(4))
		to_chat(M, "<span class='notice'>You feel a dull headache.</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(prob(8))
		M.emote("twitch_s")
	if(prob(8))
		M.emote("shiver")
	if(prob(4))
		to_chat(M, "<span class='warning'>You begin craving [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(prob(8))
		M.emote("twitch")
	if(prob(4))
		to_chat(M, "<span class='warning'>You have the strong urge for some [name]!</span>")
	if(prob(4))
		to_chat(M, "<span class='warning'>You REALLY crave some [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage5(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(8))
		M.emote("twitch")
	if(prob(6))
		to_chat(M, "<span class='warning'>Your stomach lurches painfully!</span>")
		M.visible_message("<span class='warning'>[M] gags and retches!</span>")
		update_flags |= M.Stun(rand(2,4), FALSE)
		update_flags |= M.Weaken(rand(2,4), FALSE)
	if(prob(5))
		to_chat(M, "<span class='warning'>You feel like you can't live without [name]!</span>")
	if(prob(5))
		to_chat(M, "<span class='warning'>You would DIE for some [name] right now!</span>")
	return update_flags

/// Everything under now does. end EUGH

/datum/reagent/proc/check_digesting(mob/living/M, alien)
	if(restrict_species)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.name in restrict_species)
				return FALSE
		if(ismonkey(M))
			var/mob/living/carbon/monkey/C = M
			if(C.race in restrict_species)
				return FALSE
	var/should_general_digest = TRUE
	var/datum/species/specimen = all_species[alien]
	should_general_digest = specimen.call_digest_proc(M, src)
	if(should_general_digest)
		on_general_digest(M)
	return TRUE

/datum/reagent/proc/on_general_digest(mob/living/M)
	return

/datum/reagent/proc/on_skrell_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_unathi_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_tajaran_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_diona_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_vox_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_abductor_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_skeleton_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_shadowling_digest(mob/living/M)
	return TRUE

/datum/reagent/proc/on_golem_digest(mob/living/M)
	return TRUE

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/proc/pretty_string_from_reagent_list(list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/result = "| "
	for (var/datum/reagent/R in reagent_list)
		result += "[R.name], [R.volume] | "

	return result
