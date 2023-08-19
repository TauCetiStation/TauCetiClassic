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

	var/add_religion_name = TRUE

/// Activates once selected
/datum/religion_sect/proc/on_select(mob/L, datum/religion/R)
	give_binding_rites(L, R)
	give_aspects(L, R)
	// I mean, they did choose the sect.
	on_conversion(L)

// This proc is used to give the religion it's aspects.
/datum/religion_sect/proc/give_aspects(mob/L, datum/religion/R)
	return

// This proc is used to give all binding rites once
/datum/religion_sect/proc/give_binding_rites(mob/L, datum/religion/R)
	R.give_binding_rites()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span>")

/datum/religion_sect/preset
	/// An assoc list of form aspect_type = aspect power
	var/list/datum/aspect/aspect_preset

/datum/religion_sect/preset/give_aspects(mob/L, datum/religion/R)
	R.add_aspects(aspect_preset)

/********************/
/*    CHAPLAIN      */
/********************/
/datum/religion_sect/preset/chaplain

/datum/religion_sect/preset/chaplain/puritanism
	name = "The Puritans of "
	desc = "Nothing special."
	convert_opener = "Ваша заурядная секта, сохраняйте чистоту. Восхваляйте обыкновенность!"
	aspect_preset = list(
		/datum/aspect/rescue = 1,
		/datum/aspect/lightbending/light = 1,
		/datum/aspect/mystic = 1,
	)

/datum/religion_sect/preset/chaplain/bloodgods
	name = "The Slaves of "
	desc = "Anything you need, little demon."
	convert_opener = "Да начнется Великая Жатва! Добудьте больше крови!"
	aspect_preset = list(
		/datum/aspect/death = 1,
		/datum/aspect/lightbending/darkness = 1,
		/datum/aspect/chaos = 1,
	)

/datum/religion_sect/preset/chaplain/technophile
	name = "The Technomancers of "
	desc = "A sect oriented around technology."
	convert_opener = "Обрети покой в металлической оболочке, аколит."
	aspect_preset = list(
		/datum/aspect/technology = 1,
		/datum/aspect/science = 1,
		/datum/aspect/resources = 1,
	)

/datum/religion_sect/preset/chaplain/clown
	name = "The Jesters of "
	desc = "Anything a real clown needs!"
	convert_opener = "Веселись во имя Хонкоматери, смейся от души!"
	aspect_preset = list(
		/datum/aspect/wacky = 1,
		/datum/aspect/chaos = 1,
		/datum/aspect/resources = 1,
	)

/datum/religion_sect/preset/chaplain/sounds
	name = "The Artists of "
	desc = "Bring a Colors to this world!"
	convert_opener = "Искусство уже близко!"
	aspect_preset = list(
		/datum/aspect/rescue = 1,
		/datum/aspect/lightbending/light = 1,
		/datum/aspect/mystic = 1,
	)

/datum/religion_sect/custom/chaplain
	aspects_count = 3

// This sect type allows user to select their aspects.
/datum/religion_sect/custom
	name = "Custom "
	desc = "Follow the orders of your god."
	convert_opener = "Я первый, кто встал на этот путь..."

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

/datum/religion_sect/custom/give_aspects(mob/L, datum/religion/R)
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

/********************/
/*        CULT      */
/********************/
/datum/religion_sect/preset/cult
	add_religion_name = FALSE

/datum/religion_sect/preset/cult/blood
	name = "The Cult of Blood"
	desc = "Anything you need, little demon."
	convert_opener = "Да начнется Великая Жатва! Добудьте больше крови!"
	aspect_preset = list(
		/datum/aspect/death = 1,
		/datum/aspect/rescue = 1,
		/datum/aspect/chaos = 1,
		/datum/aspect/mystic = 1,
		/datum/aspect/conjure = 2,
	)

/datum/religion_sect/preset/cult/salvation
	name = "The Cult of Salvation"
	desc = "Save life of cultists at any cost."
	convert_opener = "Обрети бессмертие!"
	aspect_preset = list(
		/datum/aspect/resources = 1,
		/datum/aspect/rescue = 1,
		/datum/aspect/chaos = 1,
		/datum/aspect/mystic = 1,
		/datum/aspect/lightbending/darkness = 2,
	)

/datum/religion_sect/preset/cult/darkness
	name = "The Cult of Darkness"
	desc = "The seizure of territories can be not only aggressive for darkness"
	convert_opener = "Позволь тьме вести тебя."
	aspect_preset = list(
		/datum/aspect/lightbending/darkness = 3,
		/datum/aspect/weapon = 2,
		/datum/aspect/technology = 1,
	)

/datum/religion_sect/preset/cult/songs
	name = "The Cult of Sound"
	desc = "Sound can lead the masses, and you will become its source"
	convert_opener = "И пусть твой путь будет освещен звуком"
	aspect_preset = list(
		/datum/aspect/rescue = 1,
		/datum/aspect/lightbending/light = 1,
		/datum/aspect/death = 1,
		/datum/aspect/mystic = 1,
		/datum/aspect/conjure = 1,
		/datum/aspect/chaos = 1,
	)

/datum/religion_sect/custom/cult
	name = "Custom Cult"
	convert_opener = "Хаос - это сила."

	aspects_count = 6

	add_religion_name = FALSE
