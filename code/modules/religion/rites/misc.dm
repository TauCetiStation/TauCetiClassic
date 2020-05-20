/*
 * Food summoning
 * Grants a lot of food while you AFK near the altar. Even more food if you finish the ritual.
 */
/datum/religion_rites/food
	name = "Create food"
	desc = "Create more and more food!"
	ritual_length = (2.2 MINUTES)
	ritual_invocations = list("O Lord, we pray to you: hear our prayer, that they may be delivered by thy mercy, for the glory of thy name...",
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
	desc = "Pray for a while in exchange for favor."
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
 * Honk
 * The ritual creates a honk that everyone hears.
 */
/datum/religion_rites/honk
	name = "Clown shriek"
	desc = "Spread honks throughout the station."
	ritual_length = (2 MINUTES)
	ritual_invocations = list("All able to hear, hear!...",
							  "...This message is dedicated to all of you...",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns...",)
	invoke_msg = "...So hear it!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_WACKY = 1,
	)

/datum/religion_rites/honk/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/items/AirHorn.ogg', VOL_EFFECTS_MASTER, null, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/honk/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	var/ratio = (100 / ritual_invocations.len) * stage
	playsound(AOG, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC, ratio)
	return TRUE

/*
 * Revitalizing items.
 * It makes a thing move and say something. You can't pick up a thing until you kill a item-mob.
 */
/datum/religion_rites/animation
	name = "Animation"
	desc = "Revives a thing on the altar."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("I appeal to you - you are the strength of the Lord...",
							  "...given from the light given by the wisdom of the gods returned...",
							  "...They endowed Animation with human passions and feelings...",
							  "...Animation, come from the New Kingdom, rejoice in the light!...",)
	invoke_msg = "I appeal to you! I am calling! Wake up from sleep!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_WEAPON = 1,
		ASPECT_SPAWN = 1,
	)

/datum/religion_rites/animation/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/obj/item/anim_item
	for(var/obj/item/O in AOG.loc)
		anim_item = O

	if(anim_item)
		var/mob/living/simple_animal/hostile/mimic/copy/religion/M = new (anim_item.loc, anim_item)
		M.pixel_x = anim_item.pixel_x
		M.pixel_y = anim_item.pixel_y

		M.a_intent = INTENT_HELP
		M.harm_intent_damage = 0
		M.melee_damage = 0

		M.faction = "Station"
	else
		INVOKE_ASYNC(src, .proc/soul_of_mouse, AOG)

	user.visible_message("<span class='notice'>[user] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/animation/proc/soul_of_mouse(obj/structure/altar_of_gods/AOG)
	// Dedicated to all dead mouse
	playsound(AOG, 'sound/effects/explosionfar.ogg', VOL_EFFECTS_MASTER)
	var/mob/living/simple_animal/mouse/mouse = new (AOG.loc)
	mouse.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	sleep(1 SECONDS)
	var/image/I = image(icon = mouse.icon, icon_state =  mouse.icon_state, layer = FLY_LAYER)
	I.layer = mouse.layer + 1
	I.invisibility = mouse.invisibility
	I.loc = mouse
	I.alpha = 150
	I.pixel_y = mouse.pixel_y + 4
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/list/viewing = list()
	for(var/mob/M in viewers(mouse))
		if(M.client && (M.client.prefs.toggles & SHOW_ANIMATIONS))
			viewing |= M.client

	flick_overlay(I, viewing, 2 SECONDS)
	animate(I, pixel_z = 16, alpha = 80, time = 1 SECONDS)
	animate(pixel_z = 32, alpha = 0, time = 1 SECONDS)
	sleep(2 SECONDS)
	mouse.health = 0
	mouse.mouse_opacity = initial(mouse.mouse_opacity)

/*
 * Spook
 * The ritual doing spook
 */
/datum/religion_rites/spook
	name = "Spook"
	desc = "Distributes a jerky sound."
	ritual_length = (2 MINUTES)
	ritual_invocations = list("I call the souls of people here, I send your soul to the otherworldly thief, in a black mirror...",
							  "...Let Evil take you and lock you up...",
							  "...torment you, torture you, torture you all, exhaust you, destroy you...",
							  "...I give evil to your soul...",
							  "...I instill Evil in your head, in your heart, in your liver, in your blood...",
							  "...I do not order...",
							  "...As I said, it will be so! I close with a key, close with a lock...")
	invoke_msg = "...I conjure! I conjure! I conjure!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_OBSCURE = 1,
	)

