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
							  "...This message is dedicated to all of you....",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns....",)
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
	ritual_length = (5 SECONDS) //(1 MINUTES)
	ritual_invocations = list("Have mercy on us, O Lord, have mercy on us...", //TODO
							  "...for at a loss for any defense, this prayer do we sinners offer Thee as Master...",
							  "...have mercy on us...",
							  "...Lord have mercy on us, for we have hoped in Thee, be not angry with us greatly, neither remember our iniquities...",
							  "...but look upon us now as Thou art compassionate, and deliver us from our enemies...",
							  "...for Thou art our God, and we, Thy people; all are the works of Thy hands, and we call upon Thy name...",
							  "...Both now and ever, and unto the ages of ages...",
							  "...The door of compassion open unto us 0 blessed Theotokos, for hoping in thee...",
							  "...let us not perish; through thee may we be delivered from adversities, for thou art the salvation of the Our race...")
	invoke_msg = "Lord have mercy. Twelve times."
	favor_cost = 100

	needed_aspects = list(
		ASPECT_WEAPON = 1,
		ASPECT_SPAWN = 1,
	)

/datum/religion_rites/animation/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/i = 0
	for(var/obj/item/O in AOG.loc)
		i += 1
		if(i > 0)
			break

	if(i == 0)
		to_chat(user, "<span class='warning'>Put any item to altar.</span>")
		return FALSE

	return ..()

/datum/religion_rites/animation/can_invocate(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		var/i = 0
		for(var/obj/item/O in AOG.loc)
			i += 1
			if(i > 0)
				break

		if(i == 0)
			to_chat(user, "<span class='warning'>Put any item to altar.</span>")
			return FALSE

	return TRUE

/datum/religion_rites/animation/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/obj/item/anim_item
	for(var/obj/item/O in AOG.loc)
		anim_item = O

	if(anim_item)
		var/mob/living/simple_animal/hostile/mimic/copy/religion/M = new (anim_item.loc, anim_item)
		M.harm_intent_damage = 0
		M.melee_damage_lower = 0
		M.melee_damage_upper = 0

		usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")

	return TRUE

/*
 * Spook
 * The ritual doing spook
 */
/datum/religion_rites/spook
	name = "Spook"
	desc = "Spread horror sound." //TODO
	ritual_length = (2 MINUTES)
	ritual_invocations = list("All able to hear, hear!...", //TODO
							  "...This message is dedicated to all of you....",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns....",)
	invoke_msg = "...So hear it!!!"
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
 * The ritual used /illuminate()
 */
/datum/religion_rites/illuminate
	name = "Illuminate"
	desc = "Create wisp of light." //TODO
	ritual_length = (2 SECONDS) //(1 MINUTES)
	ritual_invocations = list("All able to hear, hear!...", //TODO
							  "...This message is dedicated to all of you....",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns....",)
	invoke_msg = "...So hear it!!!"
	favor_cost = 200

	var/shield_icon = "at_shield2"

	needed_aspects = list(
		ASPECT_LIGHT = 1,
	)

/datum/religion_rites/illuminate/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/image/I = image('icons/effects/effects.dmi', icon_state = shield_icon, layer = MOB_LAYER + 0.01)
	for(var/mob/living/carbon/M in range(3, get_turf(AOG)))
		for(var/obj/item/device/flashlight/F in M.contents)
			if(F.brightness_on)
				if(!F.on)
					F.on = !F.on
					F.icon_state = "[initial(F.icon_state)]-on"
					F.set_light(F.brightness_on)

	I.alpha = 150
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/matrix/M = matrix(I.transform)
	M.Scale(0.3)
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
	ritual_length = (2 SECONDS) //(1 MINUTES)
	ritual_invocations = list("All able to hear, hear!...", //TODO
							  "...This message is dedicated to all of you....",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns....",)
	invoke_msg = "...So hear it!!!"
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
	ritual_length = (2 SECONDS) //(1 MINUTES)
	ritual_invocations = list("All able to hear, hear!...", //TODO
							  "...This message is dedicated to all of you....",
							  "...may all of you be healthy and smart...",
							  "...let your jokes be funny...",
							  "...and the soul be pure!...",
							  "...This screech will be devoted to all jokes and clowns....",)
	invoke_msg = "...So hear it!!!"
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