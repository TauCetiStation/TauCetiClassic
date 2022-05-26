
/// СПАВНПОИНТ ДРЕВА

/obj/structure/tree_of_greed_startingpoint
	name = "СПАВН ДРЕВА МУДРОСТИ"
	desc = "Здесь стартует древо мудрости"
	anchored = TRUE
	layer = GHOST_PLANE
	icon = 'icons/obj/Events/tree_spawner.dmi'
	icon_state = "spawnpoint"
	density = 0
	invisibility = SEE_INVISIBLE_OBSERVER
	mouse_opacity = MOUSE_OPACITY_ICON
	var/mob/camera/treeofgreed/overmind = null // tree_of_greed's overmind

/obj/structure/tree_of_greed_startingpoint/atom_init()
	. = ..()
	trees_of_greed_overmind_list += src

/obj/structure/tree_of_greed_startingpoint/proc/create_overmind(client/new_overmind)
	if(overmind)
		qdel(overmind)
	var/client/C = null
	C = new_overmind
	if(!C)
		return FALSE
	var/mob/camera/treeofgreed/B = new(src.loc)
	B.key = C.key
	B.tree_of_greed_core = src
	src.overmind = B
	return TRUE

/// СТВОЛЫ ДРЕВА

/obj/structure/tree_of_greed
	name = "Таки древо Мудрости"
	desc = "Оно готово ответить тебе на вопросы, <span class='warning'> небесплатно...</span>"
	anchored = TRUE
	layer = 11
	icon = 'icons/obj/flora/tree_of_greed.dmi'
	icon_state = "tree_of_greed"
	pixel_x = -48
	pixel_y = -20
	density = 1
	var/location_name = "Деревня"

/obj/structure/tree_of_greed/atom_init()
	. = ..()
	trees_of_greed_list += src

/obj/structure/tree_of_greed/necropolis
	location_name = "Некрополис"

/obj/structure/tree_of_greed/attack_hand(mob/living/carbon/human/user)
	var/question = sanitize(input(user, "Задайте вопрос древу.") as text|null)
	if(question)
		for(var/obj/structure/tree_of_greed_startingpoint/TR in trees_of_greed_overmind_list)
			if(TR.overmind)
				to_chat(TR.overmind, "<b><span class='notice'>Кто-то в локации [src.location_name] задал вам вопрос!</span></b>")
				to_chat(TR.overmind, "<b>Он спросил: [question]</b>")
/// ВЗОР ДРЕВА

/mob/camera/treeofgreed
	name = "Взор Древа Мудрости"
	real_name = "Взор Древа Мудрости"
	desc = "Взор волшебного Древа Мудрости. Оно следит за каждым из нас."
	icon = 'icons/obj/Events/treeofgreed.dmi'
	icon_state = "eye"
	move_speed = 20
	invisibility = 34
	see_invisible = 34
	see_in_dark = 10
	mouse_opacity = MOUSE_OPACITY_ICON
	layer = INFRONT_MOB_LAYER
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	var/obj/structure/tree_of_greed/tree_of_greed_core = null // The tree overmind's core

	var/image/ghostimage = null

	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1

/mob/camera/treeofgreed/atom_init()
	ghostimage = image(icon, src, icon_state)
	ghost_sightless_images |= ghostimage //so ghosts can see the blob eye when they disable ghost sight
	updateallghostimages()
	. = ..()


/client/proc/TreeMove(n, direct, mob/camera/treeofgreed/user)

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user, direct))
		if(step)
			user.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

/mob/camera/treeofgreed/setLoc(T)
	T = get_turf(T)
	loc = T
	return 1

/*
/mob/camera/treeofgreed/movement_delay()
	return*/

/mob/camera/treeofgreed/Login()
	..()
	sync_mind()
	treeofgreed_help()

/mob/camera/treeofgreed/proc/treeofgreed_help()
	to_chat(src, "<b><span class='notice'>Вы дерево мудрости!</span></b>")
	to_chat(src, "<b>Ваш волшебный глаз могут видеть только лепреконы.</b>")
	to_chat(src, "<b>Слышать вас могут все.</b>")
	to_chat(src, "<b>У вас есть способности. Их можно посмотреть во вкладке Воля Древа.</b>")
	to_chat(src, "<b>Вы можете телепортироваться в Логово Жадности, или к любому из своих стволов.</b>")
	to_chat(src, "<b>Вы можете открыть или закрыть торговые порталы по всему миру.</b>")
	to_chat(src, "<b>Вы можете сделать глобальный анонс..</b>")

/mob/camera/treeofgreed/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(stat)
		return

	treeofgreed_talk(message)