/datum/religion_rites/spook/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	playsound(AOG, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime, /obj/item/weapon/reagent_containers/food/snacks/glowstick)
	for(var/mob/living/carbon/M in hearers(4, get_turf(AOG)))
		if(M.mind.holy_role)
			M.make_jittery(50)
		else
			M.confused += 10
			M.make_jittery(50)
			if(prob(50))
				M.visible_message("<span class='warning bold'>[M]'s face clearly depicts true fear.</span>")
			for(var/obj/item/F in M.contents)
				if(is_type_in_list(F, blacklisted_lights))
					continue
				F.set_light(0)

	for(var/obj/machinery/light/L in range(4, get_turf(AOG)))
		L.on = TRUE
		L.broken()

	return TRUE

/*
 * Illuminate
 * The ritual turns on the flash in range, create overlay of "spirit" and the person begins to glow
 */
/datum/religion_rites/illuminate
	name = "Illuminate"
	desc = "Create wisp of light."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Come to me, wisp...",
							  "...Appear to me the one whom everyone wants...",
							  "...to whom they turn for help!..",
							  "...Good wisp, able to reveal the darkness...",
							  "...I ask you for help...",
							  "...Hear me, do not reject me...",
							  "...for it's not just for the sake of curiosity that I disturb your peace...")
	invoke_msg = "...I pray, please come!"
	favor_cost = 200

	var/shield_icon = "at_shield2"

	needed_aspects = list(
		ASPECT_LIGHT = 1,
	)

/datum/religion_rites/illuminate/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime, /obj/item/weapon/reagent_containers/food/snacks/glowstick)
	for(var/mob/living/carbon/human/H in range(3, get_turf(AOG)))
		for(var/obj/item/device/flashlight/F in H.contents)
			if(is_type_in_list(F, blacklisted_lights))
				continue
			if(F.brightness_on)
				if(!F.on)
					F.on = !F.on
					F.icon_state = "[initial(F.icon_state)]-on"
					F.set_light(F.brightness_on)

	for(var/obj/item/device/flashlight/F in range(3, get_turf(AOG)))
		if(F.brightness_on)
			if(!F.on)
				F.on = !F.on
				F.icon_state = "[initial(F.icon_state)]-on"
				F.set_light(F.brightness_on)

	var/image/I = image('icons/effects/effects.dmi', icon_state = shield_icon, layer = MOB_LAYER + 0.01)
	var/matrix/M = matrix(I.transform)
	M.Scale(0.3)
	I.alpha = 150
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.transform = M
	I.pixel_x = 12	
	I.pixel_y = 12
	user.add_overlay(I)
	user.set_light(7)
	return TRUE

/*
 * Devaluation
 * In the radius from the altar, changes the denomination of banknotes one higher
 */
/datum/religion_rites/devaluation
	name = "Devaluation"
	desc = "Changes the denomination of banknotes one higher."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Lord, hope and support...",
							  "...Thy Everlasting Throne, your backwater...",
							  "...walked through the sky...",
							  "...carried bags of money...",
							  "...bags opened...",
							  "...money fell...",
							  "...I, your slave, walked along the bottom...",
							  "...raised money...",
							  "...carried it home...",
							  "...lit candles...",
							  "...gave it to mine...",
							  "...Candles, burn...",
							  "...money, come to the house...",)
	invoke_msg = "...Till the end of time!"
	favor_cost = 150

	var/static/list/swap = list(
		/obj/item/weapon/spacecash = /obj/item/weapon/spacecash/c1,
		/obj/item/weapon/spacecash/c1 = /obj/item/weapon/spacecash/c10,
		/obj/item/weapon/spacecash/c10 = /obj/item/weapon/spacecash/c20,
		/obj/item/weapon/spacecash/c20 = /obj/item/weapon/spacecash/c50,
		/obj/item/weapon/spacecash/c50 = /obj/item/weapon/spacecash/c100,
		/obj/item/weapon/spacecash/c100 = /obj/item/weapon/spacecash/c200,
		/obj/item/weapon/spacecash/c200 = /obj/item/weapon/spacecash/c500,
		/obj/item/weapon/spacecash/c500 = /obj/item/weapon/spacecash/c1000,
		/obj/item/weapon/spacecash/c1000 = /obj/item/weapon/spacecash,
	)

	needed_aspects = list(
		ASPECT_GREED = 1,
	)

