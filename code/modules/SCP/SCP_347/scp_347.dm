/datum/species/scp347
	name = "Invisible girl"
	icobase = 'code/modules/SCP/SCP_347/r_scp347.dmi'
	deform = 'code/modules/SCP/SCP_347/r_scp347.dmi'
	dietflags = DIET_OMNI
	eyes = "blank_eyes"
	damage_mask = FALSE //No blood on body

	flags = list(
	HAS_LIPS = TRUE
	,NO_BLOOD = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	brute_mod = 1
	burn_mod = 1
	oxy_mod = 1
	tox_mod = 1
	brain_mod = 1
	speed_mod = 0

	has_gendered_icons = FALSE

/mob/living/carbon/human/scp347
	real_name = "SCP-347"
	desc = "Invisible girl, probably looks very cute."

/mob/living/carbon/human/scp347/atom_init(mapload)
	. = ..(mapload, "Invisible girl")
	universal_speak = TRUE
	universal_understand = TRUE
	gender = FEMALE
	equip_to_slot_or_del(new /obj/item/clothing/under/sundress(src), SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/heels/alternate(src), SLOT_SHOES)
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/scp347_swallowitem(src))
	AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/scp347_picklock(src))

/mob/living/carbon/human/scp347/examine(mob/user)
	to_chat(user, "<b><span class = 'info'><big>SCP-347</big></span></b> - [desc]")
	return ..(user)

/mob/living/carbon/human/proc/is_completely_naked()
	if(!w_uniform && !wear_suit && !wear_mask && !gloves && !head && !glasses && !back && !l_hand && !r_hand && !shoes)
		return TRUE
	return FALSE

/obj/effect/proc_holder/spell/aoe_turf/scp347_swallowitem
	name = "Swallow item"
	desc = ""
	panel = "SCP"
	charge_max = 10
	clothes_req = 0
	range = 1
	var/list/blacklist = list(/obj/item/weapon/grab)
	var/maxwclass = ITEM_SIZE_NORMAL //ITEM_SIZE_TINY ITEM_SIZE_SMALL ITEM_SIZE_NORMAL ITEM_SIZE_LARGE ITEM_SIZE_HUGE
	var/obj/item/holding = null

/obj/effect/proc_holder/spell/aoe_turf/scp347_swallowitem/cast(list/targets)
	var/mob/living/carbon/human/H = usr

	if(H.is_busy(H))
		return

	if(holding)
		H.visible_message("<span class='notice'>[H] starts to regurgitate something</span>", \
							 "<span class='notice'>You start to regurgitate [holding]</span>")
		if(!do_mob(H, H, 50))
			to_chat(H, "<span class='warning'>I was interrupted!</span>")
			return
		holding.forceMove(H.loc)
		H.visible_message("<span class='notice'>[H] regurgitates an item</span>", \
							 "<span class='notice'>You regurgitate [holding]</span>")
		holding = null
		name = "Swallow item"
	else
		var/obj/item/Item = H.get_active_hand()
		if(!istype(Item))
			to_chat(H, "<span class='warning'>I must be holding an item.</span>")
			return
		for(var/X in blacklist)
			if(istype(Item,X))
				to_chat(H, "<span class='warning'>I can't swallow this item.</span>")
				return
		if(Item.w_class > maxwclass)
			to_chat(H, "<span class='warning'>This item is too big to swallow.</span>")
			return

		H.visible_message("<span class='notice'>[H] attempts to swallow [Item]</span>", \
							 "<span class='notice'>You attempt to swallow [Item]</span>")
		if(!do_mob(H, H, 100))
			to_chat(H, "<span class='warning'>I was interrupted!</span>")
			return

		H.remove_from_mob(Item)
		if(!Item)
			return
		holding = Item
		Item.forceMove(H)
		name = "Regurgitate item"

		H.visible_message("<span class='notice'>[H] swallowed an item</span>", \
							 "<span class='notice'>You swallowed [Item]</span>")

/obj/effect/proc_holder/spell/aoe_turf/scp347_picklock
	name = "Pick a lock"
	desc = ""
	panel = "SCP"
	charge_max = 10
	clothes_req = 0
	range = 1
	var/picklock_time = 450
	var/bark_delay_min = 100
	var/bark_delay_max = 200
	var/timer_active = FALSE
	var/active = FALSE
	var/pickTarget = null

/obj/effect/proc_holder/spell/aoe_turf/scp347_picklock/cast(list/targets)
	var/mob/living/carbon/human/H = usr

	if(H.is_busy(H) || H.restrained())
		return

	var/list/mytargets = list(H.loc, get_step(H.loc, H.dir), get_step(H.loc, EAST), get_step(H.loc, WEST), get_step(H.loc, NORTH), get_step(H.loc, SOUTH))
	for(var/turf/T in mytargets)
		for(var/obj/machinery/door/door in T.contents)
			if(door.density)
				if(H.is_completely_naked())
					H.visible_message("<span class='notice'>You hear some metal noise</span>", \
										 "<span class='notice'>You silently start to picklock [door]</span>")
				else
					H.visible_message("<span class='warning'>[H] starts to do something with [door]'s access panel</span>", \
										 "<span class='warning'>You visible start to picklock [door]</span>")
				active = TRUE
				pickTarget = door
				if(!timer_active)
					timer_active = TRUE
					addtimer(CALLBACK(src, .proc/bark, H), rand(bark_delay_min,bark_delay_max))
				if(!do_mob(H, door, picklock_time))
					to_chat(H, "<span class='warning'>I was interrupted!</span>")
					active = FALSE
					return
				active = FALSE
				if(istype(door, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/A = door
					INVOKE_ASYNC(A, /obj/machinery/door/airlock/proc/unbolt)
				INVOKE_ASYNC(door, /obj/machinery/door/proc/open)
				return

		for(var/obj/structure/closet/C in T.contents)
			if(C.density)
				if(H.is_completely_naked())
					H.visible_message("<span class='notice'>You hear some metal noise</span>", \
										 "<span class='notice'>You silently start to picklock [C]</span>")
				else
					H.visible_message("<span class='warning'>[H] starts to do something with [C]'s access panel</span>", \
										 "<span class='warning'>You visible start to picklock [C]</span>")
				active = TRUE
				pickTarget = C
				if(!timer_active)
					timer_active = TRUE
					addtimer(CALLBACK(src, .proc/bark, H), rand(bark_delay_min,bark_delay_max))
				if(!do_mob(H, C, picklock_time))
					to_chat(H, "<span class='warning'>I was interrupted!</span>")
					active = FALSE
					return
				active = FALSE
				C.locked = 0
				INVOKE_ASYNC(C, /obj/structure/closet/proc/open)
				return
	return

/obj/effect/proc_holder/spell/aoe_turf/scp347_picklock/proc/bark(mob/living/carbon/human/H)
	if(!active)
		timer_active = FALSE
		return

	if(H.is_completely_naked())
		if(prob(25))
			H.visible_message("<span class='notice'>You hear some metal noise</span>", \
						      "<span class='notice'>You make some noise while picklocking [pickTarget]</span>")
	else
		H.visible_message("<span class='warning'>[H] continues to do something with [pickTarget]'s access panel</span>", \
						  "<span class='warning'>You make a noise while visible picklocking [pickTarget]</span>")

	addtimer(CALLBACK(src, .proc/bark, H), rand(bark_delay_min,bark_delay_max))