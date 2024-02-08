/datum/element/maelstrom
	element_flags = ELEMENT_DETACH
	var/list/datum/building_agent/available_runes = list(new /datum/building_agent/rune/maelstrom/convert(),
														new /datum/building_agent/rune/maelstrom/portal_beacon(),
														new /datum/building_agent/rune/maelstrom/teleport(),
														new /datum/building_agent/rune/maelstrom/wall(),
														new /datum/building_agent/rune/maelstrom/bloodboil()
														)
	var/static/list/rune_choices_image = list()
	//var/scribing = FALSE
	var/static/list/rune_next = list()
	//var/list/runes_by_ckey

/datum/element/maelstrom/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(target, COMSIG_IMPLANT_INJECTED, PROC_REF(user_registration))

/datum/element/maelstrom/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_IMPLANT_INJECTED, COMSIG_DETECT_MAELSTROM_IMPLANT))

/datum/element/maelstrom/proc/get_agent_radial_menu(list/datum/building_agent/BA, mob/user)
	for(var/datum/building_agent/B in BA)
		B.name = "[initial(B.name)]"
	var/datum/building_agent/choice = show_radial_menu(user, user, BA, tooltips = TRUE, require_near = TRUE)
	return choice

/datum/element/maelstrom/proc/scribe_rune(mob/user)
	var/datum/building_agent/rune/cult/choice = get_agent_radial_menu(rune_choices_image, user)
	if(!choice)
		return

	if(rune_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>Ты сможешь разметить следующую руну через [round((rune_next[user.ckey] - world.time) * 0.1)+1] секунд!</span>")
		return
	rune_next[user.ckey] = world.time + 10 SECONDS

	if(!do_after(user, 3 SECONDS, target = get_turf(user)))
		return
	if(locate(/obj/effect/decal/cleanable/crayon/maelstrom) in get_turf(user))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), rand(5, 10))

	var/picked_color = pick("#da0000", "#ff9300", "#fff200", "#a8e61d", "#00b7ef", "#da00ff", "#ffffff")
	var/static/list/shade_list = list("#da0000" = "#810c0c",
									"#ff9300" = "#a55403",
									"#fff200" = "#886422",
									"#a8e61d" = "#61840f",
									"#00b7ef" = "#0082a8",
									"#da00ff" = "#810cff",
									"#ffffff" = "#cecece")
	var/obj/effect/decal/cleanable/crayon/maelstrom/R = new choice.building_type(get_turf(user), picked_color, shade_list[picked_color])
	R.icon = rune_choices_image[choice]
	R.power = new choice.rune_type(R)
	R.power.religion = null
	R.blood_DNA = list()
	R.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type
	R.creator_ckey = user.ckey

/datum/element/maelstrom/proc/rune_choices()
	for(var/datum/building_agent/rune/maelstrom/B in available_runes)
		var/datum/rune/maelstrom/R = new B.rune_type
		rune_choices_image[B] = image(icon = R.get_choice_image())
		qdel(R)

/datum/element/maelstrom/proc/begin_draw(mob/user)
	if(rune_choices_image.len < available_runes.len)
		rune_choices()
	scribe_rune(user)

/datum/element/maelstrom/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		INVOKE_ASYNC(src, PROC_REF(begin_draw), user)
		return
	var/obj/item/weapon/implant/I = source
	if(!istype(I))
		return
	// works only when implanted to hands
	if(I.part && (I.part == H.get_bodypart(BP_L_ARM) || I.part == H.get_bodypart(BP_R_ARM)))
		INVOKE_ASYNC(src, PROC_REF(begin_draw), user)

/datum/element/maelstrom/proc/re_enable_detecting_inject(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	RegisterSignal(source, COMSIG_IMPLANT_INJECTED, PROC_REF(user_registration))

/datum/element/maelstrom/proc/user_registration(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_IMPLANT_INJECTED)
	RegisterSignal(source, COMSIG_IMPLANT_REMOVAL, PROC_REF(re_enable_detecting_inject))
	RegisterSignal(user, COMSIG_DETECT_MAELSTROM_IMPLANT, PROC_REF(detect_maelstrom_implant))

/datum/element/maelstrom/proc/detect_maelstrom_implant(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_IMPLANT_DETECTED
