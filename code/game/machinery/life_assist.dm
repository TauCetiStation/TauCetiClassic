/obj/machinery/life_assist
	anchored = FALSE
	density = FALSE
	interact_offline = TRUE
	var/mob/living/carbon/human/attached = null

	var/assist_trait

	var/icon_state_attached
	var/icon_state_detached
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/life_assist/atom_init()
	. = ..()
	update_icon()

/obj/machinery/life_assist/Destroy()
	if(attached)
		detach()
	return ..()

/obj/machinery/life_assist/update_icon()
	if(attached)
		icon_state = icon_state_attached
	else
		icon_state = icon_state_detached

/obj/machinery/life_assist/proc/attach(mob/living/carbon/human/H)
	attached = H
	AddComponent(/datum/component/bounded, H, 0, 1, CALLBACK(src, PROC_REF(resolve_stranded)))
	visible_message("<span class='notice'>[usr] подключает трубки [CASE(src, GENITIVE_CASE)] к [H].</span>")
	assist(H)
	update_icon()

/obj/machinery/life_assist/proc/detach(rip = FALSE)
	if(!rip)
		visible_message("<span class='notice'>[attached] отключен от [CASE(src, GENITIVE_CASE)]</span>")
	else
		visible_message("<span class='warning'>Трубки [CASE(src, GENITIVE_CASE)] с силой вырываются из тела [attached], оставляя за собой раны.</span>")
		attached.apply_damage(15, BRUTE, BP_CHEST)

	qdel(GetComponent(/datum/component/bounded))
	deassist(attached)
	attached = null
	update_icon()