/datum/religion_rites/devaluation/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/obj/item/weapon/spacecash/cash in range(1, AOG.loc))
		if(istype(cash, /obj/item/weapon/spacecash/ewallet))
			continue
		if(swap[cash.type])
			var/swapping = swap[cash.type]
			new swapping(cash.loc)
			if(prob(20))
				step(swapping, pick(alldirs))
			qdel(cash)
	return TRUE

/datum/religion_rites/devaluation/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	for(var/obj/item/weapon/spacecash/cash in range(1, AOG.loc))
		if(prob(20))
			step(cash, pick(alldirs))
			break
	return TRUE

/*
 * Upgrade
 * In the radius from the altar, changes stock_parts withs rating to stock_parts with rating + 1
 */
/datum/religion_rites/upgrade
	name = "Upgrade"
	desc = "Upgrade scientific things."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("The moon was born...",
							  "...the force was born...",
							  "...She endowed these things with her power...",
							  "... As the moon and the earth never part...",
							  "...So this item will be better forever...",)
	invoke_msg = "...I call on all things!"
	favor_cost = 200

	//rating of stock_parts = items with this rating
	var/static/list/swap = list(
		1 = list(
			/obj/item/weapon/stock_parts/capacitor = /obj/item/weapon/stock_parts/capacitor/adv,
			/obj/item/weapon/stock_parts/scanning_module = /obj/item/weapon/stock_parts/scanning_module/adv,
			/obj/item/weapon/stock_parts/manipulator = /obj/item/weapon/stock_parts/manipulator/nano,
			/obj/item/weapon/stock_parts/micro_laser = /obj/item/weapon/stock_parts/micro_laser/high,
			/obj/item/weapon/stock_parts/matter_bin = /obj/item/weapon/stock_parts/matter_bin/adv,
		),
		2 = list (
			/obj/item/weapon/stock_parts/capacitor/adv = /obj/item/weapon/stock_parts/capacitor/super,
			/obj/item/weapon/stock_parts/scanning_module/adv = /obj/item/weapon/stock_parts/scanning_module/phasic,
			/obj/item/weapon/stock_parts/manipulator/nano = /obj/item/weapon/stock_parts/manipulator/pico,
			/obj/item/weapon/stock_parts/micro_laser/high = /obj/item/weapon/stock_parts/micro_laser/ultra,
			/obj/item/weapon/stock_parts/matter_bin/adv = /obj/item/weapon/stock_parts/matter_bin/super,
		),
		3 = list(
			/obj/item/weapon/stock_parts/capacitor/super = /obj/item/weapon/stock_parts/capacitor/quadratic,
			/obj/item/weapon/stock_parts/scanning_module/phasic = /obj/item/weapon/stock_parts/scanning_module/triphasic,
			/obj/item/weapon/stock_parts/manipulator/pico = /obj/item/weapon/stock_parts/manipulator/femto,
			/obj/item/weapon/stock_parts/micro_laser/ultra = /obj/item/weapon/stock_parts/micro_laser/quadultra,
			/obj/item/weapon/stock_parts/matter_bin/super = /obj/item/weapon/stock_parts/matter_bin/bluespace,
		),
		4 = list(
			/obj/item/weapon/stock_parts/capacitor/quadratic = /obj/item/weapon/stock_parts/capacitor,
			/obj/item/weapon/stock_parts/scanning_module/triphasic = /obj/item/weapon/stock_parts/scanning_module,
			/obj/item/weapon/stock_parts/manipulator/femto = /obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/micro_laser/quadultra = /obj/item/weapon/stock_parts/micro_laser,
			/obj/item/weapon/stock_parts/matter_bin/bluespace = /obj/item/weapon/stock_parts/matter_bin,
		),
	)

	needed_aspects = list(
		ASPECT_SCIENCE = 1,
	)

/datum/religion_rites/upgrade/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/obj/item/weapon/stock_parts/S in range(1, AOG.loc))
		if(istype(S, /obj/item/weapon/stock_parts/console_screen))
			continue

		if(swap[S.rating][S.type])
			var/swapping = swap[S.rating][S.type]
			new swapping(S.loc)
			if(prob(20))
				step(swapping, pick(alldirs))
			qdel(S)

	return TRUE

