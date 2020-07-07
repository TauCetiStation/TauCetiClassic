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
	buckle_lying = TRUE

	var/datum/religion_rites/performing_rite
	var/datum/religion_sect/sect //easy access
	var/datum/religion/chaplain/religion //easy access
	var/chosen_aspect = FALSE

	// It's fucking science! I ain't gotta explain this.
	var/datum/experiment_data/experiments

/obj/structure/altar_of_gods/atom_init()
	. = ..()
	experiments = new
	experiments.init_known_tech()

	AddComponent(/datum/component/clickplace)

/obj/structure/altar_of_gods/examine(mob/user)
	. = ..()
	if(!global.chaplain_religion || global.chaplain_religion.aspects.len == 0)
		return

	var/can_i_see = FALSE
	var/msg = ""
	if(isobserver(user))
		can_i_see = TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.mind && L.mind.holy_role)
			can_i_see = TRUE

	if(!can_i_see)
		return

	msg += "<span class='notice'>The sect currently has [round(global.chaplain_religion.favor)] favor with [pick(global.chaplain_religion.deity_names)].\n</span>"

	if(religion.rites_info.len != 0 || religion.rites_by_name.len != 0)
		msg += "List of available Rites:"
		for(var/i in global.chaplain_religion.rites_info)
			msg += "\n[i]"

	to_chat(user, msg)

// This proc handles an animation of item being sacrified and stuff.
/obj/structure/altar_of_gods/proc/sacrifice_item(obj/item/I)
	I.mouse_opacity =  MOUSE_OPACITY_TRANSPARENT
	I.layer = FLY_LAYER

	sleep(rand(1, 3))
	if(QDELING(I))
		return

	var/static/list/waddle_angles = list(-28, -14, 0, 14, 28)

	I.waddle(pick(waddle_angles), 0)
	sleep(2)
	if(QDELING(I))
		return

	var/matrix/M = I.transform
	M.Turn(pick(waddle_angles))

	var/fly_height = rand(20, 40)

	animate(I, transform = M, pixel_z = I.pixel_z + fly_height, alpha = 0, time = 1.5 SECONDS)

	sleep(2 SECONDS)
	if(QDELING(I))
		return

	qdel(I)

// This proc is used to sacrifice all items on altar. Returns TRUE if at least something was sacrificed.
/obj/structure/altar_of_gods/proc/sacrifice(mob/user)
	if(!religion)
		to_chat(user, "<span class ='warning'>First choose aspects in your religion!</span>")
		return FALSE

	if(user.is_busy(src))
		return FALSE

	user.visible_message("<span class='notice'>[user]'s hand moves across [src].</span>", "<span class='notice'>You begin sacrificing items atop [src].</span>")
	if(!do_after(user, target = src, delay = 20))
		return FALSE

	var/sacrificed = FALSE
	for(var/obj/item/I in loc)
		if(I.flags & ABSTRACT)
			continue

		var/max_points = 0

		for(var/aspect in religion.aspects)
			var/datum/aspect/asp = religion.aspects[aspect]
			var/points = asp.sacrifice(I, user, src)
			var/mult = asp.power > 1 ? round(log(asp.power, 10), 0.01) : 0
			mult += 1
			points *= mult
			if(points > max_points)
				max_points = points

		if(max_points > MIN_FAVOUR_GAIN)
			global.chaplain_religion.adjust_favor(max_points, user)
			INVOKE_ASYNC(src, .proc/sacrifice_item, I)
			sacrificed = TRUE

		else if(max_points > 0)
			to_chat(user, "<span class='warning'>You offer [I] to [pick(religion.deity_names)], but they would not accept such pityful offering.</span>")

	if(sacrificed)
		to_chat(user, "<span class='notice'>[pick(religion.deity_names)] accepted your offering.</span>")
		return TRUE
	return FALSE

/obj/structure/altar_of_gods/attack_hand(mob/living/carbon/human/user)
	if(can_buckle && buckled_mob && istype(user))
		user_unbuckle_mob(user)
		return

	user.SetNextMove(CLICK_CD_INTERACT)
	if(user.mind && user.mind.holy_role >= HOLY_ROLE_PRIEST)
		sacrifice(user)
	else
		to_chat(user, "<span class='warning'>You don't know how to use this.</span>")

// This proc should handle sect choice, and ritual execution.
/obj/structure/altar_of_gods/proc/use_religion_tools(obj/item/I, mob/user)
	if(!user.mind)
		return

	if(user.mind.holy_role < HOLY_ROLE_PRIEST)
		return

	// Assume, that if we've gotten this far, it's a succesful tool use.
	. = TRUE
	if(istype(I, /obj/item/weapon/nullrod))
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

		performing_rite = religion.rites_by_name[choosed_rite]
		if(!performing_rite.on_chosen(user, src))
			performing_rite = null
			return

		if(!performing_rite.perform_rite(user, src))
			performing_rite = null
			return

		performing_rite.invoke_effect(user, src)
		religion.adjust_favor(-performing_rite.favor_cost)
		performing_rite = null

		for(var/item in src)
			qdel(item)

		return

	else if(istype(I, /obj/item/weapon/storage/bible) && !chosen_aspect)
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
		religion.altar = src

		sect.on_select(user, religion)
		return

	// Except when it is not.
	return FALSE

/obj/structure/altar_of_gods/attackby(obj/item/C, mob/user, params)
	if(iswrench(C))
		if(!user.is_busy(src) && C.use_tool(src, user, 40, volume = 50))
			anchored = !anchored
			visible_message("<span class='warning'>[src] has been [anchored ? "secured to the floor" : "unsecured from the floor"] by [user].</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			return

	if(anchored && use_religion_tools(C, user))
		return

	return ..()

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

/obj/structure/altar_of_gods/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	return ..()

/obj/structure/altar_of_gods/CheckExit(atom/movable/AM, target)
	if(istype(AM) && AM.checkpass(PASSTABLE))
		return TRUE
	return ..()
