/area/pluvia_heaven
	name = "Pluvia Heaven"
	icon_state = "unexplored"

/var/global/social_credit_threshold = 5 // не забыть переписать
/var/global/haram_threshold = 5
/var/global/list/available_pluvia_gongs = list()
var/global/list/wisp_start_landmark = list()

/turf/simulated/wall/heaven
	icon = 'icons/turf/walls/has_false_walls/wall_heaven.dmi'
	light_color = "#ffffff "
	light_power = 2
	light_range = 2

/turf/simulated/floor/beach/water/waterpool/heaven
	name = "Рай"
	plane = PLANE_SPACE
	light_color = "#ffffff "
	light_power = 2
	light_range = 2

/mob/living/carbon/human/proc/bless()
	to_chat(src, "<span class='notice'>\ <font size=4>Вам известно, что после смерти вы попадете в рай</span></font>")
	blessed = 1
	social_credit = 2
	var/image/eye = image('icons/mob/human_face.dmi', icon_state = "pluvia_ms_s")
	eye.plane = LIGHTING_LAMPS_PLANE
	eye.layer = ABOVE_LIGHTING_LAYER
	ADD_TRAIT(src, TRAIT_SEE_GHOSTS, QUALITY_TRAIT)
	add_overlay(eye)

/obj/item/weapon/bless_vote
	name = "Рекомендательное письмо"
	desc = "Билет до рая."
	w_class = SIZE_TINY
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/mob/living/carbon/human/owner
	var/sign = 0
	var/sign_place = "ПОДПИСАТЬ"

/obj/item/weapon/bless_vote/attack_self(mob/living/carbon/user)
	user.set_machine(src)
	var/dat
	dat = "<B><font color = ##ff0000>Рекомендательное письмо для прохода в рай</font></B><BR>"
	if(owner.gender == FEMALE)
		dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете что считаете [owner] достойной попасть в рай после смерти</font></I><BR><BR>"
	else
		dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете что считаете [owner] достойным попасть в рай после смерти</font></I><BR><BR>"
	dat += "<I><font color = ##ff0000>Просто поднесите палец к месту для подписи и слегка надколите об шип на бумаге.</font></I><BR>"
	dat += "<A href='byond://?src=\ref[src];choice=yes'>[sign_place]</A><BR>"
	var/datum/browser/popup = new(user, "window=bless_vote", "Рекомендательное письмо")
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/bless_vote/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr
	if(href_list["choice"] == "yes")
		if(usr == owner)
			to_chat(usr, "<span class='warning'>Свое письмо нельзя подписывать!</span>")
		else if(sign == 1)
			to_chat(usr, "<span class='notice'>Эта бумага уже подписана</span>")
		else if(H.social_credit > 0)
			to_chat(usr, "<span class='notice'>Подписано!</span>")
			sign_place = H.name
			H.take_certain_bodypart_damage(list(BP_L_ARM, BP_R_ARM), (rand(9) + 1) / 10)
			H.social_credit -= 1
			if(!owner.ismindshielded() && !owner.isloyal())
				owner.social_credit += 1 //@FatFat Возможно стоит добавить налог на подписи от других плувийцев. Типо не +1, а +0.5. Не уверен что это может хорошо повлиять на их социанльые взаимодействия
			sign = 1
			to_chat(owner, "<span class='notice'>Ваш уровень кармы повышен!</span>")
		else
			to_chat(usr, "<span class='notice'>У вас нет права голоса</span>")

/obj/effect/proc_holder/spell/create_bless_vote
	name = "Создание рекомендательного письма"
	range = 1
	charge_max = 0
	clothes_req = FALSE

	action_icon_state = "charge" // не забыть попросить нарисовать эконку для этого спела
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
	desc = "Попытайтесь связаться с душами предков"
	action_icon_state = "commune" // не забыть попросить нарисовать эконку для этого спела
	clothes_req = FALSE
	range = -1
	charge_max = 20
	sound = 'sound/magic/heal.ogg'
	var/mob/living/fake_body
	var/image/eye
	var/target_loc
	var/obj/my_gong

