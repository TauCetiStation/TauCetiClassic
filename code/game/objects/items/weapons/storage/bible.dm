/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/mob/affecting = null
	var/deity_name = "Christ"
	var/god_lore = ""
	max_storage_space = DEFAULT_BOX_STORAGE

	var/religify_next = list()

	var/list/rad_choices

/obj/item/weapon/storage/bible/atom_init()
	. = ..()
	rad_choices = list(
		"Altar" = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "altar"),
		"Pews" = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = "christianity_left"),
		"Mat symbol" = image(icon = 'icons/turf/carpets.dmi', icon_state = "carpetsymbol")
	)

	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/choise in rad_choices)
		if(choise == "Pews") // Don't need it
			continue
		var/image/I = rad_choices[choise]
		I.transform = M

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/bible/booze/atom_init()
	. = ..()
	for (var/i in 1 to 2)
		new /obj/item/weapon/reagent_containers/food/drinks/bottle/beer(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/spacecash(src)

/obj/item/weapon/storage/bible/proc/can_convert(atom/target, mob/user)
	if(!user.mind || !user.mind.holy_role)
		return FALSE
	if(!global.chaplain_religion || !global.chaplain_religion.faith_reactions.len)
		return FALSE
	if(!target.reagents)
		return FALSE
	if(!in_range(user, target))
		return FALSE
	return TRUE

/obj/item/weapon/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(!can_convert(target, user))
		return

	var/list/choices = list()
	for(var/reaction_id in global.chaplain_religion.faith_reactions)
		var/datum/faith_reaction/FR = global.chaplain_religion.faith_reactions[reaction_id]
		var/desc = FR.get_description(target, user)
		if(desc == "")
			continue

		choices[desc] = reaction_id

	var/chosen_reaction = input(user, "Choose a reaction that will partake in the container.", "A reaction.") as null|anything in choices
	if(!chosen_reaction)
		return
	if(!can_convert(target, user))
		return

	var/chosen_id = choices[chosen_reaction]

	var/datum/faith_reaction/FR = global.chaplain_religion.faith_reactions[chosen_id]
	FR.react(target, user)

/obj/item/weapon/storage/bible/attackby(obj/item/I, mob/user, params)
	if(length(use_sound))
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, null, -5)
	return ..()

/obj/item/weapon/storage/bible/attack_self(mob/user)
	if(user.mind && (user.mind.holy_role))
		if(religify_next[user.ckey] > world.time)
			to_chat(user, "<span class='warning'>You can't be changing the look of your entire church so often! Please wait about [round((religify_next[user.ckey] - world.time) * 0.1)] seconds to try again.</span>")
			return
		else if(global.chaplain_religion)
			change_chapel_looks(user)
			return

	return ..()

/obj/item/weapon/storage/bible/proc/change_chapel_looks(mob/user)
	var/done = FALSE
	var/changes = FALSE
	var/list/choices = list("Altar", "Pews", "Mat symbol")

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
				var/new_look = show_radial_menu(user, src, global.chaplain_religion.altar_skins, require_near = TRUE, tooltips = TRUE)
				if(!new_look)
					continue

				global.chaplain_religion.altar_icon_state = global.chaplain_religion.altar_info_by_name[new_look]
				changes = TRUE
				choices -= "Altar"

			if("Pews")
				var/new_look = show_radial_menu(user, src, global.chaplain_religion.pews_skins, require_near = TRUE, tooltips = TRUE)
				if(!new_look)
					continue

				global.chaplain_religion.pews_icon_state = global.chaplain_religion.pews_info_by_name[new_look]
				changes = TRUE
				choices -= "Pews"

			if("Mat symbol")
				var/new_mat = show_radial_menu(user, src, global.chaplain_religion.carpet_skins, require_near = TRUE, tooltips = TRUE)
				if(!new_mat)
					continue

				global.chaplain_religion.carpet_dir = global.chaplain_religion.carpet_dir_by_name[new_mat]
				changes = TRUE
				choices -= "Mat symbol"

	if(changes)
		religify_next[user.ckey] = world.time + 3 MINUTE
		global.chaplain_religion.religify_chapel()
