/*
 * Gradual creation of a things.
 */
/datum/religion_rites/spawn_item
	name = "Spawn item"
	var/obj/item/spawn_type //type for the item to be spawned
	var/sacrifice_type //type for the item to be sacrificed
	var/list/spawning_item = list() //keeps and removes the illusion items 
	var/list/illusion_to_sacrifice = list() //keeps and removes the illusions of real items

// used to choose which items will be replaced with others
/datum/religion_rites/spawn_item/proc/item_sacrifice(obj/structure/altar_of_gods/AOG, spawn_type)
	var/list/sacrifice_item = list()
	for(var/obj/item/item in AOG.loc)
		if(!istype(item, spawn_type))
			continue
		sacrifice_item += item
	return sacrifice_item

/datum/religion_rites/spawn_item/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(sacrifice_type)
		var/list/L = item_sacrifice(AOG, sacrifice_type)
		if(L.len == 0)
			to_chat(user, "<span class='warning'>You need more items for sacrifice to perform [name]!</span>")
			return FALSE
	return ..()

// created illustion of spawning item
/datum/religion_rites/spawn_item/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	if(AOG.contents.len == 0 && sacrifice_type)
		var/list/L = item_sacrifice(AOG, sacrifice_type)

		if(L.len == 0)
			to_chat(user, "<span class='warning'>You need more items for sacrifice to perform [name]!</span>")
			INVOKE_ASYNC(src, .proc/revert_effects, AOG)
			return FALSE

		favor_cost += 75 * L.len

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

	if(spawning_item.len == 0)
		//illusion of the subject lies on the real subject
		if(sacrifice_type)
			for(var/obj/item/real_item in AOG)
				var/obj/effect/overlay/I = new(AOG.loc)
				I.icon = initial(spawn_type.icon)
				I.icon_state = initial(spawn_type.icon_state)
				I.name = initial(spawn_type.icon_state)
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
			I.icon = initial(spawn_type.icon)
			I.icon_state = initial(spawn_type.icon_state)
			I.name = initial(spawn_type.icon_state)
			spawning_item += I
			I.pixel_x = rand(-10, 10)
			I.pixel_y = rand(0, 13)
			I.alpha = 20
	else
		item_restoration(stage, AOG)
	return TRUE

// nice effect for spawn item
/datum/religion_rites/spawn_item/proc/item_restoration(stage, obj/structure/altar_of_gods/AOG)
	var/ratioplus = (255 / ritual_invocations.len) * stage
	var/ratiominus = 255 / stage
	if(sacrifice_type)
		for(var/I in illusion_to_sacrifice)
			animate(I, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratiominus - rand(0, 10) - 15)
		for(var/I in spawning_item)
			animate(I, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratioplus + rand(0, 10))
	else
		for(var/I in spawning_item)
			animate(I, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = ratioplus + rand(0, 10))
	return TRUE	

// removes all illusions of the item and restores alpha on the item to replace
/datum/religion_rites/spawn_item/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		INVOKE_ASYNC(src, .proc/revert_effects, AOG)
		return FALSE
	return TRUE

/datum/religion_rites/spawn_item/proc/revert_effects(obj/structure/altar_of_gods/AOG)
	if(spawning_item)
		for(var/I in spawning_item)
			animate(I, time = 3 SECONDS, alpha = 0)
	if(sacrifice_type)
		for(var/obj/item/item in illusion_to_sacrifice)
			animate(item, time = 3 SECONDS, alpha = 255)
	sleep(3 SECONDS)
	QDEL_LIST(spawning_item)
	for(var/obj/item/item in AOG.contents)
		item.forceMove(AOG.loc)
	QDEL_LIST(illusion_to_sacrifice)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

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
	spawn_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana

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

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
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
	sacrifice_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	spawn_type = /obj/item/weapon/ore/clown

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/spawn_item/banana_ore/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	if(sacrifice_type)
		for(var/obj/I in spawning_item)
			var/obj/item/weapon/ore/banana = new /obj/item/weapon/ore/clown(AOG.loc)
			banana.pixel_x = I.pixel_x
			banana.pixel_y = I.pixel_y

		QDEL_LIST(illusion_to_sacrifice)
		QDEL_LIST(spawning_item)

		for(var/I in AOG)
			qdel(I)
		
	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE
