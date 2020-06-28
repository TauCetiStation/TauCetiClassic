//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	var/name = "Test Quirk"
	var/desc = "This is a test quirk."
	var/value = 0
	var/human_only = TRUE
	var/gain_text
	var/lose_text
	var/mob_trait //if applicable, apply and remove this mob trait
	var/mob/living/quirk_holder

	/// Which species can not have this quirk. Is used in subsystem/quirks to populate quirk_blacklist_species. (Unless overriden in
	/// proc/get_incompatible_species())
	var/list/incompatible_species
	// A dict of /datum/species flags of kind flag = value. Checks if those values are upheld.
	var/list/req_species_flags

/datum/quirk/New(mob/living/quirk_mob, spawn_effects)
	if(!quirk_mob || (human_only && !ishuman(quirk_mob)) || quirk_mob.has_quirk(type))
		qdel(src)
		return
	quirk_holder = quirk_mob
	SSquirks.quirk_objects += src
	if(gain_text)
		to_chat(quirk_holder, gain_text)
	quirk_holder.roundstart_quirks += src
	if(mob_trait)
		ADD_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
	START_PROCESSING(SSquirks, src)
	add()
	if(spawn_effects)
		on_spawn()
		addtimer(CALLBACK(src, .proc/post_add), 30)

/datum/quirk/Destroy()
	STOP_PROCESSING(SSquirks, src)
	remove()
	if(quirk_holder)
		if(lose_text)
			to_chat(quirk_holder, lose_text)
		quirk_holder.roundstart_quirks -= src
		if(mob_trait)
			REMOVE_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
	SSquirks.quirk_objects -= src
	return ..()

/datum/quirk/proc/get_incompatible_species()
	. = incompatible_species
	LAZYINITLIST(.)

	species_loop:
		for(var/specie_name in all_species)
			var/datum/species/S = all_species[specie_name]

			for(var/flag in req_species_flags)
				var/has_flag = !!S.flags[flag]
				if(has_flag != req_species_flags[flag])
					. |= specie_name
					continue species_loop

/datum/quirk/proc/transfer_mob(mob/living/to_mob)
	quirk_holder.roundstart_quirks -= src
	to_mob.roundstart_quirks += src
	if(mob_trait)
		REMOVE_TRAIT(quirk_holder, mob_trait, ROUNDSTART_TRAIT)
		ADD_TRAIT(to_mob, mob_trait, ROUNDSTART_TRAIT)
	quirk_holder = to_mob
	on_transfer()

/datum/quirk/proc/add() //special "on add" effects
/datum/quirk/proc/on_spawn() //these should only trigger when the character is being created for the first time, i.e. roundstart/latejoin
/datum/quirk/proc/remove() //special "on remove" effects

/datum/quirk/proc/on_process() //process() has some special checks, so this is the actual process
	STOP_PROCESSING(SSquirks, src) // no processing if nothing defined.

/datum/quirk/proc/post_add() //for text, disclaimers etc. given after you spawn in with the quirk
/datum/quirk/proc/on_transfer() //code called when the quirk is transferred to a new mob

/datum/quirk/process()
	if(QDELETED(quirk_holder))
		quirk_holder = null
		qdel(src)
		return
	if(quirk_holder.stat == DEAD || (human_only && !ishuman(quirk_holder)))
		return
	on_process()

/mob/living/proc/get_trait_string() //helper string. gets a string of all the quirks the mob has
	var/list/dat = list()
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		dat += T.name
	if(!dat.len)
		return "None"
	return dat.Join(", ")

/mob/living/proc/cleanse_trait_datums() //removes all quirk datums
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		qdel(T)

/mob/living/proc/transfer_trait_datums(mob/living/to_mob)
	for(var/V in roundstart_quirks)
		var/datum/quirk/T = V
		T.transfer_mob(to_mob)

/*

Commented version of Nearsighted to help you add your own quirks
Use this as a guideline

/datum/quirk/nearsighted
	name = "Nearsighted"
	///The trait's name

	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	///Short description, shows next to name in the trait panel

	value = -1
	///If this is above 0, it's a positive trait; if it's not, it's a negative one; if it's 0, it's a neutral

	mob_trait = TRAIT_NEARSIGHT
	///This define is in __DEFINES/traits.dm and is the actual "trait" that the game tracks
	///You'll need to use "HAS_TRAIT_FROM(src, X, sources)" checks around the code to check this; for instance, the Ageusia trait is checked in taste code
	///If you need help finding where to put it, the declaration finder on GitHub is the best way to locate it

	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"
	///These three are self-explanatory

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	H.put_in_hands(glasses)
	H.equip_to_slot(glasses, SLOT_GLASSES)
	H.regenerate_icons()

//This whole proc is called automatically
//It spawns a set of prescription glasses on the user, then attempts to put it into their hands, then attempts to make them equip it.
//This means that if they fail to equip it, they glasses spawn in their hands, and if they fail to be put into the hands, they spawn on the ground
//Hooray for fallbacks!
//If you don't need any special effects like spawning glasses, then you don't need an add()

*/
