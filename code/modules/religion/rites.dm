/*
 * Religion rite
 * Is a ritual performed by Chaplain at an altar.
 */
/datum/religion_rites
	/// name of the religious rite
	var/name = "religious rite"
	/// Description of the religious rite
	var/desc = "immm gonna rooon"
	/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
	/// Strings that are by default said evenly throughout the rite
	var/list/ritual_invocations
	/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0

	var/list/needed_aspects

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(user.is_busy(AOG))
		return FALSE
	if(global.chaplain_religion && global.chaplain_religion.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin performing the rite of [name]...</span>")

	if(!ritual_invocations)
		if(!user.is_busy(AOG) && do_after(user, target = AOG, delay = ritual_length))
			return TRUE
		return FALSE

	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(user.is_busy(AOG) || !do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i)
		if(!on_invocation(user, AOG))
			return FALSE

	// Because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
	if(user.is_busy(AOG) || !do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE

/// Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	return TRUE

// Does a thing on each invocation, return FALSE to cancel ritual performance.
// Will not work if ritual_invocations is null.
/datum/religion_rites/proc/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG)
	return TRUE

/*
 * Synthconversion
 * Replace your friendly robotechnicians with this little rite!
 */
/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 700

	needed_aspects = list(
		ASPECT_TECH = 1,
	)

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	if(ishuman(AOG.buckled_mob))
		if(jobban_isbanned(AOG.buckled_mob, "Cyborg") || !role_available_in_minutes(AOG.buckled_mob, ROLE_PAI))
			to_chat(usr, "<span class='warning'>[AOG.buckled_mob]'s body is too weak!</span>")
			return FALSE
		if(alert(AOG.buckled_mob, "Are you ready to sacrifice your body to turn into a cyborg?", "Rite", "Yes", "No") == "No")
			to_chat(user, "<span class='warning'>[AOG.buckled_mob] does not want to give their life!.</span>")
			return FALSE
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		return FALSE

	var/mob/living/carbon/human/human2borg = AOG.buckled_mob
	if(!istype(human2borg))
		return FALSE

	hgibs(AOG.loc, human2borg.viruses, human2borg.dna, human2borg.species.flesh_color, human2borg.species.blood_datum)
	human2borg.Robotize(global.chaplain_religion.bible_info.borg_type)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return TRUE

/*
 * Sacrifice
 * Sacrifice a willing being to get a lot of points. Non-sentient beings who can not consent give points, but a lesser amount.
 */
/datum/religion_rites/sacrifice
	name = "Sacrifice"
	desc = "Convert living energy in favor."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Hallowed be thy name...",
							  "...Thy kingdom come...",
							  "...Thy will be done in earth as it is in heaven...",
							  "...Give us this day our daily bread...",
							  "...and forgive us our trespasses...",
							  "...as we forgive them who trespass against us...",
							  "...and lead us not into temptation...")
	invoke_msg = "...but deliver us from the evil one!!"
	favor_cost = 0

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/sacrifice/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE
	if(ishuman(AOG.buckled_mob))
		if(alert(AOG.buckled_mob, "Are you ready to sacrifice your body to give strength to ["[pick(global.chaplain_religion.deity_names)]"]?", "Rite", "Yes", "No") == "No")
			to_chat(user, "<span class='warning'>[AOG.buckled_mob] does not want to give their life!.</span>")
			return FALSE
	return ..()

/datum/religion_rites/sacrifice/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		return FALSE

	var/mob/living/L = AOG.buckled_mob
	if(!istype(L))
		return FALSE

	var/sacrifice_favor = 0
	if(isanimal(L))
		sacrifice_favor += 100
	else if(ismonkey(L))
		sacrifice_favor += 150
	else if(ishuman(L) && L.mind && L.ckey)
		sacrifice_favor += 350
	else
		sacrifice_favor += 200

	if(L.stat == DEAD)
		sacrifice_favor *= 0.5
	if(!L.ckey)
		sacrifice_favor  *= 0.5

	L.gib()
	usr.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

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
		spawn_food(AOG.loc)
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
