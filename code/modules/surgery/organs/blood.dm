/****************************************************
                BLOOD SYSTEM
****************************************************/
// Blood levels
var/global/const/BLOOD_VOLUME_MAXIMUM = 600
var/global/const/BLOOD_VOLUME_NORMAL = 560
var/global/const/BLOOD_VOLUME_SAFE = 501
var/global/const/BLOOD_VOLUME_OKAY = 336
var/global/const/BLOOD_VOLUME_BAD = 224
var/global/const/BLOOD_VOLUME_SURVIVE = 122


/mob/living/carbon/human
	var/datum/reagents/vessel // Container for blood and BLOOD ONLY. Do not transfer other chems here.
	var/pale = FALSE


// Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()
	if(vessel)
		return

	vessel = new/datum/reagents(BLOOD_VOLUME_MAXIMUM)
	vessel.my_atom = src

	blood_add(BLOOD_VOLUME_NORMAL)
	addtimer(CALLBACK(src, PROC_REF(fixblood)), 1)

// Resets blood data
/mob/living/carbon/human/proc/fixblood(clean = TRUE)
	var/datum/reagent/blood/B = blood_get()
	if(istype(B))
		if(clean)
			B.data = list("donor" = REF(src), "blood_DNA" = dna.unique_enzymes,
						"blood_type" = dna.b_type, "trace_chem" = null,
						"virus2" = null, "antibodies" = null, "changeling_marker" = null)
		else // Change DNA to ours, left the rest intact
			B.data["donor"] = REF(src)
			B.data["blood_DNA"] = dna.unique_enzymes
			B.data["blood_type"] = dna.b_type

// currently take_blood ingores blood reagent and creates new blood from air so this is useless
// commented and preserved in case of future changeling mechanics or blood refactor
// but you need to update "timelimit" somewhere after death
// (and also you maybe need to write some reaction between different blood reagents)
//		if(mind)
//			var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
//			if(C)
//				B.data["changeling_marker"] = list("id" = C.unique_changeling_marker, "timelimit" = FALSE)

/mob/living/carbon/human/proc/blood_amount(exact = FALSE)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return 0

	var/volume = vessel.get_reagent_amount("blood")
	if(!exact)
		return round(volume)

	return volume

/mob/living/carbon/human/proc/blood_add(amount, list/add_data = null)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	if(amount < 0)
		return FALSE

	var/new_blood = !vessel.has_reagent("blood")

	. = vessel.add_reagent("blood", amount, data = add_data, safety = TRUE) // No reactions with single reagent

	if(new_blood) // There was no blood in vessels
		fixblood(add_data == null)

/mob/living/carbon/human/proc/blood_remove(amount)
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		return FALSE
	if(amount < 0)
		return FALSE

	return vessel.remove_reagent("blood", amount, safety = TRUE) // No reactions with single reagent

/mob/living/carbon/human/proc/blood_get()
	return vessel.get_reagent(/datum/reagent/blood)

/mob/living/carbon/human/proc/blood_trans_to(obj/target, amount = 1)
	return vessel.trans_to(target, amount)

// Makes a blood drop, leaking certain amount of blood from the mob
/mob/living/carbon/human/proc/drip(amt, tar = src, ddir)
	if(reagents.has_reagent("metatrombine"))
		return

	if(organs_by_name[O_HEART] && blood_remove(amt))
		blood_splatter(tar, src, (ddir && ddir > 0), spray_dir = ddir, basedatum = get_blood_datum())

