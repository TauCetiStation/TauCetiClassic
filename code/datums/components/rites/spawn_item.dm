/*
 This component used in chaplain rites to spawn and replace any rites on object
*/
/datum/component/rite/spawn_item
	// Type for the item to be spawned
	var/spawn_type
	// Type for the item to be sacrificed
	var/sacrifice_type
	// Keeps and removes the illusion items
	var/list/spawning_item = list()
	// Keeps and removes the illusions of real items
	var/list/illusion_to_sacrifice = list()
	// Count spawning items. Does not count if items replace
	var/count_items = 1
	// Determinate effect for /invoke_effect()
	var/datum/callback/invoke_effect
	// Change spawn_type
	var/datum/callback/change_spawn_type
	// Extra Mana Cost!
	var/adding_favor_per_item

/datum/component/rite/spawn_item/Initialize(_spawn_type, _count_items, _sacrifice_type, _adding_favor_per_item, _divine_power, datum/callback/_invoke_effect, datum/callback/_change_spawn_type, tip_text)
	spawn_type = _spawn_type
	count_items = _count_items
	sacrifice_type = _sacrifice_type
	adding_favor_per_item = _adding_favor_per_item
	invoke_effect = _invoke_effect
	change_spawn_type = _change_spawn_type

	if(tip_text && tip_text != "")
		src.tip_text = tip_text
		..()
	else
		var/datum/religion_rites/standing/rite = parent
		var/list/tips_to_add = list()
		if(sacrifice_type)
			var/obj/item/item = sacrifice_type
			tips_to_add += "This ritual requires a <i>[initial(item.name)]</i>."

		if(spawn_type)
			var/obj/item/item = spawn_type
			tips_to_add += "This ritual creates a <i>[initial(item.name)]</i>."

		rite.add_tips(tips_to_add)

	RegisterSignal(parent, list(COMSIG_RITE_CAN_START), PROC_REF(check_items_on_altar))
	RegisterSignal(parent, list(COMSIG_RITE_IN_STEP), PROC_REF(update_fake_item))
	RegisterSignal(parent, list(COMSIG_RITE_INVOKE_EFFECT), PROC_REF(replace_fake_item))
	RegisterSignal(parent, list(COMSIG_RITE_FAILED_CHECK), PROC_REF(revert_effects))

/datum/component/rite/spawn_item/Destroy()
	clear_lists()
	QDEL_NULL(invoke_effect)
	QDEL_NULL(change_spawn_type)
	return ..()

// Used to choose which items will be replaced with others
/datum/component/rite/spawn_item/proc/item_sacrifice(obj/AOG, spawn_type)
	var/list/sacrifice_items = list()
	for(var/obj/item/item in get_turf(AOG))
		if(!istype(item, spawn_type))
			continue
		sacrifice_items += item
	return sacrifice_items

/datum/component/rite/spawn_item/proc/check_items_on_altar(datum/source, mob/user, obj/AOG)
	if(!sacrifice_type) // For rites without sacrificial objects
		return NONE

	var/datum/religion_rites/standing/rite = parent

	var/list/L = item_sacrifice(AOG, sacrifice_type)
	if(!L.len)
		to_chat(user, "<span class='warning'>You need more items for sacrifice to perform [rite.name]!</span>")
		clear_lists()
		return COMPONENT_CHECK_FAILED

	if(adding_favor_per_item)
		rite.favor_cost = initial(rite.favor_cost) + adding_favor_per_item * L.len

	for(var/obj/item in L)
		item.forceMove(AOG)
		// Create illusion of real item
		var/obj/effect/overlay/I = new(get_turf(AOG))
		illusion_to_sacrifice += I
		I.appearance = item

	return NONE

// Nice effect for spawn item
/datum/component/rite/spawn_item/proc/item_restoration(obj/AOG, stage)
	var/datum/religion_rites/standing/rite = parent
	var/ratioplus = (255 / rite.ritual_invocations.len) * stage
	var/ratiominus = 255 / stage
	if(sacrifice_type)
		// In ritual_length already writeen SECONDS
		for(var/I in illusion_to_sacrifice)
			animate(I, time = ((rite.ritual_length / rite.ritual_invocations.len) + rand(-10, 10)), alpha = ratiominus - rand(0, 10) - 15)
		for(var/I in spawning_item)
			animate(I, time = (rite.ritual_length / rite.ritual_invocations.len) + rand(-10, 10), alpha = ratioplus + rand(0, 10))
	else
		for(var/I in spawning_item)
			animate(I, time = (rite.ritual_length / rite.ritual_invocations.len) + rand(-10, 10), alpha = ratioplus + rand(0, 10))

/datum/component/rite/spawn_item/proc/update_fake_item(datum/source, mob/user, obj/AOG, stage)
	if(spawning_item.len == 0)
		// Illusion of the subject lies on the real subject
		var/atom/fake = spawn_type
		if(sacrifice_type)
			for(var/obj/item/real_item in AOG)
				var/atom/A = mimic_item(fake, AOG)
				spawning_item += A
				// Set same coordinate
				A.pixel_w = real_item.pixel_w
				A.pixel_x = real_item.pixel_x
				A.pixel_y = real_item.pixel_y
				A.pixel_z = real_item.pixel_z
				A.alpha = 20
		else
			var/datum/religion_rites/standing/rite = parent
			var/counts = count_items * rite.divine_power
			for(var/count in 1 to counts)
				// Spawn illusion of item
				var/atom/A = mimic_item(fake, AOG)
				spawning_item += A
				A.pixel_x = rand(-10, 10)
				A.pixel_y = rand(0, 13)
				A.alpha = 20
	else
		item_restoration(AOG, stage)

/datum/component/rite/spawn_item/proc/mimic_item(atom/fake, obj/AOG)
	var/obj/effect/overlay/I = new(get_turf(AOG))
	I.icon = initial(fake.icon)
	I.icon_state = initial(fake.icon_state)
	I.name = initial(fake.name)
	return I

/datum/component/rite/spawn_item/proc/revert_effects(datum/source, mob/user, obj/AOG)
	if(spawning_item)
		for(var/I in spawning_item)
			animate(I, time = 3 SECONDS, alpha = 0)
	if(sacrifice_type)
		for(var/I in illusion_to_sacrifice)
			animate(I, time = 2.8 SECONDS, alpha = 255)
	addtimer(CALLBACK(src, PROC_REF(pull_out_items), AOG), 3 SECONDS)

/datum/component/rite/spawn_item/proc/pull_out_items(obj/AOG)
	for(var/obj/item/item in AOG.contents)
		item.forceMove(get_turf(AOG))
	clear_lists()
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

/datum/component/rite/spawn_item/proc/replace_fake_item(datum/source, mob/user, obj/AOG)
	for(var/obj/I in spawning_item)
		var/atom/created = new spawn_type(get_turf(AOG))

		if(invoke_effect)
			invoke_effect.Invoke(created)

		if(isitem(created))
			created.pixel_x = I.pixel_x
			created.pixel_y = I.pixel_y

	if(change_spawn_type)
		spawn_type = change_spawn_type.Invoke()

	clear_lists()

// Since the ritual is not recreated every time, you need to clear the lists.
/datum/component/rite/spawn_item/proc/clear_lists()
	QDEL_LIST(spawning_item)
	QDEL_LIST(illusion_to_sacrifice)
