/obj/effect/proc_holder/spell/no_target/draw_rune
	name = "Draw Rune"

	charge_max = 3 SECOND

	clothes_req = FALSE

	action_icon_state = "carve"
	action_background_icon_state = "bg_fanatics"

/obj/effect/proc_holder/spell/no_target/draw_rune/cast(list/targets, mob/user = usr)
	for(var/atom/A in range(1, user.loc))
		if(istype(A, /obj/effect/altrune) || istype(A,/obj/effect/largerune))
			to_chat(user, "<span class='fanatics'>Рядом уже нарисована руна.</span>")
			revert_cast(user)
			return
	var/datum/faction/fanatics/F = find_faction_by_type(/datum/faction/fanatics)
	var/datum/altrune/chosen_power
	var/list/names = list()
	for(var/datum/altrune/AR as anything in F.known_runes)
		names += AR.name
	var/chosen_rune_effect = tgui_input_list(user,"Вы собираетесь нарисовать...","Кровавые Чары", names)
	if(!chosen_rune_effect)
		revert_cast(user)
		return
	for(var/datum/altrune/selection as anything in F.known_runes)
		if(selection.name == chosen_rune_effect)
			chosen_power = selection

	carve(user, chosen_power)

/obj/effect/proc_holder/spell/no_target/draw_rune/proc/carve(mob/living/carbon/human/user, datum/altrune/power)
	var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
	var/obj/item/W = user.get_active_hand()
	for(var/atom/A in user.loc)
		if(istype(A, /obj/effect/altrune) || istype(A,/obj/effect/largerune))
			to_chat(user, "<span class='fanatics'>Рядом уже нарисована руна.</span>")
			revert_cast(user)
			return
	if(BP.is_robotic())
		to_chat(user, "<span class='fanatics'>Нужна органическая рука.</span>")
		revert_cast(user)
		return
	if(isnull(W) || !W.is_sharp())
		to_chat(user, "<span class='fanatics'>Нужно держать в руке что-то острое.</span>")
		revert_cast(user)
		return
	if(user.is_busy() || !do_after(user, 3 SECONDS, target = user))
		return
	user.visible_message("<span class='userdanger'>[user] cuts his palm with a [bicon(W)] [W.name].</span>", \
		"<span class='fanatics'>Вы надрезаете свою ладонь, готовясь рисовать.</span>")
	playsound(user, 'sound/effects/throat_cutting.ogg', VOL_EFFECTS_MASTER)
	BP.take_damage(5)

	var/turf/T = user.loc
	if(istype(T))
		T.add_blood_floor(user)
	user.bloody_hands(user)
	W.add_blood(user)

	user.visible_message("<span class='userdanger'>[user] began drawing strange symbols on the floor.</span>", \
		"<span class='fanatics'>Вы чертите руну на полу.</span>")

	if(!do_after(user, 3 SECONDS, target = user))
		return

	for(var/atom/A in range(1, user.loc))
		if(istype(A, /obj/effect/altrune) || istype(A,/obj/effect/largerune))
			to_chat(user, "<span class='fanatics'>Здесь уже кто-то нарисовал руну.</span>")
			revert_cast(user)
			return

	var/obj/effect/altrune/rune = new(user.loc)
	rune.power = new power
	rune.power.holder = rune
	rune.blood_DNA = list()
	rune.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type

/obj/effect/proc_holder/spell/no_target/draw_final_rune
	name = "Draw Large Rune"

	charge_max = 3 SECOND

	clothes_req = FALSE

	action_icon_state = "final_rune"
	action_background_icon_state = "bg_fanatics"

/obj/effect/proc_holder/spell/no_target/draw_final_rune/cast(list/targets, mob/user = usr)
	if(!istype(get_area(user.loc), /area/station/bridge))
		to_chat(user, "<span class='fanatics'>Ритуал должен быть проведён на мостике.</span>")
		revert_cast(user)
		return
	for(var/atom/A in range(1, user.loc))
		if(istype(A, /obj/effect/altrune) || istype(A,/obj/effect/largerune))
			to_chat(user, "<span class='fanatics'>Здесь уже кто-то нарисовал руну.</span>")
			revert_cast(user)
			return
		if(A.density && !istype(A, /mob/living/carbon/human))
			to_chat(user, "<span class='fanatics'>Преграда мешает рисовать.</span>")
			revert_cast(user)
			return

	carve(user)

