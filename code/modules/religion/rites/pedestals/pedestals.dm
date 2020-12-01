/obj/effect/overlay/item_illusion
	var/my_fake_type
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/religion_rites/pedestals
	var/search_radius_of_pedestals = 3

	var/list/pedestals
	// pedestal = list(type = count_of_type)
	var/list/involved_pedestals = list()

	// One element must contain the type and number of items for one pedestal. types_by_count
	var/list/rules = list()

/datum/religion_rites/pedestals/on_chosen(mob/living/user, obj/structure/altar_of_gods/AOG)
	SEND_SIGNAL(src, COMSIG_RITE_ON_CHOSEN, user, AOG)

	init_pedestals(AOG)

	if(pedestals.len < rules.len)
		to_chat(user, "<span class='warning'>You need more [rules.len - pedestals.len] pedestals.</span>")
		return FALSE

	var/rules_indx = 1
	for(var/i = 1; i <= pedestals.len; i += pedestals.len/rules.len)
		involved_pedestals[pedestals[i]] = list(rules[rules_indx] = rules[rules[rules_indx]])
		var/obj/structure/cult/pylon/P = pedestals[i]
		P.create_illusions(rules[rules_indx], rules[rules[rules_indx]])
		rules_indx += 1

	return TRUE

/datum/religion_rites/pedestals/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	..()
	for(var/obj/structure/cult/pylon/P in involved_pedestals)
		if(P.last_turf != get_turf(P))
			return FALSE
	return TRUE

/datum/religion_rites/pedestals/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!required_checks(user, AOG))
		return FALSE

	if(religion && religion.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE

	to_chat(user, "<span class='notice'>You begin performing the rite of [name]...</span>")

	if(!before_perform_rite(user, AOG))
		return FALSE

	var/items = 0
	for(var/type in rules)
		items += rules[type]

	for(var/i in 1 to items)
		if(!can_invocate(user, AOG))
			SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
			return FALSE
		user.say(i)
		stage += 1
		on_invocation(user, AOG, stage)

	// Because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
	if(!can_invocate(user, AOG))
		SEND_SIGNAL(src, COMSIG_RITE_FAILED_CHECK, user, AOG)
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)

	return TRUE

/datum/religion_rites/pedestals/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	reset_rite()

/datum/religion_rites/pedestals/proc/init_pedestals(obj/structure/altar_of_gods/AOG)
	qdel(pedestals)
	pedestals = list()
	for(var/obj/structure/cult/pylon/P in spiral_range(search_radius_of_pedestals, AOG))
		pedestals += P
		P.last_turf = get_turf(P)

/datum/religion_rites/pedestals/proc/reset_rite()
	for(var/obj/structure/cult/pylon/P in involved_pedestals)
		P.clear_items()
	qdel(involved_pedestals)
	involved_pedestals = list()

/datum/religion_rites/pedestals/test
	name = "Test"
	ritual_length = (20 SECONDS)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 0

	rules = list(
		/obj/item/weapon/card/id/sci = 1,
		/obj/item/device/pda/science = 2,
		/obj/item/weapon/card/id/sci = 1,
	)

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/pedestals/test1
	name = "Test1"
	ritual_length = (20 SECONDS)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 0

	rules = list(
		/obj/item/weapon/card/id/sci = 1,
		/obj/item/device/pda/science = 2,
		/obj/structure/altar_of_gods = 2,
		/obj/structure/cult/pylon = 2,
	)

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/pedestals/test2
	name = "Test2"
	ritual_length = (20 SECONDS)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 0

	rules = list(
		/obj/item/weapon/card/id/sci = 1,
		/obj/item/device/pda/science = 2,
		/obj/structure/altar_of_gods = 2,
		/obj/structure/cult/pylon = 2,
		/obj/structure/cult/forge = 2,
		/obj/structure/cult/shell = 2,
	)

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/pedestals/test3
	name = "Test3"
	ritual_length = (20 SECONDS)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 0

	rules = list(
		/obj/item/weapon/card/id/sci = 1,
		/obj/item/device/pda/science = 2,
		/obj/structure/altar_of_gods = 2,
		/obj/structure/cult/pylon = 2,
		/obj/structure/cult/forge = 2,
		/obj/structure/cult/shell = 2,
		/obj/structure/cult/spacewhole = 2,
		/obj/structure/cult/talisman = 2,
	)

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/pedestals/test4
	name = "Test4"
	ritual_length = (20 SECONDS)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 0

	rules = list(
		/obj/item/weapon/card/id/sci = 1,
		/obj/item/device/pda/science = 2,
		/obj/structure/altar_of_gods = 2,
		/obj/structure/cult/pylon = 2,
		/obj/structure/cult/forge = 2,
		/obj/structure/cult/shell = 2,
		/obj/structure/cult/spacewhole = 2,
		/obj/structure/cult/talisman = 2,
		/obj/structure/cult/tome= 2,
		/obj/structure/bonfire/dynamic = 3,
	)

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)
