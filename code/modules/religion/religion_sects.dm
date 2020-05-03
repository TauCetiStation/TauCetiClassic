/**
  * # Religious Sects
  *
  * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
  *
  * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  *
  */
/datum/religion_sect
	var/name = "Basic sect"
/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
/// Opening message when someone gets converted
	var/convert_opener
/// Does this require something before being available as an option?
	var/starter = TRUE
/// Allow choose aspect in sect
	var/allow_aspect = FALSE
/// Fast choose aspects
	var/list/datum/aspect/aspect_preset

/// Activates once selected
/datum/religion_sect/proc/on_select()
	for(var/aspect in aspect_preset)
		var/datum/aspect/asp = new aspect()
		asp.power = aspect_preset[aspect]
		global.chaplain_religion.aspects[asp.name] = asp

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

/datum/religion_sect/custom
	name = "Custom "
	desc = "Follow the orders of your god."
	convert_opener = "I am the first to enter here..."
	allow_aspect = TRUE

/datum/religion_sect/custom/on_select(list/aspects, count_aspects)
	for(var/i in 1 to count_aspects)
		var/aspect_select = input(usr, "Select a aspect of god (You CANNOT revert this decision!)", "Select a aspect of god", null) in aspects
		var/type_selected = aspects[aspect_select]
		if(!global.chaplain_religion.aspects[aspect_select])
			global.chaplain_religion.aspects[aspect_select] = new type_selected()
		else
			var/datum/aspect/asp = global.chaplain_religion.aspects[aspect_select]
			asp.power += 1
