/datum/religion/pluvia
	name = "Путь Плувиийца"
	deity_names_by_name = list(
		"Путь Плувиийца" = list("Лунарис")
	)
	bible_info_by_name = list(
		"Путь Плувиийца" = /datum/bible_info/chaplain/bible, //потом переделать на другую
	)

	emblem_info_by_name = list(
		"Путь Плувиийца" = "christianity", //потом переделать на другую
	)

	altar_info_by_name = list(
		"Путь Плувиийца" = "chirstianaltar",
	)
	carpet_type_by_name = list(
		"Путь Плувиийца" = /turf/simulated/floor/carpet,
	)
	style_text = "piety"
	symbol_icon_state = null
	var/haram_harm = 2
	var/haram_drunk = 1
	var/haram_food = 0.5
	var/haram_carpet = 0.25

/datum/religion/pluvia/proc/harm_haram(datum/source, mob/living/carbon/human/target)
	var/mob/living/carbon/human/attacker  = source
	if(istype(target.my_religion, /datum/religion/pluvia))
		if(attacker.haram_point < haram_threshold)
			attacker.haram_point += haram_harm
			attacker.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(attacker, "<span class='warning'>\ <font size=3>Хватит наносить вред Плувийцу!</span></font>")
		else
			global.pluvia_religion.remove_member(attacker, HOLY_ROLE_PRIEST)
			attacker.social_credit = 0
			to_chat(attacker, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
			attacker.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/suicide_haram(mob/living/carbon/human/target)
	global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
	target.social_credit = 0
	to_chat(target, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
	target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/drunk_haram(mob/living/carbon/human/target) //Я осознанно никак не проверяю, сам ли он пил или его напоили. Так можно гарантированно убить плувийца с концами - напоив его
	if(target.haram_point < haram_threshold)
		for(var/datum/reagent/R in target.reagents.reagent_list)
			if(istype(R, /datum/reagent/consumable/ethanol) || istype(R, /datum/reagent/space_drugs) || istype(R,/datum/reagent/ambrosium))
				target.reagents.del_reagent(R.id)
		target.SetDrunkenness(0)
		target.setDrugginess(0)
		target.haram_point += haram_drunk
		target.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(target, "<span class='warning'>\ <font size=3>Хватит травить себя!</span></font>")
	else
		global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
		to_chat(target, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
		target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/food_haram(datum/source, obj/item/weapon/reagent_containers/food/snacks/target)
	var/mob/living/carbon/human/H = source
	if(istype(target.loc, /obj/item/weapon/kitchen/utensil/fork/sticks))
		return
	if(H.haram_point < haram_threshold)
		H.haram_point += haram_food
		H.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(H, "<span class='warning'>\ <font size=3>Ешь как человек, а не как животное</span></font>")
	else
		global.pluvia_religion.remove_member(H, HOLY_ROLE_PRIEST)
		H.social_credit = 0
		to_chat(H, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
		H.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/religion/pluvia/proc/carpet_haram(mob/living/carbon/human/target)
	if(target.shoes)
		if(target.haram_point < haram_threshold)
			target.haram_point += haram_carpet
			target.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			to_chat(target, "<span class='warning'>\ <font size=3>Не ходи в обуви по коврам!</span></font>")
		else
			global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
			target.social_credit = 0
			to_chat(target, "<span class='warning'>\ <font size=5>Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
			target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/turf/simulated/floor/carpet/Entered(atom/movable/O)
	..()
	if(ishuman(O))
		SEND_SIGNAL(O, COMSIG_HUMAN_ON_CARPET, src)

/datum/religion/pluvia/add_member(mob/living/carbon/human/H)
	. = ..()
	if(ispluvian(H))
		H.AddSpell(new /obj/effect/proc_holder/spell/create_bless_vote)
		H.AddSpell(new /obj/effect/proc_holder/spell/no_target/ancestor_call)
	RegisterSignal(H, COMSIG_HUMAN_HARMED_OTHER, PROC_REF(harm_haram))
	RegisterSignal(H, COMSIG_HUMAN_TRY_SUICIDE, PROC_REF(suicide_haram))
	RegisterSignal(H, COMSIG_HUMAN_IS_DRUNK, PROC_REF(drunk_haram))
	RegisterSignal(H, COMSIG_HUMAN_EAT, PROC_REF(food_haram))
	RegisterSignal(H, COMSIG_HUMAN_ON_CARPET, PROC_REF(carpet_haram))

/datum/religion/pluvia/remove_member(mob/M)
	. = ..()
	for(var/obj/effect/proc_holder/spell/create_bless_vote/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	for(var/obj/effect/proc_holder/spell/no_target/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	UnregisterSignal(M, list(COMSIG_HUMAN_HARMED_OTHER, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_TRY_SUICIDE, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_IS_DRUNK, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_EAT, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_CARPET, COMSIG_PARENT_QDELETING))

/datum/religion/pluvia/setup_religions()
	global.pluvia_religion = src
	all_religions += src
