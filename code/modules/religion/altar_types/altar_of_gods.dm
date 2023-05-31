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
	var/datum/religion/religion //easy access

	var/chosen_aspect = FALSE
	var/look_piety = FALSE

	// It's fucking science! I ain't gotta explain this.
	var/datum/experiment_data/experiments
	// name = image
	var/list/rite_images = list()

	var/list/mob/mobs_around = list()
	var/list/turf/turfs_around = list()

/obj/structure/altar_of_gods/atom_init()
	. = ..()
	experiments = new
	experiments.init_known_tech()

	AddComponent(/datum/component/clickplace)
	RegisterSignal(src, list(COMSIG_OBJ_START_RITE), .proc/start_rite)
	RegisterSignal(src, list(COMSIG_OBJ_RESET_RITE), .proc/reset_rite)
	init_turfs_around()

/obj/structure/altar_of_gods/Destroy()
	mobs_around = null
	turfs_around = null
	if(religion)
		religion.altars -= src
	qdel(experiments)
	return ..()

/obj/structure/altar_of_gods/examine(mob/user)
	. = ..()
	if(!religion || religion.aspects.len == 0)
		return

	var/can_i_see = FALSE
	var/msg = ""
	if(isobserver(user))
		can_i_see = TRUE
	else if(user.my_religion == religion)
		can_i_see = TRUE

	if(!can_i_see)
		return

	var/piety = ""
	if(look_piety)
		piety = "and <span class='[religion.style_text]'>[round(religion.piety)] piety</span>"

	msg += "<span class='notice'>The religion currently has [round(religion.favor)] favor [piety] with [pick(religion.deity_names)].\n</span>"

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
	if(!religion || !religion.aspects.len)
		to_chat(user, "<span class ='warning'>First choose aspects in your religion!</span>")
		return FALSE

	if(user.is_busy(src))
		return FALSE

	user.visible_message("<span class='notice'>[user]'s hand moves across [src].</span>", "<span class='notice'>You begin sacrificing items atop [src].</span>")
	if(!do_after(user, target = src, delay = 20))
		return FALSE

	var/sacrificed = FALSE
	for(var/obj/item/I in loc)
		if(I.flags & ABSTRACT || HAS_TRAIT(I, TRAIT_NO_SACRIFICE))
			continue

		var/max_points = 0

		for(var/aspect in religion.aspects)
			var/datum/aspect/asp = religion.aspects[aspect]
			var/points = asp.sacrifice(I, user, src)
			var/mult = asp.power > 1 ? round(log(asp.power), 0.01) : 0
			mult += 1
			points *= mult
			if(points > max_points)
				max_points = points

		if(max_points > MIN_FAVOUR_GAIN)
			religion.adjust_favor(max_points, user)
			INVOKE_ASYNC(src, .proc/sacrifice_item, I)
			sacrificed = TRUE

		else if(max_points > 0)
			to_chat(user, "<span class='warning'>You offer [I] to [pick(religion.deity_names)], but they would not accept such pityful offering.</span>")

	if(sacrificed)
		to_chat(user, "<span class='notice'>[pick(religion.deity_names)] accepted your offering.</span>")
		return TRUE
	return FALSE

/obj/structure/altar_of_gods/attack_hand(mob/user)
	if(can_buckle && buckled_mob && istype(user))
		user_unbuckle_mob(user)
		return

	user.SetNextMove(CLICK_CD_INTERACT)
	if(user.mind && user.mind.holy_role >= HOLY_ROLE_PRIEST)
		sacrifice(user)
	else
		to_chat(user, "<span class='warning'>You don't know how to use this.</span>")

/obj/structure/altar_of_gods/proc/can_interact(mob/user)
	if(religion && user.my_religion != religion)
		to_chat(user, "Are you a member of another religion.")
		return FALSE
	if(!user.mind)
		return FALSE
	if(user.mind.holy_role < HOLY_ROLE_PRIEST)
		return FALSE
	return TRUE

/obj/structure/altar_of_gods/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ReligiousTool", religion.name)
		ui.open()

/obj/structure/altar_of_gods/tgui_data(mob/user)
	var/list/data = list()
	//cannot find global vars, so lets offer options
	if(!chosen_aspect)
		data["sects"] = get_sects_list()
	else
		data["sects"] = null
		data["name"] = religion.name
		data["deities"] = get_english_list(religion.deity_names)
		data["favor"] = religion.favor
		data["piety"] = religion.piety
		data["max_favor"] = religion.max_favor
		data["passive_favor_gain"] = religion.passive_favor_gain
		data["aspects"] = get_aspect_list()
		data["rites"] = get_rites_list()
		data["techs"] = get_techs_list()
		data["god_spells"] = get_spells_list()
		data["holy_reagents"] = get_reagents_list()
		data["faith_reactions"] = get_reactions_list()
		data["can_talismaning"] = istype(user.get_active_hand(), /obj/item/weapon/paper/talisman)

	data["holds_religious_tool"] = istype(user.get_active_hand(), religion.religious_tool_type)

	return data

