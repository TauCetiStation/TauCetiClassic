#define DEADLY_HARAM "maximum_haram_detected"

/datum/religion/pluvia
	name = "Путь Плувиийца"
	deity_names_by_name = list(
		"Путь Плувиийца" = list("Лунарис")
	)
	bible_info_by_name = list(
		"Путь Плувиийца" = /datum/bible_info/chaplain/bible,
	)

	emblem_info_by_name = list(
		"Путь Плувиийца" = "christianity",
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
	var/haram_suicide = DEADLY_HARAM

/datum/religion/pluvia/setup_religions()
	global.pluvia_religion = src
	all_religions += src

/datum/religion/pluvia/add_member(mob/living/carbon/human/H)
	if(!ispluvian(H))
		return
	if(istype(H.my_religion, /datum/religion/pluvia))
		return
	H.AddSpell(new /obj/effect/proc_holder/spell/create_bless_vote)
	H.AddSpell(new /obj/effect/proc_holder/spell/no_target/ancestor_call)
	RegisterSignal(H, COMSIG_HUMAN_HARMED_OTHER, PROC_REF(harm_haram))
	RegisterSignal(H, COMSIG_HUMAN_ON_SUICIDE, PROC_REF(suicide_haram))
	RegisterSignal(H, COMSIG_HUMAN_ON_ADJUST_DRUGINESS, PROC_REF(drunk_haram))
	RegisterSignal(H, COMSIG_HUMAN_ON_CONSUME, PROC_REF(food_haram))
	RegisterSignal(H, COMSIG_HUMAN_ON_CARPET, PROC_REF(carpet_haram))
	. = ..()

/datum/religion/pluvia/remove_member(mob/M)
	. = ..()
	for(var/obj/effect/proc_holder/spell/create_bless_vote/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	for(var/obj/effect/proc_holder/spell/no_target/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	UnregisterSignal(M, list(COMSIG_HUMAN_HARMED_OTHER, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_SUICIDE, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_ADJUST_DRUGINESS, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_CONSUME, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_CARPET, COMSIG_PARENT_QDELETING))

/datum/religion/pluvia/proc/adjust_haram(mob/living/carbon/human/target, haram_amount, reason)
	if(target.mind.blessed)
		return
	if(haram_amount == DEADLY_HARAM || ((target.mind.haram_point + haram_amount) >= haram_threshold))
		global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
		target.mind.social_credit = 0
		to_chat(target, "<span class='warning'>\ <font size=5>[reason] Врата рая закрыты для вас. Ищите себе другого покровителя</span></font>")
		log_admin("Pluvian [key_name(target)] lose /datum/religion/pluvia [ADMIN_JMP(target)]")
		message_admins("Pluvian [key_name(target)] lose /datum/religion/pluvia [ADMIN_JMP(target)]" )
		target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return TRUE
	else
		target.mind.haram_point += haram_amount
		target.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(target, "<span class='warning'>\ <font size=3>[reason]</span></font>")
		message_admins("Pluvian [key_name(target)] haram - [reason] [ADMIN_JMP(target)]")
		log_admin("Pluvian [key_name(target)] haram - [reason] [ADMIN_JMP(target)]")
		return FALSE

/datum/religion/pluvia/proc/harm_haram(datum/source, mob/living/carbon/human/target)
	var/mob/living/carbon/human/attacker  = source
	if(istype(target.my_religion, /datum/religion/pluvia) || target.mind.blessed)
		adjust_haram(attacker, haram_harm, "Вы нарушаете первую заповедь!")

/datum/religion/pluvia/proc/suicide_haram(mob/living/carbon/human/target)
	adjust_haram(target, haram_suicide, "Вы нарушили вторую заповедь.")

/datum/religion/pluvia/proc/drunk_haram(mob/living/carbon/human/target)
	if(!adjust_haram(target, haram_drunk, "Вы нарушаете вторую заповедь!"))
		for(var/datum/reagent/R in target.reagents.reagent_list)
			if(istype(R, /datum/reagent/consumable/ethanol) || istype(R, /datum/reagent/space_drugs) || istype(R,/datum/reagent/ambrosium))
				target.reagents.del_reagent(R.id)
		target.SetDrunkenness(0)
		target.setDrugginess(0)

/datum/religion/pluvia/proc/food_haram(datum/source, obj/item/weapon/reagent_containers/food/snacks/target)
	var/mob/living/carbon/human/H = source
	if(istype(target.loc, /obj/item/weapon/kitchen/utensil))
		return
	adjust_haram(H, haram_food, "Вы нарушаете четвертую заповедь!")

/datum/religion/pluvia/proc/custom_haram(mob/living/carbon/human/target, haram_point, reason)
	adjust_haram(target, haram_point, reason)

/turf/simulated/floor/carpet/Entered(atom/movable/O)
	..()
	if(ishuman(O))
		SEND_SIGNAL(O, COMSIG_HUMAN_ON_CARPET, src)

/datum/religion/pluvia/proc/carpet_haram(mob/living/carbon/human/target)
	if(!target.shoes || target.lying || target.crawling || target.buckled)
		return
	if(target.alerts["buckled"])
		return
	adjust_haram(target, haram_carpet, "Вы нарушаете пятую заповедь!")

#undef DEADLY_HARAM
