/****************************************************
                BLOOD SYSTEM
****************************************************/
// Blood levels
var/const/BLOOD_VOLUME_MAXIMUM = 600
var/const/BLOOD_VOLUME_NORMAL = 560
var/const/BLOOD_VOLUME_SAFE = 501
var/const/BLOOD_VOLUME_OKAY = 336
var/const/BLOOD_VOLUME_BAD = 224
var/const/BLOOD_VOLUME_SURVIVE = 122


/mob/living/carbon/human/var/datum/reagents/vessel // Container for blood and BLOOD ONLY. Do not transfer other chems here.
/mob/living/carbon/human/var/pale = FALSE          // Should affect how mob sprite is drawn, but currently doesn't.


// Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()
	if(vessel)
		return

	vessel = new/datum/reagents(BLOOD_VOLUME_MAXIMUM)
	vessel.my_atom = src

	blood_add(BLOOD_VOLUME_NORMAL)
	addtimer(CALLBACK(src, .proc/fixblood), 1)

// Resets blood data
/mob/living/carbon/human/proc/fixblood(clean = TRUE)
	var/datum/reagent/blood/B = blood_get()
	if(istype(B))
		if(clean)
			B.data = list("donor" = src, "viruses" = null, "blood_DNA" = dna.unique_enzymes,
						"blood_type" = dna.b_type, "resistances" = null, "trace_chem" = null,
						"virus2" = null, "antibodies" = null)
		else // Change DNA to ours, left the rest intact
			B.data["donor"] = src
			B.data["blood_DNA"] = dna.unique_enzymes
			B.data["blood_type"] = dna.b_type

/mob/living/carbon/human/proc/blood_amount(exact = FALSE)
	if(species && species.flags[NO_BLOOD])
		return 0

	var/volume = vessel.get_reagent_amount("blood")
	if(!exact)
		return round(volume)

	return volume

/mob/living/carbon/human/proc/blood_add(amount, list/add_data = null)
	if(species && species.flags[NO_BLOOD])
		return FALSE
	if(amount < 0)
		return FALSE

	var/new_blood = !vessel.has_reagent("blood")

	. = vessel.add_reagent("blood", amount, data = add_data, safety = TRUE) // No reactions with single reagent

	if(new_blood) // There was no blood in vessels
		fixblood(add_data == null)

/mob/living/carbon/human/proc/blood_remove(amount)
	if(species && species.flags[NO_BLOOD])
		return FALSE
	if(amount < 0)
		return FALSE

	return vessel.remove_reagent("blood", amount, safety = TRUE) // No reactions with single reagent

/mob/living/carbon/human/proc/blood_get()
	return vessel.get_reagent(/datum/reagent/blood)

/mob/living/carbon/human/proc/blood_trans_to(obj/target, amount = 1)
	return vessel.trans_to(target, amount)

// Takes care blood loss and regeneration:
/mob/living/carbon/var/tmp/next_blood_squirt = 0 // until this moved to heart or not...

