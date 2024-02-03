#define MAX_RUNES_ON_MOB 5

#define COMSIG_ATTACK_HAND_FULTOPORTAL "attackhand_fultonportal"
#define COMSIG_DETECT_MAELSTROM_IMPLANT "detect_maelstrom_implant"
	#define COMPONENT_IMPLANT_DETECTED 1

/datum/element/maelstrom
	element_flags = ELEMENT_DETACH
	var/list/datum/building_agent/available_runes = list(new /datum/building_agent/rune/maelstrom/convert(),
														new /datum/building_agent/rune/maelstrom/portal_beacon(),
														new /datum/building_agent/rune/maelstrom/teleport(),
														new /datum/building_agent/rune/maelstrom/wall(),
														new /datum/building_agent/rune/maelstrom/bloodboil()
														)
	var/static/list/rune_choices_image = list()
	//var/scribing = FALSE
	var/static/list/rune_next = list()
	//var/list/runes_by_ckey

/datum/element/maelstrom/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(target, COMSIG_IMPLANT_INJECTED, PROC_REF(user_registration))

/datum/element/maelstrom/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_DETECT_MAELSTROM_IMPLANT))

/datum/element/maelstrom/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(begin_draw), user)

/datum/element/maelstrom/proc/re_enable_detecting_inject(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	RegisterSignal(source, COMSIG_IMPLANT_INJECTED, PROC_REF(user_registration))

/datum/element/maelstrom/proc/user_registration(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_IMPLANT_INJECTED)
	RegisterSignal(source, COMSIG_IMPLANT_REMOVAL, PROC_REF(re_enable_detecting_inject))
	RegisterSignal(user, COMSIG_DETECT_MAELSTROM_IMPLANT, PROC_REF(detect_maelstrom_implant))

/datum/element/maelstrom/proc/detect_maelstrom_implant(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_IMPLANT_DETECTED
//teleporting_runes

/obj/item/weapon/kitchenknife/ritual/calling_up
	var/mob/living/blood_brother
	COOLDOWN_DECLARE(incall_cd)

/obj/item/weapon/kitchenknife/ritual/calling_up/proc/register_user(mob/living/user)
	blood_brother = user
	RegisterSignal(src, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DIED), PROC_REF(destroy_container))

/obj/item/weapon/kitchenknife/ritual/calling_up/proc/destroy_container()
	SIGNAL_HANDLER
	new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(loc)
	qdel(src)

/obj/item/weapon/kitchenknife/ritual/calling_up/Destroy()
	blood_brother = null
	return ..()

/obj/item/weapon/kitchenknife/ritual/calling_up/attack_self(mob/user)
	if(!(SEND_SIGNAL(user, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED))
		return
	if(!COOLDOWN_FINISHED(src, incall_cd))
		return
	if(user == blood_brother)
		return
	if(!isnull(blood_brother))
		COOLDOWN_START(src, incall_cd, 4 SECONDS)
		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					new /obj/effect/temp_visual/cult/sparks/purple(get_turf(user))
				if(2)
					new /obj/effect/temp_visual/cult/sparks/quantum(blood_brother.loc)
					new /obj/effect/temp_visual/maelstrom/blood/out(user.loc)
				if(3)
					if(!isnull(blood_brother))
						var/turf/T = get_turf(src)
						new /obj/effect/temp_visual/maelstrom/blood/out(user.loc)
						new /obj/effect/temp_visual/maelstrom/blood(get_turf(blood_brother))
						blood_brother.forceMove(T)
			if(!do_after(user, 1 SECOND, needhand = TRUE, target = src, can_move = TRUE, progress = FALSE))
				return

/obj/item/weapon/grenade/curse
	icon = 'icons/obj/cult.dmi'
	icon_state = "curse_grenade"

/obj/item/weapon/grenade/curse/attack_self(mob/user)
	if(SEND_SIGNAL(user, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
		return ..()

/obj/item/weapon/grenade/curse/prime()
	playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	var/list/surroundings = range(world.view, src)
	for(var/mob/living/L in surroundings)
		L.SetConfused(0)
		L.SetShockStage(0)
		L.setHalLoss(0)
		L.SetParalysis(0)
		L.SetStunned(0)
		L.SetWeakened(0)
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.handcuffed && !initial(C.handcuffed))
				C.drop_from_inventory(C.handcuffed)
			if(C.legcuffed && !initial(C.legcuffed))
				C.drop_from_inventory(C.legcuffed)
		var/throw_living = FALSE
		if(L.buckled)
			L.buckled.user_unbuckle_mob(L)
			throw_living = TRUE
		if(!isfloorturf(L.loc))
			L.forceMove(get_turf(L))
			throw_living = TRUE
		if(throw_living)
			L.throw_at(get_step(L, get_dir(src, L)), 1, 1)
		if(SEND_SIGNAL(L, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
			L.reagents.add_reagent("stimulants", 3)
			continue
		L.AdjustConfused(10)
		L.make_jittery(150)
	light_off_range(surroundings, get_turf(src))
	qdel(src)

/obj/effect/decal/cleanable/crayon/maelstrom
	var/datum/rune/power
	var/creator_ckey

/obj/effect/decal/cleanable/crayon/maelstrom/atom_init(mapload, mob/user)
	. = ..()
	//color = rgb(rand(0,255), rand(0,255), rand(0,255))
	AddElement(/datum/element/rune_function)

/datum/building_agent/rune/maelstrom
	building_type = /obj/effect/decal/cleanable/crayon/maelstrom

/datum/building_agent/rune/maelstrom/convert
	name = "Обращение"
	rune_type = /datum/rune/maelstrom/convert

/datum/building_agent/rune/maelstrom/portal_beacon
	name = "Маяк Портала Культа"
	rune_type = /datum/rune/maelstrom/portal_beacon

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
	for(var/datum/building_agent/rune/maelstrom/B in available_runes)
		var/datum/rune/maelstrom/R = new B.rune_type
		rune_choices_image[B] = image(icon = R.get_choice_image())
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

	//var/list/L = LAZYACCESS(runes_by_ckey, user.ckey)
	//if(!isnull(L) && L.len >= MAX_RUNES_ON_MOB)
	//	to_chat(user, "<span class='warning'>Ваше тело слишком слабо, чтобы выдержать ещё больше рун!</span>")
	//	return

	//scribing = TRUE
	if(!do_after(user, 3 SECONDS, target = get_turf(user)))
		//scribing = FALSE
		return
	if(locate(/obj/effect/decal/cleanable/crayon/maelstrom) in get_turf(user))
		return
	//scribing = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), (rand(9) + 1) / 10)

	var/picked_color = pick("#da0000", "#ff9300", "#fff200", "#a8e61d", "#00b7ef", "#da00ff", "#ffffff")
	var/static/list/shade_list = list("#da0000" = "#810c0c",
									"#ff9300" = "#a55403",
									"#fff200" = "#886422",
									"#a8e61d" = "#61840f",
									"#00b7ef" = "#0082a8",
									"#da00ff" = "#810cff",
									"#ffffff" = "#cecece")
	var/obj/effect/decal/cleanable/crayon/maelstrom/R = new choice.building_type(get_turf(user), picked_color, shade_list[picked_color])
	R.icon = rune_choices_image[choice]
	R.power = new choice.rune_type(R)
	R.power.religion = null
	R.blood_DNA = list()
	R.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type
	R.creator_ckey = user.ckey
	//LAZYADDASSOCLIST(runes_by_ckey, user.ckey, R)

/datum/element/rune_function
	element_flags = ELEMENT_DETACH
	var/static/list/uplink_items_image
	var/list/datum/building_agent/items_to_create = list()

/datum/element/rune_function/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_REGULAR_CLICKED, PROC_REF(on_click))
	RegisterSignal(target, COMSIG_ATTACK_HAND_FULTOPORTAL, PROC_REF(portal_handattack))
	init_subtypes(/datum/building_agent/tool/maelstrom, items_to_create)

/datum/element/rune_function/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_REGULAR_CLICKED)

/datum/element/rune_function/proc/on_click(datum/source, mob/user, params)
	SIGNAL_HANDLER
	if(!(SEND_SIGNAL(user, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED))
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	if(get_dist(user, source) > 1) // anti-telekinesis
		return
	if(istype(source, /obj/effect/decal/cleanable/crayon/maelstrom))
		var/obj/effect/decal/cleanable/crayon/maelstrom/power_holder = source
		power_holder.power.action_wrapper(user)

/datum/building_agent/tool/maelstrom/blade
	name = "Лезвие призыва"
	building_type = /obj/item/weapon/kitchenknife/ritual/calling_up

/datum/building_agent/tool/maelstrom/curse_grenade
	name = "Проклятая граната"
	building_type = /obj/item/weapon/grenade/curse

/datum/building_agent/tool/maelstrom/implanter
	name = "Имплант культа"
	building_type = /obj/item/weapon/implanter/maelstrom

/datum/element/rune_function/proc/gen_images()
	uplink_items_image = list()
	for(var/datum/building_agent/B as anything in items_to_create)
		var/atom/build = B.building_type
		uplink_items_image[B] = image(icon = initial(build.icon), icon_state = initial(build.icon_state))

/datum/element/rune_function/proc/portal_handattack(datum/uplink, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(open_uplink), user, uplink)

/datum/element/rune_function/proc/open_uplink(mob/living/user, atom/uplink)
	if(!uplink_items_image || uplink_items_image.len < items_to_create.len)
		gen_images()
	var/datum/building_agent/choice = show_radial_menu(user, uplink, uplink_items_image, tooltips = TRUE, require_near = TRUE)
	if(!istype(choice))
		return
	if(istype(choice, /datum/building_agent/tool/maelstrom/blade))
		var/obj/item/weapon/kitchenknife/ritual/calling_up/dagger = new(uplink.loc)
		dagger.register_user(user)
	else
		new choice.building_type(uplink.loc)

	playsound(src, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/sparks/purple(uplink.loc)

	qdel(uplink)

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

/obj/effect/temp_visual/maelstrom/blood
	name = "blood teleport"
	duration = 12
	icon_state = "cultin"

/obj/effect/temp_visual/maelstrom/blood/out
	icon_state = "cultout"

/obj/effect/forcefield/cult/blue
	icon_state = "techno_field"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/forcefield/cult/blue/proc/register_holder(obj/holder)
	RegisterSignal(holder, COMSIG_PARENT_QDELETING, PROC_REF(on_holder_qdel))

/obj/effect/forcefield/cult/blue/proc/on_holder_qdel()
	SIGNAL_HANDLER
	qdel(src)

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

/datum/rune/maelstrom/bloodboil/proc/nearest_acolytes()
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
	//words = list("travel", "hell", "technology")

/datum/rune/maelstrom/convert/get_choice_image()
	return image('icons/hud/screen_spells.dmi', icon_state = "convert")

/datum/rune/maelstrom/convert/can_action(mob/living/carbon/user)
	return (locate(/mob/living) in get_turf(holder))

/datum/rune/maelstrom/convert/action(mob/living/carbon/user)//user is cultist nado
	for(var/mob/living/L in holder.loc)
		if(!L.client)
			continue
		if(L.ismindprotect())
			for(var/obj/item/weapon/implant/I in L)
				if(!istype(I, /obj/item/weapon/implant/maelstrom))
					I.implant_removal(L)
			L.ghostize(can_reenter_corpse = FALSE)
			create_spawner(/datum/spawner/living, L)
			continue
		if(!L.mind?.GetRole(CYBERPSYCHO))
			var/datum/faction/F = create_uniq_faction(/datum/faction/maelstrom)
			add_faction_member(F, L, TRUE)