/proc/blood_splatter(target, datum/reagent/blood/source, large, spray_dir, basedatum)
	var/obj/effect/decal/cleanable/blood/B
	var/decal_type = /obj/effect/decal/cleanable/blood/splatter
	var/turf/T = get_turf(target)

	if(ishuman(source))
		var/mob/living/carbon/human/M = source
		source = M.blood_get()

	// Are we dripping or splattering?
	var/list/drips = list()
	// Only a certain number of drips (or one large splatter) can be on a given turf.
	for(var/obj/effect/decal/cleanable/blood/drip/drop in T)
		drips |= drop.drips
		qdel(drop)
	if(!large && drips.len < 3)
		decal_type = /obj/effect/decal/cleanable/blood/drip

	// Find a blood decal or create a new one.
	B = locate(decal_type) in T
	if(!B)
		B = new decal_type(T)

	var/obj/effect/decal/cleanable/blood/drip/drop = B
	if(istype(drop) && drips && drips.len && !large)
		drop.overlays |= drips
		drop.drips |= drips

	// If there's no data to copy, call it quits here.
	if(!istype(source))
		return B

	// Update appearance.
	B.basedatum = new(basedatum) // source.data["blood_colour"] <- leaving this pointer, could be important for later.
	B.update_icon()
	if(spray_dir)
		B.icon_state = "squirt"
		B.set_dir(spray_dir)

	// Update blood information.
	if(source.data["blood_DNA"])
		B.blood_DNA = list()
		if(source.data["blood_type"])
			B.blood_DNA[source.data["blood_DNA"]] = source.data["blood_type"]
		else
			B.blood_DNA[source.data["blood_DNA"]] = "O+"

	// Update virus information.
	if(source.data["virus2"])
		B.virus2 = virus_copylist(source.data["virus2"])

	//B.fluorescent = 0
	B.invisibility = 0
	return B

#define BLOOD_SPRAY_DISTANCE 2
/mob/living/carbon/human/proc/blood_squirt(amt, turf/sprayloc)
	set waitfor = FALSE

	if(reagents.has_reagent("metatrombine"))
		return
	if(amt <= 0 || !istype(sprayloc))
		return

	var/spraydir = pick(alldirs)
	amt = CEIL(amt / BLOOD_SPRAY_DISTANCE)
	var/bled = 0

	var/turf/old_sprayloc = sprayloc
	for(var/i = 1 to BLOOD_SPRAY_DISTANCE)
		sprayloc = get_step(sprayloc, spraydir)
		if(!istype(sprayloc) || sprayloc.density)
			break
		var/hit_mob
		var/CantPass
		for(var/thing in sprayloc)
			var/atom/A = thing
			if(!A.simulated)
				continue

			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(!H.lying)
					H.bloody_body(src)
					H.bloody_hands(src)
					var/blinding = FALSE
					if(ran_zone() == BP_HEAD)
						blinding = TRUE
						for(var/obj/item/I in list(H.head, H.glasses, H.wear_mask))
							if(I && (I.body_parts_covered & EYES))
								blinding = FALSE
								break
					if(blinding)
						H.blurEyes(10)
						H.eye_blind = max(H.eye_blind, 5)
						to_chat(H, "<span class='danger'>You are blinded by a spray of blood!</span>")
					else
						to_chat(H, "<span class='danger'>You are hit by a spray of blood!</span>")
					hit_mob = TRUE

			if(hit_mob || !A.CanPass(src, sprayloc))
				CantPass = TRUE // this is mostly for DOORS, because Adjacent() test thinks they are passable, which is actually true for click purpose... ~ZVe (I really HATE pass checks in ss13 or missing something...)
				break

		if(CantPass || !old_sprayloc.Adjacent(sprayloc, src)) // so we don't spray blood thru windows or something similar, because CanPass() above fails with that task and i don't know why.
			drip(amt, old_sprayloc) // current realization removes old one which looks awful, so lets drop normal drips instead (that doesn't fully fix this issue, but sometimes looks right).
			sprayloc = old_sprayloc // pass check failed, need to reset current spray loc to a previous state and try again (because we want to spray all blood that for() is going to squirt anyway).
		else
			drip(amt, sprayloc, spraydir)
		bled += amt
		if(hit_mob) // came from bay12 and i'l leave that "as is" for now. (this is actually makes us loose less blood than we should because of earlier break that could happen)
			break
		old_sprayloc = sprayloc // this is on purpose, we don't care about pass check and its result, just need to save our previous location, before sprayloc gets new ref with get_step().
		sleep(1)
	return bled
