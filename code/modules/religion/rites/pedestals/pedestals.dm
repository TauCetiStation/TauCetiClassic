
/datum/religion_rites/pedestals/narsie
	name = "Summon Nar-Sie"
	desc = "Summons the ancient god, don't be afraid to sacrifice your friend's body parts."
	ritual_length = (1 MINUTE)
	invoke_msg = "Venit ad nos!"
	favor_cost = 2000

	rules = list(
		/obj/item/organ/external/r_arm = 3,
		/obj/item/organ/external/l_arm = 3,
		/obj/item/organ/external/head = 3,
		/obj/item/weapon/storage/bible/tome = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
	)

/datum/religion_rites/pedestals/narsie/can_start(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE

	if(istype(get_area(AOG), religion.area_type))
		to_chat(user, "<span class='warning'>Вы можете проводить ритуал только на станции.</span>")
		return FALSE

	if(religion.members < 3)
		to_chat(user, "<span class='warning'>Слишком мало последователей.</span>")
		return FALSE

	if(SSticker.mode.nar_sie_has_risen)
		to_chat(user, "<font size='4'><span class='danger'>Я УЖЕ ЗДЕСЬ!</span></font>")
		return FALSE

	return TRUE

/datum/religion_rites/pedestals/narsie/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	..()
	var/datum/religion/cult/C = religion
	var/datum/game_mode/cult/cur_mode = C.mode
	cur_mode.nar_sie_has_risen = TRUE
	cur_mode.eldergod = TRUE

	new /obj/singularity/narsie/large(get_turf(AOG))
	return TRUE
