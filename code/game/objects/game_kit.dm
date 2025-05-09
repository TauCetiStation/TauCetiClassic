//After lying in a trash pile for countless millenniums, this wonderful thing from Goonstation finally comes back.

/obj/item/weapon/game_kit
	name = "gaming kit"
	desc = "Allows you play chess, checkers, or whichever game involving those pieces."
	icon = 'icons/obj/items.dmi'
	icon_state = "game_kit_red"
	var/selected = null
	var/board_stat = null		//Core string
	var/data = ""
	force = 8
	m_amt = 2000
	g_amt = 1000
	item_state = "sheet-metal"
	w_class = SIZE_SMALL

/obj/item/weapon/game_kit/red
	icon_state = "game_kit_red"
	name = "red gaming kit"

/obj/item/weapon/game_kit/blue
	icon_state = "game_kit_blue"
	name = "blue gaming kit"

/obj/item/weapon/game_kit/purple
	icon_state = "game_kit_purple"
	name = "purple gaming kit"

/obj/item/weapon/game_kit/orange
	icon_state = "game_kit_orange"
	name = "orange gaming kit"

/obj/item/weapon/game_kit/random/atom_init()
	. = ..()
	var/colour = pick("red", "blue", "purple", "orange")
	icon_state = "game_kit_[colour]"
	name = "[colour] gaming kit"

/obj/item/weapon/game_kit/chaplain
	desc = "Allows you to play chess, checkers, or whichever game involving those pieces, even from beyond our world!"
	icon_state = "game_kit_chaplain"

/obj/item/weapon/game_kit/atom_init()
	. = ..()
	//Parts of this terrible string is being changed into codename of pieces, and then - transformed into pictures
	board_stat = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"
	selected = "CW"

/obj/item/weapon/game_kit/MouseDrop(mob/user)
	. = ..()
	if (user == usr && !usr.restrained() && usr.stat == CONSCIOUS && (usr.contents.Find(src) || Adjacent(usr)))
		interact(user)

/obj/item/weapon/game_kit/proc/update()
	var/dat = text("<a href='byond://?src=\ref[];mode=hia'>[]</a> <a href='byond://?src=\ref[];mode=remove'>remove</a> <a href='byond://?src=\ref[];reverse=\ref[src]'>invert board</a> <HR><table style='width: 100%; max-width: 512px; border-collapse: collapse;'>", src, (selected ? text("Selected: []", selected) : "Nothing Selected"), src, src)
	//board interface update
	for (var/y = 1 to 8)
		dat += "<tr style='aspect-ratio: 1 / 1;'>"

		for (var/x = 1 to 8)
			var/color = (y + x) % 2 ? "#999999" : istype(src, /obj/item/weapon/game_kit/chaplain) ? "#a2fad1" : "#ffffff"
			var/piece = copytext(board_stat, ((y - 1) * 8 + x) * 2 - 1, ((y - 1) * 8 + x) * 2 + 1)
			dat += "<td style='background-color:[color]; padding: 0; text-align: center; aspect-ratio: 1 / 1; width: 12.5%;'>"
			if (piece != "BB")
				dat += "<a class='nobg' href='byond://?src=\ref[src];s_board=[x] [y]'><img src=[piece].png style='width: 100%; height: 100%; object-fit: contain;'></a>"  // Сохраняем пропорции изображения
			else
				dat += "<a class='nobg' href='byond://?src=\ref[src];s_board=[x] [y]'><img src=none.png style='width: 100%; height: 100%; object-fit: contain;'></a>"  // Сохраняем пропорции изображения
			dat += "</td>"
		dat += "</tr>"

	//Pieces for people to click and place on the board
	dat += "</table><HR><B>Chips:</B><BR>"
	for (var/piece in list("CB", "CW", "KB", "KW"))
		dat += "<a class='nobg' href='byond://?src=\ref[src];s_piece=[piece]'><img src=[piece].png style='width: 32px; height: 32px; object-fit: contain;'></a>"

	dat += "<HR><B>Chess pieces:</B><BR>"
	for (var/piece in list("WP", "WK", "WQ", "WI", "WN", "WR"))
		dat += "<a class='nobg' href='byond://?src=\ref[src];s_piece=[piece]'><img src=[piece].png style='width: 32px; height: 32px; object-fit: contain;'></a>"
	dat += "<br>"
	for (var/piece in list("BP", "BK", "BQ", "BI", "BN", "BR"))
		dat += "<a class='nobg' href='byond://?src=\ref[src];s_piece=[piece]'><img src=[piece].png style='width: 32px; height: 32px; object-fit: contain;'></a>"
	data = dat

