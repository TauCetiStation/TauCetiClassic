/*
 * Gradual creation of a things.
 */
/datum/religion_rites/spawn_item
	name = "Spawn item"
	var/obj/item/spawn_type //type for the item to be spawned
	var/sacrifice_type //type for the item to be sacrificed

	var/adding_favor = 75

/datum/religion_rites/spawn_item/New()
	AddComponent(/datum/component/rite_spawn_item, spawn_type, 1, sacrifice_type, adding_favor, CALLBACK(src, .proc/modify_item))

	if(sacrifice_type)
		var/obj/item/item = initial(sacrifice_type)
		tip_text += "This ritual requires a <i>[initial(item.name)]</i>."

	if(spawn_type)
		if(tip_text)
			tip_text += " "
		var/obj/item/item = initial(spawn_type)
		tip_text += "This ritual creates a <i>[initial(item.name)]</i>."

/datum/religion_rites/spawn_item/proc/modify_item(atom/item)


/*
 * Spawn banana
 */
/datum/religion_rites/spawn_item/banana
	name = "Atomic molecular reconstruction of a whole blessed banana"
	desc = "BANANAS!"
	ritual_length = (10 SECONDS)
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

/datum/religion_rites/spawn_item/modify_item(atom/item)
	if(prob(20))
		var/atom/before_item_loc = item.loc
		qdel(item)
		item = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk(before_item_loc)

/datum/religion_rites/spawn_item/banana/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Spawn bananium ore
 */
/datum/religion_rites/spawn_item/banana_ore
	name = "Enrichment of oxygen molecules with banana atoms"
	desc = "Empire recovery!"
	ritual_length = (50 SECONDS)
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
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE
