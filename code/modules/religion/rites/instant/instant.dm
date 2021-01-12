/datum/religion_rites/instant/cult
	religion_type = /datum/religion/cult

/datum/religion_rites/instant/cult/sacrifice
	name = "Sacrifice"
	desc = "Soul for the ancient gods."
	ritual_length = (5 SECONDS)
	invoke_msg = "Для моих богов!!"
	favor_cost = 50

/datum/religion_rites/instant/cult/sacrifice/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	var/mob/living/silicon/S = locate() in get_turf(AOG)
	if(S)
		return TRUE
	else if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только человек может пройти через ритуал.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/cult/sacrifice/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/datum/religion/cult/R = religion
	var/datum/mind/sacrifice_target = R.mode.sacrifice_target

	var/mob/living/silicon/S = locate() in get_turf(AOG)
	if(S)
		S.dust()
		R.mode.sacrificed += S.mind
		if(sacrifice_target && sacrifice_target == S.mind)
			to_chat(user, "<span class='[religion.style_text]'>Я принимаю эту жертву, ваша цель теперь может считаться выполненой.</span>")
			R.adjust_favor(300)
	else if(ishuman(AOG.buckled_mob))
		AOG.buckled_mob.gib()
		R.mode.sacrificed += AOG.buckled_mob.mind
		if(sacrifice_target && sacrifice_target == AOG.buckled_mob.mind)
			to_chat(user, "<span class='[religion.style_text]'>Я принимаю эту жертву, ваша цель теперь может считаться выполненой.</span>")
			R.adjust_favor(300)

	R.adjust_favor(calc_sacrifice_favor(AOG.buckled_mob))

	playsound(AOG, 'sound/magic/disintegrate.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/datum/religion_rites/instant/cult/sacrifice/proc/calc_sacrifice_favor(mob/living/L)
	if(!istype(L))
		return 0

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

	return sacrifice_favor

/datum/religion_rites/instant/cult/convert
	name = "Convert"
	desc = "The best brainwashing in the galaxy!"
	ritual_length = (5 SECONDS)
	invoke_msg = "Служи ему!!!"
	favor_cost = 100

/datum/religion_rites/instant/cult/convert/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только человек может пройти через ритуал.</span>")
		return FALSE

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(religion.is_member(H) || H.stat == DEAD || H.species.flags[NO_BLOOD])
		to_chat(user, "<span class='warning'>Неподходящее тело.</span>")
		return FALSE
	if(!global.cult_religion.mode.is_convertable_to_cult(H.mind))
		to_chat(user, "<span class='warning'>Разум тела сопротивляется.</span>")
		return FALSE
	if(jobban_isbanned(H, ROLE_CULTIST))
		to_chat(user, "<span class='warning'>Ему не нужно такое тело.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/convert/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/datum/religion/cult/cult = religion
	cult.mode.add_cultist(AOG.buckled_mob.mind)
	to_chat(AOG.buckled_mob, "<span class='[religion.style_text]'>Помогай другим культистам в тёмных делах. Их цель - твоя цель, а твоя - их. Вы вместе служите Тьме и тёмным богам.</span>")
	religion.adjust_favor(300)
	return TRUE

/datum/religion_rites/instant/cult/emp
	name = "EMP"
	desc = "Produces an electrical pulse of photons."
	ritual_length = (5 SECONDS)
	invoke_msg = "Энергетический импульс!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_TECH = 2,
	)

/datum/religion_rites/instant/cult/emp/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/turf/turf = get_turf(AOG)
	playsound(AOG, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER, 25)
	turf.hotspot_expose(700, 125)
	empulse(turf, 3, 5)
	return TRUE

/datum/religion_rites/instant/cult/drain_torture
	name = "Drain life"
	desc = "Drain life out of people on a charged torture table!"
	ritual_length = (1 SECONDS)
	invoke_msg = "Дай мне сил!!!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_OBSCURE = 1,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/instant/cult/drain_torture/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	var/datum/religion/cult/C = religion
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(table.victim?.stat != DEAD)
			return TRUE

	to_chat(user, "<span class='warning'>На заряженном столе пыток должна лежать хотя бы одна жертва.</span>")
	return FALSE

/datum/religion_rites/instant/cult/drain_torture/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/drain = 0
	var/datum/religion/cult/C = religion
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(table.victim?.stat != DEAD)
			var/bdrain = rand(1, 25)
			to_chat(table.victim, "<span class='userdanger'>Вы чувствуете слабость.</span>")
			table.victim.take_overall_damage(bdrain, 0)
			table.victim.Paralyse(5 SECONDS)
			playsound(table, 'sound/magic/transfer_blood.ogg', VOL_EFFECTS_MASTER)
			drain += bdrain

	if(!drain)
		return FALSE

	user.visible_message("<span class='userdanger'>Кровь течет из пустоты в [user]!</span>", \
		"<span class='[religion.style_text]'>Кровь начинает течь из дыры в пространстве в твое слабое смертное тело. Ты чувствуешь... переполненость.</span>", \
		"<span class='userdanger'>Вы слышите течение жидкости.</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(prob(drain * 1.5))
				if(BP.is_stump || BP.status & (ORGAN_BROKEN | ORGAN_SPLINTED | ORGAN_DEAD | ORGAN_ARTERY_CUT))
					BP.rejuvenate()
					to_chat(user, "<span class='[religion.style_text]'>Ты чувствуешь прилив сил в [BP].</span>")

	user.heal_overall_damage(1.2 * drain, drain)
	return TRUE

/datum/religion_rites/instant/cult/raise_torture
	name = "Raise"
	desc = "Gibs people on torture tables, but revive a person on the altar."
	ritual_length = (10 SECONDS)
	invoke_msg = "Восстань из мертвых!!!"
	favor_cost = 300

	needed_aspects = list(
		ASPECT_OBSCURE = 2,
		ASPECT_RESCUE = 2,
	)

/datum/religion_rites/instant/cult/raise_torture/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!AOG.buckled_mob || AOG.buckled_mob.stat != DEAD || !ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>На алтаре должен лежать мертвый человек.</span>")
		return FALSE

	var/datum/religion/cult/C = religion
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(table.victim?.stat != DEAD)
			return TRUE

	to_chat(user, "<span class='warning'>На заряженном столе пыток должна лежать хотя бы одна жертва.</span>")
	return FALSE

/datum/religion_rites/instant/cult/raise_torture/invoke_effect(mob/living/user, obj/AOG)
	..()
	if(!AOG.buckled_mob || AOG.buckled_mob.stat != DEAD || !ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>На алтаре должен лежать мертвый человек.</span>")
		return FALSE

	var/mob/living/carbon/human/corpse_to_raise
	var/list/mob/living/carbon/human/bodys_to_sacrifice = list()

	var/datum/religion/cult/C = religion
	if(C.mode.sacrifice_target && C.mode.sacrifice_target == AOG.buckled_mob.mind)
		to_chat(user, "<span class='[religion.style_text]'>Я запрещаю его воскрешать!</span>")
		return FALSE
	if(AOG.buckled_mob.mind)
		corpse_to_raise = AOG.buckled_mob

	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(!table.victim || table.victim.stat == DEAD)
			continue
		bodys_to_sacrifice += table.victim

	if(!bodys_to_sacrifice.len)
		to_chat(user, "<span class='[religion.style_text]'>Не хватает тел для жертвы.</span>")
		return FALSE

	corpse_to_raise.revive()
	SSticker.mode.add_cultist(corpse_to_raise.mind) // all checks in proc add_cultist, No reason to worry
	corpse_to_raise.visible_message("<span class='[religion.style_text]'>Глаза, раньше бездыханного тела, загораются слабым красным светом.</span>", \
		"<span class='[religion.style_text]'>Жизнь... Я снова живу...</span>", \
		"<span class='[religion.style_text]'>Вы слышите слабый, но знакомый шепот.</span>")
	playsound(AOG, 'sound/magic/cult_revive.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/M in bodys_to_sacrifice)
		user.say(pick("Паснар вал'кериам усинар!", "Саврае инес амутан!", "Йам'тотх ремиум ил'тарат!", "Хаккрутйу гопоенйим!", "Храсаи пивроиашан!", "Фирййи прхив мазенхор!", "Танах ех вакантахе!", "Облияе на ораие!", "Миуф хон внор'с!", "Вакабаи хий фен йусших!"))
		M.visible_message("<span class='[religion.style_text]'>[M] разрывается на части, чёрный дым стремительно поднимается от останков.</span>", \
			"<span class='[religion.style_text]'>Вы чувствуете, как ваша кровь кипит, разрывая вас же на части.</span>", \
			"<span class='[religion.style_text]'>Вы слышите тысячи голосов, все из них кричат от боли.</span>")

		C.mode.sacrificed += M.mind
		if(C.mode.sacrifice_target && C.mode.sacrifice_target == M.mind)
			to_chat(user, "<span class='[religion.style_text]'>Я принимаю жертву, ваша цель теперь может считаться выполненой.</span>")
			C.adjust_favor(300)

		M.gib()

	to_chat(corpse_to_raise, "<span class='[religion.style_text]'>Твоя кровь пульсирует, а голова раскалывается. Мир становится красным. Внезапно ты осознаешь ужаснейшую истину. Вуаль реальности повредилась. В твоей некогда гнившей ране пустило корни что-то зловещее.</span>")
	to_chat(corpse_to_raise, "<span class='[religion.style_text]'>Помогай своим собратьям в их темных делах. Их цель - твоя цель, а ваша - их. Отплати Темнейшему за свое воскрешение достойно.</span>")

	return TRUE

/datum/religion_rites/instant/cult/create_slave
	name = "Create homunculus"
	desc = "Creates a homunculus who can only live within the areas of your religion."
	ritual_length = (1 SECONDS) // plus 15 seconds of pollGhostCandidates
	invoke_msg = "Прийди же!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_SPAWN = 2,
		ASPECT_MYSTIC = 2,
	)

/datum/religion_rites/instant/cult/create_slave/proc/slave_enter_area(mob/slave, area/A)
	if(!(A in religion.captured_areas))
		slave.visible_message("<span class='userdanger'>[slave] медленно превращается в пыль и кости.</span>", \
				"<span class='userdanger'>Вы чувствуете боль, когда разрывается связь между вашей душой и этим гомункулом.</span>", \
				"<span class='userdanger'>Вы слышите множество тихих падений песчинок.</span>")
		slave.dust()

/datum/religion_rites/instant/cult/create_slave/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/list/candidates = pollGhostCandidates("Do you want to move into a [religion.name] homunculus?", ROLE_GHOSTLY, IGNORE_NARSIE_SLAVE, 15 SECONDS)
	if(!candidates.len)
		to_chat(user, "<span class='warning'>Ниодна душа не захотела вселяться в гомункула.</span>")
		return FALSE
	playsound(AOG, 'sound/magic/manifest.ogg', VOL_EFFECTS_MASTER)
	var/mob/M = pick(candidates)
	var/mob/living/carbon/human/dummy/D = new(get_turf(AOG)) // in soultstone code we have block for type dummy
	user.visible_message("<span class='userdanger'>На алтаре появляется фигура. Фигура... человека.</span>", \
		"<span class='[religion.style_text]'>Вы чувствуете наслаждение от очередного вашего воскрешения.</span>", \
		"<span class='userdanger'>Вы слышите, как течет жидкость.</span>")

	D.real_name = "familiar of [religion.deity_names] [num2roman(rand(1, 20))]"
	D.universal_speak = TRUE
	D.status_flags &= ~GODMODE
	D.s_tone = 35
	D.b_eyes = 200
	D.r_eyes = 200
	D.g_eyes = 200
	D.underwear = 0
	D.key = M.key
	var/datum/religion/cult/C = religion
	C.mode.add_cultist(D.mind)

	to_chat(D, "<span class='[religion.style_text]'>Твоя кровь пульсирует, а голова раскалывается. Мир становится красным. Внезапно ты осознаешь ужаснейшую истину. Вуаль реальности повредилась. В твоей некогда гнившей ране пустило корни что-то зловещее.</span>")
	to_chat(D, "<span class='[religion.style_text]'>Помогай своим собратьям в их темных делах. Их цель - твоя цель, а ваша - их. Отплати Темнейшему за свое воскрешение достойно.</span>")

	RegisterSignal(D, list(COMSIG_ENTER_AREA), .proc/slave_enter_area)
	return TRUE

/datum/religion_rites/instant/cult/freedom
	name = "Freedom"
	desc = "Frees the selected acolyte from slavery."
	ritual_length = (5 SECONDS)
	invoke_msg = "Освободись же!!!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_MYSTIC = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/instant/cult/freedom/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/list/cultists = list()
	for(var/mob/M in religion.members)
		if(ishuman(M))
			cultists += M

	if(!cultists.len)
		to_chat(user, "<span class='warning'>В вашей религии нет членов, даже вы не член её...</span>")
		return FALSE

	var/mob/living/carbon/cultist = input("Выберите кого хотите освободить.", religion.name) as null|anything in cultists
	var/is_processed = FALSE
	if(!cultist)
		return FALSE

	if(cultist.buckled)
		cultist.buckled.unbuckle_mob()
		is_processed = TRUE
	if (cultist.handcuffed)
		cultist.drop_from_inventory(cultist.handcuffed)
		is_processed = TRUE
	if (cultist.legcuffed)
		cultist.drop_from_inventory(cultist.legcuffed)
		is_processed = TRUE
	if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
		cultist.remove_from_mob(cultist.wear_mask)
		is_processed = TRUE
	if(istype(cultist.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = cultist.loc
		if(istype(closet.loc, /obj/structure/bigDelivery))
			var/obj/structure/bigDelivery/D = closet.loc
			closet.forceMove(get_turf(D.loc))
		if(closet.welded || closet.locked || !closet.opened)
			closet.welded = FALSE
			closet.locked = FALSE
			closet.open()
			closet.update_icon()
			is_processed = TRUE
	if(istype(cultist.loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/scanner = cultist.loc
		if(scanner.locked)
			scanner.locked = FALSE
			scanner.panel_open = FALSE
			scanner.open(cultist)
			is_processed = TRUE

	if(!is_processed)
		to_chat(user, "<span class='[religion.style_text]'>[cultist] уже свободен.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/summon_acolyt
	name = "Summon acolyt"
	desc = "Teleports free of the shackles and live an acolyte."
	ritual_length = (20 SECONDS) // plus 15 seconds of pollGhostCandidates
	invoke_msg = "Появись же!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_MYSTIC = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/instant/cult/summon_acolyt/invoke_effect(mob/living/user, obj/AOG)
	..()

	var/list/cultists = list()
	for(var/mob/M in religion.members)
		if(iscarbon(M))
			cultists += M

	if(!cultists.len)
		to_chat(user, "<span class='warning'>В вашей религии нет членов, даже вы не член её...</span>")
		return FALSE

	var/mob/living/carbon/cultist = input("Выберите кого хотите призвать.", religion.name) as null|anything in cultists
	if(!cultist)
		return FALSE

	if(cultist.incapacitated() || !isturf(cultist.loc))
		to_chat(user, "<span class='userdanger'>Вы не можете призвать [cultist].</span>")
		return FALSE

	cultist.visible_message("<span class='userdanger'>[cultist] внезапно исчезает!</span>")
	cultist.forceMove(get_turf(AOG))

	if(AOG.can_buckle && !AOG.buckled_mob)
		AOG.user_buckle_mob(cultist, user)

	user.visible_message("<span class='userdanger'>С красной вспышкой появляется [cultist].</span>", \
		"<span class='[religion.style_text]'>Вас на мгновенье ослепила красная вспышка. Теперь вы видите перед собой внезапно появившееся тело.</span>", \
		"<span class='[religion.style_text]'>Вы слышите хлопок и чувствуете запах озона.</span>")

	return TRUE

/datum/religion_rites/instant/communicate
	name = "Communicate"
	desc = "Sends a message to all members of the religion!"
	ritual_length = (5 SECONDS)
	invoke_msg = "Услышь меня!!!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_HERD = 1,
	)

/datum/religion_rites/instant/communicate/invoke_effect(mob/living/user, obj/AOG)
	..()

	var/input = sanitize(input(user, "Введите сообщение, которое услышат другие последователи.", "[religion.name]", ""))

	for(var/mob/M in global.mob_list)
		if(religion.is_member(M) || isobserver(M))
			to_chat(M, "<span class='[religion.style_text]'>Аколит [user.real_name]: [input]</span>")

	playsound(AOG, 'sound/magic/message.ogg', VOL_EFFECTS_MASTER)

	return TRUE