/obj/item/weapon/game_kit/attack_ai(mob/user)
	return interact(user)

/obj/item/weapon/game_kit/chaplain/attack_ai(mob/user)
	return

/obj/item/weapon/game_kit/chaplain/attack_ghost(mob/dead/observer/user)
	set_light(3, 1, "#a2fad1")
	addtimer(CALLBACK(src, .atom/proc/set_light, 0), 10)
	return interact(user)

/obj/item/weapon/game_kit/chaplain/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
	else
		return ..()

/obj/item/weapon/game_kit/interact(mob/user)
	user.machine = src
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/chess)		//Sending pictures to the client
	assets.send(user)
	if (!( data ))
		update()

	var/datum/browser/popup = new(user, "game_kit", "Game Board", 320, 390, ntheme = CSS_THEME_LIGHT)
	popup.set_content(data)
	popup.open()

/obj/item/weapon/game_kit/Topic(href, href_list)
	..()

	if (usr.incapacitated())
		if(!isobserver(usr) || !istype(src, /obj/item/weapon/game_kit/chaplain))
			return

	if (usr.contents.Find(src) || (Adjacent(usr) && istype(loc, /turf)))
		if (href_list["s_piece"])
			selected = href_list["s_piece"]
		else if (href_list["mode"])
			if (href_list["mode"] == "remove")
				selected = "remove"
			else
				selected = null
		else if (href_list["reverse"])
			var/firstpart
			var/secondpart
			for (var/symbol = 65, symbol > 1, symbol-=2)
				firstpart += copytext(board_stat, symbol-2, symbol)

			for (var/symbol = 129, symbol > 65, symbol-=2)
				secondpart += copytext(board_stat, symbol-2, symbol)

			board_stat = secondpart + firstpart

		else if (href_list["s_board"])
			if (!( selected ))
				selected = href_list["s_board"]
			else
				var/tx = text2num(copytext(href_list["s_board"], 1, 2))
				var/ty = text2num(copytext(href_list["s_board"], 3, 4))
				if ((copytext(selected, 2, 3) == " " && length(selected) == 3))
					var/sx = text2num(copytext(selected, 1, 2))
					var/sy = text2num(copytext(selected, 3, 4))
					var/place = ((sy - 1) * 8 + sx) * 2 - 1
					selected = copytext(board_stat, place, place + 2)
					if (place == 1)
						board_stat = text("BB[]", copytext(board_stat, 3, 129))
					else
						if (place == 127)
							board_stat = text("[]BB", copytext(board_stat, 1, 127))
						else
							if (place)
								board_stat = text("[]BB[]", copytext(board_stat, 1, place), copytext(board_stat, place + 2, 129))
					place = ((ty - 1) * 8 + tx) * 2 - 1
					if (place == 1)
						board_stat = text("[][]", selected, copytext(board_stat, 3, 129))
					else
						if (place == 127)
							board_stat = text("[][]", copytext(board_stat, 1, 127), selected)
						else
							if (place)
								board_stat = text("[][][]", copytext(board_stat, 1, place), selected, copytext(board_stat, place + 2, 129))
					selected = null
					playsound(src, 'sound/misc/chess_move.ogg', VOL_EFFECTS_MASTER)
				else
					if (selected == "remove")
						var/place = ((ty - 1) * 8 + tx) * 2 - 1
						if (place == 1)
							board_stat = text("BB[]", copytext(board_stat, 3, 129))
						else
							if (place == 127)
								board_stat = text("[]BB", copytext(board_stat, 1, 127))
							else
								if (place)
									board_stat = text("[]BB[]", copytext(board_stat, 1, place), copytext(board_stat, place + 2, 129))
					else
						if (length(selected) == 2)
							var/place = ((ty - 1) * 8 + tx) * 2 - 1
							if (place == 1)
								board_stat = text("[][]", selected, copytext(board_stat, 3, 129))
							else
								if (place == 127)
									board_stat = text("[][]", copytext(board_stat, 1, 127), selected)
								else
									if (place)
										board_stat = text("[][][]", copytext(board_stat, 1, place), selected, copytext(board_stat, place + 2, 129))
							playsound(src, 'sound/misc/chess_move.ogg', VOL_EFFECTS_MASTER)
		add_fingerprint(usr)
		update()
		for(var/mob/M in viewers(1, src.loc))		//If someone is playing with us - they would see that we made a move.
			if ((M.client && M.machine == src))
				interact(M)
