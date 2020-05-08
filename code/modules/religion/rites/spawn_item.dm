/*
 * Gradual creation of a things.
 */
/datum/religion_rites/spawn_item
	name = "Spawn item"
	var/item_path //path for item
	var/list/spawning_item //creating items
	var/list/replacement_item //ref on items for replace their

// created objects
/datum/religion_rites/spawn_item/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(replacement_item)
		//check count needed items on altar
		for(var/i in replacement_item)
			var/obj/item/item = i
			if(item.loc != AOG.loc)
				replacement_item -= item
			if(replacement_item.len == 0)
				to_chat(user, "We need more [item.name]!")
				return FALSE

		//not tought items!
		for(var/i in replacement_item)
			var/obj/item/item = i
			item.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	if(spawning_item.len == 0)
		var/obj/item/item
		//illusion of the subject lies on the real subject 
		if(item_path && replacement_item)
			for(var/i in replacement_item)
				var/obj/item/real_item = i
				item = new item_path(AOG.loc)
				if(spawning_item)
					spawning_item += item
					//set same coordinate
					item.pixel_w = real_item.pixel_w
					item.pixel_x = real_item.pixel_x
					item.pixel_y = real_item.pixel_y
					item.pixel_z = real_item.pixel_z
					item.alpha = 20
		else
			//spawn one illusion of item
			item = new item_path(AOG.loc)
			spawning_item += item
			item.pixel_x = rand(-10, 10)
			item.pixel_y = rand(0, 13)
			item.alpha = 20
	else
		item_restoration()
	return TRUE

// nice effect for spawn item
/datum/religion_rites/spawn_item/proc/item_restoration()
	var/stage = 255 / (ritual_invocations.len - 1) - 20
	if(replacement_item)
		for(var/obj/item/item in replacement_item)
			animate(item, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = item.alpha - stage - rand(0, 10))
		for(var/obj/item/item in spawning_item)
			animate(item, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = item.alpha + stage + rand(0, 10))
	else
		for(var/obj/item/item in spawning_item)
			animate(item, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = item.alpha + stage + rand(0, 10))
	return TRUE	

//removes all illusions of the item and restores alpha on the item to replace
/datum/religion_rites/spawn_item/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(user.is_busy(AOG) || !do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
		if(spawning_item)
			for(var/item in spawning_item)
				animate(item, time = 3 SECONDS, alpha = 0)
		if(replacement_item)
			for(var/obj/item/i in replacement_item)
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
	invoke_msg = "..and send me strength!!!"
	favor_cost = 75
	spawning_item = list()
	item_path = /obj/item/weapon/reagent_containers/food/snacks/grown/banana

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_FOOD = 1,
	)

/datum/religion_rites/spawn_item/banana/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	QDEL_LIST(spawning_item)
	
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	var/obj/item/banana
	if(prob(20))
		banana = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk(AOG.loc)
	else
		banana = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(AOG.loc)
	for(var/obj/item/item in spawning_item)
		banana.pixel_x = item.pixel_x
		banana.pixel_y = item.pixel_y
	banana.name = "blessed [banana.name]"

	return TRUE

/*
 * Spawn bananium ore
 */
/datum/religion_rites/spawn_item/banana_ore/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/banana/I in AOG.loc)
		replacement_item += I
		favor_cost += 75

	if(replacement_item.len == 0)
		to_chat(user, "We need more bananas!")
		return FALSE
	return ..()

/datum/religion_rites/spawn_item/banana_ore
	name = "Enrichment of oxygen molecules with banana atoms"
	desc = "BANANAS!"
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Oh great mother!...",
							"...May your power descend to us and bestow upon your part....",
							"...Rising from sleep, in the middle of the night I bring you a song...",
							"...and falling at Your feet, I appeal to Thee...",
							"...take pity on me, and over all the clowns of the world!...",
							"...pick me up lying carelessly and save me...")
	invoke_msg = "..and send me strength!!!"
	favor_cost = 150
	spawning_item = list()
	replacement_item = list()
	item_path = /obj/item/weapon/ore/clown

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/spawn_item/banana_ore/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	if(replacement_item)
		for(var/obj/item/item in spawning_item)
			var/obj/item/weapon/ore/banana = new /obj/item/weapon/ore/clown(AOG.loc)
			banana.pixel_x = item.pixel_x
			banana.pixel_y = item.pixel_y

		QDEL_LIST(replacement_item)
		QDEL_LIST(spawning_item)
	return TRUE