// Add the LIFE_ASSIST trait, etc.
/obj/machinery/life_assist/proc/assist(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	if(assist_trait)
		ADD_TRAIT(H, assist_trait, src)

// Remove the LIFE_ASSIST trait, etc.
/obj/machinery/life_assist/proc/deassist(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	if(assist_trait)
		REMOVE_TRAIT(H, assist_trait, src)

/obj/machinery/life_assist/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(!(Adjacent(usr) && Adjacent(over_object) && usr.Adjacent(over_object)))
		return

	if(!do_skill_checks(usr))
		return
	if(do_after(usr, 20, target = src))
		if(!(Adjacent(usr) && Adjacent(over_object) && usr.Adjacent(over_object)))
			return
		if(attached)
			detach()
		else if(ishuman(over_object))
			var/mob/living/carbon/human/H = over_object
			if(HAS_TRAIT(H, assist_trait))
				visible_message("<span class='notice'>[H] уже подключен к [CASE(src, DATIVE_CASE)]</span>")
				return
			attach(H)

/obj/machinery/life_assist/proc/resolve_stranded(datum/component/bounded/bounds)
	if(get_dist(bounds.master, src) == 2 && !anchored)
		step_towards(src, bounds.master)
		var/dist = get_dist(src, get_turf(bounds.master))
		if(dist >= bounds.min_dist && dist <= bounds.max_dist)
			return TRUE

	detach(rip = TRUE)
	return TRUE

/obj/machinery/life_assist/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()

	if(moving_diagonally)
		return .

	if(has_gravity(src))
		playsound(src, 'sound/effects/roll.ogg', VOL_EFFECTS_MASTER)



/obj/machinery/life_assist/artificial_ventilation
	name = "artificial ventilation machine"
	cases = list("аппарат ИВЛ", "аппарата ИВЛ", "аппарату ИВЛ", "аппарат ИВЛ", "аппаратом ИВЛ", "аппарате ИВЛ")
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "av_idle"
	desc = "Аппарат искусственной вентиляции лёгких. Заменяет функции лёгких."

	icon_state_attached = "av_ventilating"
	icon_state_detached = "av_idle"

	assist_trait = TRAIT_EXTERNAL_VENTILATION

	var/obj/item/weapon/tank/holding

/obj/machinery/life_assist/artificial_ventilation/attackby(obj/item/weapon/W, mob/user)
	if (!istype(W, /obj/item/weapon/tank) || istype(W, /obj/item/weapon/tank/jetpack) || (stat & BROKEN) || holding)
		return
	if(do_after(user, 10, target = src))
		if(!user.drop_from_inventory(W, src))
			return
		holding = W
		add_overlay(holding.icon_state)
		visible_message("<span class='notice'>[CASE(holding, NOMINATIVE_CASE)] вставлен в [CASE(src, ACCUSATIVE_CASE)]</span>")
		if(attached)
			update_internal(attached, TRUE)

/obj/machinery/life_assist/artificial_ventilation/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(user.is_busy() || issilicon(user))
		return
	if(holding && do_after(user, 20, target = src))
		user.put_in_hands(holding)
		visible_message("<span class='notice'>[CASE(holding, NOMINATIVE_CASE)] извлечён из [CASE(src, GENITIVE_CASE)]</span>")
		cut_overlay(holding.icon_state)
		holding = null
		if(attached)
			update_internal(attached, FALSE)

/obj/machinery/life_assist/artificial_ventilation/attach(mob/living/carbon/human/H)
	..()
	update_internal(TRUE)

/obj/machinery/life_assist/artificial_ventilation/detach(rip = FALSE)
	update_internal(FALSE)
	..()

/obj/machinery/life_assist/artificial_ventilation/proc/update_internal(connect = TRUE)
	if(!attached)
		return
	if(connect && holding)
		if(attached.internal)
			visible_message("<span class='notice'>[attached] уже подключен к другому баллону</span>")
			return
		attached.internal = holding
	else if(attached.internal == holding)
		attached.internal = null

/obj/machinery/life_assist/cardiopulmonary_bypass
	name = "cardiopulmonary bypass machine"
	cases = list("аппарат ИК", "аппарата ИК", "аппарату ИК", "аппарат ИК", "аппаратом ИК", "аппарате ИК")
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "cpb_idle"
	desc = "Аппарат искусственного кровообращения. Заменяет функции сердца."

	density = TRUE

	icon_state_attached = "cpb_pumping"
	icon_state_detached = "cpb_idle"

	assist_trait = TRAIT_EXTERNAL_HEART

/obj/machinery/life_assist/cardiopulmonary_bypass/assist(mob/living/carbon/human/H)
	..()
	var/obj/item/organ/internal/heart/mob_heart = H.organs_by_name[O_HEART]
	if(mob_heart)
		// +50%, compensates possible heart problems. Modval is capped so there is no danger of overbuffing it
		mob_heart.heart_metabolism_mod.ModAdditive(0.5, src)

/obj/machinery/life_assist/cardiopulmonary_bypass/deassist(mob/living/carbon/human/H)
	..()
	var/obj/item/organ/internal/heart/mob_heart = H.organs_by_name[O_HEART]
	if(mob_heart)
		mob_heart.heart_metabolism_mod.RemoveMods(src)

/obj/machinery/life_assist/external_cooling_device
	name = "External Cooling Device"
	cases = list("аппарат вспомогательного охлаждения", "аппарата вспомогательного охлаждения", "аппарату вспомогательного охлаждения", "аппарат вспомогательного охлаждения", "аппаратом вспомогательного охлаждения", "аппарате вспомогательного охлаждения")
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "cooler_idle"
	desc = "Аппарат для вспомогательного охлаждения подключённой машинерии. Имеет разъёмы для подключения к СПУ."

	density = TRUE

	icon_state_attached = "cooler_pumping"
	icon_state_detached = "cooler_idle"

	assist_trait = TRAIT_EXTERNAL_COOLING

/obj/machinery/life_assist/hemodialysis
	name = "Hemodialysis Machine"
	cases = list("аппарат для гемодиализа", "аппарата для гемодиализа", "аппарату для гемодиализа", "аппарат для гемодализа", "аппаратом для гемодиализа", "аппарате для гемодиализа")
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "hemo_idle"
	desc = "Аппарат для гемодиализа. Заменяет функции почек."

	density = TRUE

	icon_state_attached = "hemo_pumping"
	icon_state_detached = "hemo_idle"

	assist_trait = TRAIT_EXTERNAL_KIDNEY
	var/filtertick = TRUE

	var/obj/item/weapon/reagent_containers/glass/beaker/beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large

/obj/machinery/life_assist/hemodialysis/attackby(obj/item/weapon/W, mob/user)
	if (!istype(W, /obj/item/weapon/reagent_containers/glass/beaker) || (stat & BROKEN) || beaker)
		return
	if(do_after(user, 1 SECOND, target = src))
		if(!user.drop_from_inventory(W, src))
			return
		beaker = W
		visible_message("<span class='notice'>[CASE(beaker, NOMINATIVE_CASE)] вставлен в [CASE(src, ACCUSATIVE_CASE)]</span>")
		update_icon()

/obj/machinery/life_assist/hemodialysis/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(user.is_busy() || issilicon(user))
		return
	if(beaker && do_after(user, 20, target = src))
		user.put_in_hands(beaker)
		visible_message("<span class='notice'>[CASE(beaker, NOMINATIVE_CASE)] извлечён из [CASE(src, GENITIVE_CASE)]</span>")
		beaker = null
		update_icon()

/obj/machinery/life_assist/hemodialysis/process()
	if(!attached || !beaker || (beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return

	filtertick = !filtertick

	if(filtertick && beaker.reagents.has_reagent("blood"))
		attached.inject_blood(beaker, 9)
		update_icon()
		return

	attached.blood_trans_to(beaker, 10)
	playsound(src, 'sound/machines/dialysis.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
	for(var/datum/reagent/x in attached.reagents.reagent_list)
		attached.reagents.trans_to(beaker, 3)

	update_icon()

/obj/machinery/life_assist/hemodialysis/update_icon()
	..()
	cut_overlays()
	if(!beaker)
		return

	add_overlay("di_beaker")
	if(beaker && beaker.reagents && beaker.reagents.total_volume)
		var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

		var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
		switch(percent)
			if(0 to 9)		filling.icon_state = "reagent0"
			if(10 to 24) 	filling.icon_state = "reagent10"
			if(25 to 49)	filling.icon_state = "reagent25"
			if(50 to 74)	filling.icon_state = "reagent50"
			if(75 to 79)	filling.icon_state = "reagent75"
			if(80 to 90)	filling.icon_state = "reagent80"
			if(91 to INFINITY)	filling.icon_state = "reagent100"

		filling.icon += mix_color_from_reagents(beaker.reagents.reagent_list)
		add_overlay(filling)
