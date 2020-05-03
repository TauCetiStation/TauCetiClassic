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
	var/datum/religion_sect/sect //easy access
	var/datum/religion/chaplain/religion //easy access
	var/chosen_aspect = FALSE

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

	if(!can_i_see || global.chaplain_religion.aspects.len == 0)
		return

	msg += "<span class='notice'>The sect currently has [round(global.chaplain_religion.favor)] favor with [pick(global.chaplain_religion.deity_names)].\n</span>"
	msg += "List of available Rites:\n"
	for(var/i in global.chaplain_religion.rites)
		msg += i
	if(msg)
		to_chat(user, msg)

/obj/structure/altar_of_gods/MouseDrop_T(mob/target, mob/user)
	if(isliving(target))
		if(can_climb(target) && !buckled_mob && target.loc != loc)
			if(user.incapacitated())
				return
			if(iscarbon(target))
				target.loc = loc
				for(var/obj/O in src)
					O.loc = loc
				src.add_fingerprint(target)
		else
			if(can_buckle && istype(target) && !buckled_mob && istype(user))
				user_buckle_mob(target, user)

/obj/structure/altar_of_gods/attackby(obj/item/C, mob/user, params)
	if(iswrench(C))
		anchored = !anchored
		visible_message("<span class='warning'>[src] has been [anchored ? "bolted to the floor" : "unbolted from the floor"] by [user].</span>")
		return

	if(!anchored)
		return ..()

	if(!user.mind)
		return

	if(user.mind.holy_role < HOLY_ROLE_PRIEST)
		to_chat(user, "<span class='warning'>You don't know how to use this.</span>")
		return

	//If we can sacrifice, we do nothing but the sacrifice instead of typical attackby behavior
	if(religion && !(C.flags & ABSTRACT))
		var/max_points = 0

		for(var/aspect in religion.aspects)
			var/datum/aspect/asp = religion.aspects[aspect]
			var/points = asp.sacrifice(C, user)
			if(points > max_points)
				max_points = points

		if(max_points > 0)
			global.chaplain_religion.adjust_favor(max_points, user)
			to_chat(user, "<span class='notice'>You offer [C]'s power to [pick(religion.deity_names)], pleasing them.</span>")
			user.drop_from_inventory(C)
			qdel(C)
			return

	if(istype(C, /obj/item/weapon/nullrod))
		if(!religion)
			to_chat(user, "<span class ='warning'>First choose aspects in your religion!</span>")
			return

		if(performing_rite)
			to_chat(user, "<span class='notice'>You are already performing [performing_rite.name]!</span>")
			return

		if(religion.rites.len == 0)
			to_chat(user, "<span class='notice'>Your religion doesn't have any rites to perform!</span>")
			return

		var/rite_select = input(user, "Select a rite to perform!", "Select a rite", null) in religion.rites
		if(!Adjacent(user))
			to_chat(user, "<span class='warning'>You are too far away!</span>")
			return

		var/selection2type = religion.rites[rite_select]
		performing_rite = new selection2type(src)

		if(!performing_rite.perform_rite(user, src))
			QDEL_NULL(performing_rite)
		else
			performing_rite.invoke_effect(user, src)
			religion.adjust_favor(-performing_rite.favor_cost)
			QDEL_NULL(performing_rite)
		return

	else if(istype(C, /obj/item/weapon/storage/bible) && !chosen_aspect)
		if(!global.chaplain_religion)
			to_chat(user, "<span class='warning'>It appears the game hasn't even started! Stop right there!</span>")
			return

		chosen_aspect = TRUE
		var/list/available_options = generate_available_sects(user)
		if(!available_options)
			return

		var/sect_select = input(user, "Select a aspects preset", "Select a preset", null) in available_options
		if(!Adjacent(user))
			to_chat(user, "<span class='warning'>You are too far away!</span>")
			return

		sect = available_options[sect_select]
		religion = global.chaplain_religion

		sect.on_select(user, religion)

/obj/structure/altar_of_gods/proc/generate_available_sects(mob/user) //eventually want to add sects you get from unlocking certain achievements
	var/list/variants = list()
	for(var/type in subtypesof(/datum/religion_sect))
		var/datum/religion_sect/sect = new type(src)
		if(!sect.name)
			continue
		if(!sect.starter)
			continue
		sect.name += global.chaplain_religion.name
		variants[sect.name] = sect

	return variants