/obj/effect/proc_holder/spell/no_target/ancestor_call/proc/mimic_message(datum/source, message)
	fake_body.say(message)

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
		fake_body.icon = user.icon
		fake_body.icon_state = user.icon_state
		fake_body.copy_overlays(user)
		fake_body.name = user.name
		fake_body.alpha = 127
		RegisterSignal(user,COMSIG_HUMAN_SAY, PROC_REF(mimic_message))
		user.reset_view(fake_body, TRUE)
		user.toggle_telepathy_hear(fake_body)
		eye = image('icons/mob/human_face.dmi',"pluvia_ms_s")
		eye.plane = LIGHTING_LAMPS_PLANE
		eye.layer = ABOVE_LIGHTING_LAYER
		user.add_overlay(eye)
		user.hud_used.set_parallax(PARALLAX_HEAVEN)
	else
		UnregisterSignal(user, list(COMSIG_HUMAN_SAY, COMSIG_PARENT_QDELETING))
		user.remove_remote_hearer(fake_body)
		user.toggle_telepathy_hear(fake_body)
		qdel(fake_body)
		fake_body = null
		target_loc = null
		user.reset_view(null)
		user.cut_overlay(eye)
		available_pluvia_gongs += my_gong
		user.hud_used.set_parallax(PARALLAX_CLASSIC)
	user.clear_alert("Звонок")

/obj/structure/pluvia_gong
	name = "Гонг"
	desc = "Когда очень-очень нужно связаться с живыми"

	icon = 'icons/obj/pluvia_gong.dmi'
	icon_state = "gong"
	var/next_ring = 0
	var/mob/target

/obj/item/weapon/melee/pluvia_gong_baton
	name = "Палочка для гонга"
	desc = ""
	icon_state = "mallet"
	item_state = "mallet"

/obj/structure/pluvia_gong/atom_init()
	. = ..()
	available_pluvia_gongs += src

/obj/structure/pluvia_gong/proc/ring(mob/user)
	if(next_ring > world.time)
		to_chat(user, "<span class='notice'>Please wait [round((next_ring - world.time) * 0.1, 0.1)] seconds before next ring.</span>")
		return
	next_ring = world.time + 30 SECONDS
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in human_list)
		if(H.mind && H != user && ispluvian(H))
			if(istype(H.my_religion, /datum/religion/pluvia) || H.blessed)
				possible_targets[H] = image(H.icon, H.icon_state)
				var/mob/living/target = possible_targets[H]
				target.copy_overlays(H)

	visible_message("[bicon(src)] <span class='notice'>[src] rings, strucken by [user].</span>")
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

/mob/living/simple_animal/ancestor_wisp
	name = "Светлячок"
	real_name = "Светлячок"
	desc = "ЗАСПРАЙТИ МЕНЯ ЗАСПРАЙТИ МЕНЯ ЗАСПРАЙТИ МЕНЯ"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'
	icon_state = "bluemob_2"
	icon_living = "bluemob_2"
	stat = CONSCIOUS
	maxHealth = 1
	health = 1
	melee_damage = 0
	speed = 10
	faction = "Station"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_OBSERVER
	invisibility = INVISIBILITY_OBSERVER
	universal_understand = TRUE
	universal_speak = FALSE
	w_class = SIZE_MINUSCULE
	density = FALSE //если будут жаловаться на имбовость, вернуть TRUE, чтобы в ниж можно было вслепую что-то кидать-стрелять
	min_oxy = 0
	max_tox = 0
	max_co2 = 0
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


/obj/effect/landmark/ancestor_wisp_start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER

/obj/effect/landmark/ancestor_wisp_start/New(loc)
	..()
	wisp_start_landmark += loc

/obj/structure/wisp_tv //я еще не придумал как оформить это визуально
	name = "ПРИДУМАЙ МНЕ ИМЯ"
	desc = "ПРИДУМАЙ МНЕ ОПИСАНИЕ"
	icon = 'icons/obj/computer.dmi'
	icon_state = "security_det"
	var/next_wisp = 0
	density = TRUE

/obj/structure/wisp_tv/attack_hand(mob/living/carbon/human/user)
	if(user.get_species() in list(PLUVIAN_SPIRIT))
		if(next_wisp > world.time)
			to_chat(user, "<span class='notice'>Please wait [round((next_wisp - world.time) * 0.1, 0.1)] seconds before next wisp.</span>")
			return
		next_wisp = world.time + 70 SECONDS
		var/mob/living/simple_animal/ancestor_wisp/new_wisp = new /mob/living/simple_animal/ancestor_wisp(pick(wisp_start_landmark))
		user.hud_used.set_parallax(PARALLAX_CLASSIC)
		user.mind.transfer_to(new_wisp)
		new_wisp.my_body = user
