/area/pluvia_heaven
	name = "Pluvia Heaven"
	icon_state = "unexplored"

/var/global/social_credit_threshold = 5 // не забыть переписать
/var/global/haram_threshold = 5
/var/global/list/available_pluvia_gongs = list()

/mob/living/carbon/human/proc/bless()
	to_chat(src, "<span class='notice'>\ <font size=4>Вам известно, что после смерти вы попадете в рай</span></font>")
	src.blessed = 1
	var/image/eye = image('icons/mob/human_face.dmi', icon_state = "pluvia_ms_s")
	eye.plane = LIGHTING_LAMPS_PLANE
	eye.layer = ABOVE_LIGHTING_LAYER
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
	dat = "<B><font color = ##ff0000>Рекомендательное письмо для прохода в рай</B><BR>"
	if(owner.gender == "female")
		dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете что считаете [owner] достойной попасть в рай после смерти</I><BR><BR>"
	else
		dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете что считаете [owner] достойным попасть в рай после смерти</I><BR><BR>"
	dat += "<I><font color = ##ff0000>Просто поднесите палец к месту для подписи и слегка надколите об шип на бумаге.</I><BR>"
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

/obj/effect/proc_holder/spell/no_target/ancestor_call/cast(list/targets,mob/living/user = usr)
	if(!fake_body)
		if(available_pluvia_gongs.len == 0)
			to_chat(user, "<span class='warning'>Все линии связи сейчас заняты! Попробуйте позже</span>")
			return
		if(!target_loc)
			my_gong = pick(available_pluvia_gongs)
			target_loc = my_gong.loc
		user.adjustBrainLoss(2)
		available_pluvia_gongs -= my_gong
		fake_body = new /mob/living/(target_loc)
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
	user.clear_alert("Звонок")

/obj/structure/pluvia_gong
	name = "Гонг"
	desc = "Когда очень-очень нужно связаться с живыми"

	icon = 'icons/obj/big_bell.dmi'
	icon_state = "lord_Voker"
	var/next_ring = 0
	var/mob/target

/obj/item/weapon/melee/pluvia_gong_baton
	name = "Палочка для гонга"
	desc = ""
	icon_state = "stunbaton"
	item_state = "baton"

/obj/structure/pluvia_gong/atom_init()
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
				possible_targets[H].copy_overlays(H)

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
