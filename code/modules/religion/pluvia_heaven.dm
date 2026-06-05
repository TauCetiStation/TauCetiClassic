/var/global/list/available_pluvia_gongs = list()

/obj/effect/landmark/heaven_landmark
	name = "Heaven"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER

/area/pluvian_heaven
	name = "Pluvian Heaven"
	icon_state = "blue2"

/turf/simulated/wall/heaven
	icon = 'icons/turf/walls/has_false_walls/wall_heaven.dmi'
	light_color = "#ffffff"
	light_power = 2
	light_range = 2

/turf/simulated/floor/beach/water/waterpool/heaven
	name = "Heaven"
	cases = list("Рай", "Рая", "Раю", "Рай", "Раем", "Рае")
	plane = PLANE_SPACE
	light_color = "#ffffff"
	light_power = 2
	light_range = 2

/obj/item/weapon/bless_vote
	name = "Bless vote"
	cases = list("Рекомендательное письмо", "Рекомендательного письма", "Рекомендательному письму", "Рекомендательное письмо", "Рекомендательным письмом", "Рекомендательном письме")
	desc = "Билет до рая."
	w_class = SIZE_TINY
	icon = 'icons/obj/items.dmi'
	icon_state = "bless-vote"
	item_state_world = "bless-vote_world"
	var/mob/living/carbon/human/owner
	var/sign = FALSE
	var/sign_place = "ПОДПИСАТЬ"

/obj/item/weapon/bless_vote/attack_self(mob/living/carbon/user)
	user.set_machine(src)
	var/dat
	dat = "<B><font color = ##ff0000>[CASE(src, NOMINATIVE_CASE)] для прохода в рай</font></B><BR>"
	if(owner.gender == FEMALE)
		dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете [CASE(owner, ACCUSATIVE_CASE)] достойной попасть в рай после смерти</font></I><BR><BR>"
	else
		dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете [CASE(owner, ACCUSATIVE_CASE)] достойным попасть в рай после смерти</font></I><BR><BR>"
	dat += "<I><font color = ##ff0000>Проколите подушечку пальца об шип и приложите к месту для печати</font></I><BR>"
	dat += "<A href='byond://?src=\ref[src];choice=yes'>[sign_place]</A><BR>"
	var/datum/browser/popup = new(user, "window=bless_vote", "Рекомендательное письмо")
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/bless_vote/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr
	if (usr.incapacitated() || src.loc != usr)
		return
	if(href_list["choice"] == "yes")
		if(usr == owner)
			to_chat(usr, "<span class='warning'>Свое письмо нельзя подписывать!</span>")
		else if(sign)
			to_chat(usr, "<span class='notice'>Эта бумага уже подписана</span>")
		else if(H.mind.pluvian_social_credit > 0)
			to_chat(usr, "<span class='notice'>Подписано!</span>")
			sign_place = H.name
			H.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), (rand(9) + 1) / 10)
			H.mind.pluvian_social_credit -= 1
			if(!ismindshielded(owner) && !isloyal(owner))
				owner.mind.pluvian_social_credit += 1
			sign = TRUE
			to_chat(owner, "<span class='notice'>Ваш уровень кармы повышен!</span>")
		else
			to_chat(usr, "<span class='notice'>У вас нет права голоса</span>")


/obj/effect/proc_holder/spell/create_bless_vote
	name = "Рекомендательное письмо"
	cases = list("Рекомендательное письмо", "Рекомендательного письма", "Рекомендательному письму", "Рекомендательное письмо", "Рекомендательным письмом", "Рекомендательном письме")
	range = 1
	charge_max = 0
	clothes_req = FALSE
	action_icon_state = "pluvia_bless"
	sound = 'sound/magic/heal.ogg'

/obj/effect/proc_holder/spell/create_bless_vote/choose_targets(mob/user = usr)
	var/obj/item/weapon/paper/P
	var/obj/item/target
	var/list/possible_targets = list()
	for(P in orange(range, user))
		possible_targets[P] = image(P.icon, P.icon_state)

	if(possible_targets.len == 0)
		revert_cast()
		to_chat(user, "<span class='warning'>Рядом с вами нет бумаги.</span>")
		return

	target = show_radial_menu(user, user, possible_targets, radius = 36, tooltips = TRUE)
	if(!target)
		revert_cast()
		return
	perform(list(target), user=user)

