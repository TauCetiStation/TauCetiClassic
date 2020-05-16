/*
 * A data-class(ha-ha) used to keep any information for a conversion of one reagent to another via faith(*favor).
 */
/datum/faith_reaction
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
		after_reaction(container, user)

// Return TRUE if reaction went alright.
/datum/faith_reaction/proc/do_reaction(atom/container, mob/user)
	var/to_convert = container.reagents.get_reagent_amount(convertable_id)

	if(favor_cost != 0)
		to_convert = min(global.chaplain_religion.favor / favor_cost, to_convert)

	if(to_convert <= 0)
		return FALSE

	global.chaplain_religion.favor -= to_convert * favor_cost

	container.reagents.remove_reagent(convertable_id, to_convert)
	container.reagents.add_reagent(result_id, to_convert)
	return TRUE

/datum/faith_reaction/proc/after_reaction(atom/container, mob/user)
	return



/datum/faith_reaction/bless/after_reaction(atom/container, mob/user)
	to_chat(user, "<span class='notice'>You bless [container].</span>")

/datum/faith_reaction/bless/water2holywater
	result_id = "holywater"
	needed_aspects = list(ASPECT_SALUTIS = 1)
	favor_cost = 0



/datum/faith_reaction/curse/after_reaction(atom/container, mob/user)
	to_chat(user, "<span class='warning'>You curse [container]!</span>")

/datum/faith_reaction/curse/water2unholywater
	result_id = "unholywater"
	needed_aspects = list(ASPECT_OBSCURUM = 1)
	favor_cost = 0

/datum/faith_reaction/curse/water2blood
	needed_aspects = list(ASPECT_MORTEM = 1)
	// You get 1 point per unit of blood when sacrificing.
	favor_cost = 2

/datum/faith_reaction/curse/water2ectoplasm
	needed_aspects = list(ASPECT_MYSTIC = 1)
	favor_cost = 2



// Something more science-y sounding.
/datum/faith_reaction/convert/after_reaction(atom/container, mob/user)
	to_chat(user, "<span class='notice'>You enrich [container].</span>")

/datum/faith_reaction/convert/water2gold
	result_id = "gold"
	needed_aspects = list(ASPECT_LUCRUM = 2)
	favor_cost = 10

/datum/faith_reaction/convert/water2silver
	result_id = "silver"
	needed_aspects = list(ASPECT_LUCRUM = 1)
	favor_cost = 2



/datum/faith_reaction/water2sugar
	result_id = "sugar"
	needed_aspects = list(ASPECT_FAMES = 1)
	favor_cost = 0

/datum/faith_reaction/water2sugar/after_reaction(atom/container, mob/user)
	to_chat(user, "<span class='warning'>You sweeten [container].</span>")

/datum/faith_reaction/water2wine
	result_id = "wine"
	needed_aspects = list(ASPECT_FAMES = 1, ASPECT_SALUTIS = 1)
	favor_cost = 0

/datum/faith_reaction/water2wine/after_reaction(atom/container, mob/user)
	to_chat(user, "<span clas='notice'>You have just created wine!</span>")

/datum/faith_reaction/water2pwine
	result_id = "pwine"
	needed_aspects = list(ASPECT_FAMES = 1, ASPECT_OBSCURUM = 1)
	favor_cost = 5

/datum/faith_reaction/water2pwine/after_reaction(atom/container, mob/user)
	to_chat(user, "<span clas='notice'>You have just created... err... wine?!</span>")
