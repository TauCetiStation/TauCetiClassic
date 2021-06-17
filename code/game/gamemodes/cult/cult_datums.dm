/datum/rune
	var/name
	var/obj/effect/rune/holder
	var/datum/religion/religion
	// Used only for sprite generation
	var/list/words = list()

	var/static/list/all_words = RUNE_WORDS

/datum/rune/New(holder)
	src.holder = holder

/datum/rune/Destroy()
	holder = null
	return ..()

/datum/rune/proc/ghost_action(mob/living/carbon/user)
	return

/datum/rune/proc/can_action(mob/living/carbon/user)
	return TRUE

/datum/rune/proc/action(mob/living/carbon/user)
	return

/datum/rune/proc/action_wrapper(mob/living/carbon/user)
	if(!can_action(user))
		return

	fizzle(user)
	action(user)
	holder_reaction(user)
	if(!religion.get_tech(RTECH_REUSABLE_RUNE))
		qdel(holder)

/datum/rune/proc/holder_reaction(mob/living/carbon/user)
	if(istype(holder, /obj/effect/rune))
		return rune_reaction(user)
	return talisman_reaction(user)

/datum/rune/proc/rune_reaction(mob/living/carbon/user)
	return

/datum/rune/proc/talisman_reaction(mob/living/carbon/user)
	return

/datum/rune/proc/fizzle(mob/living/user)
	if(istype(holder, /obj/effect/rune))
		user.say(pick("Хаккрутжу гопоенжим.", "Нхерасаи пивроиашан.", "Фиржжи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Мийф хон внор'с.", "Вакабаи хиж фен жусвикс."))
	else
		user.whisper(pick("Хаккрутжу гопоенжим.", "Нхерасаи пивроиашан.", "Фиржжи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Мийф хон внор'с.", "Вакабаи хиж фен жусвикс."))
	holder.visible_message("<span class='danger'>Иероглиф начинает пульсировать незаметным светом и сразу тухнет.</span>","<span class='danger'>Вы слишите тихое шипение.</span>")

/datum/rune/cult

/datum/rune/cult/teleport
	var/delay = 1 SECONDS

/datum/rune/cult/teleport/proc/teleporting(turf/target, mob/user)
	playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/blood/out(user.loc)
	playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/blood(target)
	var/list/companions = holder.handle_teleport_grab(target, user, FALSE)
	LAZYINITLIST(companions)
	user.forceMove(target)
	user.eject_from_wall(TRUE, companions = companions)
	for(var/mob/M in companions + user)
		if(M.client)
			new /obj/screen/temp/cult_teleportation(M, M)

	after_tp(get_turf(user), user, companions)

/datum/rune/cult/teleport/proc/after_tp(turf/target, mob/user, list/companions)
	return

/datum/rune/cult/teleport/teleport_to_heaven
	name = "Телепорт в РАЙ"
	words = list("travel", "self", "hell")
	var/turf/destination

/datum/rune/cult/teleport/teleport_to_heaven/action(mob/living/carbon/user)
	if(!destination)
		var/area/A = locate(religion.area_type)
		destination = get_turf(pick(A.contents))
	teleporting(destination	, user)

/datum/rune/cult/teleport/teleport_to_heaven/proc/create_from_heaven(turf/target, mob/user)
	if(istype(target, /turf/space))
		return

	var/obj/effect/rune/rand_rune = locate(holder.type) in target
	if(istype(rand_rune?.power, /datum/rune/cult/teleport/teleport_from_heaven))
		return

	var/obj/effect/rune/R = new(target, religion, user)
	R.power = new /datum/rune/cult/teleport/teleport_from_heaven(R, get_turf(holder))
	R.power.religion = religion
	R.icon = get_uristrune_cult(TRUE, R.power.words)

/datum/rune/cult/teleport/teleport_to_heaven/after_tp(turf/target, mob/living/user, list/companions)
	if(user) // user can gibbed
		create_from_heaven(target, user)
		var/datum/religion/cult/C = religion
		if(companions)
			for(var/mob/living/L in companions)
				C.create_anomalys(TRUE)
				create_from_heaven(get_step(target, global.alldirs), user)
			C.create_anomalys(TRUE) // with user
		else
			C.create_anomalys(TRUE)

