#define BRAINSWAP_TIME 50

/datum/rune
	var/name
	var/obj/effect/rune/holder
	var/datum/religion/religion
	// Used only for sprite generation
	var/list/words = list()

	var/static/list/all_words = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")

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

	action(user)
	fizzle(user)
	holder_reaction(user)
	if(!religion.reusable_rune)
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
	var/list/companions = holder.handle_teleport_grab(target, user)
	user.forceMove(target)
	user.eject_from_wall(TRUE, companions = companions)
	after_tp(target, user, companions)

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

/datum/rune/cult/teleport/teleport_to_heaven/after_tp(turf/target, mob/living/user, list/companions)
	if(user && !(locate(/obj/effect/rune) in target)) // user can gibbed
		var/obj/effect/rune/R = new(target, religion)
		R.power = new /datum/rune/cult/teleport/teleport_from_heaven(R, get_turf(holder))
		R.power.religion = religion
		R.icon = get_uristrune_cult(TRUE, R.power.words)

		var/damage = round(((world.time * 0.1)**1/2) * 0.5) // 42 damage if round goes 2 hours ir 72000 ticks
		user.take_overall_damage(damage, 0, "warp")

		var/datum/religion/cult/C = religion
		if(companions)
			for(var/mob/living/L in companions)
				L.take_overall_damage(damage, 0, "warp")
				C.create_anomalys(TRUE)
			C.create_anomalys(TRUE) // with user
		else
			C.create_anomalys(TRUE)

/datum/rune/cult/teleport/teleport_from_heaven
	name = "Teleport from HEAVEN"
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
		to_chat(user, "<span calss='notice'>Id телепорта - </span><span class='[religion.style_text]'>[id]</span>")
		return FALSE // Without instant teleport
	var/list/tp_runes = get_tp_runes()
	if(!tp_runes.len)
		to_chat(user, "<span calss='warning'>Рун телепорта с id - </span><span class='[religion.style_text]'>[id]</span><span calss='warning'>не обнаружено</span>")
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

/datum/rune/cult/capture_area
	name = "Захват Зоны"
	words = list("join", "hell", "technology")
	var/per_obj_cd = 1 SECONDS
	var/static/already_use = FALSE
	var/static/first_area_captured = FALSE
	var/obj/structure/cult/statue/capture/statue

/datum/rune/cult/capture_area/Destroy()
	already_use = FALSE
	QDEL_NULL(statue)
	return ..()

/datum/rune/cult/capture_area/can_action(mob/living/carbon/user)
	var/area/area = get_area(holder)
	if(already_use)
		to_chat(user, "<span class='warning'>Вы уже захватываете одну зону.</span>")
		return FALSE

	if(is_centcom_level(user.z))
		to_chat(user, "<span class='warning'>Эта зона уже под вашим контролем.</span>")
		return FALSE

	if(religion == area.religion)
		to_chat(user, "<span class='warning'>Эта зона уже под вашим контролем.</span>")
		return FALSE

	if(first_area_captured)
		var/area/user_area = get_area(user)
		if(istype(religion, area.religion?.type) || !istype(religion, user_area.religion?.type))
			to_chat(user, "<span class='warning'>Вы должны находится в уже захваченной зоне, а руна в зоне, которую вы хотите захватить.</span>")
			return FALSE

	return TRUE

/datum/rune/cult/capture_area/action(mob/living/carbon/user)
	already_use = TRUE
	var/area/A = get_area(holder)
	var/datum/announcement/station/cult/capture_area/announce = new
	announce.play(A)
	statue = new(get_turf(holder), holder)
	if(religion.religify_area(A.type, CALLBACK(src, .proc/capture_iteration)))
		first_area_captured = TRUE
	already_use = FALSE

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
	return TRUE

/datum/rune/cult/look_to_future/action(mob/living/carbon/user)
	var/mob/living/carbon/human/H = locate() in holder.loc
	for(var/atom/A in range(3))
		if(istype(A, /turf/simulated/wall))
			if(religion.wall_types)
				var/atom/type = pick(religion.wall_types)
				var/image/I = image(initial(type.icon), A, initial(type.icon_state))
				H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "rune-future-wall", I, H)
		else if(istype(A, /turf/simulated/floor))
			if(religion.floor_types)
				var/atom/type = pick(religion.floor_types)
				var/image/I = image(initial(type.icon), A, initial(type.icon_state))
				H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "rune-future-floor", I, H)
		else if(religion.door_types && (istype(A, /obj/machinery/door/airlock) || istype(A, /obj/structure/mineral_door)))
			H.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "rune-future-door", null, H, pick(religion.door_types), A)

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
	if(!religion.reusable_rune) // The first click puts up a wall. The second click removes the wall and rune.
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
	name = "Бладбоил"
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

/datum/rune/cult/armor
	name = "Призыв Обмундирования"
	words = list("hell", "destroy", "other")

/datum/rune/cult/armor/action(mob/living/carbon/user)
	user.visible_message("<span class='userdanger'>Из руны начинает гореть яркий красный свет, когда он рассвеивается, то на руне появляется броня и меч...</span>", \
	"<span class='userdanger'>Вы ослеплены вспышкой красного света! После ослепления вы видите на месте руны набо доспехов с мечом.</span>")
	var/datum/religion/cult/R = religion
	new /obj/item/clothing/head/culthood(holder.loc)
	new /obj/item/clothing/suit/cultrobes(holder.loc)
	new /obj/item/clothing/shoes/boots/cult(holder.loc)
	new /obj/item/weapon/storage/backpack/cultpack(holder.loc)
	new /obj/item/weapon/melee/cultblade(holder.loc, R.blade_with_shield)
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)

#undef BRAINSWAP_TIME
