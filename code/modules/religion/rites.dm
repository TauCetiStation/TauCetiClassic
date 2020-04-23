/datum/religion_rites
/// name of the religious rite
	var/name = "religious rite"
/// Description of the religious rite
	var/desc = "immm gonna rooon"
/// length it takes to complete the ritual
	var/ritual_length = (10 SECONDS) //total length it'll take
/// list of invocations said (strings) throughout the rite
	var/list/ritual_invocations //strings that are by default said evenly throughout the rite
/// message when you invoke
	var/invoke_msg
	var/favor_cost = 0

///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(religious_sect && religious_sect.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
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
		if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i)
	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg)
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	religious_sect.on_riteuse(user,AOG)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 0.5 MINUTES //BALANCE
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 500 //BALANCE

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		return FALSE
	var/mob/living/carbon/human/human2borg
	if(istype(AOG.buckled_mob, /mob/living/carbon/human))
		human2borg = AOG.buckled_mob
	if(!human2borg)
		return FALSE
	human2borg.Robotize()
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return TRUE

/*********CUSTOM**********/

/datum/religion_rites/sacrifice
	name = "Sacrifice"
	desc = "Convert living energy in favor."
	ritual_length = 0.5 MINUTES //BALANCE
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... gege!!"
	favor_cost = 0

/datum/religion_rites/sacrifice/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE
	return ..()

/datum/religion_rites/sacrifice/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(AOG && !AOG.buckled_mob)
		return FALSE
	var/mob/living/L
	if(istype(AOG.buckled_mob, /mob/living))
		L = AOG.buckled_mob
	if(!L)
		return FALSE
	religious_sect.favor += 200
	L.gib()
	L.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/food
	name = "Create food"
	desc = "Create more and more food!"
	ritual_length = 0.2 MINUTES //BALANCE
	ritual_invocations = list("By the inner workings of our god...",
						"... We call upon you, in the face of adversity...",
						"... to complete us, removing that which is undesirable...")
	invoke_msg = "... gege!!"
	favor_cost = 300

/datum/religion_rites/food/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	return ..()

/datum/religion_rites/food/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks

	playsound(AOG, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(AOG), null))
		if(M.eyecheck() <= 0)
			M.flash_eyes()

	for(var/i = 1, i <= 4 + rand(1,5), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf_loc(AOG)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))

	user.visible_message("<span class='notice'>[usr] has been finished the rite of [name]!</span>")
	return TRUE
