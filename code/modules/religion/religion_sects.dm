/**
  * #Religious Sects
  * A religious sect is an aspects preset for a religion, nothing more.
  */
/datum/religion_sect
	var/name = ""
	/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
	/// Opening message when someone gets converted
	var/convert_opener
	/// Does this require something before being available as an option?
	var/starter = TRUE

/// Activates once selected
/datum/religion_sect/proc/on_select(mob/living/L, datum/religion/R)
	give_aspects(L, R)
	// I mean, they did choose the sect.
	on_conversion(L)

// This proc is used to give the religion it's aspects.
/datum/religion_sect/proc/give_aspects(mob/living/L, datum/religion/R)
	return

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span>")


/datum/religion_sect/preset
	/// An assoc list of form aspect_type = aspect power
	var/list/datum/aspect/aspect_preset

/datum/religion_sect/preset/give_aspects(mob/living/L, datum/religion/R)
	R.add_aspects(aspect_preset)

/datum/religion_sect/preset/puritanism
	name = "The Puritans of "
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, conserve the purity. Praise normalcy!"
	aspect_preset = list(
		/datum/aspect/rescue = 1,
		/datum/aspect/lightbending/light = 1,
		/datum/aspect/mystic = 1,
	)

/datum/religion_sect/preset/bloodgods
	name = "The Slaves of "
	desc = "Anything you need, little demon."
	convert_opener = "Let the Great Harvest begin! Bring more blood!"
	aspect_preset = list(
	    /datum/aspect/death = 1,
		/datum/aspect/lightbending/darkness = 1,
		/datum/aspect/chaos = 1,
    )
		
/datum/religion_sect/preset/technophile
	name = "The Technomancers of "
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte."
	aspect_preset = list(
		/datum/aspect/technology = 1,
		/datum/aspect/science = 1,
		/datum/aspect/resources = 1,
	)

/datum/religion_sect/preset/clown
	name = "The Jesters of "
	desc = "Anything a real clown needs!"
	convert_opener = "Honk for the Honkmother, slip for the Slippy Joe!"
	aspect_preset = list(
		/datum/aspect/wacky = 1,
		/datum/aspect/chaos = 1,
		/datum/aspect/resources = 1,
		/datum/aspect/herd = 1,
	)

// This sect type allows user to select their aspects.
/datum/religion_sect/custom
	name = "Custom "
	desc = "Follow the orders of your god."
	convert_opener = "I am the first to enter here..."

	// How many aspects can a user select.
	var/aspects_count = 3

// What aspects does this sect allow to choose from?
/datum/religion_sect/custom/proc/get_allowed_aspects()
	. = list()
	for(var/i in subtypesof(/datum/aspect))
		var/datum/aspect/asp = i
		if(!initial(asp.name))
			continue
		if(!initial(asp.starter))
			continue
		. += list(initial(asp.name) = i)

/datum/religion_sect/custom/proc/aspectlist2msg(list/aspect_list)
	. = aspect_list.len ? "" : "None"
	var/first = TRUE
	for(var/aspect_type in aspect_list)
		var/datum/aspect/asp = aspect_type
		if(!first)
			. += ", "
		. += "[initial(asp.name)] [num2roman(aspect_list[aspect_type])]"
		first = FALSE

/datum/religion_sect/custom/give_aspects(mob/living/L, datum/religion/R)
	var/list/aspects = get_allowed_aspects()

	var/list/aspects_to_add = list()

	for(var/i in 1 to aspects_count)
		var/aspect_select = input(L, "Select aspects of your religion (You CANNOT revert this decision!)", aspectlist2msg(aspects_to_add), null) in aspects
		var/aspect_type = aspects[aspect_select]

		if(!aspects_to_add[aspect_type])
			aspects_to_add[aspect_type] = 1
		else
			aspects_to_add[aspect_type] += 1

	R.add_aspects(aspects_to_add)
