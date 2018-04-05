/obj/effect/proc_holder/changeling/biodegrade
	name = "Biodegrade"
	desc = "Dissolves restraints or other objects preventing free movement."
	helptext = "This is obvious to nearby people, and can destroy \
		standard restraints and closets."
	chemical_cost = 30 //High cost to prevent spam
	genomecost = 2
	req_human = 1
	genetic_damage = 10
	max_genetic_damage = 5
	req_stat = UNCONSCIOUS


/obj/effect/proc_holder/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = FALSE // only one form of shackles removed per use
	if(user.back && istype(user.back, /obj/item/device/radio/electropack))
		user.visible_message("<span class='warning'>[user] vomits a glob of \
			acid on \his [user.back]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our \
			electropack!</span>")
		addtimer(CALLBACK(src, .proc/dissolve_electropack, user, user.back), 30)
		used = TRUE

	if(!used && user.wear_mask && (istype(user.wear_mask, /obj/item/clothing/mask/horsehead)|| \
		istype(user.wear_mask, /obj/item/clothing/mask/pig) || istype(user.wear_mask, /obj/item/clothing/mask/cowmask) \
		|| istype(user.wear_mask, /obj/item/clothing/head/chicken)))
		user.visible_message("<span class='warning'>[user] vomits a glob of \
			acid on \his [user.wear_mask ]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our \
			mask!</span>")
		addtimer(CALLBACK(src, .proc/dissolve_horsehead, user, user.wear_mask), 30)
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
		addtimer(CALLBACK(src, .proc/dissolve_handcuffs, user, O), 30)
		used = TRUE

	if(user.wear_suit && istype(user.wear_suit, /obj/item/clothing/suit/straight_jacket) && !used)
		user.visible_message("<span class='warning'>[user] vomits a glob \
			of acid across the front of \his [user.wear_suit]!</span>", \
			"<span class='warning'>We vomit acidic ooze onto our straight \
			jacket!</span>")
		addtimer(CALLBACK(src, .proc/dissolve_straightjacket, user, user.wear_suit), 30)
		used = TRUE


	if(istype(user.loc, /obj/structure/closet) && !used)
		user.loc.visible_message("<span class='warning'>[user.loc]'s hinges suddenly \
			begin to melt and run!</span>")
		to_chat(user,"<span class='warning'>We vomit acidic goop onto the \
			interior of [user.loc]!</span>")
		addtimer(CALLBACK(src, .proc/open_closet, user, user.loc), 70)
		used = TRUE

	if(istype(user.loc, /obj/effect/spider/cocoon) && !used)
		user.loc.visible_message("<span class='warning'>[user.loc] shifts and starts to fall apart!</span>")
		to_chat(user,"<span class='warning'>We secrete acidic enzymes from our skin and begin melting our cocoon...</span>")
		addtimer(CALLBACK(src, .proc/dissolve_cocoon, user, user.loc), 25) //Very short because it's just webs
		used = TRUE

	if(used)
		feedback_add_details("changeling_powers","BD")
	return 1

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/item/weapon/handcuffs/O)
	if(istype(O) && user.handcuffed == O)
		O.visible_message("<span class='warning'>[O] dissolves into a puddle of sizzling goop.</span>")
		qdel(O)

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_straightjacket(mob/living/carbon/human/user, obj/item/clothing/suit/straight_jacket/O)
	if(istype(O) && user.wear_suit == O)
		O.visible_message("<span class='warning'>[O] dissolves into a puddle of sizzling goop.</span>")
		qdel(O)

/obj/effect/proc_holder/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/O)
	if(istype(O) && user.loc == O)
		var/obj/structure/closet/C = O
		C.visible_message("<span class='warning'>[C]'s door breaks and opens!</span>")
		C.welded = FALSE
		C.locked = FALSE
		C.broken = TRUE
		C.open(TRUE)
		to_chat(user,"<span class='warning'>We open the container restraining us!</span>")

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/effect/spider/cocoon/O)
	if(istype(O) && user.loc == O)
		qdel(O) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user,"<span class='warning'>We dissolve the cocoon!</span>")

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_electropack(mob/living/carbon/human/user, obj/item/device/radio/electropack/O)
	if(istype(O) && user.back == O)
		O.visible_message("<span class='warning'>[O] dissolves into a puddle of sizzling goop.</span>")
		qdel(O)

/obj/effect/proc_holder/changeling/biodegrade/proc/dissolve_horsehead(mob/living/carbon/human/user, obj/item/clothing/mask/O)
	if(user.wear_mask == O && (istype(O, /obj/item/clothing/mask/horsehead)|| \
		istype(O, /obj/item/clothing/mask/pig) || istype(O, /obj/item/clothing/mask/cowmask) \
		|| istype(O, /obj/item/clothing/head/chicken)))
		O.visible_message("<span class='warning'>[O] dissolves into a puddle of sizzling goop.</span>")
		qdel(O)