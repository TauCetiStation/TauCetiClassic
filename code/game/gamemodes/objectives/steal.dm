var/global/list/possible_items_for_steal = list()

#define ADD_TO_POIFS_LIST(type) ADD_TO_GLOBAL_LIST(type, possible_items_for_steal)
ADD_TO_POIFS_LIST(/obj/item/weapon/gun/energy/laser/selfcharging/captain)
ADD_TO_POIFS_LIST(/obj/item/weapon/hand_tele)
ADD_TO_POIFS_LIST(/obj/item/weapon/rcd)
ADD_TO_POIFS_LIST(/obj/item/weapon/tank/jetpack)
ADD_TO_POIFS_LIST(/obj/item/clothing/under/rank/captain)
ADD_TO_POIFS_LIST(/obj/item/device/aicard)
ADD_TO_POIFS_LIST(/obj/item/clothing/shoes/magboots)
ADD_TO_POIFS_LIST(/obj/item/blueprints)
ADD_TO_POIFS_LIST(/obj/item/clothing/suit/space/nasavoid)
ADD_TO_POIFS_LIST(/obj/item/weapon/tank)
ADD_TO_POIFS_LIST(/obj/item/slime_extract)
ADD_TO_POIFS_LIST(/obj/item/weapon/reagent_containers/food/snacks/meat/corgi)
ADD_TO_POIFS_LIST(/obj/item/clothing/under/rank/research_director)
ADD_TO_POIFS_LIST(/obj/item/clothing/under/rank/chief_engineer)
ADD_TO_POIFS_LIST(/obj/item/clothing/under/rank/chief_medical_officer)
ADD_TO_POIFS_LIST(/obj/item/clothing/under/rank/head_of_security)
ADD_TO_POIFS_LIST(/obj/item/clothing/under/rank/head_of_personnel)
ADD_TO_POIFS_LIST(/obj/item/weapon/reagent_containers/hypospray/cmo)
ADD_TO_POIFS_LIST(/obj/item/weapon/pinpointer)
ADD_TO_POIFS_LIST(/obj/item/clothing/suit/armor/laserproof)
ADD_TO_POIFS_LIST(/obj/item/weapon/reagent_containers/spray/extinguisher/golden)
ADD_TO_POIFS_LIST(/obj/item/weapon/gun/energy/gun/nuclear)
ADD_TO_POIFS_LIST(/obj/item/weapon/pickaxe/drill/diamond_drill)
ADD_TO_POIFS_LIST(/obj/item/weapon/storage/backpack/holding)
ADD_TO_POIFS_LIST(/obj/item/weapon/stock_parts/cell/hyper)
ADD_TO_POIFS_LIST(/obj/item/stack/sheet/mineral/diamond)
ADD_TO_POIFS_LIST(/obj/item/stack/sheet/mineral/gold)
ADD_TO_POIFS_LIST(/obj/item/stack/sheet/mineral/uranium)
#undef ADD_TO_POIFS_LIST

/datum/objective/steal
	conflicting_types = list(
		/datum/objective/steal
	)

	var/obj/item/steal_target
	var/target_name

	var/static/possible_items[] = list(
		"the captain's antique laser gun" = /obj/item/weapon/gun/energy/laser/selfcharging/captain,
		"a hand teleporter" = /obj/item/weapon/hand_tele,
		"an RCD" = /obj/item/weapon/rcd,
		"a jetpack" = /obj/item/weapon/tank/jetpack,
		"a captain's jumpsuit" = /obj/item/clothing/under/rank/captain,
		"a functional AI" = /obj/item/device/aicard,
		"a pair of magboots" = /obj/item/clothing/shoes/magboots,
		"the station blueprints" = /obj/item/blueprints,
		"a nasa voidsuit" = /obj/item/clothing/suit/space/nasavoid,
		"28 moles of phoron (full tank)" = /obj/item/weapon/tank,
		"a sample of slime extract" = /obj/item/slime_extract,
		"a piece of corgi meat" = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi,
		"a research director's jumpsuit" = /obj/item/clothing/under/rank/research_director,
		"a chief engineer's jumpsuit" = /obj/item/clothing/under/rank/chief_engineer,
		"a chief medical officer's jumpsuit" = /obj/item/clothing/under/rank/chief_medical_officer,
		"a head of security's jumpsuit" = /obj/item/clothing/under/rank/head_of_security,
		"a head of personnel's jumpsuit" = /obj/item/clothing/under/rank/head_of_personnel,
		"the hypospray" = /obj/item/weapon/reagent_containers/hypospray/cmo,
		"the captain's pinpointer" = /obj/item/weapon/pinpointer,
		"an ablative armor vest" = /obj/item/clothing/suit/armor/laserproof,
		"the golden fire extinguisher" = /obj/item/weapon/reagent_containers/spray/extinguisher/golden,
	)

	var/static/possible_items_special[] = list(
		/*"nuclear authentication disk" = /obj/item/weapon/disk/nuclear,*///Broken with the change to nuke disk making it respawn on z level change.
		"nuclear gun" = /obj/item/weapon/gun/energy/gun/nuclear,
		"diamond drill" = /obj/item/weapon/pickaxe/drill/diamond_drill,
		"bag of holding" = /obj/item/weapon/storage/backpack/holding,
		"hyper-capacity cell" = /obj/item/weapon/stock_parts/cell/hyper,
		"10 diamonds" = /obj/item/stack/sheet/mineral/diamond,
		"50 gold bars" = /obj/item/stack/sheet/mineral/gold,
		"25 refined uranium bars" = /obj/item/stack/sheet/mineral/uranium,
	)