#undef BLOOD_SPRAY_DISTANCE


/****************************************************
                BLOOD TRANSFERS
****************************************************/

// Gets blood from mob to the container, preserving all data in it
/mob/living/carbon/proc/take_blood(obj/item/weapon/reagent_containers/container, amount)
	var/datum/reagent/blood/B = new
	B.holder = container
	B.volume += amount

	// Set reagent data:
	B.data["donor"] = REF(src)
	if (!B.data["virus2"])
		B.data["virus2"] = list()
	B.data["virus2"] |= virus_copylist(virus2)
	B.data["antibodies"] = antibodies
	B.data["blood_DNA"] = dna.unique_enzymes // todo: for some reason we ignore original blood datum and all his data here, refactoring needed
	B.data["blood_type"] = dna.b_type
	B.data["time"] = world.time

	if (mind)
		// Changeling blood has unique marker like DNA but invisible for scanners
		// timer means until what time marker should be considered "active" out of (alive) changeling body
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		if (C)
			var/marker_preserve_for = timeofdeath ? timeofdeath : world.time
			marker_preserve_for += 1 MINUTES + rand(0, 20) MINUTES
			B.data["changeling_marker"] = list("id" = C.unique_changeling_marker, "timelimit" = marker_preserve_for)

	var/list/temp_chem = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	B.data["trace_chem"] = list2params(temp_chem)

	if(container)
		container.reagents.reagent_list += B
		container.reagents.update_total()
		container.on_reagent_change()
		container.reagents.handle_reactions()

	return B

// For humans, blood does not appear from blue, it comes from vessels
/mob/living/carbon/human/take_blood(obj/item/weapon/reagent_containers/container, amount)
	if(blood_amount(exact = TRUE) < amount)
		return null

	. = ..()
	blood_remove(amount) // Removes blood if human

// Transfers blood from container to vessels
// Diseases, antibodies, viruses, chemical traces, but NOT actual blood
/mob/living/carbon/proc/inject_blood(obj/item/weapon/reagent_containers/container, amount)
	var/datum/reagent/blood/injected = container.reagents.get_reagent(/datum/reagent/blood)
	if(!istype(injected))
		return

	var/list/sniffles = virus_copylist(injected.data["virus2"])
	for(var/ID in sniffles)
		var/datum/disease2/disease/sniffle = sniffles[ID]
		infect_virus2(src, sniffle, 1)

	if(injected.data["antibodies"] && prob(5))
		antibodies |= injected.data["antibodies"]

	var/list/chems = params2list(injected.data["trace_chem"])
	for(var/C in chems)
		reagents.add_reagent(C, (text2num(chems[C]) / BLOOD_VOLUME_NORMAL) * amount) // adds trace chemicals to owner's blood

	container.reagents.remove_reagent("blood", amount)

// Transfers blood from container to vessels, respecting blood types compatability
/mob/living/carbon/human/inject_blood(obj/item/weapon/reagent_containers/container, amount)
	var/datum/reagent/blood/injected = container.reagents.get_reagent(/datum/reagent/blood)
	if(!istype(injected))
		return

	if(HAS_TRAIT(src, TRAIT_NO_BLOOD))
		reagents.add_reagent("blood", amount, injected.data)
		return

	blood_add(amount, injected.data)
	var/datum/reagent/blood/our = blood_get()

	if(!blood_compatible(injected.data["blood_type"], our.data["blood_type"]))
		reagents.add_reagent("toxin", amount * 0.5)
	..()

