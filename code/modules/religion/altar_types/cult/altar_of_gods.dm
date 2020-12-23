/obj/structure/altar_of_gods/cult
	name = "Altar of the Death"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "satanaltar"

	change_preset_name = FALSE
	custom_sect = FALSE

	type_of_sects = /datum/religion_sect/preset/cult

/obj/structure/altar_of_gods/cult/interact_bible(obj/item/I, mob/user)
	if(!chosen_aspect)
		..(I, user)
	else
		if(!religion)
			to_chat(user, "<span class ='warning'>First choose aspects in your religion!</span>")
			return

		if(performing_rite)
			to_chat(user, "<span class='warning'>You are already performing [performing_rite.name]!</span>")
			return

		if(religion.rites_info.len == 0 || religion.rites_by_name.len == 0)
			to_chat(user, "<span class='warning'>Your religion doesn't have any rites to perform!</span>")
			return

		if(!Adjacent(user))
			to_chat(user, "<span class='warning'>You are too far away!</span>")
			return

		if(performing_rite)
			to_chat(user, "<span class='warning'>You are already performing [performing_rite.name]!</span>")
			return

		// Choices of rite in radial menu
		var/list/rite_choices = list()
		for(var/i in religion.rites_by_name)
			var/aspect
			var/aspect_power = 0
			var/datum/religion_rites/rite = religion.rites_by_name[i]
			for(var/asp in rite.needed_aspects)
				if(rite.needed_aspects[asp] > aspect_power)
					aspect = asp
					aspect_power = rite.needed_aspects[asp]

			var/datum/aspect/strongest_aspect = religion.aspects[aspect]
			rite_choices[rite.name] = image(icon = strongest_aspect.icon, icon_state = strongest_aspect.icon_state)

		var/choosed_rite = show_radial_menu(user, src, rite_choices, require_near = TRUE, tooltips = TRUE)
		if(!choosed_rite)
			return

		// TODO: REWORCK FOR CULT RITES!!
		performing_rite = religion.rites_by_name[choosed_rite]

		performing_rite.perform_rite(user, src)
