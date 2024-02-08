
/datum/rune/maelstrom

/datum/rune/maelstrom/proc/get_choice_image()
	return get_uristrune_cult(FALSE, words)

/datum/rune/maelstrom/action_wrapper(mob/living/carbon/user)
	if(!can_action(user))
		return

	fizzle(user)
	action(user)
	do_invoke_glow()
	qdel(holder)

/datum/rune/maelstrom/proc/do_invoke_glow()
	set waitfor = FALSE
	animate(holder, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
	sleep(0.5 SECONDS)
	animate(holder, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)

/datum/rune/maelstrom/holder_reaction(mob/living/carbon/user)
	if(istype(holder, /obj/effect/decal/cleanable/crayon/maelstrom))
		return rune_reaction(user)
	return talisman_reaction(user)

/datum/rune/maelstrom/fizzle(mob/living/user)
	user.whisper(pick("Хаккрутжу гопоенжим.", "Нхерасаи пивроиашан.", "Фиржжи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Мийф хон внор'с.", "Вакабаи хиж фен жусвикс."))
	holder.visible_message("<span class='danger'>Иероглиф начинает пульсировать незаметным светом и сразу тухнет.</span>","<span class='danger'>Вы слышите тихое шипение.</span>")

var/global/list/teleporting_runes = list()
ADD_TO_GLOBAL_LIST(/obj/effect/decal/cleanable/crayon/maelstrom, teleporting_runes)
/datum/rune/maelstrom/teleport
	name = "Телепорт"
	var/id
	var/id_inputing = FALSE

/datum/rune/maelstrom/teleport/get_choice_image()
	return image('icons/hud/screen_spells.dmi', icon_state = "teleport")

/datum/rune/maelstrom/teleport/proc/teleporting(turf/target, mob/user)
	playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/maelstrom/blood/out(user.loc)
	playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/maelstrom/blood(target)

	var/list/companions = holder.handle_teleport_grab(target, user, FALSE)
	LAZYINITLIST(companions)
	user.forceMove(target)
	user.eject_from_wall(gib = FALSE, companions = companions)

	for(var/mob/M in companions + user)
		if(M.client)
			new /atom/movable/screen/temp/cult_teleportation(M, M)

	after_tp(get_turf(user), user, companions)

/datum/rune/maelstrom/teleport/proc/input_rune_id(mob/living/carbon/user)
	id = input(user, "Выберите Id руны телепорта", "Редактор Id рун") as null|anything in get_runes_ids() + "New ID"
	if(!id)
		return
	if(id == "New ID")
		id = input(user, "Введите Id руны телепорта", "Редактор Id рун", pick(all_words))

	to_chat(user, "<span class='notice'>Id телепорта - </span><span class='cult'>[id]</span>")

/datum/rune/maelstrom/teleport/can_action(mob/living/carbon/user)
	if(!id && !id_inputing)
		id_inputing = TRUE
		input_rune_id(user)
		id_inputing = FALSE
		return FALSE // Without instant teleport
	var/list/tp_runes = get_tp_runes_by_id()
	if(!tp_runes.len)
		to_chat(user, "<span class='warning'>Рун телепорта с id - </span><span class='cult'>[id]</span> <span class='warning'>не обнаружено</span>")
		return FALSE
	var/list/acolytes = nearest_acolytes()
	if(length(acolytes) < 2)
		to_chat(user, "<span class='cult'>Требуется не менее 2 культиста вокруг руны!</span>")
		return FALSE
	return TRUE

/datum/rune/maelstrom/teleport/proc/get_runes_by_type(rune_type)
	var/list/valid_runes = list()
	for(var/obj/effect/decal/cleanable/crayon/maelstrom/R as anything in global.teleporting_runes)
		if(!istype(R.power, rune_type))
			continue
		if(is_station_level(R.loc.z))
			valid_runes += R
	return valid_runes

/datum/rune/maelstrom/teleport/proc/get_runes_ids()
	var/list/runes = get_runes_by_type(/datum/rune/maelstrom/teleport) - holder
	var/list/uniq_ids = list()
	for(var/obj/effect/decal/cleanable/crayon/maelstrom/R as anything in runes)
		var/datum/rune/maelstrom/teleport/T = R.power
		uniq_ids |= T.id
	return uniq_ids

/datum/rune/maelstrom/teleport/proc/get_tp_runes_by_id()
	var/list/runes = get_runes_by_type(/datum/rune/maelstrom/teleport) - holder
	var/list/valid_runes = list()
	for(var/obj/effect/decal/cleanable/crayon/maelstrom/R as anything in runes)
		var/datum/rune/maelstrom/teleport/T = R.power
		if(T.id == id)
			valid_runes += R
	return valid_runes

/datum/rune/maelstrom/teleport/action(mob/living/carbon/user)
	var/list/tp_runes = get_tp_runes_by_id()
	if(tp_runes.len)
		user.visible_message("<span class='userdanger'>[user] исчезает во вспышке красного света!</span>", \
			"<span class='cult'>Вы чувствуете, как ваше тело проскальзывает сквозь измерения!</span>", \
			"<span class='userdanger'>Вы слышите болезненный хруст и хлюпанье внутренностей.</span>")
		var/turf/T = get_turf(pick(tp_runes))
		teleporting(T, user)

/datum/rune/maelstrom/teleport/ghost_action(mob/living/carbon/user)
	var/list/tp_runes = get_tp_runes_by_id()
	if(tp_runes.len)
		user.forceMove(get_turf(pick(tp_runes)))

/datum/rune/maelstrom/teleport/proc/after_tp(turf/target, mob/living/user, list/companions)
	if(!companions.len)
		return
	for(var/mob/living/M in list(user) + companions)
		if(SEND_SIGNAL(M, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
			continue
		M.Paralyse(2 SECONDS)


/datum/rune/maelstrom/wall
	name = "Призыв Стены"
	var/obj/effect/forcefield/cult/blue/wall

/datum/rune/maelstrom/wall/Destroy()
	QDEL_NULL(wall)
	return ..()

/datum/rune/maelstrom/wall/get_choice_image()
	return image('icons/hud/screen_spells.dmi', icon_state = "wall")

/datum/rune/maelstrom/wall/can_action(mob/living/carbon/user)
	if(!wall)
		var/list/acolytes = nearest_acolytes()
		if(length(acolytes) < 2)
			to_chat(user, "<span class='cult'>Требуется не менее 2 культиста вокруг руны!</span>")
			return FALSE
		action(user)
		return FALSE
	return TRUE

/datum/rune/maelstrom/wall/action(mob/living/carbon/user)
	if(wall)
		to_chat(user, "<span class='userdanger'>Ваша сила перестает течь в руне, и вы чувствуете, как пространство над руной начинает редеть.</span>")
		QDEL_NULL(wall)
	else
		wall = new (get_turf(holder))
		wall.register_holder(holder)
		to_chat(user, "<span class='userdanger'>Ваша сила начинает течь в руне, и вы чувствуете, как пространство над руной начинает сгущаться.</span>")

	user.take_bodypart_damage(2, 0)

/datum/rune/maelstrom/portal_beacon
	name = "Маяк Портала Культа"
	words = list("travel", "hell", "technology")

/datum/rune/maelstrom/portal_beacon/get_choice_image()
	return image('icons/hud/screen_spells.dmi', icon_state = "portal")

/datum/rune/maelstrom/portal_beacon/can_action(mob/living/carbon/user)
	SEND_SIGNAL(holder, COMSIG_ATTACK_HAND_FULTOPORTAL, user)
	return FALSE

/datum/rune/maelstrom/bloodboil
	name = "Кипение Крови"
	words = list("destroy", "blood", "see")

/datum/rune/maelstrom/bloodboil/get_choice_image()
	return image('icons/hud/screen_spells.dmi', icon_state = "blood_boil")

/datum/rune/maelstrom/proc/nearest_acolytes()
	var/list/acolytes = list()
	for(var/mob/living/carbon/C in range(1, holder))
		if(SEND_SIGNAL(C, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
			acolytes += C
	return acolytes

/datum/rune/maelstrom/bloodboil/proc/nearest_heretics()
	var/list/heretics = list()
	for(var/mob/living/heretic in view(5, holder))
		if(SEND_SIGNAL(heretic, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
			continue
		heretics += heretic
	return heretics

/datum/rune/maelstrom/bloodboil/can_action(mob/living/carbon/user)
	var/list/acolytes = nearest_acolytes()
	if(length(acolytes) < 3)
		to_chat(user, "<span class='cult'>Вам необходимо как минимум 3 культиста вокруг руны.</span>")
		return FALSE
	var/list/heretics = nearest_heretics()
	if(length(heretics) < 1)
		to_chat(user, "<span class='cult'>Никого нет рядом.</span>")
		return FALSE
	return TRUE

/datum/rune/maelstrom/bloodboil/action(mob/living/carbon/user)
	var/list/acolytes = nearest_acolytes()
	var/list/heretics = nearest_heretics()
	if(length(heretics) < 1)
		to_chat(user, "<span class='cult'>Никого нет рядом.</span>")
		return
	var/damage_for_acolytes = length(heretics) * 30 / length(acolytes)
	var/damage_modifier = length(acolytes) * 30

	for(var/mob/living/carbon/M in heretics)
		M.take_overall_damage(damage_modifier * 0.1, damage_modifier * 0.9)
		to_chat(M, "<span class='userdanger'>Твоя кровь кипит!</span>")
		if(prob(5) && M)
			M.gib()
	for(var/mob/living/L in acolytes)
		L.take_overall_damage(damage_for_acolytes * 0.1, damage_for_acolytes * 0.9)

/datum/rune/maelstrom/convert
	name = "Свести с ума"

/datum/rune/maelstrom/convert/get_choice_image()
	return image('icons/hud/screen_spells.dmi', icon_state = "convert")

/datum/rune/maelstrom/convert/can_action(mob/living/carbon/user)
	return (locate(/mob/living) in get_turf(holder))

/datum/rune/maelstrom/convert/action(mob/living/carbon/user)//user is cultist nado
	var/list/acolytes = nearest_acolytes()
	for(var/mob/living/L in get_turf(holder))
		if(!L.client)
			to_chat(user, "<span class='cult'>На руне существо без разума.</span>")
			continue
		if(L.ismindprotect())
			if(length(acolytes) < 2)
				to_chat(user, "<span class='cult'>Для разрушения защиты разума необходимо как минимум 2 культиста вокруг руны.</span>")
				continue
			// Remove all implants except maelstrom and loyalty
			for(var/obj/item/weapon/implant/I in L)
				if(istype(I, /obj/item/weapon/implant/mind_protect/loyalty))
					continue
				if(istype(I, /obj/item/weapon/implant/maelstrom))
					continue
				I.implant_removal(L)
			// Replace loyalty by fake implant
			L.fake_loyal_implant_replacement()
			L.ghostize(can_reenter_corpse = FALSE)
			create_spawner(/datum/spawner/living/maelstrom, L)
			continue
		if(L.mind && !L.mind.GetRole(CYBERPSYCHO))
			var/datum/faction/F = create_uniq_faction(/datum/faction/maelstrom)
			add_faction_member(F, L, TRUE)
