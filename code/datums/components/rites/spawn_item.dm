/*
 This component used
*/
/datum/component/rite_spawn_item
	var/spawn_type //type for the item to be spawned
	var/sacrifice_type //type for the item to be sacrificed
	var/list/spawning_item = list() //keeps and removes the illusion items
	var/list/illusion_to_sacrifice = list() //keeps and removes the illusions of real items

	var/datum/religion_rites/rite
	var/datum/callback/callback
	var/adding_favor_per_item

/datum/component/rite_spawn_item/Initialize(_spawn_type, _sacrifice_type, _adding_favor_per_item, datum/callback/_callback)
	spawn_type = _spawn_type
	sacrifice_type = _sacrifice_type
	rite = parent
	adding_favor_per_item = _adding_favor_per_item
	callback = _callback

	RegisterSignal(parent, list(COMSIG_RITE_REQUIRED_CHECK), .proc/check_items_on_altar)
	RegisterSignal(parent, list(COMSIG_RITE_BEFORE_PERFORM), .proc/create_fake_of_item)
	RegisterSignal(parent, list(COMSIG_RITE_ON_INVOCATION), .proc/update_fake_item)
	RegisterSignal(parent, list(COMSIG_RITE_INVOKE_EFFECT), .proc/replace_fake_item)
	RegisterSignal(parent, list(COMSIG_RITE_FAILED_CHECK), .proc/revert_effects)

// used to choose which items will be replaced with others
/datum/component/rite_spawn_item/proc/item_sacrifice(atom/movable/AOG, spawn_type)
	var/list/sacrifice_item = list()
	for(var/obj/item/item in AOG.loc)
		if(!istype(item, spawn_type))
			continue
		sacrifice_item += item
	return sacrifice_item

/datum/component/rite_spawn_item/proc/check_items_on_altar(datum/source, mob/user, atom/movable/AOG)
	if(sacrifice_type)
		var/list/L = item_sacrifice(AOG, sacrifice_type)
		if(L.len == 0)
			to_chat(user, "<span class='warning'>You need more items for sacrifice to perform [rite.name]!</span>")
			clear_lists()
			return TRUE
	return FALSE

// created illustion of spawning item
/datum/component/rite_spawn_item/proc/create_fake_of_item(datum/source, mob/user, atom/movable/AOG)
	if(sacrifice_type)
		var/list/L = item_sacrifice(AOG, sacrifice_type)
		if(L.len == 0)
			to_chat(user, "<span class='warning'>You need more items for sacrifice to perform [rite.name]!</span>")
			clear_lists()
			return FALSE

		if(adding_favor_per_item)
			rite.favor_cost = initial(rite.favor_cost) + adding_favor_per_item * L.len

		for(var/obj/item in L)
			item.forceMove(AOG)
			//create illusion of real item
			var/obj/effect/overlay/I = new(AOG.loc)
			illusion_to_sacrifice += I
			I.icon = item.icon
			I.icon_state = item.icon_state
			I.name = item.name
			I.pixel_w = item.pixel_w
			I.pixel_x = item.pixel_x
			I.pixel_y = item.pixel_y
			I.pixel_z = item.pixel_z
	return TRUE

// nice effect for spawn item
/datum/component/rite_spawn_item/proc/item_restoration(atom/movable/AOG, stage)
	var/ratioplus = (255 / rite.ritual_invocations.len) * stage
	var/ratiominus = 255 / stage
	if(sacrifice_type)
		for(var/I in illusion_to_sacrifice)
			animate(I, time = (rite.ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratiominus - rand(0, 10) - 15)
		for(var/I in spawning_item)
			animate(I, time = (rite.ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratioplus + rand(0, 10))
	else
		for(var/I in spawning_item)
			animate(I, time = (rite.ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratioplus + rand(0, 10))

/datum/component/rite_spawn_item/proc/update_fake_item(datum/source, mob/user, atom/movable/AOG, stage)
	if(spawning_item.len == 0)
		//illusion of the subject lies on the real subject
		var/atom/fake
		if(sacrifice_type)
			for(var/obj/item/real_item in AOG)
				var/obj/effect/overlay/I = new(AOG.loc)
				fake = sacrifice_type
				I.icon = initial(fake.icon)
				I.icon_state = initial(fake.icon_state)
				I.name = initial(fake.icon_state)
				spawning_item += I
				//set same coordinate
				I.pixel_w = real_item.pixel_w
				I.pixel_x = real_item.pixel_x
				I.pixel_y = real_item.pixel_y
				I.pixel_z = real_item.pixel_z
				I.alpha = 20
		else
			//spawn one illusion of item
			var/obj/effect/overlay/I = new(AOG.loc)
			fake = spawn_type
			I.icon = initial(fake.icon)
			I.icon_state = initial(fake.icon_state)
			I.name = initial(fake.icon_state)
			spawning_item += I
			I.pixel_x = rand(-10, 10)
			I.pixel_y = rand(0, 13)
			I.alpha = 20
	else
		item_restoration(AOG, stage)

/datum/component/rite_spawn_item/proc/revert_effects(datum/source, mob/user, atom/movable/AOG, stage)
	if(spawning_item)
		for(var/I in spawning_item)
			animate(I, time = 3 SECONDS, alpha = 0)
	if(sacrifice_type)
		for(var/obj/item/item in illusion_to_sacrifice)
			animate(item, time = 2.8 SECONDS, alpha = 255)
	sleep(3 SECONDS)
	for(var/obj/item/item in AOG.contents)
		item.forceMove(AOG.loc)
	clear_lists()
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

/datum/component/rite_spawn_item/proc/replace_fake_item(datum/source, mob/user, atom/movable/AOG)
	for(var/obj/I in spawning_item)
		var/atom/created = new spawn_type(AOG.loc)

		if(callback)
			callback.Invoke(created)

		if(!istype(created, /mob))
			created.pixel_x = I.pixel_x
			created.pixel_y = I.pixel_y

	for(var/I in AOG)
		qdel(I)

	clear_lists()

// since the ritual does not re-create the ritual every time, I have to clean the lists.
/datum/component/rite_spawn_item/proc/clear_lists()
	QDEL_LIST(spawning_item)
	QDEL_LIST(illusion_to_sacrifice)
