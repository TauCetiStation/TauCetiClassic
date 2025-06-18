var/global/const/TOUCH = 1
var/global/const/INGEST = 2

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/proccessing_reaction_count = 0

/datum/reagents/New(maximum=100)
	maximum_volume = maximum

/datum/reagents/proc/remove_any(amount=1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1,reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount) break
		if(total_volume <= 0 || !reagent_list.len) break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		update_total()

	handle_reactions()
	return total_transfered

/datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

/datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

/datum/reagents/proc/trans_to(obj/target, amount=1, multiplier=1, preserve_data=1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if (!target )
		return
	if(amount < 0) return
	if(amount > 2000) return
	if(total_volume == 0)
		return
	var/datum/reagents/R
	if(istype(target,/datum/reagents))
		R = target
	else
		if (!target.reagents)
			return
		R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		if (current_reagent.id == "blood" && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.inject_blood(my_atom, amount)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, TRUE, current_reagent.religion)	//safety checks on these so all chemicals are transferred
		remove_reagent(current_reagent.id, current_reagent_transfer, safety = 1)							// to the target container before handling reactions

	update_total()
	R.update_total()
	R.handle_reactions()
	handle_reactions()
	return amount

/datum/reagents/proc/trans_to_ingest(obj/target, amount=1, multiplier=1, preserve_data=1)//For items ingested. A delay is added between ingestion and addition of the reagents
	if (!target )
		return
	if (!target.reagents || src.total_volume<=0)
		return

	if(amount < 0) return
	if(amount > 2000) return

	var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder
	B.volume = maximum_volume
	B.reagents.maximum_volume = maximum_volume

	var/datum/reagents/BR = B.reagents
	var/datum/reagents/R = target.reagents

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)

	trans_to(B, amount)

	digest_with_delay(BR, target, B)

	return amount

/datum/reagents/proc/digest_with_delay(datum/reagents/BR, obj/target, obj/item/weapon/reagent_containers/glass/beaker/noreact/B)
	set waitfor = FALSE

	sleep(95)
	BR.reaction(target, INGEST)
	sleep(5)
	BR.trans_to(target, BR.total_volume)
	qdel(B)

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1, safety = 0)
	if(!target)
		return
	if(!target.reagents || src.total_volume<=0)
		return
	if(amount < 0) return
	if(amount > 2000) return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, TRUE, current_reagent.religion)	//safety check so all chemicals are transferred before reacting

	update_total()
	R.update_total()
	if(!safety)
		R.handle_reactions()
		handle_reactions()
	return amount

/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, multiplier=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	if (!target)
		return
	if(src.total_volume<=0 || !get_reagent_amount(reagent))
		return
	if(amount < 0) return
	if(amount > 2000) return

	var/datum/reagents/R = null
	if(istype(target, /datum/reagents))
		R = target
	else
		if(!target.reagents)
			return
		R = target.reagents

	if(get_reagent_amount(reagent)<amount)
		amount = get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = copy_data(current_reagent)
			R.add_reagent(current_reagent.id, amount * multiplier, trans_data, safety = TRUE)
			remove_reagent(current_reagent.id, amount, 1, safety = TRUE)
			break

	update_total()
	R.update_total()
	R.handle_reactions()
	//handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
	return amount

/datum/reagents/proc/metabolize(mob/M)
	for(var/datum/reagent/R in reagent_list)
		if(M && R)
			var/mob/living/carbon/C = M //currently metabolism work only for carbon, there is no need to check mob type
			var/remove_amount = R.custom_metabolism * C.get_metabolism_factor()
			if(remove_amount > 0)
				R.on_mob_life(M)
				remove_reagent(R.id, remove_amount)
	update_total()

/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	for(var/datum/reagent/R in reagent_list)
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A, )
	for(var/datum/reagent/R in reagent_list)
		R.on_update (A)
	update_total()

