/datum/element/rune_function
	element_flags = ELEMENT_DETACH
	var/static/list/uplink_items_image
	var/list/datum/building_agent/items_to_create = list()

/datum/element/rune_function/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_REGULAR_CLICKED, PROC_REF(on_click))
	RegisterSignal(target, COMSIG_ATTACK_HAND_FULTOPORTAL, PROC_REF(portal_handattack))
	if(items_to_create.len)
		return
	init_subtypes(/datum/building_agent/tool/maelstrom, items_to_create)

/datum/element/rune_function/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_REGULAR_CLICKED)

/datum/element/rune_function/proc/on_click(datum/source, mob/user, params)
	SIGNAL_HANDLER
	if(!(SEND_SIGNAL(user, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED))
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	if(get_dist(user, source) > 1) // anti-telekinesis
		return
	if(istype(source, /obj/effect/decal/cleanable/crayon/maelstrom))
		var/obj/effect/decal/cleanable/crayon/maelstrom/power_holder = source
		power_holder.power.action_wrapper(user)

/datum/element/rune_function/proc/gen_images()
	uplink_items_image = list()
	for(var/datum/building_agent/B as anything in items_to_create)
		var/atom/build = B.building_type
		uplink_items_image[B] = image(icon = initial(build.icon), icon_state = initial(build.icon_state))

/datum/element/rune_function/proc/open_uplink(mob/living/user, atom/uplink)
	if(!uplink_items_image || uplink_items_image.len < items_to_create.len)
		gen_images()
	var/datum/building_agent/choice = show_radial_menu(user, uplink, uplink_items_image, tooltips = TRUE, require_near = TRUE)
	if(!istype(choice))
		return
	if(istype(choice, /datum/building_agent/tool/maelstrom/blade))
		var/obj/item/weapon/kitchenknife/ritual/calling_up/dagger = new(uplink.loc)
		dagger.register_user(user)
	else
		new choice.building_type(uplink.loc)

	playsound(src, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/sparks/purple(uplink.loc)

	qdel(uplink)

/datum/element/rune_function/proc/portal_handattack(datum/uplink, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(open_uplink), user, uplink)
