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

	var/social_credit_threshold = 3

/datum/religion/pluvia/setup_religions()
	global.pluvia_religion = src
	all_religions += src

	social_credit_threshold = (SSticker.totalPlayersReady/10) + 3

/datum/religion/pluvia/add_member(mob/living/carbon/human/H)
	if(!ispluvian(H))
		return
	if(istype(H.my_religion, /datum/religion/pluvia))
		return
	H.AddSpell(new /obj/effect/proc_holder/spell/create_bless_vote)
	H.AddSpell(new /obj/effect/proc_holder/spell/no_target/ancestor_call)
	register_haram_signals(H)
	. = ..()

/datum/religion/pluvia/remove_member(mob/M)
	. = ..()
	for(var/obj/effect/proc_holder/spell/create_bless_vote/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	for(var/obj/effect/proc_holder/spell/no_target/spell_to_remove in M.spell_list)
		M.RemoveSpell(spell_to_remove)
	unregister_haram_signals(M)
	. = ..()

/datum/religion/pluvia/proc/register_haram_signals(mob/M)
	RegisterSignal(M, COMSIG_HUMAN_HARMED_OTHER, PROC_REF(harm_haram))
	RegisterSignal(M, COMSIG_HUMAN_ON_SUICIDE, PROC_REF(suicide_haram))
	RegisterSignal(M, COMSIG_HUMAN_ON_ADJUST_DRUGINESS, PROC_REF(drunk_haram))
	RegisterSignal(M, COMSIG_HUMAN_ON_CONSUME, PROC_REF(food_haram))
	RegisterSignal(M, COMSIG_HUMAN_ON_CARPET, PROC_REF(carpet_haram))

/datum/religion/pluvia/proc/unregister_haram_signals(mob/M)
	UnregisterSignal(M, list(COMSIG_HUMAN_HARMED_OTHER, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_SUICIDE, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_ADJUST_DRUGINESS, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_CONSUME, COMSIG_PARENT_QDELETING))
	UnregisterSignal(M, list(COMSIG_HUMAN_ON_CARPET, COMSIG_PARENT_QDELETING))

// todo: change to element like cult things
/datum/religion/pluvia/proc/bless(mob/living/carbon/human/M)
	if(!ispluvian(M))
		return

	if(!M.mind || M.mind.pluvian_blessed)
		return

	unregister_haram_signals(M)

	to_chat(M, "<span class='notice'>\ <font size=4>Вам известно, что после смерти вы попадете в рай</span></font>")
	M.mind.pluvian_blessed = 1
	M.mind.pluvian_social_credit = 2
	ADD_TRAIT(M, TRAIT_SEE_GHOSTS, RELIGION_TRAIT)
	ADD_TRAIT(M, TRAIT_GLOWING_EYES, RELIGION_TRAIT)
	ADD_TRAIT(M, TRAIT_PLUVIAN_BLESSED, RELIGION_TRAIT)
	M.update_body(BP_HEAD)

/datum/religion/pluvia/proc/adjust_haram(mob/living/carbon/human/target, haram_amount, reason)
	if(haram_amount == DEADLY_HARAM || ((target.mind.pluvian_haram_points + haram_amount) >= PLUVIAN_HARAM_THRESHOLD))
		global.pluvia_religion.remove_member(target, HOLY_ROLE_PRIEST)
		target.mind.pluvian_social_credit = 0
		to_chat(target, "<span class='warning'>\ <font size=5>[reason] Врата рая закрыты для вас. Ищите себе другого покровителя.</span></font>")
		message_admins("Pluvian [key_name_admin(target)] lose /datum/religion/pluvia" )
		log_admin("Pluvian [key_name(target)] lose /datum/religion/pluvia")
		target.playsound_local(null, 'sound/effects/heaven_fail.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		return TRUE
	else
		target.mind.pluvian_haram_points += haram_amount
		target.playsound_local(null, 'sound/effects/haram.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		to_chat(target, "<span class='warning'>\ <font size=3>[reason]</span></font>")
		message_admins("Pluvian [key_name_admin(target)] haram - [reason]")
		log_admin("Pluvian [key_name(target)] haram - [reason]")
		return FALSE

/datum/religion/pluvia/proc/harm_haram(datum/source, mob/living/carbon/human/target)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/attacker = source
	if(istype(target.my_religion, /datum/religion/pluvia))
		adjust_haram(attacker, haram_harm, "Вы нарушаете первую заповедь!")

/datum/religion/pluvia/proc/suicide_haram(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	adjust_haram(target, haram_suicide, "Вы нарушили вторую заповедь.")

/datum/religion/pluvia/proc/drunk_haram(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(!adjust_haram(target, haram_drunk, "Вы нарушаете вторую заповедь!"))
		for(var/datum/reagent/R in target.reagents.reagent_list)
			if(istype(R, /datum/reagent/consumable/ethanol) || istype(R, /datum/reagent/space_drugs) || istype(R,/datum/reagent/ambrosium))
				target.reagents.del_reagent(R.id)
		target.SetDrunkenness(0)
		target.setDrugginess(0)

/datum/religion/pluvia/proc/food_haram(datum/source, obj/item/weapon/reagent_containers/food/snacks/target)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = source

	if(istype(target.loc, /obj/item/weapon/kitchen/utensil))
		return
	adjust_haram(H, haram_food, "Вы нарушаете четвертую заповедь!")

/datum/religion/pluvia/proc/carpet_haram(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(!target.shoes || target.lying || target.crawling || target.buckled)
		return
	if(target.alerts["buckled"])
		return
	adjust_haram(target, haram_carpet, "Вы нарушаете пятую заповедь!")

#undef DEADLY_HARAM