/datum/reagents/proc/handle_reactions()
	if(!my_atom)
		/*
		We are created abstractly, there is no need for us to handle any reactions, unless somebody wants to
		code in such support.
		*/
		return

	if(my_atom.flags & NOREACT) return //Yup, no reactions here. No siree.


	// Carefull, next while cycle are async
	proccessing_reaction_count += 1
	var/reaction_occured = 0
	do
		reaction_occured = 0
		for(var/datum/reagent/R in reagent_list) // Usually a small list
			for(var/reaction in chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id

				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction

				//check if this recipe needs to be heated to mix
				if(C.requires_heating)
					if(istype(my_atom.loc, /obj/machinery/bunsen_burner))
						if(!my_atom.loc:heated)
							continue
					else
						continue

				var/total_required_reagents = C.required_reagents.len
				var/total_matching_reagents = 0
				var/total_required_catalysts = C.required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/list/multipliers = list()

				for(var/B in C.required_reagents)
					if(!has_reagent(B, C.required_reagents[B]))	break
					total_matching_reagents++
					multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
				for(var/B in C.required_catalysts)
					if(!has_reagent(B, C.required_catalysts[B]))	break
					total_matching_catalysts++

				if(!C.required_container)
					matching_container = 1

				else
					if(my_atom.type == C.required_container)
						matching_container = 1

				if(!C.required_other)
					matching_other = C.check_requirements(src)

				else
					/*if(istype(my_atom, /obj/item/slime_core))
						var/obj/item/slime_core/M = my_atom

						if(M.POWERFLAG == C.required_other && M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1*/
					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/M = my_atom

						if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
							matching_other = 1


				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other)
					var/multiplier = min(multipliers)
					var/preserved_data = null
					for(var/B in C.required_reagents)
						if(!preserved_data)
							preserved_data = get_data(B)
						remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)

					var/created_volume = C.result_amount*multiplier
					if(C.result)
						feedback_add_details("chemical_reaction","[C.result]|[C.result_amount*multiplier]")
						multiplier = max(multiplier, 1) //this shouldnt happen ...
						add_reagent(C.result, C.result_amount*multiplier)
						if(preserved_data)
							set_data(C.result, preserved_data)

						//add secondary products
						for(var/S in C.secondary_results)
							add_reagent(S, C.result_amount * C.secondary_results[S] * multiplier)

					var/list/seen = viewers(4, get_turf(my_atom))
					for(var/mob/M in seen)
						to_chat(M, "<span class='notice'>[bicon(my_atom)] The solution begins to bubble.</span>")

				/*	if(istype(my_atom, /obj/item/slime_core))
						var/obj/item/slime_core/ME = my_atom
						ME.Uses--
						if(ME.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in viewers(4, get_turf(my_atom)) )
								to_chat(M, "<span class='notice'>[bicon(my_atom)] The innards begin to boil!</span>")
					*/
					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								to_chat(M, "<span class='notice'>[bicon(my_atom)] The [my_atom]'s power is consumed in the reaction.</span>")
							ME2.name = "used slime extract"
							ME2.desc = "This extract has been used up."
							ME2.origin_tech = null

					playsound(my_atom, 'sound/effects/bubbles.ogg', VOL_EFFECTS_MASTER)

					C.on_reaction(src, created_volume)
					reaction_occured = 1
					break

	while(reaction_occured)
	update_total()
	if (proccessing_reaction_count > 0)
		proccessing_reaction_count -= 1
	return 0

/datum/reagents/proc/is_reaction_in_proccessing()
	if (proccessing_reaction_count > 0)
		return TRUE
	return FALSE

/datum/reagents/proc/isolate_reagent(reagent)
	for(var/datum/reagent/R in reagent_list)
		if (R.id != reagent)
			del_reagent(R.id)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	for(var/datum/reagent/R in reagent_list)
		if (R.id == reagent)
			reagent_list -= R
			qdel(R)
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
			return 0
	return 1

/datum/reagents/proc/update_total()
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < 0.1)
			del_reagent(R.id)
		else
			total_volume += R.volume
	return 0

/datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id)
	return 0

/datum/reagents/proc/reaction(atom/A, method=TOUCH, volume_modifier=0)

	switch(method)
		if(TOUCH)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A))
					if(!R)
						return
					else
						INVOKE_ASYNC(R, TYPE_PROC_REF(/datum/reagent, reaction_mob), A, TOUCH, R.volume+volume_modifier)
				if(isturf(A))
					if(!R)
						return
					else
						INVOKE_ASYNC(R, TYPE_PROC_REF(/datum/reagent, reaction_turf), A, R.volume+volume_modifier)
				if(isobj(A))
					if(!R)
						return
					else
						INVOKE_ASYNC(R, TYPE_PROC_REF(/datum/reagent, reaction_obj), A, R.volume+volume_modifier)
		if(INGEST)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A) && R)
					if(!R)
						return
					else
						INVOKE_ASYNC(R, TYPE_PROC_REF(/datum/reagent, reaction_mob), A, INGEST, R.volume+volume_modifier)
				if(isturf(A) && R)
					if(!R)
						return
					else
						INVOKE_ASYNC(R, TYPE_PROC_REF(/datum/reagent, reaction_turf), A, R.volume+volume_modifier)
				if(isobj(A) && R)
					if(!R)
						return
					else
						INVOKE_ASYNC(R, TYPE_PROC_REF(/datum/reagent, reaction_obj), A, R.volume+volume_modifier)
	return