/obj/structure/altar_of_gods/tgui_static_data(mob/user)
	var/list/data = list()
	data["encyclopedia"] = religion.encyclopedia.get_entire_encyclopedia()
	return data

/obj/structure/altar_of_gods/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return FALSE
	var/mob/user = ui.user
	if(!can_interact(user))
		return FALSE
	switch(action)
		if("sect_select")
			sect_select(user, params["path"])
			return TRUE
		if("perform_rite")
			perform_rite(user, params["rite_name"])
			return FALSE
		if("talismaning_rite")
			talismaning_rite(user, params["rite_name"])
			return FALSE
	return FALSE

// This proc should handle sect choice, and ritual execution.
/obj/structure/altar_of_gods/proc/use_religion_tools(obj/item/I, mob/user)
	if(!can_interact(user))
		return

	// Assume, that if we've gotten this far, it's a succesful tool use.
	. = TRUE
	if(!religion && user?.my_religion?.religious_tool_type && istype(I, user.my_religion.religious_tool_type))
		religion = user.my_religion
		religion.altars |= src
		interact_religious_tool(I, user)
		return

	if(!religion)
		return

	if(istype(I, religion.religious_tool_type))
		interact_religious_tool(I, user)
		return

	if(istype(I, /obj/item/weapon/paper/talisman))
		interact_talisman(I, user)
		return

	// Except when it is not.
	return FALSE

/obj/structure/altar_of_gods/proc/perform_rite(mob/user, rite_name)
	if(!istype(user.get_active_hand(), religion.religious_tool_type))
		return

	if(!rite_name)
		return

	if(performing_rite)
		to_chat(user, "<span class='warning'>You are already performing [performing_rite.name]!</span>")
		return

	if(!Adjacent(user))
		to_chat(user, "<span class='warning'>You are too far away!</span>")
		return

	performing_rite = religion.rites_by_name[rite_name]
	performing_rite.perform_rite(user, src)

/obj/structure/altar_of_gods/proc/talismaning_rite(mob/user, rite_name)
	var/obj/item/weapon/paper/talisman/T = user.get_active_hand()
	if(!istype(T))
		return
	if(T.rite)
		to_chat(user, "<span class='warning'>Талисман уже заряжен.</span>")
		return

	T.religion = religion

	var/datum/religion_rites/R = religion.rites_by_name[rite_name]
	if(!religion.check_costs(R.favor_cost*2, R.piety_cost*2, user))
		return
	if(!do_after(user, 5 SECONDS, target = src))
		return

	to_chat(user, "<span class='notice'>Вы успешно зарядили талисман.</span>")
	T.rite = new R.type
	T.rite.religion = religion
	T.rite.favor_cost = 0
	T.rite.piety_cost = 0
	religion.adjust_favor(-R.favor_cost*2)
	religion.adjust_piety(-R.piety_cost*2)

/obj/structure/altar_of_gods/proc/interact_religious_tool(obj/item/I, mob/user)
	if(!religion)
		return

	tgui_interact(user)

/obj/structure/altar_of_gods/proc/sect_select(mob/living/user, sect_type)
	if(!istype(user.get_active_hand(), religion.religious_tool_type))
		return

	if(!sect_type || chosen_aspect)
		return

	chosen_aspect = TRUE

	religion.sect = new sect_type
	religion.sect.on_select(user, religion)

/obj/structure/altar_of_gods/proc/interact_talisman(obj/item/weapon/paper/talisman/T, mob/user)
	if(!religion)
		return
	if(T.rite)
		to_chat(user, "<span class='warning'>Талисман уже заряжен.</span>")
		return

	tgui_interact(user)

