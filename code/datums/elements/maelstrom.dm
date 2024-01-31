#define MAX_RUNES_ON_MOB 5

#define COMSIG_ATTACK_HAND_FULTOPORTAL "attackhand_fultonportal"

/datum/element/maelstrom
	element_flags = ELEMENT_DETACH
	var/list/datum/building_agent/available_runes = list(new /datum/building_agent/rune/maelstrom/portal_beacon(),
														new /datum/building_agent/rune/maelstrom/teleport(),
														new /datum/building_agent/rune/maelstrom/wall(),
														new /datum/building_agent/rune/maelstrom/bloodboil()
														)
	//var/datum/religion/religion
	var/static/list/rune_choices_image = list()
	//var/scribing = FALSE
	var/static/list/rune_next = list()
	var/list/runes_by_ckey

/datum/element/maelstrom/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(target, COMSIG_AFTER_TELEPORT, PROC_REF(prevent_paralysing))
	RegisterSignal(target, COMSIG_ATTACK_HAND_FULTOPORTAL, PROC_REF(open_uplink))

/datum/element/maelstrom/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_AFTER_TELEPORT))

/datum/element/maelstrom/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(begin_draw), user)

/datum/element/maelstrom/proc/prevent_paralysing(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_NO_PARALYZE
teleporting_runes


/datum/element/maelstrom/proc/open_uplink(datum/source, mob/living/user)
	/obj/item/weapon/kitchenknife/ritual/calling_up
	/obj/item/weapon/grenade/curse
	/*	var/datum/building_agent/choice = show_radial_menu(user, src, items_image, tooltips = TRUE, require_near = TRUE)
	if(!choice)
		return

	if(!religion.check_costs(choice.favor_cost, choice.piety_cost, user))
		return

	if(istype(choice, /datum/building_agent/tool/cult/tome))
		religion.spawn_bible(loc)
	else
		new choice.building_type(loc)

	religion.adjust_favor(-choice.favor_cost)
	religion.adjust_piety(-choice.piety_cost)
	playsound(src, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	icon_state = "forge_active"
	VARSET_IN(src, icon_state, "forge_inactive", 10)*/

/obj/effect/decal/cleanable/crayon/maelstrom
	var/datum/rune/power
	var/creator_ckey

/obj/effect/decal/cleanable/crayon/maelstrom/atom_init(mapload, mob/user)
	. = ..()
	AddElement(/datum/element/rune_function)

/datum/building_agent/rune/maelstrom
	building_type = /obj/effect/decal/cleanable/crayon/maelstrom

/datum/building_agent/rune/maelstrom/portal_beacon
	name = "Маяк Портала Культа"
	rune_type = /datum/rune/cult/portal_beacon

/datum/building_agent/rune/maelstrom/teleport
	name = "Телепорт"
	rune_type = /datum/rune/maelstrom/teleport

/datum/building_agent/rune/maelstrom/wall
	name = "Призыв Стены"
	rune_type = /datum/rune/maelstrom/wall

/datum/building_agent/rune/maelstrom/bloodboil
	name = "Кипение Крови"
	rune_type = /datum/rune/maelstrom/bloodboil

/datum/element/maelstrom/proc/begin_draw(mob/user)
	if(rune_choices_image.len < available_runes.len)
		rune_choices()
	scribe_rune(user)

/datum/element/maelstrom/proc/rune_choices()
	for(var/datum/building_agent/rune/cult/B in available_runes)
		var/datum/rune/cult/R = new B.rune_type
		rune_choices_image[B] = image(icon = get_uristrune_cult(FALSE, R.words))
		qdel(R)

/datum/element/maelstrom/proc/get_agent_radial_menu(list/datum/building_agent/BA, mob/user)
	for(var/datum/building_agent/B in BA)
		B.name = "[initial(B.name)]"
	var/datum/building_agent/choice = show_radial_menu(user, user, BA, tooltips = TRUE, require_near = TRUE)
	return choice

/datum/element/maelstrom/proc/scribe_rune(mob/user)
	var/datum/building_agent/rune/cult/choice = get_agent_radial_menu(rune_choices_image, user)
	if(!choice)
		return
	/*
	if(scribing)
		to_chat(user, "<span class='warning'>Вы уже рисуете руну!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!(part in list(H.get_bodypart(BP_L_ARM), H.get_bodypart(BP_R_ARM))))
			to_chat(user, "<span class='warning'>Необходимо расположить силу в руках!</span>")
			return
	*/
	if(rune_next[user.ckey] > world.time)
		to_chat(user, "<span class='warning'>Ты сможешь разметить следующую руну через [round((rune_next[user.ckey] - world.time) * 0.1)+1] секунд!</span>")
		return
	rune_next[user.ckey] = world.time + 10 SECONDS

	var/list/L = LAZYACCESS(runes_by_ckey, user.ckey)
	if(!isnull(L) && L.len >= MAX_RUNES_ON_MOB)
		to_chat(user, "<span class='warning'>Ваше тело слишком слабо, чтобы выдержать ещё больше рун!</span>")
		return

	//scribing = TRUE
	if(!do_after(user, 3 SECONDS, target = get_turf(user)))
		//scribing = FALSE
		return
	//scribing = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), (rand(9) + 1) / 10)

	var/obj/effect/rune/R = new choice.building_type(get_turf(user))//religion
	R.icon = rune_choices_image[choice]
	R.power = new choice.rune_type(R)
	R.power.religion = null
	R.blood_DNA = list()
	R.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type
	R.creator_ckey = user.ckey
	LAZYADDASSOCLIST(runes_by_ckey, user.ckey, R)

	new /obj/effect/temp_visual/cult/sparks/purple(get_turf(R))



/datum/element/rune_function
	element_flags = ELEMENT_DETACH

/datum/element/rune_function/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_CLICK, PROC_REF(on_click))

