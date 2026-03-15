/atom/var/list/suit_fibers

/atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves && istype(M.gloves, /obj/item/clothing/gloves)) //transfer dirt from gloves to touched objects
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.dirt_transfers)
			if(G.blood_DNA)
				if(!blood_DNA)
					blood_DNA = list()
				blood_DNA |= G.blood_DNA.Copy()
			add_dirt_cover(G.dirt_overlay)
			G.dirt_transfers--
	else if(M.dirty_hands_transfers) //transfer dirt from hands to touched objects
		add_dirt_cover(M.hand_dirt_datum)
		if(M.blood_DNA)
			if(!blood_DNA)
				blood_DNA = list()
			blood_DNA |= M.blood_DNA.Copy()
		M.dirty_hands_transfers--
	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = isitem(src)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & UPPER_TORSO))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !(fibertext in suit_fibers))//Wearing a suit means less of the uniform exposed.
					suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & ARMS))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
					var/obj/item/clothing/gloves/C = M.gloves
					if(C.can_leave_fibers)
						suit_fibers += fibertext
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in suit_fibers))
			suit_fibers += fibertext
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
				var/obj/item/clothing/gloves/C = M.gloves
				if(C.can_leave_fibers)
					suit_fibers += fibertext
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
			var/obj/item/clothing/gloves/C = M.gloves
			if(C.can_leave_fibers)
				suit_fibers += fibertext
	if(M.species.flags[FUR])
		fibertext = "Small particles of [M.species.name] fur."
		var/bio_restriction = 100 - M.getarmor(null, "bio")
		if(prob(bio_restriction) && !(fibertext in suit_fibers))
			ADD_TRAIT(src, TRAIT_XENO_FUR, GENERIC_TRAIT)
			suit_fibers += "Small particles of [M.species.name] fur."

	if(!suit_fibers.len) suit_fibers = null