/datum/rune/cult/teleport/teleport_from_heaven
	name = "Телепорт из РАЯ"
	var/turf/destination
	words = list("travel", "self", "technology")

/datum/rune/cult/teleport/teleport_from_heaven/New(holder, turf/_destination)
	..()
	destination = _destination

/datum/rune/cult/teleport/teleport_from_heaven/Destroy()
	destination = null
	return ..()

/datum/rune/cult/teleport/teleport_from_heaven/action(mob/living/carbon/user)
	teleporting(destination, user)

/datum/rune/cult/teleport/teleport
	name = "Телепорт"
	words = list("travel", "self", "see")
	var/id
	var/id_inputing = FALSE

/datum/rune/cult/teleport/teleport/can_action(mob/living/carbon/user)
	if(!id && !id_inputing)
		id_inputing = TRUE
		id = input(user, "Введите Id руны телепорта", "Редактор Id рун", pick(all_words))
		to_chat(user, "<span class='notice'>Id телепорта - </span><span class='[religion.style_text]'>[id]</span>")
		return FALSE // Without instant teleport
	var/list/tp_runes = get_tp_runes()
	if(!tp_runes.len)
		to_chat(user, "<span class='warning'>Рун телепорта с id - </span><span class='[religion.style_text]'>[id]</span> <span class='warning'>не обнаружено</span>")
		return FALSE
	if(tp_runes.len >= 5)
		to_chat(user, "<span class='userdanger'>Вы чувствуете боль, так как руна исчезает в сдвиге реальности, вызванном большим напряжением в пространственно-временной ткани мира.</span>")
		user.take_overall_damage(5, 0)
		return FALSE
	return TRUE

/datum/rune/cult/teleport/teleport/proc/get_tp_runes()
	var/list/runes = list()
	for(var/obj/effect/rune/R in religion.runes)
		if(!istype(R.power, type) || R.power == src)
			continue
		var/datum/rune/cult/teleport/teleport/T = R.power
		if(T.id == id && (!is_centcom_level(R.loc.z) || istype(get_area(R), religion.area_type)))
			runes += R
	return runes

/datum/rune/cult/teleport/teleport/action(mob/living/carbon/user)
	var/list/tp_runes = get_tp_runes()

	if(tp_runes.len)
		user.visible_message("<span class='userdanger'>[user] исчезает во вспышке красного света!</span>", \
			"<span class='[religion.style_text]'>Вы чувствуете, как ваше тело проскальзывает сквозь измерения!</span>", \
			"<span class='userdanger'>Вы слышите болезненный хруст и хлюпанье внутренностей.</span>")
		var/turf/T = get_turf(pick(tp_runes))
		teleporting(T, user)

/datum/rune/cult/teleport/teleport/ghost_action(mob/living/carbon/user)
	var/list/tp_runes = get_tp_runes()

	if(tp_runes.len)
		user.forceMove(get_turf(pick(tp_runes)))

#define REQ_TURFS_TO_CAPTURE 40
/datum/rune/cult/capture_area
	name = "Захват Зоны"
	words = list("join", "hell", "technology")
	var/per_obj_cd = 1 SECONDS
	var/obj/structure/cult/statue/capture/statue

/datum/rune/cult/capture_area/Destroy()
	if(!QDELETED(statue))
		qdel(statue)
	return ..()

/datum/rune/cult/capture_area/can_action(mob/living/carbon/user)
	var/datum/religion/cult/R = global.cult_religion
	if(R.capturing_area)
		to_chat(user, "<span class='warning'>Вы уже захватываете зону.</span>")
		return FALSE

	var/area/area = get_area(holder)
	if(!is_station_level(user.z) || !area.valid_territory || religion == area.religion)
		to_chat(user, "<span class='warning'>Эта зона уже под вашим контролем.</span>")
		return FALSE

	var/turfs = 0
	for(var/turf/T in area)
		if(turfs == REQ_TURFS_TO_CAPTURE)
			break
		turfs++

	if(turfs < REQ_TURFS_TO_CAPTURE)
		to_chat(user, "<span class='warning'>Эта зона слишком мала.</span>")
		return FALSE

	return TRUE

