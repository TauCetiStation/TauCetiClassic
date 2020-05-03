/**
  * #Religious Sects
  * A religious sect is an aspects preset for a religion, nothing more.
  */
/datum/religion_sect
	var/name = "Basic sect"
	/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
	/// Opening message when someone gets converted
	var/convert_opener
	/// Does this require something before being available as an option?
	var/starter = TRUE
	/// Fast choose aspects
	var/list/datum/aspect/aspect_preset

/// Activates once selected
/datum/religion_sect/proc/on_select(mob/living/L)
	for(var/aspect in aspect_preset)
		var/datum/aspect/asp = new aspect()
		asp.power = aspect_preset[aspect]
		global.chaplain_religion.aspects[asp.name] = asp

	// I mean, they did choose the sect.
	on_conversion(L)

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span>")

/datum/religion_sect/puritanism
	name = "The Puritans of "
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"
	aspect_preset = list(/datum/aspect/salutis = 1, /datum/aspect/lux = 1, /datum/aspect/spiritus = 1)

/datum/religion_sect/technophile
	name = "The Technomancers of "
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte."
	aspect_preset = list(/datum/aspect/technology = 1, /datum/aspect/progressus = 1, /datum/aspect/metallum = 1)

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
		. += list(initial(asp.name) = i)

/datum/religion_sect/custom/proc/aspectlist2msg(list/aspect_list)
	. = aspect_list.len ? "" : "None"
	var/first = TRUE
	for(var/aspect in aspect_list)
		var/datum/aspect/asp = aspect_list[aspect]
		if(!first)
			. += ", "
		. += "[asp.name] [num2roman(asp.power)]"
		first = FALSE

/datum/religion_sect/custom/on_select(mob/living/L)
	var/static/list/aspects = get_allowed_aspects()

	for(var/i in 1 to aspects_count)
		var/aspect_select = input(L, "Select aspects of your religion (You CANNOT revert this decision!)", aspectlist2msg(global.chaplain_religion.aspects), null) in aspects
		var/type_selected = aspects[aspect_select]
		if(!global.chaplain_religion.aspects[aspect_select])
			global.chaplain_religion.aspects[aspect_select] = new type_selected()
		else
			var/datum/aspect/asp = global.chaplain_religion.aspects[aspect_select]
			asp.power += 1
