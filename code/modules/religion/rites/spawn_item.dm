/*
 * Gradual creation of a things.
 */
/datum/religion_rites/spawn_item
	name = "Spawn item"
	var/obj/item/item_path //path for the item to be spawned
	var/list/spawning_item //if you want to spawn some object, then create this list in the object
	var/list/items_to_sacrifice //if you want to spawn some object, then create this list in the object

// used to choose which items will be replaced with others
/datum/religion_rites/spawn_item/proc/item_sacrifice(obj/structure/altar_of_gods/AOG, item_path)
	var/list/sacrifice_item = list()
	for(var/obj/item/item in AOG.loc)
		if(!istype(item, item_path))
			continue
		sacrifice_item += item
	return sacrifice_item

// created objects
/datum/religion_rites/spawn_item/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	if(items_to_sacrifice)
		//check count needed items on altar
		for(var/obj/item/item in items_to_sacrifice)
			if(item.loc != AOG.loc)
				items_to_sacrifice -= item
			if(items_to_sacrifice.len == 0)
				to_chat(user, "We need more [item.name]!")
				return FALSE

		//not tought items!
		for(var/obj/item/item in items_to_sacrifice)
			item.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	if(spawning_item.len == 0)
		//illusion of the subject lies on the real subject
		if(items_to_sacrifice)
			for(var/obj/item/real_item in items_to_sacrifice)
				var/obj/effect/overlay/I = new(AOG.loc)
				I.icon = initial(item_path.icon)
				I.icon_state = initial(item_path.icon_state)
				I.name = initial(item_path.icon_state)
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
			I.icon = initial(item_path.icon)
			I.icon_state = initial(item_path.icon_state)
			I.name = initial(item_path.icon_state)
			spawning_item += I
			I.pixel_x = rand(-10, 10)
			I.pixel_y = rand(0, 13)
			I.alpha = 20
	else
		item_restoration(stage, AOG)
	return TRUE

// nice effect for spawn item
/datum/religion_rites/spawn_item/proc/item_restoration(stage, obj/structure/altar_of_gods/AOG)
	var/ratio = 255 / stage - 20
	if(items_to_sacrifice)
		for(var/obj/item/I in items_to_sacrifice)
			animate(I, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = I.alpha - ratio - rand(0, 10) - 10)
		for(var/I in spawning_item)
			animate(I, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratio + rand(0, 10))
	else
		for(var/I in spawning_item)
			animate(I, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratio + rand(0, 10))
	return TRUE	

// removes all illusions of the item and restores alpha on the item to replace
/datum/religion_rites/spawn_item/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(user.is_busy(AOG) || !do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
		if(spawning_item)
			for(var/I in spawning_item)
				animate(I, time = 3 SECONDS, alpha = 0)
		if(items_to_sacrifice)
			for(var/obj/item/i in items_to_sacrifice)
				animate(i, time = 3 SECONDS, alpha = 255)
				i.mouse_opacity = initial(i.mouse_opacity)
		sleep(3 SECONDS)
		QDEL_LIST(spawning_item)
		playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)
		return FALSE
	return TRUE

/*
 * Spawn banana
 */
/datum/religion_rites/spawn_item/banana
	name = "Atomic molecular reconstruction of a whole blessed banana"
	desc = "BANANAS!"
	ritual_length = (40 SECONDS)
	ritual_invocations = list("Oh great mother!...",
							"...May your power descend to us and bestow upon your part....",
							"...Rising from sleep, in the middle of the night I bring you a song...",
							"...and falling at Your feet, I appeal to Thee...",
							"...take pity on me, and over all the clowns of the world!...",
							"...pick me up lying carelessly and save me...")
	invoke_msg = "...and send me strength!!!"
	favor_cost = 75
	spawning_item = list()
	item_path = /obj/item/weapon/reagent_containers/food/snacks/grown/banana

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_CHAOS = 1,
	)

/datum/religion_rites/spawn_item/banana/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	var/obj/item/banana	
	for(var/obj/I in spawning_item)
		if(prob(20))
			banana = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk(AOG.loc)
		else
			banana = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(AOG.loc)

		banana.name = "blessed [banana.name]"
		banana.pixel_x = I.pixel_x
		banana.pixel_y = I.pixel_y

	QDEL_LIST(spawning_item)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/*
 * Spawn bananium ore
 */
/datum/religion_rites/spawn_item/banana_ore
	name = "Enrichment of oxygen molecules with banana atoms"
	desc = "Empire recovery!"
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Oh great mother!...",
							"...Help us in this difficult moment!...",
							"...We pray, please send us strength!...",
							"...Empower these bananas with your energy...",
							"...And may they gain your mighty power in order to help us!...",
							"...Now is the time for your help, so please do, oh great one!...")
	invoke_msg = "...We believe in you!!!"
	favor_cost = 150
	spawning_item = list()
	items_to_sacrifice = list()
	item_path = /obj/item/weapon/ore/clown

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/spawn_item/banana_ore/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	items_to_sacrifice = item_sacrifice(AOG, /obj/item/weapon/reagent_containers/food/snacks/grown/banana)

	if(items_to_sacrifice.len == 0)
		to_chat(user, "We need more bananas!")
		return FALSE

	favor_cost += items_to_sacrifice.len * 75
	return ..()

/datum/religion_rites/spawn_item/banana_ore/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	if(items_to_sacrifice)
		for(var/obj/I in spawning_item)
			var/obj/item/weapon/ore/banana = new /obj/item/weapon/ore/clown(AOG.loc)
			banana.pixel_x = I.pixel_x
			banana.pixel_y = I.pixel_y

		QDEL_LIST(items_to_sacrifice)
		QDEL_LIST(spawning_item)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE
