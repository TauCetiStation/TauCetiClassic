/obj/effect/altrune
	name = "rune"
	desc = ""
	anchored = TRUE
	icon = 'icons/obj/rune.dmi'
	unacidable = 1
	layer = TURF_LAYER
	var/datum/altrune/power
	var/disappearance = FALSE

/obj/effect/altrune/atom_init(mapload, mob/user, rand_icon = FALSE)
	. = ..()
	pixel_x = rand(-5,5)
	pixel_y = rand(-5,5)
	icon_state = "[rand(1,6)]"

/obj/effect/altrune/Destroy()
	QDEL_NULL(power)

	return ..()

/obj/effect/altrune/examine(mob/user)
	if(isfanatic(user) || isobserver(user))
		to_chat(user,"<span class='fanatics'>Это же [bicon(src)] кровавая руна!</span>")
		if(!power)
			return
		to_chat(user,"<span class='fanatics'>Именование чар: [power?.name]</span>.")
		to_chat(user,"<span class='fanatics'>[power?.desc]</span>")
		return
	to_chat(user,"[bicon(src)] That's a [name].")

	to_chat(user,"It's a rune. Somebody's being naughty leaving it here.")

/obj/effect/altrune/attack_hand(mob/living/carbon/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(get_dist(user, src) > 1) // anti-telekinesis
		return
	if(disappearance)
		return
	if(iscultist(user))
		user.say(pick("Хаккрутйу гопоенйим.", "Храсаи пивроиашан.", "Фирййи прхив мазенхор.", "Танах ех вакантахе.", "Облияе на ораие.", "Миуф хон внор'с.", "Вакабаи хий фен йусших."))
		to_chat(user, "<span class='cult'>У-упс, не та руна!</span>")
		user.adjustBrainLoss(15)
		return
	if(!isfanatic(user))
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle) || user.silent || HAS_TRAIT(user, TRAIT_MUTE))
		to_chat(user, "<span class='danger'>Вы не можете говорить!</span>")
		return
	if(user.lying)
		to_chat(user, "<span class='danger'>Нужно стоять на ногах!</span>")
		return

	var/static/list/selection = list(
		"Use" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_use"),
		"Trash" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_trash")
	)

	var/choice = show_radial_menu(user, src, selection, tooltips = TRUE)
	if(!choice)
		return

	if(!user.Adjacent(src))
		return

	if(choice == "Trash")
		user.visible_message("<span class='userdanger'>[user] passes his hand over the [bicon(src)] rune, causing it to disappear.</span>", \
		"<span class='fanatics'>Вы уничтожаете руну.</span>")
		disappearance = TRUE
		disappearance()

	else
		power.before_action(user)

/obj/effect/altrune/proc/disappearance()
	add_filter("disappearance", 1, motion_blur_filter(0, 0))
	animate(get_filter("disappearance"), x = 25, y = 25,  time = 4 SECOND)
	animate(src, alpha = 0, time = 2 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 6 SECONDS)

//large runa, cant be removed, can only b drawn on de bridge and can only b used for final ritual

/obj/effect/largerune
	name = "blood rune"
	desc = "Огромная, нарисованная кровью зловещая руна."
	anchored = TRUE
	icon = 'icons/effects/96x96.dmi'
	unacidable = 1
	layer = TURF_LAYER
	var/datum/altrune/power
	icon_state = "rune_large"

/obj/effect/largerune/atom_init(mapload, mob/user, rand_icon = FALSE)
	. = ..()
	pixel_x = -32
	pixel_y = -32
	color = "#bd0101"

/obj/effect/largerune/examine(mob/user)
	. = ..()
	if(isfanatic(user) || isobserver(user))
		to_chat(user,"<span class='fanatics'>[power.desc]</span>")

/obj/effect/largerune/Destroy()
	QDEL_NULL(power)

	return ..()

/obj/effect/largerune/attack_hand(mob/living/carbon/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(get_dist(user, src) > 2)
		return
	if(!isfanatic(user))
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle) || user.silent || HAS_TRAIT(user, TRAIT_MUTE))
		to_chat(user, "<span class='danger'>Вы не можете говорить!</span>")
		return
	if(user.lying)
		to_chat(user, "<span class='danger'>Нужно стоять на ногах!</span>")
		return
	power.before_action(user)
