/****************************************************
				BLOOD SYSTEM
****************************************************/
//Blood levels
var/const/BLOOD_VOLUME_MAXIMUM = 600
var/const/BLOOD_VOLUME_NORMAL = 560
var/const/BLOOD_VOLUME_SAFE = 501
var/const/BLOOD_VOLUME_OKAY = 336
var/const/BLOOD_VOLUME_BAD = 224
var/const/BLOOD_VOLUME_SURVIVE = 122

/mob/living/carbon/human/var/datum/reagents/vessel	//Container for blood and BLOOD ONLY. Do not transfer other chems here.
/mob/living/carbon/human/var/pale = 0			//Should affect how mob sprite is drawn, but currently doesn't.

//Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()

	if(vessel)
		return

	vessel = new/datum/reagents(BLOOD_VOLUME_MAXIMUM)
	vessel.my_atom = src

	if(species && species.flags[NO_BLOOD]) //We want the var for safety but we can do without the actual blood.
		return

	vessel.add_reagent("blood",BLOOD_VOLUME_NORMAL)
	addtimer(CALLBACK(src, .proc/fixblood), 1)

//Resets blood data
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.data = list(	"donor"=src,"viruses"=null,"blood_DNA"=dna.unique_enzymes,"blood_type"=dna.b_type,	\
							"resistances"=null,"trace_chem"=null, "virus2" = null, "antibodies" = null)

// Takes care blood loss and regeneration
/mob/living/carbon/var/tmp/next_blood_squirt = 0 // until this moved to heart or not...
/mob/living/carbon/human/proc/handle_blood(blood_volume = 0)

	//Blood regeneration if there is some space
	if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume)
		var/datum/reagent/blood/B = locate() in vessel.reagent_list //Grab some blood
		if(B) // Make sure there's some blood at all
			if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
				for(var/datum/reagent/blood/D in vessel.reagent_list)
					if(D.data["donor"] == src)
						B = D
						break

			B.volume += 0.1 // regenerate blood VERY slowly
			if (reagents.has_reagent("nutriment"))	//Getting food speeds it up
				B.volume += 0.4
				reagents.remove_reagent("nutriment", 0.1)
			if (reagents.has_reagent("iron"))	//Hematogen candy anyone?
				B.volume += 0.8
				reagents.remove_reagent("iron", 0.1)

	// Damaged heart virtually reduces the blood volume, as the blood isn't
	// being pumped properly anymore.
	var/obj/item/organ/internal/heart/IO = organs_by_name[O_HEART]
	if(!IO)
		return

	if(IO.damage > 1 && IO.damage < IO.min_bruised_damage || IO.heart_status == HEART_FIBR)
		blood_volume *= 0.8
	else if(IO.damage >= IO.min_bruised_damage && IO.damage < IO.min_broken_damage)
		blood_volume *= 0.6
	else if((IO.damage >= IO.min_broken_damage && IO.damage < INFINITY) || IO.heart_status == HEART_FAILURE)
		blood_volume *= 0.3

	//Effects of bloodloss
	if(!HAS_TRAIT(src, TRAIT_CPB))
		switch(blood_volume)
			if(BLOOD_VOLUME_SAFE to 10000)
				if(pale)
					pale = 0
					update_body()
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(!pale)
					pale = 1
					update_body()
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='warning'>You feel [word]</span>")
				if(prob(1))
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='warning'>You feel [word]</span>")
				if(oxyloss < 20)
					oxyloss += 3
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(!pale)
					pale = 1
					update_body()
				eye_blurry += 6
				if(oxyloss < 50)
					oxyloss += 10
				oxyloss += 1
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='warning'>You feel extremely [word]</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				oxyloss += 5
				toxloss += 3
				if(prob(15))
					var/word = pick("dizzy","woosey","faint")
					to_chat(src, "<span class='warning'>You feel extremely [word]</span>")
			if(0 to BLOOD_VOLUME_SURVIVE)
				// There currently is a strange bug here. If the mob is not below -100 health
				// when death() is called, apparently they will be just fine, and this way it'll
				// spam deathgasp. Adjusting toxloss ensures the mob will stay dead.
				if(!iszombie(src)) //zombies dont care about blood
					toxloss += 300 // just to be safe!
					death()

	// Without enough blood you slowly go hungry.
	if(blood_volume < BLOOD_VOLUME_SAFE)
		if(nutrition >= 300)
			nutrition -= 10
		else if(nutrition >= 200)
			nutrition -= 3

	//Bleeding out
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
						//somehow you can apply pressure to every wound on the organ at the same time
						//you're basically forced to do nothing at all, so let's make it pretty effective
						var/min_eff_damage = max(0, W.damage - 10) / 6 //still want a little bit to drip out, for effect
						blood_max += max(min_eff_damage, W.damage - 30) / 40
					else
						blood_max += W.damage / 40

		if(BP.status & ORGAN_ARTERY_CUT)
			var/bleed_amount = FLOOR((vessel.total_volume / (BP.applied_pressure ? 400 : 250)) * BP.arterial_bleed_severity, 1)
			if(bleed_amount)
				if(open_wound)
					blood_max += bleed_amount
					do_spray += "the [BP.artery_name] in \the [src]'s [BP.name]"
				else
					vessel.remove_reagent("blood", bleed_amount)
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

	if(world.time >= next_blood_squirt && isturf(loc) && do_spray.len) // It becomes very spammy otherwise. Arterial bleeding will still happen outside of this block, just not the squirt effect.
		if(prob(50)) // added 50 prob for message and halved delay between squit effects (difference between us and Bay12), lets see how this will be on live server.
			visible_message("<span class='danger'>Blood squirts from [pick(do_spray)]!</span>")
		next_blood_squirt = world.time + 50
		var/turf/sprayloc = get_turf(src)
		blood_max -= drip(CEIL(blood_max / 3), sprayloc)
		if(blood_max > 0)
			blood_max -= blood_squirt(blood_max, sprayloc)
			if(blood_max > 0)
				drip(blood_max, get_turf(src))
	else
		drip(blood_max)