// adds new reagent by ID, mix it with those already present if needed
/datum/reagents/proc/add_reagent(reagent, amount, list/data = null, safety = FALSE, datum/religion/_religion)
	if(!isnum(amount) || amount < 0 || amount > 2000)
		return FALSE

	update_total()
	if(total_volume + amount > maximum_volume)
		amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

	// if we already have this reagent just trasnfer new data and update volume
	for(var/datum/reagent/R in reagent_list)
		if (R.id == reagent)
			R.volume += amount

			// blood is one common datum /datum/reagent/blood with different data uploads, we mix it here manually
			// todo: currently only viruses, else it can break mobs
			// part of the work happens in /inject_blood()
			if(R.id == "blood" && reagent == "blood")
				if(R.data && R.data["virus2"])
					R.data["virus2"] |= virus_copylist(data["virus2"])

			// not blood, but same problems
			else if(R.id == "customhairdye" || R.id == "paint_custom")
				for(var/color in R.data)
					R.data[color] = (R.data[color] + data[color]) * 0.5
				// I am well aware of RGB_CONTRAST define, but in reagent colors everywhere else we use hex codes, so I did the thing below. ~Luduk.
				R.color = numlist2hex(list(R.data["r_color"], R.data["g_color"], R.data["b_color"]))

			// Update:
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
			if(!safety)
				handle_reactions()
			return TRUE

	// new reagent we don't have, need to create
	var/datum/reagent/D = chemical_reagents_list[reagent]
	if(D)
		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		R.religion = _religion

		if(data)
			R.data = data.Copy()

			if(data["virus2"]) // list of datums, need to copy manually through virus_copylist()
				R.data["virus2"] |= virus_copylist(data["virus2"])

		if(reagent == "customhairdye" || reagent == "paint_custom")
			R.color = numlist2hex(list(R.data["r_color"], R.data["g_color"], R.data["b_color"]))

		// Update:
		R.on_new()

		update_total()
		if(my_atom)
			my_atom.on_reagent_change()
		if(!safety)
			handle_reactions()
		return TRUE
	else
		warning("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")

	if(!safety)
		handle_reactions()

	return FALSE

/datum/reagents/proc/remove_reagent(reagent, amount, safety = 0)//Added a safety check for the trans_id_to
	if(!isnum(amount) || amount < 0 || amount > 2000)
		return FALSE

	for(var/datum/reagent/R in reagent_list)
		if (R.id == reagent)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return TRUE

	return FALSE

/datum/reagents/proc/has_reagent(reagent, amount = 0)
	for(var/datum/reagent/R in reagent_list)
		if(R.id == reagent)
			if(!amount)
				return R
			else if(R.volume >= amount)
				return R

	return FALSE

/datum/reagents/proc/get_reagent_amount(reagent)
	for(var/datum/reagent/R in reagent_list)
		if (R.id == reagent)
			return R.volume

	return 0

/datum/reagents/proc/get_reagent(type)
	. = locate(type) in reagent_list

/datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if (res != "") res += ", "
		res += A.name

	return res

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) // Like add_reagent but you can enter a list. Format it like this: list("toxin" = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount)) return 1
	if(amount < 0) return 0
	if(amount > 2000) return

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "proffering a data-carrying reagent ([reagent_id])"
			return D.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "reagent data set ([reagent_id])"
			D.data = new_data

/datum/reagents/proc/delete()
	for(var/datum/reagent/R in reagent_list)
		R.holder = null
	if(my_atom)
		my_atom.reagents = null

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if (!current_reagent || !current_reagent.data) return null
	if (!istype(current_reagent.data, /list)) return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if (trans_data["virus2"])
		var/list/v = trans_data["virus2"]
		trans_data["virus2"] = v.Copy()

	if (trans_data["changeling_marker"])
		var/list/v = trans_data["changeling_marker"]
		trans_data["changeling_marker"] = v.Copy()

	return trans_data

/datum/reagents/Destroy()
	. = ..()
	for(var/datum/reagent/R in reagent_list)
		qdel(R)
	reagent_list.Cut()
	reagent_list = null
	if(my_atom)
		if(my_atom.reagents == src)
			my_atom.reagents = null
		my_atom = null

/datum/reagents/proc/create_chempuff(amount, multiplier=1, preserve_data=1, name_from_reagents = TRUE, icon_from_reagents = TRUE)
	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(my_atom))
	if(name_from_reagents)
		D.name = get_master_reagent_name()
	D.create_reagents(amount)
	D.icon = 'icons/obj/chempuff.dmi'
	trans_to(D, amount, multiplier, preserve_data)
	if(icon_from_reagents)
		D.icon += mix_color_from_reagents(D.reagents.reagent_list)
	return D

/datum/reagents/proc/standard_splash(atom/target, amount=null, mob/living/user=null)
	if(total_volume <= 0)
		return

	if(isnull(amount))
		amount = total_volume

	var/datum/reagents/splash = new()
	splash.maximum_volume = maximum_volume
	trans_to(splash, amount=amount)

	if(!isnull(user))
		var/turf/T = get_turf(target)
		message_admins("[key_name_admin(user)] splashed ([splash.get_reagents()]) on [target], location [COORD(T)] [ADMIN_JMP(user)]")
		log_game("[key_name(user)] splashed [splash.get_reagents()] on [target], location [COORD(T)]")

		if(ismob(target))
			var/mob/living/L = target
			var/contained = splash.get_reagents()

			L.log_combat(user, "splashed with [my_atom.name], reagents: [contained] (INTENT: [uppertext(user.a_intent)])")

			var/image/splash_animation = image('icons/effects/effects.dmi', L, "splash")
			splash_animation.color = mix_color_from_reagents(splash.reagent_list)
			splash_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_APART
			flick_overlay_view(splash_animation, target, 1 SECONDS)

	splash.reaction(target, TOUCH)
	splash.clear_reagents()

///////////////////////////////////////////////////////////////////////////////////

// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