/datum/rune/cult/capture_area/action(mob/living/carbon/user)
	var/area/area = get_area(holder)
	var/area/user_area = get_area(user)
	if(!istype(religion, area.religion?.type) && istype(religion, user_area.religion?.type))
		per_obj_cd = 0.5 SECONDS

	var/datum/religion/cult/R = global.cult_religion
	R.capturing_area = TRUE
	var/datum/announcement/station/cult/capture_area/announce = new
	announce.play(area)
	statue = new(get_turf(holder), holder)
	R.religify_area(area.type, CALLBACK(src, .proc/capture_iteration), null, TRUE)
	R.capturing_area = FALSE

/datum/rune/cult/capture_area/proc/capture_iteration(i, list/all_items)
	if(!holder || !src)
		return FALSE

	if((100*i)/all_items.len % 25 == 0)
		for(var/mob/M in religion.members)
			to_chat(M, "<span class='[religion.style_text]'>Захват [get_area(holder)] завершен на [round((100*i)/all_items.len, 0.1)]%</span>")

	INVOKE_ASYNC(src, .proc/capture_effect, i, all_items)
	sleep(per_obj_cd)
	return TRUE

/datum/rune/cult/capture_area/proc/capture_effect(i, list/all_items)
	var/turf = get_turf(all_items[i])
	var/list/viewing = list()
	for(var/mob/M in viewers(turf))
		if(M.client && (M.client.prefs.toggles & SHOW_ANIMATIONS))
			viewing |= M.client

	var/image/I = image(uristrune_cache[pick(uristrune_cache)], turf, layer = SINGULARITY_LAYER)
	flick_overlay(I, viewing, 30)
	animate(I, alpha = 0, time = 30)

	statue.do_shake_animation(0.5, per_obj_cd)
#undef REQ_TURFS_TO_CAPTURE

/datum/rune/cult/portal_beacon
	name = "Маяк Портала Культа"
	words = list("travel", "hell", "technology")

// Work only for rite
/datum/rune/cult/portal_beacon/can_action(mob/living/carbon/user)
	return FALSE

/datum/rune/cult/look_to_future
	name = "Назад в Будущее"
	words = list("see", "hell", "self")

/datum/rune/cult/look_to_future/can_action(mob/living/carbon/user)
	var/mob/living/carbon/human/H = locate() in holder.loc
	if(!H)
		to_chat(user, "<span class='warning'>На руне должен быть человек.</span>")
		return FALSE
	if(is_centcom_level(holder.z))
		to_chat(user, "<span class='warning'>Вы уже в будущем.</span>")
		return FALSE
	return TRUE

/datum/rune/cult/look_to_future/action(mob/living/carbon/user)
	var/mob/living/carbon/human/H = locate() in holder.loc
	for(var/atom/A in range(3))
		if(istype(A, /turf/simulated/wall))
			if(religion.wall_types)
				var/atom/type = pick(religion.wall_types)
				var/image/I = image(initial(type.icon), A, initial(type.icon_state))
				H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "rune-future-wall-[H.name]", I, H)

		else if(istype(A, /turf/simulated/floor))
			if(religion.floor_types)
				var/atom/type = pick(religion.floor_types)
				var/image/I = image(initial(type.icon), A, initial(type.icon_state))
				H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "rune-future-floor-[H.name]", I, H)

/datum/rune/cult/item_port
	name = "Телепорт Предметов"
	words = list("travel", "other", "see")

/datum/rune/cult/item_port/can_action(mob/living/carbon/user)
	if(!religion.altars.len)
		to_chat(user, "<span class='warning'>У вас должен быть алтарь.</span>")
		return FALSE
	return TRUE

