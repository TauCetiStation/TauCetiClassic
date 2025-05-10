/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state = "bible"
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE

	var/datum/religion/religion
	var/religify_next = list()
	var/religify_cd = 3 MINUTE

	var/list/rad_choices

/obj/item/weapon/storage/bible/atom_init()
	. = ..()
	rad_choices = list(
		"Altar" = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "altar"),
		"Emblem" = image(icon = 'icons/obj/lectern.dmi', icon_state = "christianity"),
		"Mat symbol" = image(icon = 'icons/turf/turf_decals.dmi', icon_state = "religion_christianity")
	)

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/atom_init()
	. = ..()
	for(var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/beer(src)
	for(var/i in 1 to 3)
		new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/proc/can_convert(atom/target, mob/user)
	if(!user.mind || !user.mind.holy_role)
		return FALSE
	if(!religion.faith_reactions.len)
		return FALSE
	if(!target.reagents)
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	return TRUE

/obj/item/weapon/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || !religion)
		return

	if(!can_convert(target, user))
		return

	var/list/choices = list()
	for(var/reaction_id in religion.faith_reactions)
		var/datum/faith_reaction/FR = religion.faith_reactions[reaction_id]
		var/desc = FR.get_description(target, user, religion)
		if(desc == "")
			continue

		choices[desc] = reaction_id

	var/chosen_reaction = input(user, "Choose a reaction that will partake in the container.", "A reaction.") as null|anything in choices
	if(!chosen_reaction)
		return
	if(!can_convert(target, user))
		return

	var/chosen_id = choices[chosen_reaction]

	var/datum/faith_reaction/FR = religion.faith_reactions[chosen_id]
	FR.react(target, user, religion)

/obj/item/weapon/storage/bible/attackby(obj/item/I, mob/user, params)
	if(length(use_sound))
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, FALSE, null, -5)
	return ..()

/obj/item/weapon/storage/bible/attack_self(mob/user)
	if(user.mind?.holy_role && !iscultist(user))
		change_chapel_looks(user)
		return

	return ..()

/obj/item/weapon/storage/bible/proc/change_chapel_looks(mob/user)
	if(religify_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>You can't be changing the look of your entire church so often! Please wait about [round((religify_next[user.ckey] - world.time) * 0.1)] seconds to try again.</span>")
		return

	var/done = FALSE
	var/changes = FALSE
	var/list/choices = list("Altar", "Emblem", "Mat symbol")

	to_chat(user, "<span class='notice'>Select chapel attributes.</span>")
	while(!done)
		if(!choices.len)
			done = TRUE
			break

		var/list/temp_images = list()
		for(var/choose in choices)
			temp_images[choose] += rad_choices[choose]

		var/looks = show_radial_menu(user, src, temp_images, tooltips = TRUE, require_near = TRUE)
		if(!looks)
			done = TRUE
			break

		switch(looks)
			if("Altar")
				var/new_look = show_radial_menu(user, src, religion.altar_skins, radius = 38, require_near = TRUE, tooltips = TRUE)
				if(!new_look)
					continue

				religion.altar_icon_state = religion.altar_info_by_name[new_look]
				changes = TRUE
				choices -= "Altar"

			if("Emblem")
				var/new_look = show_radial_menu(user, src, religion.emblem_skins, radius = 38, require_near = TRUE, tooltips = TRUE)
				if(!new_look)
					continue

				religion.emblem_icon_state = religion.emblem_info_by_name[new_look]
				changes = TRUE
				choices -= "Emblem"

			if("Mat symbol")
				var/new_mat = show_radial_menu(user, src, religion.decal_radial_menu, radius = 38, require_near = TRUE, tooltips = TRUE)
				if(!new_mat)
					continue

				religion.decal = "religion_[lowertext(new_mat)]"
				changes = TRUE
				choices -= "Mat symbol"

	if(changes)
		religify_next[user.ckey] = world.time + religify_cd
		religion.religify(null, null, user)
