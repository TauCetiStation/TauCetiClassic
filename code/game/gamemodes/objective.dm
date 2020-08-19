//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
var/global/list/all_objectives = list()

/datum/objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/explanation_text = "Nothing"	//What that person is supposed to do.
	var/datum/mind/target = null		//If they are focused on a particular person.
	var/target_amount = 0				//If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = OBJECTIVE_LOSS   //currently only used for custom objectives.

	var/list/protected_jobs = list("Velocity Officer", "Velocity Chief", "Velocity Medical Doctor") // They can't be targets of any objective.

/datum/objective/New(var/text)
	all_objectives |= src
	if(text)
		explanation_text = text

/datum/objective/Destroy()
	all_objectives -= src
	return ..()

/datum/objective/proc/check_completion()
	return completed

/datum/objective/proc/find_target()
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target.assigned_role in protected_jobs)
			continue
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD))
			possible_targets += possible_target
	if(possible_targets.len > 0)
		target = pick(possible_targets)


/datum/objective/proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
	for(var/datum/mind/possible_target in SSticker.minds)
		if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
			target = possible_target
			break



/datum/objective/assassinate/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/assassinate/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/assassinate/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current) || !SSmapping.has_level(target.current.z) || !target.current.ckey) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN




/datum/objective/mutiny/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/mutiny/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Assassinate [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/mutiny/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey)
			return OBJECTIVE_WIN
		var/turf/T = get_turf(target.current)
		if(T && !is_station_level(T.z))			//If they leave the station they count as dead for this
			return OBJECTIVE_HALFWIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN


/datum/objective/mutiny/rp/find_target()
	..()
	if(target && target.current)
		explanation_text = "Assassinate, capture or convert [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/mutiny/rp/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Capture, convert or exile from station [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]. Assassinate if you have no choice."
	else
		explanation_text = "Free Objective"
	return target

	// less violent rev objectives
/datum/objective/mutiny/rp/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return OBJECTIVE_HALFWIN

		//assume that only carbon mobs can become rev heads for now
		if(target.current:handcuffed || !ishuman(target.current))
			return OBJECTIVE_WIN

		// Check if they're converted
		if(istype(SSticker.mode, /datum/game_mode/revolution))
			if(target in SSticker.mode:revolutionaries)
				return OBJECTIVE_WIN

		var/turf/T = get_turf(target.current)
		if(T && !is_station_level(T.z))
			return OBJECTIVE_WIN

		return OBJECTIVE_LOSS

	return OBJECTIVE_WIN

/datum/objective/anti_revolution/execute/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/anti_revolution/execute/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has extracted confidential information above their clearance. Execute \him[target.current]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/execute/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current))
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/anti_revolution/brig
	var/already_completed = 0

/datum/objective/anti_revolution/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [target.assigned_role] for 20 minutes to set an example."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/anti_revolution/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Brig [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] for 20 minutes to set an example."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/brig/check_completion()
	if(already_completed)
		return OBJECTIVE_WIN

	if(target && target.current)
		if(target.current.stat == DEAD)
			return OBJECTIVE_LOSS
		if(target.is_brigged(10 * 60 * 10))
			already_completed = 1
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_LOSS

/datum/objective/anti_revolution/demote/find_target()
	..()
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [target.assigned_role]  has been classified as harmful to NanoTrasen's goals. Demote \him[target.current] to assistant."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "[target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] has been classified as harmful to NanoTrasen's goals. Demote \him[target.current] to assistant."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/anti_revolution/demote/check_completion()
	if(target && target.current && istype(target,/mob/living/carbon/human))
		var/obj/item/weapon/card/id/I = target.current:wear_id
		if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			I = P.id

		if(!istype(I)) return OBJECTIVE_WIN

		if(I.assignment == "Test Subject")
			return OBJECTIVE_WIN
		else
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/debrain/find_target()//I want braaaainssss
	..()
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/debrain/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Steal the brain of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return OBJECTIVE_WIN
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return OBJECTIVE_LOSS
	if( !target.current || !isbrain(target.current) )
		return OBJECTIVE_LOSS
	var/atom/A = target.current
	while(A.loc)			//check to see if the brainmob is on our person
		A = A.loc
		if(A == owner.current)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/dehead/find_target()
	..()
	if(target && target.current)
		explanation_text = "Put the head of [target.current.real_name] in biogel can and steal it."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/dehead/find_target_by_role(role, role_type=0)
	..()
	if(target && target.current)
		explanation_text = "Steal the head of [target.current.real_name] the [!role_type ? target.assigned_role : target.special_role], make shure that head is stored in the biogel can."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/dehead/check_completion()
	if(!target)//If it's a free objective.
		return OBJECTIVE_WIN
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return OBJECTIVE_LOSS
	var/list/all_items = owner.current.get_contents()
	for(var/obj/item/device/biocan/B in all_items)
		if(B.brainmob && B.brainmob == target.current)
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_LOSS


