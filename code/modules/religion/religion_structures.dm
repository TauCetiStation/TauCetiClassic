/obj/structure/altar_of_gods
	name = "Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "altar"
	density = TRUE
	anchored = TRUE
	layer = CONTAINER_STRUCTURE_LAYER
	climbable = TRUE
	pass_flags = PASSTABLE
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	var/datum/religion_rites/performing_rite
	var/datum/religion_sect/sect_to_altar //easy access
	var/datum/religion/chaplain/religion_to_altar //easy access

/obj/structure/altar_of_gods/examine(mob/user)
	. = ..()
	var/can_i_see = FALSE
	var/msg = ""
	if(isobserver(user))
		can_i_see = TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.mind && L.mind.holy_role)
			can_i_see = TRUE

	if(!can_i_see || global.chaplain_religion.sect_aspects.len == 0)
		return

	msg += "<span class='notice'>The sect currently has [round(global.chaplain_religion.favor)] favor with [pick(global.chaplain_religion.deity_names)].\n</span>"
	msg += "List of available Rites:\n"
	for(var/i in global.chaplain_religion.rites_list)
		msg += i
	if(msg)
		to_chat(user, msg)

/obj/structure/altar_of_gods/attack_hand(mob/living/user)
	if(!Adjacent(user) || !user.pulling)
		return ..()
	if(!isliving(user.pulling))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, "<span class='warning'>[pushed_mob] is buckled to [pushed_mob.buckled]!</span>")
		return ..()
	to_chat(user,"<span class='notice'>You try to coax [pushed_mob] onto [src]...</span>")
	if(!do_after(user, (5 SECONDS), target = pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/attackby(obj/item/C, mob/user, params)
	//If we can sac, we do nothing but the sacrifice instead of typical attackby behavior (IE damage the structure)
	if(religion_to_altar)
		for(var/aspect in religion_to_altar.sect_aspects)
			var/datum/aspect/asp = religion_to_altar.sect_aspects[aspect]
			if(asp.sacrifice(C, user))
				to_chat(user, "<span class='notice'>You offer [C]'s power to [pick(religion_to_altar.deity_names)], pleasing them.</span>")
				qdel(C)
				break

	if(user.mind.holy_role < HOLY_ROLE_PRIEST)
		to_chat(user, "<span class='warning'>You don't know how to use this.</span>")
		return

	//start ritual
	if(istype(C, /obj/item/weapon/nullrod))
		if(religion_to_altar.rites_list.len == 0)
			to_chat(user, "<span class='notice'>Your religion doesn't have any rites to perform!</span>")
			return

		var/rite_select = input(user, "Select a rite to perform!", "Select a rite", null) in religion_to_altar.rites_list
		if(!(src in oview(2)))
			to_chat(user, "<span class='warning'>You are too far away!</span>")
			return

		var/selection2type = religion_to_altar.rites_list[rite_select]
		performing_rite = new selection2type(src)

		if(!performing_rite.perform_rite(user, src))
			QDEL_NULL(performing_rite)
		else
			performing_rite.invoke_effect(user, src)
			religion_to_altar.adjust_favor(-performing_rite.favor_cost)
			QDEL_NULL(performing_rite)

	//choose aspect preset
	if(istype(C, /obj/item/weapon/storage/bible))
		if(!global.religious_sect)
			var/list/available_options = generate_available_sects(user)
			if(!available_options)
				return

			var/sect_select = input(user, "Select a aspects preset", "Select a preset", null) in available_options
			if(!(src in oview(2)))
				to_chat(user, "<span class='warning'>You are too far away!</span>")
				return

			global.religious_sect = available_options[sect_select]
			sect_to_altar = global.religious_sect
			religion_to_altar = global.chaplain_religion

			if(sect_to_altar.allow_aspect)
				//choose aspects for the god and his desire
				var/list/aspects = generate_aspect(user)
				if(!aspects)
					return

				for(var/i in 1 to 3)
					var/aspect_select = input(user, "Select a aspect of god (You CANNOT revert this decision!)", "Select a aspect of god", null) in aspects
					var/type_selected = aspects[aspect_select]
					if(!istype(religion_to_altar.sect_aspects[aspect_select], type_selected))
						religion_to_altar.sect_aspects[aspect_select] = new type_selected()
					else
						var/datum/aspect/asp = religion_to_altar.sect_aspects[aspect_select]
						asp.power += 1

				//add rites
				for(var/i in religion_to_altar.sect_aspects)
					var/datum/aspect/asp = religion_to_altar.sect_aspects[i]
					if(asp.rite)
						religion_to_altar.rites_list += asp.rite
			else
				if(sect_to_altar.aspect_preset.len != 0)
					for(var/aspect in sect_to_altar.aspect_preset)
						var/datum/aspect/asp = new aspect()
						asp.power = sect_to_altar.aspect_preset[aspect]
						religion_to_altar.sect_aspects[asp.name] = asp

			if(isliving(user) && user.mind && user.mind.holy_role)
				sect_to_altar.on_conversion(user)

			religion_to_altar.update_rites()

/obj/structure/altar_of_gods/proc/generate_available_sects(mob/user) //eventually want to add sects you get from unlocking certain achievements
	var/list/variants = list()
	for(var/type in subtypesof(/datum/religion_sect))
		var/datum/religion_sect/sect = new type(src)
		if(!sect.name)
			continue
		sect.name += global.chaplain_religion.name
		variants[sect.name] = sect
	return variants

/obj/structure/altar_of_gods/proc/generate_aspect(mob/user)
	. = list()
	for(var/i in subtypesof(/datum/aspect))
		var/datum/aspect/asp = i
		. += list(initial(asp.name) = i)
