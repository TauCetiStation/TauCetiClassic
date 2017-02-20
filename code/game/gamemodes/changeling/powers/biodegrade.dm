/obj/effect/proc_holder/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement."
	helptext = "This is obvious to nearby people, and can destroy \
		standard restraints and closets."
	chemical_cost = 30 //High cost to prevent spam
	genomecost = 2
	req_human = 1
	genetic_damage = 10
	max_genetic_damage = 0
	req_stat = UNCONSCIOUS


/obj/effect/proc_holder/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = FALSE // only one form of shackles removed per use
	if(user.back && istype(user.back,/obj/item/device/radio/electropack))
		user.visible_message("<span class='warning'>[user] vomits a glob of \
			acid on \his [user.back]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our \
			electropack!</span>")
		addtimer(src, "dissolve_electropack",30,FALSE,user,user.back)
		used = TRUE

	if(user.wear_mask  && istype(user.wear_mask ,/obj/item/clothing/mask/horsehead))
		user.visible_message("<span class='warning'>[user] vomits a glob of \
			acid on \his [user.wear_mask ]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our \
			mask!</span>")
		addtimer(src,"dissolve_horsehead",30,FALSE,user,user.wear_mask )
		used = TRUE

	if(!user.restrained() && istype(user.loc, /turf) && !used)
		to_chat(user,"<span class='warning'>We are already free!</span>")
		return 0

	if(user.handcuffed && !used)
		var/obj/item/weapon/handcuffs/O = user.handcuffed
		user.visible_message("<span class='warning'>[user] vomits a glob of \
			acid on \his [O]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our \
			restraints!</span>")

		addtimer(src, "dissolve_handcuffs", 30, FALSE, user, O)
		used = TRUE

	if(user.wear_suit && istype(user.wear_suit, /obj/item/clothing/suit/straight_jacket) && !used)
		user.visible_message("<span class='warning'>[user] vomits a glob \
			of acid across the front of \his [user.wear_suit]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our straight \
			jacket!</span>")
		addtimer(src, "dissolve_straightjacket", 30, FALSE, user, user.wear_suit)
		used = TRUE


	if(istype(user.loc, /obj/structure/closet) && !used)
		user.loc.visible_message("<span class='warning'>[user.loc]'s hinges suddenly \
			begin to melt and run!</span>")
		to_chat(user,"<span class='warning'>We vomit acidic goop onto the \
			interior of [user.loc]!</span>")
		addtimer(src, "open_closet", 70, FALSE, user, user.loc)
		used = TRUE

	if(istype(user.loc, /obj/effect/spider/cocoon) && !used)
		user.loc.visible_message("<span class='warning'>[user.loc] shifts and starts to fall apart!</span>")
		to_chat(user,"<span class='warning'>We secrete acidic enzymes from our skin and begin melting our cocoon...</span>")
		addtimer(src, "dissolve_cocoon", 25, FALSE, user, user.loc) //Very short because it's just webs
		used = TRUE

	if(used)
		feedback_add_details("changeling_powers","BD")
	return 1

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(istype(O,/obj/item/weapon/handcuffs))
		var/obj/item/weapon/handcuffs/cuffs = O
		if(O && user.handcuffed == O)
			user.unEquip(cuffs)
			cuffs.visible_message("<span class='warning'>[O] dissolves into a puddle of sizzling goop.</span>")
			cuffs.loc = get_turf(user)
			qdel(cuffs)

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/O)
	if(istype(O,/obj/item/clothing/suit/straight_jacket))
		var/obj/item/clothing/suit/straight_jacket/S = O
		if(S && user.wear_suit == S)
			user.unEquip(S)
			S.visible_message("<span class='warning'>[S] dissolves into a puddle of sizzling goop.</span>")
			S.loc = get_turf(user)
			qdel(S)

/obj/effect/proc_holder/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/O)
	if(istype(O,/obj/structure/closet))
		var/obj/structure/closet/C = O
		if(C && user.loc == C)
			C.visible_message("<span class='warning'>[C]'s door breaks and opens!</span>")
			C.welded = FALSE
			C.locked = FALSE
			C.broken = TRUE
			C.open()
			to_chat(user,"<span class='warning'>We open the container restraining us!</span>")

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/O)
	if(istype(O,/obj/effect/spider/cocoon))
		var/obj/effect/spider/cocoon/C = O
		if(C && user.loc == C)
			qdel(C) //The cocoon's destroy will move the changeling outside of it without interference
			to_chat(user,"<span class='warning'>We dissolve the cocoon!</span>")

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_electropack(mob/living/carbon/human/user, obj/O)
	if(istype(user.back,/obj/item/device/radio/electropack))
		var/obj/item/device/radio/electropack/E = O
		if(E && user.back == E)
			user.unEquip(E)
			E.visible_message("<span class='warning'>[E] dissolves into a puddle of sizzling goop.</span>")
			qdel(E)

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_horsehead(mob/living/carbon/human/user, obj/O)
	if(istype(O,/obj/item/clothing/mask/horsehead))
		var/obj/item/clothing/mask/horsehead/Horse = O
		if(Horse && user.wear_mask  == Horse)
			user.unEquip(Horse)
			Horse.visible_message("<span class='warning'>[Horse] dissolves into a puddle of sizzling goop.</span>")
			qdel(Horse)