/datum/religion_rites/upgrade/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	for(var/obj/item/weapon/stock_parts/S in range(1, AOG.loc))
		if(prob(20))
			step(S, pick(alldirs))
			break
	return TRUE

/*
 * Revive
 * Revive animal
 */
/datum/religion_rites/revive_animal
	name = "Revive"
	desc = "The animal revives from the better world."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("I will say, whisper, quietly say such words...",
							  "...May every disease leave you...",
							  "...You will not know that you are in torment, pain and suffering...",
							  "...No one can hurt...",
							  "...You must poison the whole, chase the tails from the body a animal...",
							  "... let them go to the raw ground, the water goes and does not come back...",
							  "...God helps, and in my words the work is strengthened...",)
	invoke_msg = "...Let it be so!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 1,
	)

/datum/religion_rites/revive_animal/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE

	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	if(!isanimal(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE

	return ..()

/datum/religion_rites/revive_animal/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	if(!isanimal(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE

	var/mob/living/simple_animal/animal = AOG.buckled_mob
	if(!istype(animal))
		return FALSE

	animal.rejuvenate()
	animal.icon_state = animal.icon_living

	return TRUE

/*
 * Create random friendly animal
 * AoE relocor items
 */
/datum/religion_rites/call_animal
	name = "Call animal"
	desc = "Create random friendly animal."
	ritual_length = (1.5 MINUTES)
	ritual_invocations = list("As these complex nodules of the world are interconnected...",
						"...so even my animal will be connected with this place...",
						"...My will has allowed me to create and call you to life...",
						"...Your existence is limited to fulfilling your goal...",
						"...Let you come here...")
	invoke_msg = "...Let it be so!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 1,
		ASPECT_DEATH = 1,
	)

	var/list/summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos, /mob/living/carbon/monkey, /mob/living/carbon/monkey/skrell, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/simple_animal/slime)

/datum/religion_rites/call_animal/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	var/type = pick(summon_type)
	var/mob/M = new type(AOG.loc)

	for(var/mob/dead/observer/O in observer_list)
		if(O.has_enabled_antagHUD == TRUE && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_RFAMILIAR) && role_available_in_minutes(O, ROLE_RFAMILIAR))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find("chfamiliar") && (ROLE_RFAMILIAR in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C, M)
	return TRUE

/datum/religion_rites/call_animal/proc/question(client/C, mob/M)
	if(!C)
		return
	var/response = alert(C, "Do you want to become the Familiar of religion?", "Familiar request", "No", "Yes", "Never for this round")
	if(!C || M.ckey)
		return //handle logouts that happen whilst the alert is waiting for a response, and responses issued after a brain has been located.
	if(response == "Yes")
		var/mob/candidate = C.mob
		var/mob/god
		if(global.chaplain_religion.active_deities.len == 0)
			god = pick(global.chaplain_religion.deity_names)
		else
			god = pick(global.chaplain_religion.active_deities)
		M.mind = candidate.mind
		M.ckey = candidate.ckey
		M.name = "familiar of [god.name] [pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")]"
		M.real_name = name
		candidate.cancel_camera()
		candidate.reset_view()
	else if (response == "Never for this round")
		C.prefs.ignore_question += "chfamiliar"

/*
 * Create religious sword
 * Just create claymore with reduced damage.
 */
/datum/religion_rites/create_sword
	name = "Create sword"
	desc = "Creates a religious sword in the name of God."
	ritual_length = (1 MINUTES)
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

	needed_aspects = list(
		ASPECT_WEAPON = 1
	)

/datum/religion_rites/create_sword/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	var/obj/item/weapon/claymore/religion/R = new (AOG.loc)
	var/mob/god
	if(global.chaplain_religion.active_deities.len == 0)
		god = pick(global.chaplain_religion.deity_names)
	else
		god = pick(global.chaplain_religion.active_deities)
	R.down_overlay = image('icons/effects/effects.dmi', icon_state = "at_shield2", layer = OBJ_LAYER - 0.01)
	R.down_overlay.alpha = 100
	R.add_overlay(R.down_overlay)

	R.name = "[R.name] of [god.name]"

	return TRUE