/datum/element/rune_function/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_CLICK)

/datum/element/rune_function/proc/on_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER
	user.SetNextMove(CLICK_CD_INTERACT)
	if(get_dist(user, source) > 1) // anti-telekinesis
		return
	if(istype(source, /obj/effect/decal/cleanable/crayon/maelstrom))
		var /obj/effect/decal/cleanable/crayon/maelstrom/power_holder = source
		power_holder.power.action_wrapper(user)


/datum/rune/maelstrom
	var/obj/effect/holder2

/datum/rune/maelstrom/New(holder)
	. = ..()
	holder2 = holder

/datum/rune/maelstrom/Destroy()
	holder2 = null
	return ..()

/datum/rune/maelstrom/action_wrapper(mob/living/carbon/user)
	if(!can_action(user))
		return

	fizzle(user)
	action(user)
	holder_reaction(user)
	qdel(holder)

/datum/rune/maelstrom/holder_reaction(mob/living/carbon/user)
	if(istype(holder, /obj/effect/rune) || istype(holder2, /obj/effect/decal/cleanable/crayon/maelstrom))
		return rune_reaction(user)
	return talisman_reaction(user)

/datum/rune/maelstrom/fizzle(mob/living/user)
	user.whisper(pick("Хаккрутжу гопоенжим.", "Нхерасаи пивроиашан.", "Фиржжи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Мийф хон внор'с.", "Вакабаи хиж фен жусвикс."))
	holder.visible_message("<span class='danger'>Иероглиф начинает пульсировать незаметным светом и сразу тухнет.</span>","<span class='danger'>Вы слышите тихое шипение.</span>")

var/global/list/teleporting_runes = list()
ADD_TO_GLOBAL_LIST(/datum/rune/maelstrom/teleport, teleporting_runes)
/datum/rune/maelstrom/teleport
	name = "Телепорт"

/datum/rune/maelstrom/teleport/proc/teleporting(turf/target, mob/user)
	playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/maelstrom/blood/out(user.loc)
	playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/maelstrom/blood(target)

	var/list/companions = holder2.handle_teleport_grab(target, user, FALSE)
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

	to_chat(user, "<span class='notice'>Id телепорта - </span><span class='[religion.style_text]'>[id]</span>")

/datum/rune/maelstrom/teleport/can_action(mob/living/carbon/user)
	if(!id && !id_inputing)
		id_inputing = TRUE
		input_rune_id(user)
		id_inputing = FALSE
		return FALSE // Without instant teleport
	var/list/tp_runes = get_tp_runes_by_id()
	if(!tp_runes.len)
		to_chat(user, "<span class='warning'>Рун телепорта с id - </span><span class='[religion.style_text]'>[id]</span> <span class='warning'>не обнаружено</span>")
		return FALSE
	return TRUE

/datum/rune/maelstrom/teleport/get_runes_by_type(rune_type)
	var/list/valid_runes = list()
	for(var/obj/effect/decal/cleanable/crayon/maelstrom/R as anything in global.teleporting_runes)
		if(!istype(R.power, rune_type))
			continue
		if(!is_centcom_level(R.loc.z) || istype(get_area(R), area_type))
			valid_runes += R
	return valid_runes

/datum/rune/maelstrom/teleport/proc/get_runes_ids()
	var/list/runes = get_runes_by_type(/datum/rune/maelstrom/teleport) - holder
	var/list/uniq_ids = list()
	for(var/obj/effect/decal/cleanable/crayon/maelstrom/R as anything in global.teleporting_runes)
		var/datum/rune/maelstrom/teleport/T = R.power
		uniq_ids |= T.id
	return uniq_ids

/datum/rune/maelstrom/teleport/proc/get_tp_runes_by_id()
	var/list/runes = religion.get_runes_by_type(/datum/rune/maelstrom/teleport) - holder
	var/list/valid_runes = list()
	for(var/obj/effect/decal/cleanable/crayon/maelstrom/R as anything in global.teleporting_runes)
		var/datum/rune/maelstrom/teleport/T = R.power
		if(T.id == id)
			valid_runes += R
	return valid_runes