/obj/effect/proc_holder/spell/no_target/draw_final_rune/proc/carve(mob/living/carbon/human/user)
	var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
	var/obj/item/W = user.get_active_hand()
	if(BP.is_robotic())
		to_chat(user, "<span class='fanatics'>Нужна органическая рука.</span>")
		revert_cast(user)
		return
	if(isnull(W) || !W.is_sharp())
		to_chat(user, "<span class='fanatics'>Нужно держать в руке что-то острое.</span>")
		revert_cast(user)
		return
	if(user.is_busy() || !do_after(user, 3 SECONDS, target = user))
		return
	user.visible_message("<span class='userdanger'>[user] cuts his palm with a [bicon(W)] [W.name].</span>", \
		"<span class='fanatics'>Вы надрезаете свою ладонь, готовясь рисовать.</span>")
	playsound(user, 'sound/effects/throat_cutting.ogg', VOL_EFFECTS_MASTER)
	BP.take_damage(5)

	var/turf/T = user.loc
	if(istype(T))
		T.add_blood_floor(user)
	user.bloody_hands(user)
	W.add_blood(user)

	user.visible_message("<span class='userdanger'>[user] began drawing strange symbols on the floor.</span>", \
		"<span class='fanatics'>Вы чертите руну на полу.</span>")

	if(!do_after(user, 3 SECONDS, target = user))
		return

	for(var/atom/A in range(1, user.loc))
		if(istype(A, /obj/effect/altrune) || istype(A,/obj/effect/largerune))
			to_chat(user, "<span class='fanatics'>Здесь уже кто-то нарисовал руну.</span>")
			revert_cast(user)
			return
		if(A.density && !istype(A, /mob/living/carbon/human))
			to_chat(user, "<span class='fanatics'>Преграда мешает рисовать</span>")
			return

	var/obj/effect/largerune/rune = new(user.loc)
	rune.power = new /datum/altrune/final_ritual
	rune.power.holder = rune
	rune.blood_DNA = list()
	rune.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type


/obj/effect/proc_holder/spell/no_target/fanatics_cry
	name = "Cry"
	clothes_req = FALSE
	charge_max = 30 SECONDS
	invocation_type = "shout"
	action_icon_state = "fanaticscry"
	action_background_icon_state = "bg_fanatics"

/obj/effect/proc_holder/spell/no_target/fanatics_cry/before_cast(list/targets, mob/user = usr)
	..()
	ADD_TRAIT(user, TRAIT_DISTORTED_INVOCATION, GENERIC_TRAIT)
	user.chat_color = "#ff0000"
	var/newinvocation = ""
	for(var/i in 1 to 3)
		newinvocation += pick(list("фгхтаа", "гн", "кса", "виа", "чие", "лье", "с'ше", "руаль", "молэ", "аве", "йато", "мара ", "рий", "маграа", "гю", "хрэ"))
		if(prob(45))
			newinvocation += pick("`", "'", "-")
	newinvocation += "!!!"
	invocation = newinvocation

/obj/effect/proc_holder/spell/no_target/fanatics_cry/cast(list/targets, mob/living/carbon/human/user = usr)
	for(var/mob/living/carbon/human/fanatic in view(6, user))
		if(!isfanatic(fanatic))
			continue
		fanatic.apply_status_effect(/datum/status_effect/fanatic_inspiration, 25 SECONDS)
		fanatic.adjustHalLoss(-30)
		fanatic.AdjustStunned(-5)
		fanatic.AdjustWeakened(-5)
		if(istype(fanatic.wear_suit, /obj/item/clothing/suit/hooded/fanatics_robes))
			fanatic.adjustBruteLoss(-15)
			fanatic.adjustFireLoss(-15)
			fanatic.adjustHalLoss(-10)
	user.chat_color = initial(user.chat_color)
	REMOVE_TRAIT(user, TRAIT_DISTORTED_INVOCATION, GENERIC_TRAIT)

/obj/item/weapon/champion_cape
	name = "cape"
	icon = 'icons/obj/items.dmi'
	icon_state = "champion_cape"
	canremove = FALSE
	slot_flags = SLOT_FLAGS_BACK
	flags = ABSTRACT | DROPDEL