/obj/effect/proc_holder/spell/create_bless_vote/cast(list/targets, mob/living/carbon/human/user = usr)
	var/obj/item/target = targets[1]
	var/obj/item/weapon/bless_vote/V = new /obj/item/weapon/bless_vote(user.loc)
	V.owner = user
	user.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), (rand(9) + 1) / 10)
	to_chat(src, "<span class='notice'>Ваша кровь растекается по бумаге, образуя символы</span>")
	qdel(target)


/obj/effect/proc_holder/spell/no_target/ancestor_call
	name = "Связь с предками"
	cases = list("Связь с предками", "Связи с предками", "Связи с предками", "Связь с предками", "Связью с предками", "Связи с предками")
	desc = "Попытайтесь связаться с душами предков"
	action_icon_state = "pluvia_call"
	clothes_req = FALSE
	range = -1
	charge_max = 20
	sound = 'sound/magic/heal.ogg'
	var/mob/living/fake_body
	var/target_loc
	var/obj/my_gong

/obj/effect/proc_holder/spell/no_target/ancestor_call/proc/mimic_message(datum/source, message)
	fake_body.say(message)

// todo: refactor holocalls, make this spell holocall
/obj/effect/proc_holder/spell/no_target/ancestor_call/cast(list/targets,mob/living/carbon/human/user = usr)
	if(!fake_body)
		if(available_pluvia_gongs.len == 0)
			to_chat(user, "<span class='warning'>Все линии связи сейчас заняты! Попробуйте позже</span>")
			return
		if(!target_loc)
			my_gong = pick(available_pluvia_gongs)
			target_loc = my_gong.loc
		user.adjustBrainLoss(2)
		available_pluvia_gongs -= my_gong
		fake_body = new /mob/living(target_loc)
		fake_body.appearance = user.appearance
		fake_body.name = user.real_name
		fake_body.alpha = 127
		RegisterSignal(user,COMSIG_HUMAN_SAY, PROC_REF(mimic_message))
		user.reset_view(fake_body, TRUE)
		fake_body.add_remote_hearer(user)
		ADD_TRAIT(user, TRAIT_GLOWING_EYES, REF(src))
		ADD_TRAIT(user, TRAIT_PLUVIAN_BLESSED, REF(src))
		user.update_body(BP_HEAD)
		user.hud_used.set_parallax(PARALLAX_HEAVEN)
	else
		UnregisterSignal(user, list(COMSIG_HUMAN_SAY, COMSIG_PARENT_QDELETING))
		fake_body.remove_remote_hearer(user)
		qdel(fake_body)
		fake_body = null
		target_loc = null
		user.reset_view(null)
		REMOVE_TRAIT(user, TRAIT_GLOWING_EYES, REF(src))
		REMOVE_TRAIT(user, TRAIT_PLUVIAN_BLESSED, REF(src))
		user.update_body(BP_HEAD)
		available_pluvia_gongs += my_gong
		user.hud_used.set_parallax(PARALLAX_CLASSIC)
	user.clear_alert("Звонок")

/obj/structure/pluvia_gong
	name = "Gong"
	desc = "Когда очень-очень нужно связаться с живыми"
	cases = list("Гонг", "Гонга", "Гонгу", "Гонга", "Гонгом", "Гонге")
	icon = 'icons/obj/pluvia_gong.dmi'
	icon_state = "gong"
	anchored = TRUE
	var/next_ring = 0
	var/mob/target

/obj/item/weapon/melee/pluvia_gong_baton
	name = "Gong`s stick"
	desc = "Инструмент для плувийского гонга"
	cases = list("Колотушка для гонга", "Колотушки для гонга", "Колотушке для гонга", "Колотушки для гонга", "Колотушкой для гонга", "Колотушке для гонга")
	icon_state = "mallet"
	item_state_world = "mallet_world"
	item_state = "mallet"

/obj/structure/pluvia_gong/atom_init()
	. = ..()
	available_pluvia_gongs += src