/proc/blood_compatible(blood_donor, blood_recipient)
	var/static/list/blood_recipient_can_receive = list(
		BLOOD_A_PLUS = list(
			BLOOD_A_PLUS = TRUE, BLOOD_A_MINUS = TRUE,
			BLOOD_O_PLUS = TRUE, BLOOD_O_MINUS = TRUE
			),
		BLOOD_A_MINUS = list(
			BLOOD_A_MINUS = TRUE,
			BLOOD_O_MINUS = TRUE
			),
		BLOOD_B_PLUS = list(
			BLOOD_B_PLUS = TRUE, BLOOD_B_MINUS = TRUE,
			BLOOD_O_PLUS = TRUE, BLOOD_O_MINUS = TRUE
			),
		BLOOD_B_MINUS = list(
			BLOOD_B_MINUS = TRUE,
			BLOOD_O_MINUS = TRUE
			),
		BLOOD_O_PLUS = list(
			BLOOD_O_PLUS = TRUE, BLOOD_O_MINUS = TRUE
			),
		BLOOD_O_MINUS = list(
			BLOOD_O_MINUS = TRUE
			),
		BLOOD_AB_PLUS = list(
			BLOOD_A_PLUS  = TRUE, BLOOD_A_MINUS  = TRUE,
			BLOOD_B_PLUS  = TRUE, BLOOD_B_MINUS  = TRUE,
			BLOOD_O_PLUS  = TRUE, BLOOD_O_MINUS  = TRUE,
			BLOOD_AB_PLUS = TRUE, BLOOD_AB_MINUS = TRUE
			),
		BLOOD_AB_MINUS = list(
			BLOOD_A_MINUS  = TRUE,
			BLOOD_B_MINUS  = TRUE,
			BLOOD_O_MINUS  = TRUE,
			BLOOD_AB_MINUS = TRUE
			)
		)
	return blood_recipient_can_receive[blood_recipient][blood_donor]

//Percentage of maximum blood volume.
/mob/living/carbon/human/proc/get_blood_volume()
	return round((vessel.get_reagent_amount("blood")/species.blood_volume)*100)

//Percentage of maximum blood volume, affected by the condition of circulation organs
/mob/living/carbon/human/proc/get_blood_circulation()
	var/obj/item/organ/internal/heart/heart = organs_by_name[O_HEART]
	var/blood_volume = get_blood_volume()
	if(!heart)
		return 0.25 * blood_volume

	var/recent_pump = LAZYACCESS(heart.external_pump, 1) > world.time - (20 SECONDS)
	var/pulse_mod = 1
	if((status_flags & FAKEDEATH) || heart.is_robotic())
		pulse_mod = 1
	else
		switch(heart.pulse)
			if(PULSE_NONE)
				if(recent_pump)
					pulse_mod = LAZYACCESS(heart.external_pump, 2)
				else
					pulse_mod *= 0.25
			if(PULSE_SLOW)
				pulse_mod *= 0.9
			if(PULSE_FAST)
				pulse_mod *= 1.1
			if(PULSE_2FAST, PULSE_THREADY)
				pulse_mod *= 1.25
	blood_volume *= pulse_mod

	var/min_efficiency = recent_pump ? 0.5 : 0.3
	blood_volume *= max(min_efficiency, (1-(heart.damage / heart.max_damage)))

	return min(blood_volume, 100)

//Whether the species needs blood to carry oxygen. Used in get_blood_oxygenation and may be expanded based on blood rather than species in the future.
/mob/living/carbon/human/proc/blood_carries_oxygen()
	return species.blood_oxy

//Percentage of maximum blood volume, affected by the condition of circulation organs, affected by the oxygen loss. What ultimately matters for brain
/mob/living/carbon/human/proc/get_blood_oxygenation()
	var/blood_volume = get_blood_circulation()
	if(blood_carries_oxygen())
		if(!need_breathe())
			return blood_volume
	else
		blood_volume = 100

	var/blood_volume_mod = max(0, 1 - getOxyLoss()/(species.total_health/2))
	var/oxygenated_mult = 0
	if(reagents.has_reagent("dexalin")) // Dexalin.
		oxygenated_mult = 0.5
	else if(reagents.has_reagent("dexalinp")) // Dexplus.
		oxygenated_mult = 0.8
	blood_volume_mod = blood_volume_mod + oxygenated_mult - (blood_volume_mod * oxygenated_mult)
	blood_volume = blood_volume * blood_volume_mod
	return min(blood_volume, 100)
