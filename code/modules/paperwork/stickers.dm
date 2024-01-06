/obj/item/weapon/paper/sticker
	name = "sticker"
	cases = list("стикер", "стикера", "стикеру", "стикер", "стикером", "стикере")
	desc = "Самоклеящаяся бумага для заметок."
	icon_state = "sticker_yellow"
	slot_flags = null

	free_space = 100

	var/theme_color = "sticker_theme_yellow"

/obj/item/weapon/paper/sticker/yellow
	icon_state = "sticker_yellow"

	theme_color = "sticker_theme_yellow"

/obj/item/weapon/paper/sticker/red
	icon_state = "sticker_red"

	theme_color = "sticker_theme_red"

/obj/item/weapon/paper/sticker/green
	icon_state = "sticker_green"

	theme_color = "sticker_theme_green"

/obj/item/weapon/paper/sticker/blue
	icon_state = "sticker_blue"

	theme_color = "sticker_theme_blue"

/obj/item/weapon/paper/sticker/show_content(mob/user, forceshow = FALSE, forcestars = FALSE, infolinks = FALSE, view = TRUE)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	name = sanitize(name)
	var/data

	if((!(ishuman(user) || isobserver(user) || issilicon(user)) && !forceshow) || forcestars)
		data = "[stars(info)][stamp_text]"
	else
		data = "[infolinks ? info_links : info][stamp_text]"

	if(view)
		var/datum/browser/popup = new(user, "window=[name]", "[name]", 200, 200, ntheme = theme_color)
		popup.set_content(data)
		popup.open()

	return data

/obj/item/weapon/paper/sticker/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(!istype(target, /obj/structure) && !ismachinery(target) && !ismob(target)) return
	if(src.loc != user) return

	var/list/click_params = params2list(params)
	var/matrix/M = matrix()
	M.Turn(rand(-20,20))
	transform = M
	user.drop_from_inventory(src, target.loc, text2num(click_params[ICON_X]) + target.pixel_x - world.icon_size / 2, text2num(click_params[ICON_Y]) + target.pixel_y - world.icon_size / 2)

	AddComponent(/datum/component/bounded, target, 0, 0, CALLBACK(src, PROC_REF(resolve_stranded)))

	return

/obj/item/weapon/paper/sticker/proc/resolve_stranded(datum/component/bounded/bounds)
	if(get_dist(bounds.master, src) == 1 && isturf(loc))
		step_towards(src, bounds.master)
		var/dist = get_dist(src, get_turf(bounds.master))
		if(dist >= bounds.min_dist && dist <= bounds.max_dist)
			return TRUE

	qdel(GetComponent(/datum/component/bounded))
	return TRUE

/obj/item/weapon/stickers
	name = "stickers"
	cases = list("стикеры", "стикеров", "стикерам", "стикеры", "стикерами", "стикерах")
	desc = "Самоклеящаяся бумага для заметок."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stickers_4"

	var/stickers_amount = 20

/obj/item/weapon/stickers/update_icon()
	if(!stickers_amount)
		qdel(src)
		return

	icon_state = "stickers_[ceil(stickers_amount/5)]"

/obj/item/weapon/stickers/MouseDrop(mob/user)
	. = ..()
	if(user == usr && !usr.incapacitated() && Adjacent(usr))
		var/prev_intent = user.a_intent
		user.set_a_intent(INTENT_GRAB)
		attack_hand(user)
		user.set_a_intent(prev_intent)

/obj/item/weapon/stickers/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/stickers/attack_hand(mob/living/user)
	if(user && user.a_intent == INTENT_GRAB)
		return ..()

	var/obj/item/weapon/paper/sticker/S

	switch(stickers_amount)
		if(1 to 5)
			S = new /obj/item/weapon/paper/sticker/blue(src)
		if(6 to 10)
			S = new /obj/item/weapon/paper/sticker/green(src)
		if(11 to 15)
			S = new /obj/item/weapon/paper/sticker/red(src)
		if(16 to 20)
			S = new /obj/item/weapon/paper/sticker/yellow(src)

	if(ishuman(user))
		user.put_in_hands(S)
	else
		S.forceMove(get_turf(src))

	stickers_amount--

	to_chat(user, "<span class='notice'>Вы взяли стикер.</span>")
	add_fingerprint(user)
	update_icon()