/mob/living/carbon/human/proc/handle_blood()
	var/blood_total = blood_amount(exact = TRUE)

	// Blood regeneration if there is some space:
	if(blood_total < BLOOD_VOLUME_NORMAL)
		var/change_volume = 0.1 // Regenerate blood VERY slowly
		if (reagents.has_reagent("nutriment")) // Getting food speeds it up
			change_volume += 0.4
			reagents.remove_reagent("nutriment", 0.1)
		if (reagents.has_reagent("iron")) // Hematogen candy anyone?
			change_volume += 0.8
			reagents.remove_reagent("iron", 0.1)
		blood_add(change_volume)
		blood_total += change_volume

	// Damaged heart virtually reduces the blood volume, as the blood isn't
	// being pumped properly anymore.
	var/obj/item/organ/internal/heart/IO = organs_by_name[O_HEART]
	if(!IO)
		return

	var/blood_volume = blood_total // Blood volume adjusted by heart

	if(IO.damage > 1 && IO.damage < IO.min_bruised_damage || IO.heart_status == HEART_FIBR)
		blood_volume *= 0.8
	else if(IO.damage >= IO.min_bruised_damage && IO.damage < IO.min_broken_damage)
		blood_volume *= 0.6
	else if((IO.damage >= IO.min_broken_damage && IO.damage < INFINITY) || IO.heart_status == HEART_FAILURE)
		blood_volume *= 0.3

	// Effects of bloodloss
	if(!HAS_TRAIT(src, TRAIT_CPB))
		switch(blood_volume)
			if(BLOOD_VOLUME_SAFE to 10000)
				if(pale)
					pale = FALSE
					update_body()
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(!pale)
					pale = TRUE
					update_body()
					var/word = pick("dizzy", "woosey", "faint")
					to_chat(src, "<span class='warning'>You feel [word]</span>")
				if(prob(1))
					var/word = pick("dizzy", "woosey", "faint")
					to_chat(src, "<span class='warning'>You feel [word]</span>")
				if(oxyloss < 20)
					oxyloss += 3
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(!pale)
					pale = TRUE
					update_body()
				blurEyes(6)
				if(oxyloss < 50)
					oxyloss += 10
				oxyloss += 1
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy", "woosey", "faint")
					to_chat(src, "<span class='warning'>You feel extremely [word]</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				oxyloss += 5
				toxloss += 3
				if(prob(15))
					var/word = pick("dizzy", "woosey", "faint")
					to_chat(src, "<span class='warning'>You feel extremely [word]</span>")
			if(0 to BLOOD_VOLUME_SURVIVE)
				if(!iszombie(src)) // zombies dont care about blood
					death()

	// Without enough blood you slowly go hungry.
	if(blood_volume < BLOOD_VOLUME_SAFE)
		if(nutrition >= 300)
			nutrition -= 10
		else if(nutrition >= 200)
			nutrition -= 3

	// Bleeding out:
	var/blood_max = 0
	var/list/do_spray = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_robotic())
			continue

		var/open_wound
		if(BP.status & ORGAN_BLEEDING)
			if(BP.open)
				blood_max += 2 // Yer stomach is cut open

			for(var/datum/wound/W in BP.wounds)
				if(!open_wound && (W.damage_type == CUT || W.damage_type == PIERCE) && W.damage && !W.is_treated())
					open_wound = TRUE

				if(W.bleeding())
					if(BP.applied_pressure)
						if(ishuman(BP.applied_pressure))
							var/mob/living/carbon/human/H = BP.applied_pressure
							H.bloody_hands(src, 0)
						// somehow you can apply pressure to every wound on the organ at the same time
						// you're basically forced to do nothing at all, so let's make it pretty effective
						var/min_eff_damage = max(0, W.damage - 10) / 6 // still want a little bit to drip out, for effect
						blood_max += max(min_eff_damage, W.damage - 30) / 40
					else
						blood_max += W.damage / 40

		if(BP.status & ORGAN_ARTERY_CUT)
			var/bleed_amount = blood_total / (BP.applied_pressure ? 500 : 250) * BP.arterial_bleed_severity
			if(bleed_amount)
				if(open_wound)
					blood_max += bleed_amount
					do_spray += "the [BP.artery_name] in \the [src]'s [BP.name]"
				else
					blood_remove(bleed_amount)
				playsound(src, 'sound/effects/ArterialBleed.ogg', VOL_EFFECTS_MASTER)

	if(blood_max == 0) // so... there is no blood loss, lets stop right here.
		return

	switch(pulse)
		if(PULSE_NONE)
			blood_max *= 0.2 // simulates passive blood loss.
		if(PULSE_SLOW)
			blood_max *= 0.8
		if(PULSE_FAST)
			blood_max *= 1.25
		if(PULSE_2FAST)
			blood_max *= 1.5
		if(PULSE_THREADY)
			blood_max *= 1.8

	if(reagents.has_reagent("inaprovaline"))
		blood_max *= 0.8

	if(!isturf(loc)) // No floor to drip on
		blood_remove(blood_max)
		return

	if(world.time >= next_blood_squirt && do_spray.len) // It becomes very spammy otherwise. Arterial bleeding will still happen outside of this block, just not the squirt effect.
		if(prob(50)) // added 50 prob for message and halved delay between squit effects (difference between us and Bay12), lets see how this will be on live server.
			visible_message("<span class='danger'>Blood squirts from [pick(do_spray)]!</span>")
		next_blood_squirt = world.time + 50
		var/turf/sprayloc = get_turf(src)
		var/third = CEIL(blood_max / 3)
		drip(third, sprayloc)
		blood_max -= third
		if(blood_max > 0)
			blood_squirt(blood_max, sprayloc)
	else
		drip(blood_max) // No fancy shooting of blood, just bleeding

// Makes a blood drop, leaking certain amount of blood from the mob
/mob/living/carbon/human/proc/drip(amt, tar = src, ddir)
	if(organs_by_name[O_HEART] && blood_remove(amt))
		blood_splatter(tar, src, (ddir && ddir > 0), spray_dir = ddir, basedatum = species.blood_datum)

/proc/blood_splatter(target, datum/reagent/blood/source, large, spray_dir, basedatum)
	var/obj/effect/decal/cleanable/blood/B
	var/decal_type = /obj/effect/decal/cleanable/blood/splatter
	var/turf/T = get_turf(target)

	if(istype(source, /mob/living/carbon/human))
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
	var/datum/reagent/blood/B = container.reagents.get_reagent(/datum/reagent/blood)
	if(!istype(B))
		B = new /datum/reagent/blood
	B.holder = container
	B.volume += amount

	// Set reagent data:
	B.data["donor"] = src
	if (!B.data["virus2"])
		B.data["virus2"] = list()
	B.data["virus2"] |= virus_copylist(virus2)
	B.data["antibodies"] = antibodies
	B.data["blood_DNA"] = dna.unique_enzymes
	B.data["blood_type"] = dna.b_type
	if(resistances && resistances.len)
		if(B.data["resistances"])
			B.data["resistances"] |= resistances.Copy()
		else
			B.data["resistances"] = resistances.Copy()

	var/list/temp_chem = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	B.data["trace_chem"] = list2params(temp_chem)
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

	if(species && species.flags[NO_BLOOD])
		reagents.add_reagent("blood", amount, injected.data)
		return

	blood_add(amount, injected.data)
	var/datum/reagent/blood/our = blood_get()

	if(blood_incompatible(injected.data["blood_type"], our.data["blood_type"]))
		reagents.add_reagent("toxin", amount * 0.5)
	..()

/proc/blood_incompatible(donor, receiver)
	if(!donor || !receiver)
		return FALSE
	var/donor_antigen = copytext(donor, 1, -1)
	var/receiver_antigen = copytext(receiver, 1, -1)
	var/donor_rh = (findtext(donor, "+") > 0)
	var/receiver_rh = (findtext(receiver, "+") > 0)
	if(donor_rh && !receiver_rh) // Bad: "+" -> "-". Other combinations is ok
		return TRUE
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O")
				return TRUE
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O")
				return TRUE
		if("O")
			if(donor_antigen != "O")
				return TRUE
		// AB is a universal receiver
	return FALSE