/obj/structure/altar_of_gods/proc/get_sects_list()
	var/list/all_sects = list()
	for(var/sect_type in religion.get_sects_types())
		var/datum/religion_sect/RS = new sect_type

		var/list/sect_info = list()

		sect_info[SECT_NAME]      = RS.name
		if(RS.add_religion_name)
			sect_info[SECT_NAME] += religion.name
		sect_info[SECT_DESC]      = RS.desc
		sect_info[SECT_PRESET]    = null
		sect_info[SECT_ASP_COUNT] = null
		sect_info[SECT_PATH]      = RS.type

		if(istype(RS, /datum/religion_sect/preset))
			var/datum/religion_sect/preset/PRS = RS
			var/list/aspect_name_by_count = list()
			for(var/asp_type in PRS.aspect_preset)
				var/datum/aspect/asp_byond_cheat = asp_type
				aspect_name_by_count[initial(asp_byond_cheat.name)] = PRS.aspect_preset[asp_type]
			sect_info[SECT_PRESET]    = aspect_name_by_count
		else if(istype(RS, /datum/religion_sect/custom))
			var/datum/religion_sect/custom/CRS = RS
			sect_info[SECT_ASP_COUNT] = CRS.aspects_count

		all_sects += list(sect_info)

		QDEL_NULL(RS)

	return all_sects

/obj/structure/altar_of_gods/proc/get_aspect_list()
	var/list/aspects = list()
	for(var/aspect_name in religion.aspects)
		var/datum/aspect/asp = religion.aspects[aspect_name]
		aspects[aspect_name] = asp.power
	return aspects

/obj/structure/altar_of_gods/proc/get_rites_list()
	var/list/all_rites = list()
	for(var/rite_name in religion.rites_by_name)
		var/list/rite_info = list()
		var/datum/religion_rites/RR = religion.rites_by_name[rite_name]
		rite_info[RITE_NAME]       = RR.name
		rite_info[RITE_DESC]       = RR.desc
		rite_info[RITE_TIPS]       = RR.tips
		rite_info[RITE_LENGTH]     = RR.ritual_length
		rite_info[RITE_FAVOR]      = RR.favor_cost
		rite_info[RITE_PIETY]      = RR.piety_cost
		rite_info[RITE_TALISMANED] = RR.can_talismaned
		rite_info[RITE_PATH]       = RR.type
		rite_info["power"]         = RR.divine_power
		all_rites += list(rite_info)
	return all_rites

/obj/structure/altar_of_gods/proc/get_techs_list()
	var/list/techs = list()
	for(var/tech_name in religion.all_techs)
		techs += tech_name
	return techs

/obj/structure/altar_of_gods/proc/get_spells_list()
	var/list/all_spells = list()
	for(var/type in religion.god_spells)
		var/obj/spell = type
		all_spells += initial(spell.name)
	return all_spells

/obj/structure/altar_of_gods/proc/get_reagents_list()
	var/list/reagents = list()
	for(var/reagent_name in religion.holy_reagents)
		reagents += reagent_name
	return reagents

/obj/structure/altar_of_gods/proc/get_reactions_list()
	var/list/reactions = list()
	for(var/reaction_name in religion.faith_reactions)
		var/datum/faith_reaction/FR = religion.faith_reactions[reaction_name]
		reactions += "[FR.convertable_id] to [FR.result_id]"
	return reactions

/obj/structure/altar_of_gods/attackby(obj/item/C, mob/user, params)
	if(iswrenching(C))
		if(!user.is_busy(src) && C.use_tool(src, user, 40, volume = 50))
			anchored = !anchored
			visible_message("<span class='warning'>[src] has been [anchored ? "secured to the floor" : "unsecured from the floor"] by [user].</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			if(anchored)
				init_turfs_around()
			else
				clear_turfs_around()
			return

	if(anchored && use_religion_tools(C, user))
		return

	return ..()

/obj/structure/altar_of_gods/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	return ..()

/obj/structure/altar_of_gods/proc/init_turfs_around()
	for(var/turf/T as anything in RANGE_TURFS(3, src))
		RegisterSignal(T, list(COMSIG_ATOM_ENTERED), .proc/turf_around_enter)
		RegisterSignal(T, list(COMSIG_ATOM_EXITED), .proc/turf_around_exit)
		turfs_around += T

/obj/structure/altar_of_gods/proc/clear_turfs_around()
	for(var/turf/T in turfs_around)
		UnregisterSignal(T, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
		turfs_around -= T
	for(var/M in mobs_around)
		mobs_around -= M

/obj/structure/altar_of_gods/proc/turf_around_enter(atom/source, atom/movable/mover, atom/oldLoc)
	if(ismob(mover))
		mobs_around |= mover

/obj/structure/altar_of_gods/proc/turf_around_exit(atom/source, atom/movable/mover, atom/newLoc)
	mobs_around -= mover

/obj/structure/altar_of_gods/proc/start_rite()
	return

/obj/structure/altar_of_gods/proc/reset_rite()
	performing_rite = null

	for(var/item in src)
		qdel(item)

/obj/structure/altar_of_gods/proc/setup_altar(datum/religion/R)
	religion = R
	religion.altars |= src
	chosen_aspect = TRUE
