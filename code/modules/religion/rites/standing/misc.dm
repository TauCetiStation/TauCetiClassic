/*
 * Food summoning
 * Grants a lot of food while you AFK near the altar. Even more food if you finish the ritual.
 */
/datum/religion_rites/standing/food
	name = "Создание Еды"
	desc = "Нужно больше и больше еды!"
	ritual_length = (2.1 MINUTES)
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

/datum/religion_rites/standing/food/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf(AOG)))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(get_turf(AOG), 4 + rand(2, 5) * divine_power)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/food/rite_step(mob/living/user, obj/AOG)
	..()
	if(prob(50))
		spawn_food(get_turf(AOG), 1)

/*
 * Prayer
 * Increases favour while you AFK near altar, heals everybody around if invoked succesfully.
 */
/datum/religion_rites/standing/pray
	name = "Молитва"
	desc = "За добрые слова вы получаете немного favor'а."
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

	var/adding_favor = 0

	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/standing/pray/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/heal_num = -15 * divine_power
	for(var/mob/living/L in range(2, src))
		L.apply_damages(heal_num, heal_num, heal_num, heal_num, heal_num, heal_num)

	adding_favor = min(adding_favor + 2.0, 20.0)

	usr.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/pray/rite_step(mob/living/user, obj/AOG, stage)
	..()
	religion.adjust_favor(15 + adding_favor)
	adding_favor = min(adding_favor + 0.1, 20.0)

/*
 * Honk
 * The ritual creates a honk that everyone hears.
 */
/datum/religion_rites/standing/honk
	name = "Клоунский Крик"
	desc = "Разносит хонк по всей станции."
	ritual_length = (1.9 MINUTES)
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

/datum/religion_rites/standing/honk/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/items/AirHorn.ogg', VOL_EFFECTS_MASTER, null, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/standing/honk/rite_step(mob/living/user, obj/AOG, stage)
	..()
	var/ratio = (100 / ritual_invocations.len) * stage
	playsound(AOG, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC, ratio)

/*
 * Revitalizing items.
 * It makes a thing move and say something. You can't pick up a thing until you kill a item-mob.
 */
/datum/religion_rites/standing/animation
	name = "Анимация"
	desc = "Возрождает вещи на алтаре."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("I appeal to you - you are the strength of the Lord...",
							  "...given from the light given by the wisdom of the gods returned...",
							  "...They endowed Animation with human passions and feelings...",
							  "...Animation, come from the New Kingdom, rejoice in the light!...",)
	invoke_msg = "I appeal to you! I am calling! Wake up from sleep!"
	favor_cost = 80

	needed_aspects = list(
		ASPECT_SPAWN = 1,
		ASPECT_WEAPON = 1,
	)

/datum/religion_rites/standing/animation/on_chosen(mob/living/user, obj/AOG)
	if(!..())
		return FALSE
	var/anim_items = 0
	for(var/obj/item/O in get_turf(AOG))
		anim_items++
	if(!anim_items)
		to_chat(user, "<span class='warning'>Put any the item on the altar!</span>")
		return FALSE
	favor_cost = round((initial(favor_cost) * religion.members.len * anim_items / divine_power), 10)
	religion.update_rites()
	return TRUE

/datum/religion_rites/standing/animation/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/list/anim_items = list()
	for(var/obj/item/O in get_turf(AOG))
		anim_items += O

	favor_cost = round((initial(favor_cost) * religion.members.len * anim_items.len) / divine_power, 10)
	religion.update_rites()

	if(!religion.check_costs(favor_cost, piety_cost, user))
		return FALSE

	if(anim_items.len != 0)
		for(var/obj/item/O in anim_items)
			var/mob/living/simple_animal/hostile/mimic/copy/religion/R = new(O.loc, O)
			religion.add_member(R, HOLY_ROLE_PRIEST)
			R.friends = religion.members

		user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Spook
 * This ritual spooks players: Light lamps pop out, and people start to shake
 */
/datum/religion_rites/standing/spook
	name = "Испуг"
	desc = "Издаёт из алтаря страшный крик."
	ritual_length = (20 SECONDS)
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

/datum/religion_rites/standing/spook/proc/remove_spook_effect(mob/living/carbon/M)
	M.remove_alt_appearance("spookyscary")

/datum/religion_rites/standing/spook/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	playsound(AOG, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	for(var/mob/living/carbon/M in hearers(4, get_turf(AOG)))
		if(M?.mind?.holy_role)
			M.make_jittery(50)
		else
			M.confused += 10 * divine_power
			M.make_jittery(50)
			if(prob(50))
				M.visible_message("<span class='warning bold'>[M]'s face clearly depicts true fear.</span>")

		var/image/I = image(icon = 'icons/mob/human.dmi', icon_state = pick("ghost", "husk_s", "zombie", "skeleton"), layer = INFRONT_MOB_LAYER, loc = M)
		I.override = TRUE
		M.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/everyone, "spookyscary", I)
		addtimer(CALLBACK(src, .proc/remove_spook_effect, M), 10 SECONDS * divine_power)

	var/list/targets = list()
	for(var/turf/T in range(4))
		targets += T
	light_off_range(targets, AOG)

	return TRUE

/*
 * Illuminate
 * The ritual turns on the flash in range, create overlay of "spirit" and the person begins to glow
 */
/datum/religion_rites/standing/illuminate
	name = "Озарение"
	desc = "Создаёт пучок света над вами."
	ritual_length = (50 SECONDS)
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

/datum/religion_rites/standing/illuminate/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/list/blacklisted_lights = list(/obj/item/device/flashlight/flare, /obj/item/device/flashlight/slime, /obj/item/weapon/reagent_containers/food/snacks/glowstick)
	for(var/mob/living/carbon/human/H in range(3, get_turf(AOG)))
		for(var/obj/item/device/flashlight/F in H.contents)
			if(is_type_in_list(F, blacklisted_lights))
				continue
			if(F.light_on)
				if(!F.on)
					F.on = !F.on
					F.icon_state = "[initial(F.icon_state)]-on"
					F.set_light_on(FALSE)

	for(var/obj/item/device/flashlight/F in range(3, get_turf(AOG)))
		if(F.light_on)
			if(!F.on)
				F.on = !F.on
				F.icon_state = "[initial(F.icon_state)]-on"
				F.set_light_on(FALSE)

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
 * Revive
 * Revive animal
 */
/datum/religion_rites/standing/revive_animal
	name = "Возрождение Животного"
	desc = "Возвращает душу животного из лучшего мира."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("I will say, whisper, quietly say such words...",
							  "...May every disease leave you...",
							  "...You will not know that you are in torment, pain and suffering...",
							  "...No one can hurt...",
							  "...You must poison the whole, chase the tails from the body a animal...",
							  "... let them go to the raw ground, the water goes and does not come back...",
							  "...God helps, and in my words the work is strengthened...",)
	invoke_msg = "...Let it be so!"
	favor_cost = 150
	can_talismaned = FALSE

	needed_aspects = list(
		ASPECT_SPAWN = 1,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/standing/revive_animal/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE

	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	if(!isanimal(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE

	var/mob/living/simple_animal/S = AOG.buckled_mob
	if(!S.animalistic)
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE

	if(!S.stat == DEAD)
		to_chat(user, "<span class='warning'>Only a ritual is performed on dead animals.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/standing/revive_animal/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/simple_animal/animal = AOG.buckled_mob
	if(!istype(animal))
		to_chat(user, "<span class='warning'>Only a animal can go through the ritual.</span>")
		return FALSE
	animal.maxHealth *= divine_power
	animal.rejuvenate()

	return TRUE