/datum/objective/steal/set_target(item_name)
	target_name = item_name
	steal_target = possible_items[target_name]
	if (!steal_target )
		steal_target = possible_items_special[target_name]
	explanation_text = "Steal [target_name]."
	return steal_target


/datum/objective/steal/find_target()
	set_target(pick(possible_items))
	return TRUE

/datum/objective/steal/find_pseudorandom_target(list/all_objectives)
	var/list/conflicting_objectives = list()
	for(var/datum/objective/steal/O in all_objectives)
		if(O.type in conflicting_types)
			conflicting_objectives += O

	if(!conflicting_objectives.len)
		return FALSE

	var/datum/objective/steal/enemy_objective = pick(conflicting_objectives)
	set_target(enemy_objective.target_name)

	return TRUE

/datum/objective/steal/select_target()
	var/list/possible_items_all = possible_items+possible_items_special+"custom"
	var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
	if (!new_target)
		return FALSE
	if (new_target == "custom")
		var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!custom_target)
			return FALSE
		var/tmp_obj = new custom_target
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		custom_name = sanitize_safe(input("Enter target name:", "Objective target", input_default(custom_name)) as text|null)
		if (!custom_name)
			return FALSE
		target_name = custom_name
		steal_target = custom_target
		explanation_text = "Steal [target_name]."
	else
		set_target(new_target)
	auto_target = FALSE
	return TRUE

/datum/objective/steal/check_completion()
	if(!steal_target || !owner.current)	return OBJECTIVE_LOSS
	if(!isliving(owner.current))	return OBJECTIVE_LOSS
	var/list/all_items = owner.current.GetAllContents()
	switch (target_name)
		if("28 moles of phoron (full tank)","10 diamonds","50 gold bars","25 refined uranium bars")
			var/target_amount = text2num(target_name)//Non-numbers are ignored.
			var/found_amount = 0.0//Always starts as zero.

			for(var/obj/item/I in all_items) //Check for phoron tanks
				if(istype(I, steal_target))
					found_amount += (target_name == "28 moles of phoron (full tank)" ? (I:air_contents:gas["phoron"]) : (I:amount))
			return found_amount>=target_amount

		if("50 coins (in bag)")
			var/obj/item/weapon/moneybag/B = locate() in all_items

			if(B)
				var/target = text2num(target_name)
				var/found_amount = 0.0
				for(var/obj/item/weapon/coin/C in B)
					found_amount++
				return found_amount>=target

		if("a functional AI")
			for(var/obj/item/device/aicard/C in all_items) //Check for ai card
				for(var/mob/living/silicon/ai/M in C)
					if(istype(M, /mob/living/silicon/ai) && M.stat != DEAD) //See if any AI's are alive inside that card.
						return OBJECTIVE_WIN

			for(var/obj/item/clothing/suit/space/space_ninja/S in all_items) //Let an AI downloaded into a space ninja suit count
				if(S.AI && S.AI.stat != DEAD)
					return OBJECTIVE_WIN
			for(var/mob/living/silicon/ai/ai in ai_list)
				if(ai.stat == DEAD)
					continue
				if(istype(ai.loc, /turf))
					var/area/check_area = get_area(ai)
					if(istype(check_area, /area/shuttle/escape/centcom))
						return OBJECTIVE_WIN
					if(istype(check_area, /area/shuttle/escape_pod1/centcom))
						return OBJECTIVE_WIN
					if(istype(check_area, /area/shuttle/escape_pod2/centcom))
						return OBJECTIVE_WIN
					if(istype(check_area, /area/shuttle/escape_pod3/centcom))
						return OBJECTIVE_WIN
					if(istype(check_area, /area/shuttle/escape_pod4/centcom))
						return OBJECTIVE_WIN
		else

			for(var/obj/I in all_items) //Check for items
				if(istype(I, steal_target))
					return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
