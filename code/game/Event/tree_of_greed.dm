
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
	var/mob/camera/treeofgreed/overmind = null // tree_of_greed's overmind
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds

/obj/structure/tree_of_greed/atom_init()
	. = ..()
	trees_of_greed_list += src

/obj/structure/tree_of_greed/attack_hand(mob/living/carbon/human/user)
	var/question = sanitize(input(user, "Задайте вопрос древу."))
	for(var/client/X in global.admins)
		to_chat_admin_pm(X,"<span class='adminsay'><span class='prefix'>TREE QUESTION:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservejump=\ref[user]'>JMP</A>): <span class='message emojify linkify'>[question]</span></span>")

/obj/structure/tree_of_greed/proc/create_overmind(client/new_overmind)
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

/// CAMERA MODE

/mob/camera/treeofgreed
	name = "Глаз Древа Мудрости"
	real_name = "Глаз Древа Мудрости"
	desc = "Взор волшебного Древа Мудрости. Оно следит за каждым из нас."
	icon = 'icons/obj/Events/treeofgreed.dmi'
	icon_state = "eye"
	move_speed = 40
	invisibility = 34
	see_invisible = 34
	see_in_dark = 10
	mouse_opacity = MOUSE_OPACITY_ICON
	layer = INFRONT_MOB_LAYER
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	var/obj/structure/tree_of_greed/tree_of_greed_core = null // The tree overmind's core

	var/image/ghostimage = null

/mob/camera/treeofgreed/atom_init()
	ghostimage = image(icon, src, icon_state)
	ghost_sightless_images |= ghostimage //so ghosts can see the blob eye when they disable ghost sight
	updateallghostimages()
	. = ..()



/mob/camera/treeofgreed/movement_delay()
	return

/mob/camera/treeofgreed/Login()
	..()
	sync_mind()
	treeofgreed_help()

/mob/camera/treeofgreed/proc/treeofgreed_help()
	to_chat(src, "<span class='notice'>Вы дерево мудрости!</span>")
	to_chat(src, "Ваш волшебный глаз могут видеть только лепреконы")

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

/*
/mob/camera/treeofgreed/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = FALSE
	var/obj/effect/blob/B = locate() in range(3, NewLoc)
	if(NewLoc && B)
		loc = NewLoc
		return TRUE
*/

/mob/camera/treeofgreed/Destroy()
	if(ghostimage)
		ghost_sightless_images -= ghostimage
		QDEL_NULL(ghostimage)
		updateallghostimages()
	return ..()

// Tree verbs

/mob/camera/treeofgreed/verb/transport_core()
	set category = "Tree Of Greed Verbs"
	set name = "Вернуться к стволу древа"
	set desc = "Возвращает вас назад к стволу"

	if(tree_of_greed_core)
		src.loc = tree_of_greed_core.loc
		to_chat(src, "<span class='notice'>Вы перенеслись к своему стволу!</span>")

/mob/camera/treeofgreed/verb/turnoff_the_vends()
	set category = "Tree Of Greed Verbs"
	set name = "Выключить торговые порталы"
	set desc = "Выключает все торговые порталы"

	if(tree_of_greed_approval)
		tree_of_greed_approval = FALSE
		for(var/obj/machinery/vending/lepr/L in lepr_vends_list)
			L.icon_state = "portal_closed"
		to_chat(src, "<span class='notice'>Вы отключили все торговые автоматы!</span>")
	else
		to_chat(src, "<span class='warning'>Порталы уже отключены!</span>")


/mob/camera/treeofgreed/verb/turnon_the_vends()
	set category = "Tree Of Greed Verbs"
	set name = "Включить торговые порталы"
	set desc = "Включает все торговые порталы"

	if(!tree_of_greed_approval)
		tree_of_greed_approval = TRUE
		for(var/obj/machinery/vending/lepr/L in lepr_vends_list)
			L.icon_state = "portal"
		to_chat(src, "<span class='notice'>Вы включили все торговые автоматы!</span>")
	else
		to_chat(src, "<span class='warning'>Порталы уже включены!</span>")
