/*
 * Gradual creation of a things.
 */
/datum/religion_rites/spawn_item
	name = "Spawn item"
	//Type for the item to be spawned
	var/spawn_type
	//Type for the item to be sacrificed. If you specify the type here, then the component itself will change spawn_type to sacrifice_type.
	var/sacrifice_type
	//Additional favor per sacrificing-item
	var/adding_favor = 75

/datum/religion_rites/spawn_item/New()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, CALLBACK(src, .proc/modify_item))

// Used to apply some effect to an item after its spawn.
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

/datum/religion_rites/spawn_item/banana/modify_item(atom/item)
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
	. = ..()
	if(!.)
		return FALSE

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(AOG.loc))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0 && !(CLUMSY in M.mutations))
			M.flash_eyes()

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/spawn_item/banana_ore/modify_item(atom/item)
	if(prob(20))
		new item(item.loc)

/*
 * Create random friendly animal.
 * Any ghost with preference can become animal.
 */
/datum/religion_rites/spawn_item/call_animal
	name = "Call animal"
	desc = "Create random friendly animal."
	ritual_length = (1.3 MINUTES)
	ritual_invocations = list("As these complex nodules of the world are interconnected...",
						"...so even my animal will be connected with this place...",
						"...My will has allowed me to create and call you to life...",
						"...Your existence is limited to fulfilling your goal...",
						"...Let you come here...")
	invoke_msg = "...Let it be so!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 1,
	)

	var/list/summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos, /mob/living/carbon/monkey, /mob/living/carbon/monkey/skrell, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/simple_animal/slime)

/datum/religion_rites/spawn_item/call_animal/New()
	spawn_type = choose_spawn_type()
	AddComponent(/datum/component/rite/spawn_item, spawn_type, 1, sacrifice_type, adding_favor, CALLBACK(src, .proc/modify_item), CALLBACK(src, .proc/choose_spawn_type), "This ritual creates a <i>random friendly animal</i>.")

/datum/religion_rites/spawn_item/call_animal/proc/choose_spawn_type()
	return pick(summon_type)

/datum/religion_rites/spawn_item/call_animal/modify_item(atom/animal)
	for(var/mob/dead/observer/O in observer_list)
		if(O.has_enabled_antagHUD && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_GHOSTLY) && role_available_in_minutes(O, ROLE_GHOSTLY))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find(IGNORE_FAMILIAR) && (ROLE_GHOSTLY in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C, animal)

/datum/religion_rites/spawn_item/call_animal/proc/question(client/C, mob/M)
	if(!C)
		return
	var/response = alert(C, "Do you want to become the Familiar of religion?", "Familiar request", "No", "Yes", "Never for this round")
	if(!C || M.ckey)
		return //handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yes")
		var/mob/candidate = C.mob
		var/god_name
		if(global.chaplain_religion.active_deities.len == 0)
			god_name = pick(global.chaplain_religion.deity_names)
		else
			var/mob/god = pick(global.chaplain_religion.active_deities)
			god_name = god.name
		M.mind = candidate.mind
		M.ckey = candidate.ckey
		M.name = "familiar of [god_name] [num2roman(rand(1, 20))]"
		M.real_name = M.name
		candidate.cancel_camera()
		candidate.reset_view()
	else if (response == "Never for this round")
		C.prefs.ignore_question += IGNORE_FAMILIAR

/datum/religion_rites/spawn_item/call_animal/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	return TRUE

/*
 * Create religious sword
 * Just create claymore with reduced damage.
 */
/datum/religion_rites/spawn_item/create_sword
	name = "Create sword"
	desc = "Creates a religious sword in the name of God."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("The Holy Spirit, who solves all problems, sheds light on all roads so that I can reach my goal...",
						"...You are giving me the Divine gift of forgiveness and the forgiveness of all evil done against me...",
						"...who abides with all the storms of life...",
						"...In this prayer, I want to thank you for everything...",
						"...looking for time to prove that I will never part with you...",
						"...despite any illusory matter...",
						"...I want to abide with you in your eternal glory...",
						"...I thank you for all your blessings to me and my neighbors...",)
	invoke_msg = "...Let it be so!"
	favor_cost = 100

	spawn_type = /obj/item/weapon/claymore/religion

	needed_aspects = list(
		ASPECT_WEAPON = 1
	)

/datum/religion_rites/spawn_item/create_sword/modify_item(atom/sword)
	var/god_name
	if(global.chaplain_religion.active_deities.len == 0)
		god_name = pick(global.chaplain_religion.deity_names)
	else
		var/mob/god = pick(global.chaplain_religion.active_deities)
		god_name = god.name
	sword.name = "[sword.name] of [god_name]"

/datum/religion_rites/spawn_item/create_sword/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	return TRUE
