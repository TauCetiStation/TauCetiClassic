/*
 * A data-class(ha-ha) used to keep any information for a conversion of one reagent to another via faith(*favor).
 */
/datum/faith_reaction
	var/id

	// The id of a reagent resulting from this reaction.
	var/result_id
	// The id of a reagent that is going to be used up.
	var/convertable_id = "water"
	// Favour cost per unit of convertable_id.
	var/favor_cost = 0

	// Is used to determine which aspects are required for this
	// reaction to be permitted.
	var/list/needed_aspects

/datum/faith_reaction/proc/react(atom/container, mob/user)
	if(do_reaction(container, user))
		INVOKE_ASYNC(src, .proc/after_reaction, container, user)

/datum/faith_reaction/proc/get_amount(atom/container, mob/user)
	var/to_convert = container.reagents.get_reagent_amount(convertable_id)
	if(favor_cost != 0)
		to_convert = min(global.chaplain_religion.favor / favor_cost, to_convert)
	return to_convert

/datum/faith_reaction/proc/get_description(atom/container, mob/user)
	var/to_convert = get_amount(container, user)
	if(to_convert <= 0)
		return ""

	var/datum/reagent/result = global.chemical_reagents_list[result_id]
	var/datum/reagent/convertable = global.chemical_reagents_list[convertable_id]

	return "Convert [convertable.name] into [result.name] ([to_convert * favor_cost] favor)"

// Return TRUE if reaction went alright.
/datum/faith_reaction/proc/do_reaction(atom/container, mob/user)
	var/to_convert = get_amount(container, user)
	if(to_convert <= 0)
		return FALSE

	global.chaplain_religion.favor -= to_convert * favor_cost

	container.reagents.remove_reagent(convertable_id, to_convert)
	container.reagents.add_reagent(result_id, to_convert)
	return TRUE

/datum/faith_reaction/proc/after_reaction(atom/container, mob/user)
	if(!istype(container, /atom/movable))
		return

	INVOKE_ASYNC(user, /mob.proc/pray_animation)
	sleep(2)
	if(QDELING(container) || QDELING(user))
		return

	playsound(src, 'sound/voice/holy.ogg', VOL_EFFECTS_MASTER)

	var/atom/movable/AM = container
	if(AM.can_waddle())
		AM.waddle(pick(-28, 0, 28), 4)

	var/holy_outline = filter(type = "outline", size = 1, color = "#FFD700EE")
	container.filters += holy_outline
	animate(container.filters[container.filters.len], color = "#FFD70000", time = 2 SECONDS)
	addtimer(CALLBACK(src, .proc/revert_effects, container, user, holy_outline), 2 SECONDS)

/datum/faith_reaction/proc/revert_effects(atom/container, mob/user, holy_outline)
	container.filters -= holy_outline



/datum/faith_reaction/bless/after_reaction(atom/container, mob/user)
	..()
	to_chat(user, "<span class='notice'>You bless [container].</span>")

/datum/faith_reaction/bless/water2holywater
	id = "water2holywater"

	result_id = "holywater"
	needed_aspects = list(ASPECT_RESCUE = 1)
	favor_cost = 0



/datum/faith_reaction/curse/after_reaction(atom/container, mob/user)
	..()
	to_chat(user, "<span class='warning'>You curse [container]!</span>")

/datum/faith_reaction/curse/water2unholywater
	id = "unwater2holywater"

	result_id = "unholywater"
	needed_aspects = list(ASPECT_OBSCURE = 1)
	favor_cost = 0

/datum/faith_reaction/curse/water2blood
	id = "water2blood"

	result_id = "blood"
	needed_aspects = list(ASPECT_DEATH = 1)
	// You get 1 point per unit of blood when sacrificing.
	favor_cost = 2

/datum/faith_reaction/curse/water2ectoplasm
	id = "water2ectoplasm"

	result_id = "ectoplasm"
	needed_aspects = list(ASPECT_MYSTIC = 1)
	favor_cost = 2



// Something more science-y sounding.
/datum/faith_reaction/convert/after_reaction(atom/container, mob/user)
	..()
	to_chat(user, "<span class='notice'>You enrich [container].</span>")

/datum/faith_reaction/convert/water2gold
	id = "water2gold"

	result_id = "gold"
	needed_aspects = list(ASPECT_GREED = 2)
	favor_cost = 10

/datum/faith_reaction/convert/water2silver
	id = "water2silver"

	result_id = "silver"
	needed_aspects = list(ASPECT_GREED = 1)
	favor_cost = 2



/datum/faith_reaction/water2sugar
	id = "water2sugar"

	result_id = "sugar"
	needed_aspects = list(ASPECT_FOOD = 1)
	favor_cost = 0

/datum/faith_reaction/water2sugar/after_reaction(atom/container, mob/user)
	..()
	to_chat(user, "<span class='warning'>You sweeten [container].</span>")

/datum/faith_reaction/water2wine
	id = "water2wine"

	result_id = "wine"
	needed_aspects = list(ASPECT_FOOD = 1, ASPECT_RESCUE = 1)
	favor_cost = 0

/datum/faith_reaction/water2wine/after_reaction(atom/container, mob/user)
	..()
	to_chat(user, "<span clas='notice'>You have just created wine!</span>")

/datum/faith_reaction/water2pwine
	id = "water2pwine"

	result_id = "pwine"
	needed_aspects = list(ASPECT_FOOD = 1, ASPECT_OBSCURE = 1)
	favor_cost = 5

/datum/faith_reaction/water2pwine/after_reaction(atom/container, mob/user)
	..()
	to_chat(user, "<span clas='notice'>You have just created... err... wine?!</span>")