/datum/rune/cult/item_port/action(mob/living/carbon/user)
	var/obj/structure/altar_of_gods/cult/altar = pick(religion.altars)

	for(var/obj/O in holder.loc)
		var/with_mob = FALSE
		for(var/mob/living/L in O.contents)
			with_mob = TRUE
			break
		if(!with_mob && !O.anchored && !O.freeze_movement)
			O.visible_message("<span class='danger'>[O] внезапно исчезает!</span>")
			O.forceMove(altar.loc)
			O.visible_message("<span class='danger'>[O] внезапно появляется!</span>")

	playsound(altar, 'sound/magic/SummonItems_generic.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='userdanger'>Вы чувствуете, как воздух движется над руной.</span>", \
		"<span class='[religion.style_text]'>Вы чувствуете, как воздух целенаправленной куда-то движется от руны.</span>", \
		"<span class='userdanger'>Вы чувствуете запах и вкус озона.</span>")

/datum/rune/cult/wall
	name = "Призыв Стены"
	words = list("destroy", "travel", "self")

	var/obj/effect/forcefield/cult/alt_app/wall

/datum/rune/cult/wall/Destroy()
	QDEL_NULL(wall)
	return ..()

/datum/rune/cult/wall/can_action(mob/living/carbon/user)
	if(!religion.get_tech(RTECH_REUSABLE_RUNE)) // The first click puts up a wall. The second click removes the wall and rune.
		if(!wall)
			action(user)
			return FALSE
	return TRUE

/datum/rune/cult/wall/action(mob/living/carbon/user)
	if(wall)
		to_chat(user, "<span class='userdanger'>Ваша кровь перестает течь в руне, и вы чувствуете, как пространство над руной начинает редеть.</span>")
		QDEL_NULL(wall)
	else
		wall = new /obj/effect/forcefield/cult/alt_app(get_turf(holder))
		to_chat(user, "<span class='userdanger'>Ваша кровь начинает течь в руне, и вы чувствуете, как пространство над руной начинает сгущаться.</span>")

	user.take_bodypart_damage(2, 0)

/datum/rune/cult/bloodboil
	name = "Кипение Крови"
	words = list("destroy", "blood", "see")

/datum/rune/cult/bloodboil/can_action(mob/living/carbon/user)
	var/list/acolytes = religion.nearest_acolytes(holder, 1)
	if(length(acolytes) < 3)
		to_chat(user, "<span class='[religion.style_text]'>Вам необходимо как минимум 3 культиста вокруг руны.</span>")
		return FALSE
	var/list/heretics = religion.nearest_heretics(holder, 5)
	if(length(heretics) < 1)
		to_chat(user, "<span class='[religion.style_text]'>Никого нет рядом.</span>")
		return FALSE
	return TRUE

/datum/rune/cult/bloodboil/action(mob/living/carbon/user)
	var/list/acolytes = religion.nearest_acolytes(holder, 1, "Дедло ол[pick("'","`")]бтох!")
	var/list/heretics = religion.nearest_heretics(holder, 5)
	if(length(heretics) < 1)
		to_chat(user, "<span class='[religion.style_text]'>Никого нет рядом.</span>")
		return
	var/damage_for_acolytes = 65 / length(acolytes)
	var/damage_modifier = min(120 / length(heretics), 45)

	for(var/mob/living/carbon/M in heretics)
		M.take_overall_damage(damage_modifier, damage_modifier)
		to_chat(M, "<span class='userdanger'>Твоя кровь кипит!</span>")
		if(prob(5) && M)
			M.gib()
	for(var/obj/effect/rune/R in view(holder))
		if(prob(10))
			explosion(R.loc, -1, 0, 1, 5)
	for(var/mob/living/L in acolytes)
		L.take_overall_damage(damage_for_acolytes, 0)

/datum/rune/cult/charge_pylons
	name = "Активация Пилонов"
	words = list("destroy", "other", "technology")
	var/time_to_stop = 2 MINUTE

/datum/rune/cult/charge_pylons/can_action(mob/living/carbon/user)
	var/has_pylon = FALSE
	for(var/obj/structure/cult/pylon/P in oview(1, holder))
		if(!P.anchored)
			continue
		has_pylon = TRUE
		break
	if(!has_pylon)
		to_chat(user, "<span class='warning'>Вокруг руны нету пилонов.</span>")
		return
	return TRUE

/datum/rune/cult/charge_pylons/action(mob/living/carbon/user)
	var/pylons = 0
	for(var/obj/structure/cult/pylon/P in oview(1, holder))
		if(!P.anchored)
			continue
		P.activate(time_to_stop, religion)
		pylons++

	holder.visible_message("<span class='warning'>[russian_plural(pylons, "Пилон", "Пилоны")] начинают зловеще светиться.</span>")