/obj/structure/pluvia_gong/proc/ring(mob/user)
	if(next_ring > world.time)
		to_chat(user, "<span class='notice'>Пожалуйста подождите [round((next_ring - world.time) * 0.1, 0.1)] секунд</span>")
		return
	next_ring = world.time + 30 SECONDS
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in human_list)
		if(H.mind && H != user && ispluvian(H))
			if(istype(H.my_religion, /datum/religion/pluvia) || H.mind.pluvian_blessed)
				possible_targets[H] = image(H.icon, H.icon_state)
				var/mob/living/target = possible_targets[H]
				target.copy_overlays(H)

	visible_message("[bicon(src)] <span class='notice'>[CASE(src, NOMINATIVE_CASE)] гудит от удара [CASE(user, ACCUSATIVE_CASE)].</span>")
	playsound(src, 'sound/effects/bell.ogg', VOL_EFFECTS_MASTER, 75, null)

	if(possible_targets.len == 0)
		to_chat(user, "<span class='warning'>Список активных абонентов пуст</span>")
		return
	target = show_radial_menu(user, user, possible_targets, radius = 36, tooltips = TRUE)
	if(!target)
		return
	target.throw_alert("Звонок", /atom/movable/screen/alert/pluvia_ring)
	target.playsound_local(null, 'sound/effects/bell.ogg', VOL_EFFECTS_MASTER, 75, null)
	for(var/obj/effect/proc_holder/spell/no_target/ancestor_call/S in target.spell_list)
		S.target_loc = src.loc
		S.my_gong = src

/obj/structure/pluvia_gong/attackby(obj/item/I,mob/user)
	if(istype(I,/obj/item/weapon/melee/pluvia_gong_baton))
		ring(user)

ADD_TO_GLOBAL_LIST(/mob/living/simple_animal/ancestor_wisp, pluvian_wisps)
/mob/living/simple_animal/ancestor_wisp
	name = "Wisp"
	real_name = "Wisp"
	cases = list("Светлячок", "Светлячка", "Светлячку", "Светлячка", "Светлячком", "Светлячке")
	desc = "Безобидный светлячок"
	icon = 'icons/mob/mob.dmi'
	icon_state = "wisp"
	icon_living = "wisp"
	stat = CONSCIOUS
	maxHealth = 1
	health = 1
	melee_damage = 0
	speed = 2
	faction = "Station"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_OBSERVER
	invisibility = INVISIBILITY_OBSERVER
	universal_understand = TRUE
	universal_speak = FALSE
	w_class = SIZE_MINUSCULE
	density = FALSE
	ventcrawler = 2
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	unsuitable_atoms_damage = 0
	var/mob/living/carbon/human/my_body

/mob/living/simple_animal/ancestor_wisp/UnarmedAttack(atom/A)
	return

/mob/living/simple_animal/ancestor_wisp/RangedAttack(atom/A, params)
	return

/mob/living/simple_animal/ancestor_wisp/start_pulling(atom/movable/AM)
	return

/mob/living/simple_animal/ancestor_wisp/proc/return_to_heaven()
	set category = "Светлячок"
	set name = "Вернуться в рай"
	set desc = "Возвращает вас обратно в ваше тело"
	death()

/mob/living/simple_animal/ancestor_wisp/atom_init()
	..()
	verbs += /mob/living/simple_animal/ancestor_wisp/proc/return_to_heaven

/mob/living/simple_animal/ancestor_wisp/death()
	. = ..()
	if(mind && my_body)
		mind.transfer_to(my_body)
		verbs -= /mob/living/simple_animal/ancestor_wisp/proc/return_to_heaven
		my_body.hud_used.set_parallax(PARALLAX_HEAVEN)
	qdel(src)

/mob/living/simple_animal/ancestor_wisp/Process_Spacemove(movement_dir = 0)
	return 1

/obj/effect/landmark/ancestor_wisp_start
	name = "ancestor wisp start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER

/obj/structure/moonwell
	name = "Moonwell"
	cases = list("Лунный колодец", "Лунного колодца", "Лунному колодцу", "Лунного колодца", "Лунным колодцем", "Лунном колодце")
	desc = "Ну-ка посмотрим, что там у станционеров."
	icon = 'icons/obj/structures/moonwell.dmi'
	icon_state = "well"
	var/next_wisp = 0
	density = TRUE
	anchored = TRUE

/obj/structure/moonwell/attack_hand(mob/living/carbon/human/user)
	if(user.get_species() in list(PLUVIAN_SPIRIT))
		if(next_wisp > world.time)
			to_chat(user, "<span class='notice'>Пожалуйста подождите [round((next_wisp - world.time) * 0.1, 0.1)] секунд.</span>")
			return
		next_wisp = world.time + 70 SECONDS
		var/turf/T = pick_landmarked_location("ancestor wisp start")
		var/mob/living/simple_animal/ancestor_wisp/new_wisp = new /mob/living/simple_animal/ancestor_wisp(T)
		user.hud_used.set_parallax(PARALLAX_CLASSIC)
		user.mind.transfer_to(new_wisp)
		new_wisp.my_body = user
