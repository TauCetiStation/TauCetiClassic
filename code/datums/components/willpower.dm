/datum/component/willpower
	var/possible_effects = list(/datum/willpower_effect/painkiller, /datum/willpower_effect/skills, /datum/willpower_effect/nutrition, /datum/willpower_effect/fat)
	var/effects = list()
	var/active_effect
	var/willpower_points = 0

/datum/component/willpower/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	for(var/WE in possible_effects)
		var/i = new WE
		effects += i

	RegisterSignal(parent, COMSIG_ADD_WILLPOWER, PROC_REF(add_willpower))

/datum/component/willpower/proc/add_willpower(datum/source, amount, ...)
	SIGNAL_HANDLER
	willpower_points += amount

/datum/component/willpower/proc/do_select_effect()
	var/mob/living/carbon/human/H = parent
	if(H.species.flags[NO_WILLPOWER])
		to_chat(parent, "<span class='warning'>Вы безвольное существо.</span>")
		return
	if(H.stat == DEAD)
		to_chat(parent, "<span class='warning'>Мертвые не своевольничают.</span>")
		return
	if(!willpower_points)
		to_chat(parent, "<span class='warning'>У вас нет воли.</span>")
		return
	var/datum/willpower_effect/selected_effect
	var/list/names = list()
	for(var/datum/willpower_effect/WE in effects)
		names += WE.name

	var/chosen_willpower_effect = tgui_input_list(parent,"Вы собираете волю в кулак...","ВОЛЯ", names)
	for(var/datum/willpower_effect/selection in effects)
		if(selection.name == chosen_willpower_effect)
			selected_effect = selection

	use_effect(selected_effect)

/datum/component/willpower/proc/can_use_effect(datum/willpower_effect/WE)
	if(!ishuman(parent))
		return
	if(willpower_points < WE.cost)
		to_chat(parent, "<span class='warning'>Вам не хватает воли.</span>")
		return FALSE
	return WE.special_check(parent)

/datum/component/willpower/proc/use_effect(datum/willpower_effect/WE)
	if(!can_use_effect(WE))
		return FALSE
	WE.do_effect(parent)
	willpower_points -= WE.cost

/datum/willpower_effect
	var/name = "Эффект воли"
	var/desc = "Крутое описание."
	var/cost = 1
	var/effect_sound = 'sound/effects/willpower.ogg'

/datum/willpower_effect/proc/special_check(mob/living/carbon/human/user)
	return TRUE

/datum/willpower_effect/proc/do_effect(mob/living/carbon/human/user)
	user.playsound_local(null, effect_sound, VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
	to_chat(user, desc)

/datum/willpower_effect/painkiller
	name = "Превозмочь боль"
	desc = "<span class='green bold'>Ваше тело сопротивляется боли.</span>"

/datum/willpower_effect/painkiller/do_effect(mob/living/carbon/human/user)
	..()
	user.reagents.add_reagent("endorphine", 15)

/datum/willpower_effect/skills
	name = "Сосредоточиться на задаче"
	desc = "<span class='nicegreen'>Вы сосредотачиваетесь. В течение минуты профессиональные действия будут даваться вам легче.</span>"

/datum/willpower_effect/skills/do_effect(mob/living/carbon/human/user)
	..()
	var/datum/skillset/willpower/buff = new
	user.add_skills_buff(buff, 1 MINUTE)
	addtimer(CALLBACK(null, PROC_REF(to_chat), src, "<span class='notice'>Вы теряете концентрацию.</span>"), 1 MINUTE)

/datum/willpower_effect/nutrition
	name = "Перетерпеть голод"
	desc = "<span class='nicegreen'>Вы стараетесь не обращать внимания на бурчание в животе.</span>"

/datum/willpower_effect/nutrition/special_check(mob/living/carbon/human/user)
	if(user.nutrition >= NUTRITION_LEVEL_NORMAL)
		to_chat(user, "<span class='notice'>Вы не голодны.</span>")
		return FALSE
	return TRUE

/datum/willpower_effect/nutrition/do_effect(mob/living/carbon/human/user)
	..()
	user.nutrition = NUTRITION_LEVEL_WELL_FED

/datum/willpower_effect/fat
	name = "Сжечь калории"
	desc = "<span class='nicegreen'>Вы напрягаете свой живот, сбрасывая вес по древней скрелльской методике похудания.</span>"

/datum/willpower_effect/fat/special_check(mob/living/carbon/human/user)
	if(user.nutrition >= NUTRITION_LEVEL_NORMAL)
		to_chat(user, "<span class='notice'>Вы не переели.</span>")
		return FALSE
	else if(HAS_TRAIT_FROM(user, TRAIT_FAT, ROUNDSTART_TRAIT))
		to_chat(user, "<span class='notice'>Вы даже помыслить не можете о том, чтобы сбросить вес.</span>")
		return FALSE
	return TRUE

/datum/willpower_effect/fat/do_effect(mob/living/carbon/human/user)
	..()
	user.nutrition = NUTRITION_LEVEL_STARVING+50
	user.overeatduration = 0
