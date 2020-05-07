/*
 * Food summoning
 * Grants a lot of food while you AFK near the altar. Even more food if you finish the ritual.
 */
/datum/religion_rites/food
	name = "Create food"
	desc = "Create more and more food!"
	ritual_length = (2.2 MINUTES)
	ritual_invocations = list("O Lord, we pray to you: hear our prayer, that they may be delivered by thy mercy, for the glory of thy name...", //TODO
						"...our crops and gardens, now it's fair for our sins that are destroyed and a real disaster is suffered, from birds, worms, mice, moles and other animals...",
						"...and driven far away from this place by Your authority, may they not harm anyone, but these fields and waters...",
						"...and the gardens will be left completely at rest so that all that is growing and born in them will serve for thy glory...",
						"...and our needs helped, for we praise you...")
	invoke_msg = "...and bring glory to you!!"
	favor_cost = 300

	needed_aspects = list(
		ASPECT_FOOD = 1,
	)

// This proc is also used by spells/religion.dm "spawn food". Stupid architecture, gotta deal with it some time ~Luduk
// Perhaps allow God to do rituals instead? ~Luduk
/proc/spawn_food(atom/location, amount)
	var/static/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food)

	playsound(location, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/i in 1 to amount)
		var/chosen = pick(borks)
		var/obj/B = new chosen(location)
		var/obj/randomcatcher/CATCH
		if(!B.icon_state || !B.reagents || !B.reagents.reagent_list.len)
			QDEL_NULL(B)
			CATCH = new /obj/randomcatcher(location)
			B = CATCH.get_item(pick(/obj/random/foods/drink_can, /obj/random/foods/drink_bottle, /obj/random/foods/food_snack, /obj/random/foods/food_without_garbage))
			QDEL_NULL(CATCH)
		if(B && prob(80))
			for(var/j in 1 to rand(1, 3))
				step(B, pick(NORTH, SOUTH, EAST, WEST))

/datum/religion_rites/food/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(AOG.loc, 4 + rand(2, 5))

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/food/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(prob(50))
		spawn_food(AOG.loc, 1)
	return TRUE

/*
 * Prayer
 * Increases favour while you AFK near altar, heals everybody around if invoked succesfully.
 */
/datum/religion_rites/pray
	name = "Prayer to god"
	desc = "Very long pray for favor"
	ritual_length = (4 MINUTES)
	ritual_invocations = list("Have mercy on us, O Lord, have mercy on us...",
							  "...for at a loss for any defense, this prayer do we sinners offer Thee as Master...",
							  "...have mercy on us...",
							  "...Lord have mercy on us, for we have hoped in Thee, be not angry with us greatly, neither remember our iniquities...",
							  "...but look upon us now as Thou art compassionate, and deliver us from our enemies...",
							  "...for Thou art our God, and we, Thy people; all are the works of Thy hands, and we call upon Thy name...",
							  "...Both now and ever, and unto the ages of ages...",
							  "...The door of compassion open unto us 0 blessed Theotokos, for hoping in thee...",
							  "...let us not perish; through thee may we be delivered from adversities, for thou art the salvation of the Our race...")
	invoke_msg = "Lord have mercy. Twelve times."
	favor_cost = 0

	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/pray/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/heal_num = -15
	for(var/mob/living/L in range(2, src))
		L.apply_damages(heal_num, heal_num, heal_num, heal_num, heal_num, heal_num)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/pray/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	global.chaplain_religion.favor += 20
	return TRUE

/*
 * Gradual creation of a things.
 */
/datum/religion_rites/spawn_item
	name = "Spawn item"
	var/fake_path
	var/list/spawning_fake_item //path for fake-item
	var/list/replacement_item //ref on items for replace their

/obj/item/fake
	name = "Not real thing"
	icon_state = null
	mouse_opacity =  MOUSE_OPACITY_TRANSPARENT
	alpha = 0

// created temp fake object
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
			var/obj/item/fake/item = i
			item.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	if(spawning_fake_item.len == 0)
		var/obj/item/fake/fake_item
		if(fake_path && replacement_item)
			for(var/i in replacement_item)
				var/obj/item/real_item = i
				fake_item = new fake_path(AOG.loc)
				if(spawning_fake_item)
					spawning_fake_item += fake_item
					//set same coordinate
					fake_item.pixel_w = real_item.pixel_w
					fake_item.pixel_x = real_item.pixel_x
					fake_item.pixel_y = real_item.pixel_y
					fake_item.pixel_z = real_item.pixel_z
					fake_item.alpha = 20
		else
			fake_item = new fake_path(AOG.loc)
			spawning_fake_item += fake_item
			fake_item.pixel_w = rand(-10, 10)
			fake_item.pixel_x = rand(-10, 10)
			fake_item.pixel_y = rand(-10, 10)
			fake_item.pixel_z = rand(-10, 10)
		fake_item.alpha = 20
	else
		item_restoration()
	return TRUE

// nice effect for spawn item
/datum/religion_rites/spawn_item/proc/item_restoration()
	var/stage = 255 / (ritual_invocations.len - 1) - 20
	if(replacement_item)
		for(var/obj/item/item in replacement_item)
			animate(item, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = item.alpha - stage - rand(0, 10))
		for(var/obj/item/item in spawning_fake_item)
			animate(item, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = item.alpha + stage + rand(0, 10))
	else
		for(var/obj/item/item in spawning_fake_item)
			animate(item, time = (ritual_invocations.len + rand(0, 3)) SECONDS, alpha = item.alpha + stage + rand(0, 10))
	return TRUE	

/*
 * Spawn banana
 */
/datum/religion_rites/spawn_item/banana
	name = "Atomic molecular reconstruction of a whole blessed banana"
	desc = "BANANAS!"
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Oh great mother!...",
							"...May your power descend to us and bestow upon your part....",
							"...Rising from sleep, in the middle of the night I bring you a song...",
							"...and falling at Your feet, I appeal to Thee...",
							"...take pity on me, and over all the clowns of the world!...",
							"...pick me up lying carelessly and save me...")
	invoke_msg = "..and send me strength!!!"
	//favor_cost = 150
	spawning_fake_item = list()
	fake_path = /obj/item/fake/banana

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_FOOD = 1,
	)

/datum/religion_rites/spawn_item/banana/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(spawning_fake_item)
		for(var/i in spawning_fake_item)
			QDEL_NULL(i)
	
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	var/obj/item/banana
	if(prob(20))
		banana = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk(AOG.loc)
	else
		banana = new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(AOG.loc)
	
	banana.name = "blessed [banana.name]"

	return TRUE

/obj/item/fake/banana
	name = "Banana"
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"

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
	//favor_cost = 150
	spawning_fake_item = list()
	replacement_item = list()
	fake_path = /obj/item/fake/banana_ore

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/spawn_item/banana_ore/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(spawning_fake_item)
		for(var/i in spawning_fake_item)
			QDEL_NULL(i)
	
	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(!M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	if(replacement_item)
		for(var/i in 0 to replacement_item.len)
			new /obj/item/weapon/ore/clown(AOG.loc)

		for(var/i in replacement_item)
			QDEL_NULL(i)

	return TRUE

/obj/item/fake/banana_ore
	name = "bananium ore"
	icon = 'icons/obj/mining.dmi'
	icon_state = "Clown ore"