/datum/objective/protect/find_target()//The opposite of killing a dude.
	..()
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/protect/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/protect/check_completion()
	if(!target)			//If it's a free objective.
		return OBJECTIVE_WIN
	if(target.current)
		if(target.current.stat == DEAD || issilicon(target.current) || isbrain(target.current))
			return OBJECTIVE_LOSS
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS


/datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping alone."

/datum/objective/hijack/check_completion()
	if(!owner.current || owner.current.stat)
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(issilicon(owner.current))
		return OBJECTIVE_LOSS
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/list/protected_mobs = list(/mob/living/silicon/ai, /mob/living/silicon/pai)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)	continue
		if (player.mind && (player.mind != owner))
			if(player.stat != DEAD)			//they're not dead!
				if(get_turf(player) in shuttle)
					return OBJECTIVE_LOSS
	return OBJECTIVE_WIN


/datum/objective/block
	explanation_text = "Do not allow any organic lifeforms to escape on the shuttle alive."


/datum/objective/block/check_completion()
	if(!istype(owner.current, /mob/living/silicon))
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(!owner.current)
		return OBJECTIVE_LOSS
	var/area/shuttle = locate(/area/shuttle/escape/centcom)
	var/protected_mobs[] = list(/mob/living/silicon/ai, /mob/living/silicon/pai, /mob/living/silicon/robot)
	for(var/mob/living/player in player_list)
		if(player.type in protected_mobs)	continue
		if (player.mind)
			if (player.stat != DEAD)
				if (get_turf(player) in shuttle)
					return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

/datum/objective/silence/check_completion()
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS

	for(var/mob/living/player in player_list)
		if(player == owner.current)
			continue
		if(player.mind)
			if(player.stat != DEAD)
				var/turf/T = get_turf(player)
				if(!T)	continue
				switch(T.loc.type)
					if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom)
						return OBJECTIVE_LOSS
	return OBJECTIVE_WIN


/datum/objective/escape
	explanation_text = "Escape on the shuttle or an escape pod alive and free."


/datum/objective/escape/check_completion()
	if(issilicon(owner.current))
		return OBJECTIVE_LOSS
	if(isbrain(owner.current))
		return OBJECTIVE_LOSS
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	if(!owner.current || owner.current.stat ==2)
		return OBJECTIVE_LOSS
	var/turf/location = get_turf(owner.current.loc)
	if(!location)
		return OBJECTIVE_LOSS

	if(istype(location, /turf/simulated/shuttle/floor4)) // Fails traitors if they are in the shuttle brig -- Polymorph
		if(istype(owner.current, /mob/living/carbon))
			var/mob/living/carbon/C = owner.current
			if (!C.restrained())
				return OBJECTIVE_WIN
		return OBJECTIVE_LOSS

	var/area/check_area = location.loc
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
		return OBJECTIVE_LOSS



/datum/objective/survive
	explanation_text = "Stay alive until the end."

/datum/objective/survive/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return OBJECTIVE_LOSS		//Brains no longer win survive objectives. --NEO
	if(issilicon(owner.current) && owner.current != owner.original)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

// Similar to the anti-rev objective, but for traitors
/datum/objective/brig
	var/already_completed = 0

/datum/objective/brig/find_target()
	..()
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [target.assigned_role] brigged for 10 minutes."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/brig/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Have [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role] brigged for 10 minutes."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/brig/check_completion()
	if(already_completed)
		return OBJECTIVE_WIN

	if(target && target.current)
		if(target.current.stat == DEAD)
			return OBJECTIVE_LOSS
		// Make the actual required time a bit shorter than the official time
		if(target.is_brigged(10 * 60 * 5))
			already_completed = 1
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_LOSS

// Harm a crew member, making an example of them
/datum/objective/harm
	var/already_completed = 0

/datum/objective/harm/find_target()
	..()
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/harm/find_target_by_role(role, role_type=0)
	..(role, role_type)
	if(target && target.current)
		explanation_text = "Make an example of [target.current.real_name], the [!role_type ? target.assigned_role : target.special_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/harm/check_completion()
	if(already_completed)
		return OBJECTIVE_WIN

	if(target && target.current && istype(target.current, /mob/living/carbon/human))
		if(target.current.stat == DEAD)
			return OBJECTIVE_LOSS

		var/mob/living/carbon/human/H = target.current
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & ORGAN_BROKEN)
				already_completed = 1
				return OBJECTIVE_WIN
			if(BP.is_stump)
				already_completed = 1
				return OBJECTIVE_WIN

		var/obj/item/organ/external/head/BP = H.bodyparts_by_name[BP_HEAD]
		if(BP.disfigured)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS


/datum/objective/nuclear
	explanation_text = "Destroy the station with a nuclear device."



/datum/objective/steal
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


/datum/objective/steal/proc/set_target(item_name)
	target_name = item_name
	steal_target = possible_items[target_name]
	if (!steal_target )
		steal_target = possible_items_special[target_name]
	explanation_text = "Steal [target_name]."
	return steal_target


/datum/objective/steal/find_target()
	return set_target(pick(possible_items))


/datum/objective/steal/proc/select_target()
	var/list/possible_items_all = possible_items+possible_items_special+"custom"
	var/new_target = input("Select target:", "Objective target", steal_target) as null|anything in possible_items_all
	if (!new_target) return
	if (new_target == "custom")
		var/obj/item/custom_target = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if (!custom_target) return
		var/tmp_obj = new custom_target
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		custom_name = sanitize_safe(input("Enter target name:", "Objective target", input_default(custom_name)) as text|null)
		if (!custom_name) return
		target_name = custom_name
		steal_target = custom_target
		explanation_text = "Steal [target_name]."
	else
		set_target(new_target)
	return steal_target

/datum/objective/steal/check_completion()
	if(!steal_target || !owner.current)	return OBJECTIVE_LOSS
	if(!isliving(owner.current))	return OBJECTIVE_LOSS
	var/list/all_items = owner.current.get_contents()
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



/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research levels."
	return target_amount


/datum/objective/download/check_completion()
	if(!ishuman(owner.current))
		return OBJECTIVE_LOSS
	if(!owner.current || owner.current.stat == DEAD)
		return OBJECTIVE_LOSS
	if(!(istype(owner.current:wear_suit, /obj/item/clothing/suit/space/space_ninja)&&owner.current:wear_suit:s_initialized))
		return OBJECTIVE_LOSS
	var/current_amount
	var/obj/item/clothing/suit/space/space_ninja/S = owner.current:wear_suit
	if(!S.stored_research.len)
		return OBJECTIVE_LOSS
	else
		for(var/datum/tech/current_data in S.stored_research)
			if(current_data.level>1)	current_amount+=(current_data.level-1)
	if(current_amount<target_amount)	return OBJECTIVE_LOSS
	return OBJECTIVE_WIN



/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount


/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/holding/A = locate()
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(M.stat==2)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
		captured_amount+=0.1
	for(var/mob/living/carbon/xenomorph/larva/M in A)//Larva are important for research.
		if(M.stat==2)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/xenomorph/humanoid/M in A)//Aliens are worth twice as much as humans.
		if(istype(M, /mob/living/carbon/xenomorph/humanoid/queen))//Queens are worth three times as much as humans.
			if(M.stat==2)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat==2)
			captured_amount+=1
			continue
		captured_amount+=2
	if(captured_amount<target_amount)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN



/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	if (SSticker)
		var/n_p = 1 //autowin
		if (SSticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/dead/new_player/P in new_player_list)
				if(P.client && P.ready && P.mind!=owner)
					n_p ++
		else if (SSticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P in human_list)
				if(P.client && !(P.mind in SSticker.mode.changelings) && P.mind!=owner)
					n_p ++
		target_amount = min(target_amount, n_p)

	explanation_text = "Absorb [target_amount] compatible genomes."
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner && owner.changeling && owner.changeling.absorbed_dna && (owner.changeling.absorbedcount >= target_amount))
		return OBJECTIVE_WIN
	else
		return OBJECTIVE_LOSS



/* Isn't suited for global objectives
//---------CULTIST----------
/datum/objective/eldergod
	explanation_text = "Summon Nar-Sie via the use of an appropriate rune. It will only work if nine cultists stand on and around it."

/datum/objective/eldergod/check_completion()
	if(eldergod) //global var, defined in rune4.dm
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/survivecult
	var/num_cult
	explanation_text = "Our knowledge must live on. Make sure at least 5 acolytes escape on the shuttle to spread their work on an another station."

/datum/objective/survivecult/check_completion()
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS
	var/cultists_escaped = 0
	var/area/shuttle/escape/centcom/C = /area/shuttle/escape/centcom
	for(var/turf/T in	get_area_turfs(C.type))
		for(var/mob/living/carbon/H in T)
			if(iscultist(H))
				cultists_escaped++
	if(cultists_escaped>=5)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/sacrifice/proc/find_target() //stolen from traitor target objective
 //I don't know how to make it work with the rune otherwise, so I'll do it via a global var, sacrifice_target, defined in rune15.dm
	var/list/possible_targets = call(/datum/game_mode/cult/proc/get_unconvertables)()
	if(possible_targets.len > 0)
		sacrifice_target = pick(possible_targets)
	if(sacrifice_target && sacrifice_target.current)
		explanation_text = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell join blood) and three acolytes to do so."
	else
		explanation_text = "Free Objective"
	return sacrifice_target

/datum/objective/sacrifice/check_completion() //again, calling on a global list defined in rune15.dm
	if(sacrifice_target.current in sacrificed)
		return OBJECTIVE_WIN
	else
		return OBJECTIVE_LOSS
//-------ENDOF CULTIST------
*/

//Meme objectives
/datum/objective/meme_attune/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	explanation_text = "Attune [target_amount] humanoid brains."
	return target_amount

/datum/objective/meme_attune/check_completion()
	if(owner?.current)
		if (istype(owner.current, /mob/living/parasite/meme))
			var/mob/living/parasite/meme/M = owner.current
			if (M.indoctrinated.len >= target_amount)
				return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//Borer objective(s).
/datum/objective/borer_survive
	explanation_text = "Survive in a host until the end of the round."

/datum/objective/borer_survive/check_completion()
	if(owner && owner.current)
		var/mob/living/simple_animal/borer/B = owner.current
		if(istype(B) && B.stat < DEAD && B.host && B.host.stat < DEAD)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/borer_reproduce
	explanation_text = "Reproduce at least once."

/datum/objective/borer_reproduce/check_completion()
	if(owner && owner.current)
		var/mob/living/simple_animal/borer/B = owner.current
		if(istype(B) && B.has_reproduced)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//Vox heist objectives.

/datum/objective/heist/proc/choose_target()
	return

/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list("Roboticist" , "Medical Doctor" , "Chemist" , "Station Engineer")
	var/list/possible_targets = list()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (possible_target.assigned_role != "MODE"))

			possible_targets += possible_target
			for(var/role in roles)
				if(possible_target.assigned_role == role)
					priority_targets += possible_target
					continue

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take them alive."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/heist/kidnap/check_completion()
	if(target && target.current)
		if (target.current.stat == DEAD)
			return FALSE // They're dead. Fail.
		//if (!target.current.restrained())
		//	return OBJECTIVE_LOSS // They're loose. Close but no cigar.
		if(get_area(target) == locate(/area/shuttle/vox/arkship))
			return TRUE
	else
		return FALSE

/datum/objective/heist/loot/choose_target()
	var/loot = "an object"
	switch(rand(1, 7))
		if(1)
			target = /obj/structure/particle_accelerator
			target_amount = 6
			loot = "a complete particle accelerator (6 components)"
		if(2)
			target = /obj/machinery/the_singularitygen
			target_amount = 1
			loot = "a Gravitational Singularity Generator"
		if(3)
			target = /obj/machinery/power/emitter
			target_amount = 4
			loot = "four emitters"
		if(4)
			target = /obj/machinery/nuclearbomb
			target_amount = 1
			loot = "a nuclear bomb"
		if(5)
			target = /obj/item/weapon/gun
			target_amount = 6
			loot = "six guns"
		if(6)
			target = /obj/item/weapon/gun/energy
			target_amount = 4
			loot = "four energy guns"
		if(7)
			target = /obj/item/weapon/gun/energy/ionrifle
			target_amount = 1
			loot = "an ion rifle"

	explanation_text = "We are lacking in hardware. Steal [loot]."

/datum/objective/heist/loot/check_completion()
	var/total_amount = 0

	for(var/obj/O in locate(/area/shuttle/vox/arkship))
		if(istype(O,target)) total_amount++
		for(var/obj/I in O.contents)
			if(istype(I, target))
				total_amount++
		if(total_amount >= target_amount)
			return TRUE

	var/datum/game_mode/heist/H = SSticker.mode
	for(var/datum/mind/raider in H.raiders)
		if(raider.current)
			for(var/obj/O in raider.current.get_contents())
				if(istype(O,target))
					total_amount++
				if(total_amount >= target_amount)
					return TRUE

	return FALSE

/datum/objective/heist/salvage/choose_target()
	switch(rand(1, 3))
		if(1)
			target = "metal"
			target_amount = pick(150, 200)
		if(2)
			target = "glass"
			target_amount = pick(150, 200)
		if(3)
			target = "plasteel"
			target_amount = pick(20, 30, 40, 50)

	explanation_text = "Ransack the station and escape with [target_amount] [target]."

/datum/objective/heist/salvage/check_completion()
	var/total_amount = 0

	for(var/obj/item/O in locate(/area/shuttle/vox/arkship))

		var/obj/item/stack/sheet/S
		if(istype(O, /obj/item/stack/sheet))
			if(O.name == target)
				S = O
				total_amount += S.get_amount()
		for(var/obj/I in O.contents)
			if(istype(I, /obj/item/stack/sheet))
				if(I.name == target)
					S = I
					total_amount += S.get_amount()

	var/datum/game_mode/heist/H = SSticker.mode
	for(var/datum/mind/raider in H.raiders)
		if(raider.current)
			for(var/obj/item/O in raider.current.get_contents())
				if(istype(O,/obj/item/stack/sheet))
					if(O.name == target)
						var/obj/item/stack/sheet/S = O
						total_amount += S.get_amount()

	if(total_amount >= target_amount)
		return TRUE
	return FALSE
/*
var/heist_rob_total = 0
/proc/heist_recursive_price_check(atom/movable/AM,loop=0)
	loop++
	if(loop > 15) return
	heist_rob_total += AM.get_price()
	if(AM.contents && AM.contents.len)
		for(var/atom/movable/I in AM.contents)
			heist_rob_total += I.get_price()
			if(I.contents && I.contents.len)
				heist_recursive_price_check(I,loop)
/proc/heist_recursive_price_reset(atom/movable/AM,loop=0)
	loop++
	if(loop > 15) return
	AM.price = 0
	if(AM.contents && AM.contents.len)
		for(var/atom/movable/I in AM.contents)
			I.price = 0
			if(I.contents && I.contents.len)
				heist_recursive_price_reset(I,loop)
/proc/heist_get_shuttle_price()
	heist_rob_total = 0
	var/area/A = get_area(locate(/obj/effect/landmark/heist/aurora))
	if(A)
		for(var/atom/movable/AM in A)
			heist_recursive_price_check(AM)
/datum/objective/heist/robbery/choose_target()
	target = "valuables"
	target_amount = 1000000
	explanation_text = "Ransack the station for any valuables."
/datum/objective/heist/robbery/check_completion()
	heist_rob_total = 0
	for(var/atom/movable/AM in locate(/area/shuttle/vox/arkship))
		heist_recursive_price_check(AM)
	if(heist_rob_total >= target_amount) return OBJECTIVE_WIN
	return OBJECTIVE_LOSS*/

/datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/game_mode/heist/H = SSticker.mode
	if(H.is_raider_crew_safe())
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

#define MAX_VOX_KILLS 13 //Number of kills during the round before the Inviolate is broken.
						 //Would be nice to use vox-specific kills but is currently not feasible.
var/global/vox_kills = 0 //Used to check the Inviolate.

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."

/datum/objective/heist/inviolate_death/check_completion()
	if(vox_kills > MAX_VOX_KILLS)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/blob_takeover
	explanation_text = "Reach critical mass!"

/datum/objective/blob_takeover/check_completion()
	if(blobs.len >= blobwincount)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