/mob/camera/treeofgreed/proc/treeofgreed_talk(message)
	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if (!message)
		return

	//var/message_a = say_quote(message)
	message = "<span class='say_quote'>звучит в вашей голове:</span> \"<span class='body'>[message]</span>\""
	message = "<font color=\"#EE4000\"><i><span class='game say'>Голос <span class='name'>Древа Мудрости</span> <span class='message'>[message]</span></span></i></font>"

	to_chat(src, message)
	for(var/mob/M as anything in view(8, src))
		if(isobserver(M) || ishuman(M))
			to_chat(M, message)

/mob/camera/treeofgreed/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	return

/mob/camera/treeofgreed/blob_act()
	return

/mob/camera/treeofgreed/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Всё супер")

/mob/camera/treeofgreed/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = FALSE
	//move_speed = 15
	if(NewLoc)
		loc = NewLoc
		return TRUE

/mob/camera/treeofgreed/Destroy()
	if(ghostimage)
		ghost_sightless_images -= ghostimage
		QDEL_NULL(ghostimage)
		updateallghostimages()
	return ..()

// Tree verbs

/mob/camera/treeofgreed/verb/transport_core()
	set category = "Воля Древа"
	set name = "Переместиться в Логово Жадности"
	set desc = "Возвращает вас в Логово Жадности"

	if(tree_of_greed_core)
		src.loc = tree_of_greed_core.loc
		to_chat(src, "<span class='notice'><b>Вы перенеслись в Логово Жадности!</b></span>")

/mob/camera/treeofgreed/verb/transport_tree()
	set category = "Воля Древа"
	set name = "Переместиться к одному из ваших стволов"
	set desc = "Перемещает вас к одному из существующих Древ Мудрости"

	var/list/candidates = list()
	for(var/obj/structure/tree_of_greed/T in trees_of_greed_list)
		candidates += T.location_name
	var/desired_loc = input("Куда переместиться?", "Локация") in candidates
	if(!desired_loc)
		return
	for(var/obj/structure/tree_of_greed/TR in trees_of_greed_list)
		if(TR && TR.location_name == desired_loc)
			src.loc = TR.loc
			to_chat(src, "<span class='notice'><b>Вы переместились. Теперь вы находитесь в локации [desired_loc]</b></span>")

/mob/camera/treeofgreed/verb/turnoff_the_vends()
	set category = "Воля Древа"
	set name = "Выключить торговые порталы"
	set desc = "Выключает все торговые порталы"

	if(tree_of_greed_approval)
		tree_of_greed_approval = FALSE
		for(var/obj/machinery/vending/lepr/L in lepr_vends_list)
			if(!istype(L, /obj/machinery/vending/lepr/ILB))
				L.icon_state = "portal_closed"
		to_chat(src, "<span class='notice'>Вы отключили все торговые автоматы!</span>")
	else
		to_chat(src, "<span class='warning'>Порталы уже отключены!</span>")

/mob/camera/treeofgreed/verb/turnon_the_vends()
	set category = "Воля Древа"
	set name = "Включить торговые порталы"
	set desc = "Включает все торговые порталы."

	if(!tree_of_greed_approval)
		tree_of_greed_approval = TRUE
		for(var/obj/machinery/vending/lepr/L in lepr_vends_list)
			if(!istype(L, /obj/machinery/vending/lepr/ILB))
				L.icon_state = "portal"
		to_chat(src, "<span class='notice'>Вы включили все торговые автоматы!</span>")
	else
		to_chat(src, "<span class='warning'>Порталы уже включены!</span>")

/mob/camera/treeofgreed/verb/turnon_the_vends()
	set category = "Воля Древа"
	set name = "Включить торговые порталы"
	set desc = "Включает все торговые порталы."

	if(!tree_of_greed_approval)
		tree_of_greed_approval = TRUE
		for(var/obj/machinery/vending/lepr/L in lepr_vends_list)
			if(!istype(L, /obj/machinery/vending/lepr/ILB))
				L.icon_state = "portal"
		to_chat(src, "<span class='notice'>Вы включили все торговые автоматы!</span>")
	else
		to_chat(src, "<span class='warning'>Порталы уже включены!</span>")

/mob/camera/treeofgreed/verb/global_announcement_tree()
	set category = "Воля Древа"
	set name = "Сделать глобальное заявление"
	set desc = "Вы можете произнести что-то, что услышат все."

	var/new_msg = sanitize(input(src, "Введите сообщение:") as text|null)
	new_msg = sanitize(new_msg)
	log_say("[key_name(src)] : [new_msg]")

	if(!new_msg)
		return
	for(var/mob/T in player_list)
		to_chat(T, "<br><span class='notice'><b><font size=6>Голос <span class='name'>Древа Мудрости</span> звучит в вашей голове: <i>[new_msg]</i></font></b></span>")