//Makes a blood drop, leaking certain amount of blood from the mob
/mob/living/carbon/human/proc/drip(amt, tar = src, ddir)
	if(remove_blood(amt))
		blood_splatter(tar, src, (ddir && ddir > 0), spray_dir = ddir, basedatum = species.blood_datum)
		return amt
	return 0

/proc/blood_splatter(target, datum/reagent/blood/source, large, spray_dir, basedatum)
	var/obj/effect/decal/cleanable/blood/B
	var/decal_type = /obj/effect/decal/cleanable/blood/splatter
	var/turf/T = get_turf(target)

	if(istype(source, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = source
		source = M.get_blood(M.vessel)

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
	if(!source)
		return B

	// Update appearance.
	B.basedatum = new(basedatum) // source.data["blood_colour"] <- leaving this pointer, could be important for later.
	B.update_icon()
	if(spray_dir)
		B.icon_state = "squirt"
		B.dir = spray_dir

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
						H.eye_blurry = max(H.eye_blurry, 10)
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

/mob/living/carbon/human/proc/remove_blood(amt)
	if(!organs_by_name[O_HEART] || species.flags[NO_BLOOD]) //TODO: Make drips come from the reagents instead (Bay12 TODO).
		return 0
	if(!amt)
		return 0
	return vessel.remove_reagent("blood", amt)

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to the container, preserving all data in it.
/mob/living/carbon/proc/take_blood(obj/item/weapon/reagent_containers/container, amount)

	var/datum/reagent/B = get_blood(container.reagents)
	if(!B) B = new /datum/reagent/blood
	B.holder = container
	B.volume += amount

	//set reagent data
	B.data["donor"] = src
	if (!B.data["virus2"])
		B.data["virus2"] = list()
	B.data["virus2"] |= virus_copylist(src.virus2)
	B.data["antibodies"] = src.antibodies
	B.data["blood_DNA"] = src.dna.unique_enzymes
	if(src.resistances && src.resistances.len)
		if(B.data["resistances"])
			B.data["resistances"] |= src.resistances.Copy()
		else
			B.data["resistances"] = src.resistances.Copy()
	B.data["blood_type"] = src.dna.b_type

	var/list/temp_chem = list()
	for(var/datum/reagent/R in src.reagents.reagent_list)
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	B.data["trace_chem"] = list2params(temp_chem)
	return B

//For humans, blood does not appear from blue, it comes from vessels.
/mob/living/carbon/human/take_blood(obj/item/weapon/reagent_containers/container, amount)

	if(species && species.flags[NO_BLOOD])
		return null

	if(vessel.get_reagent_amount("blood") < amount)
		return null

	. = ..()
	vessel.remove_reagent("blood",amount) // Removes blood if human

//Transfers blood from container ot vessels
/mob/living/carbon/proc/inject_blood(obj/item/weapon/reagent_containers/container, amount)
	var/datum/reagent/blood/injected = get_blood(container.reagents)
	if (!injected)
		return
	var/list/sniffles = virus_copylist(injected.data["virus2"])
	for(var/ID in sniffles)
		var/datum/disease2/disease/sniffle = sniffles[ID]
		infect_virus2(src,sniffle,1)
	if (injected.data["antibodies"] && prob(5))
		antibodies |= injected.data["antibodies"]
	var/list/chems = list()
	chems = params2list(injected.data["trace_chem"])
	for(var/C in chems)
		src.reagents.add_reagent(C, (text2num(chems[C]) / 560) * amount)//adds trace chemicals to owner's blood
	reagents.update_total()

	container.reagents.remove_reagent("blood", amount)

//Transfers blood from container ot vessels, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(obj/item/weapon/reagent_containers/container, amount)

	var/datum/reagent/blood/injected = get_blood(container.reagents)

	if(species && species.flags[NO_BLOOD])
		reagents.add_reagent("blood", amount, injected.data)
		reagents.update_total()
		return

	if(!injected)
		return

	var/datum/reagent/blood/our = get_blood(vessel)

	vessel.add_reagent("blood", amount, injected.data)
	if(!our)
		fixblood()
		our = get_blood(vessel)
	vessel.update_total()

	if(blood_incompatible(injected.data["blood_type"],our.data["blood_type"]) )
		reagents.add_reagent("toxin",amount * 0.5)
		reagents.update_total()
	..()

//Gets human's own blood.
/mob/living/carbon/proc/get_blood(datum/reagents/container)
	var/datum/reagent/blood/res = locate() in container.reagent_list //Grab some blood
	if(res) // Make sure there's some blood at all
		if(res.data["donor"] != src) //If it's not theirs, then we look for theirs
			for(var/datum/reagent/blood/D in container.reagent_list)
				if(D.data["donor"] == src)
					return D
	return res

/proc/blood_incompatible(donor,receiver)
	if(!donor || !receiver) return 0
	var/donor_antigen = copytext(donor,1,-1)
	var/receiver_antigen = copytext(receiver,1,-1)
	var/donor_rh = (findtext(donor,"+")>0)
	var/receiver_rh = (findtext(receiver,"+")>0)
	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0