/datum/rune/maelstrom/teleport/action(mob/living/carbon/user)
	var/list/tp_runes = get_tp_runes_by_id()
	if(tp_runes.len)
		user.visible_message("<span class='userdanger'>[user] исчезает во вспышке красного света!</span>", \
			"<span class='[religion.style_text]'>Вы чувствуете, как ваше тело проскальзывает сквозь измерения!</span>", \
			"<span class='userdanger'>Вы слышите болезненный хруст и хлюпанье внутренностей.</span>")
		var/turf/T = get_turf(pick(tp_runes))
		teleporting(T, user)

/datum/rune/maelstrom/teleport/ghost_action(mob/living/carbon/user)
	var/list/tp_runes = get_tp_runes_by_id()
	if(tp_runes.len)
		user.forceMove(get_turf(pick(tp_runes)))

/datum/rune/maelstrom/teleport/after_tp(turf/target, mob/living/user, list/companions)
	if(!companions.len)
		return
	for(var/mob/living/M in list(user) + companions)
		if(SEND_SIGNAL(M, COMSIG_AFTER_TELEPORT) & COMPONENT_NO_PARALYZE)
			continue
		M.Paralyze(2 SECONDS)

/obj/effect/temp_visual/maelstrom/blood
	name = "blood teleport"
	duration = 12
	icon_state = "cultin"

/obj/effect/temp_visual/maelstrom/blood/out
	icon_state = "cultout"



/datum/rune/maelstrom/wall
	name = "Призыв Стены"
	var/obj/effect/forcefield/cult/alt_app/wall

/datum/rune/maelstrom/wall/Destroy()
	QDEL_NULL(wall)
	return ..()

/datum/rune/maelstrom/wall/can_action(mob/living/carbon/user)
	if(!wall)
		action(user)
		return FALSE
	return TRUE

/datum/rune/maelstrom/wall/action(mob/living/carbon/user)
	if(wall)
		to_chat(user, "<span class='userdanger'>Ваша сила перестает течь в руне, и вы чувствуете, как пространство над руной начинает редеть.</span>")
		QDEL_NULL(wall)
	else
		wall = new /obj/effect/forcefield/cult/alt_app(get_turf(holder))
		to_chat(user, "<span class='userdanger'>Ваша сила начинает течь в руне, и вы чувствуете, как пространство над руной начинает сгущаться.</span>")

	user.take_bodypart_damage(2, 0)

/datum/rune/maelstrom/portal_beacon
	name = "Маяк Портала Культа"
	words = list("travel", "hell", "technology")

/datum/rune/maelstrom/portal_beacon/can_action(mob/living/carbon/user)
	return FALSE

/obj/effect/anomaly/bluespace/fulton/attack_hand(mob/living/user)
	SEND_SIGNAL(user, COMSIG_ATTACK_HAND_FULTOPORTAL)

/datum/rune/maelstrom/bloodboil
	name = "Кипение Крови"
	words = list("destroy", "blood", "see")

/datum/rune/maelstrom/bloodboil/proc/nearest_acolytes()
	var/list/acolytes = list()
	for(var/mob/living/carbon/C in range(1, holder))
		if(SEND_SIGNAL(C, COMSIG_BLOODBOIL_COUNT_ACOLYTE) & COMPONENT_MAELSTROM_MEMBER)
			acolytes += C
	return acolytes

/datum/rune/maelstrom/bloodboil/proc/nearest_heretics()
	var/list/heretics = list()
	for(var/mob/living/heretic in view(5, holder))
		if(SEND_SIGNAL(heretic, COMSIG_BLOODBOIL_COUNT_AFFECTED) & COMPONENT_NO_BLOODBOIL)
			heretics += heretic

/datum/rune/cult/bloodboil/can_action(mob/living/carbon/user)
	var/list/acolytes = nearest_acolytes()
	if(length(acolytes) < 3)
		to_chat(user, "<span class='cult'>Вам необходимо как минимум 3 культиста вокруг руны.</span>")
		return FALSE
	var/list/heretics = nearest_heretics()
	if(length(heretics) < 1)
		to_chat(user, "<span class='cult'>Никого нет рядом.</span>")
		return FALSE
	return TRUE

/datum/rune/cult/bloodboil/action(mob/living/carbon/user)
	var/list/acolytes = nearest_acolytes()
	var/list/heretics = nearest_heretics()
	if(length(heretics) < 1)
		to_chat(user, "<span class='cult'>Никого нет рядом.</span>")
		return
	var/damage_for_acolytes = length(heretics) * 30 / length(acolytes)
	var/damage_modifier = length(acolytes) * 30

	for(var/mob/living/carbon/M in heretics)
		M.take_overall_damage(damage_modifier * 0.1, damage_for_acolytes * 0.9)
		to_chat(M, "<span class='userdanger'>Твоя кровь кипит!</span>")
		if(prob(5) && M)
			M.gib()
	for(var/mob/living/L in acolytes)
		L.take_overall_damage(damage_for_acolytes * 0.1, damage_for_acolytes * 0.9)
