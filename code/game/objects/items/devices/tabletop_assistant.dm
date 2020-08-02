#define CARD_MODE "Card Mode"
#define GAMEKIT_MODE "Gamekit Mode"
#define DICE_MODE "Dice Mode"
#define REMOVE_CASINO_MODE 0
#define CARD_PICKUP_MODE 1
#define SORT_DECK_MODE 2
#define DEDUCT_CARD_MODE 3
#define CARD_PICK_MODE 4
#define OUTPUT_KIT_MODE 0
#define SAVE_LAYOUT_MODE 1
#define DICE_ROLL_MODE 1

/obj/item/device/tabletop_assistant
	desc = "A little neat thinga-ma-doo to help you in all your tabletopping needs."
	name = "tabletop assistant"
	icon = 'icons/obj/tabletop_assistant.dmi'
	icon_state = "tabletop"
	item_state = "analyzer"
	w_class = ITEM_SIZE_NORMAL
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=2;engineering=2"
	var/data = "" // Is used for UI interaction.
	var/report_time = 0 // So people can't spam with papers.
	var/interaction_time = 0 // So people generally can't spam with interactions.
	var/interaction_mode = 1 // Determines which exact interaction the assistant does.
	var/interaction_number = 1 // Is used everywhere.
	var/dice_sum = 0 // Is used in counting dice results
	var/result_log = "" // A string to output onto paper dice roll's results.
	var/board_stat = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB" // Used for gaming kit interactions.
	var/mode = CARD_MODE // Determines which interaction mode the assistant is in
	var/list/determined_layouts = list("Chess" = "BRBNBIBQBKBIBNBRBPBPBPBPBPBPBPBPBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBWPWPWPWPWPWPWPWPWRWNWIWQWKWIWNWR"
			                          ,"Checkers" = "BBCBBBCBBBCBBBCBCBBBCBBBCBBBCBBBBBCBBBCBBBCBBBCBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBCRBBCRBBCRBBCRBBBBCRBBCRBBCRBBCRCRBBCRBBCRBBCRBB"
			                          ,"Clear" = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB")

/obj/item/device/tabletop_assistant/atom_init()
	. = ..()
	update_icon()

/obj/item/device/tabletop_assistant/update_icon()
	var/icon_temp = initial(icon_state)
	switch(mode)
		if(CARD_MODE)
			icon_temp = "[icon_temp]_card"
		if(GAMEKIT_MODE)
			icon_temp = "[icon_temp]_gamekit"
		if(DICE_MODE)
			icon_temp ="[icon_temp]_dice"
	icon_state = "[icon_temp]_[interaction_mode]"

/obj/item/device/tabletop_assistant/proc/update()
	var/dat = "<CENTER><B>Tabletop Assistant</B></CENTER><BR><a href='?src=\ref[src];mode=1'>[mode]</a><HR>"
	switch(mode)
		if(CARD_MODE)
			dat += "<a href='?src=\ref[src];cardpickup=1'>Card Pick Up Count</a><BR>"
			dat += "<a href='?src=\ref[src];cardremovecasino=1'>Remove \"Casino\" Cards</a><BR>"
			dat += "<a href='?src=\ref[src];cardsort=1'>Sort Card Deck<BR></a>"
			dat += "<a href='?src=\ref[src];carddeductlost=1'>Lost Cards Deduction</a><BR>"
			dat += "<a href='?src=\ref[src];cardtakecertain=1'>Take Certain Card</a><BR>"
			if(interaction_mode == CARD_PICKUP_MODE)
				dat += "<HR>Card pick up amount: [interaction_number]"
		if(GAMEKIT_MODE)
			dat += "<a href='?src=\ref[src];gamekitselect=1'>Select Saved Layout</a><BR>"
			dat += "<a href='?src=\ref[src];gamekitsave=1'>Save Gaming Kit Layout</a><BR>"
			dat += "<a href='?src=\ref[src];gamekitoutput=1'>Output Gaming Kit Layout</a><BR>"
		if(DICE_MODE)
			dat += "<a href='?src=\ref[src];diceroll=1'>Set Dice Roll Number</a><BR>"
			dat += "<a href='?src=\ref[src];diceoutputsum=1'>Output Dice Roll Result</a><BR>"
			dat += "<a href='?src=\ref[src];diceclearsum=1'>Clear Dice Roll Result</a><BR>"
			dat += "<a href='?src=\ref[src];diceoutputresult=1'>Output Dice Roll Result Log</a><BR>"
			dat += "<a href='?src=\ref[src];diceclearresult=1'>Clear Dice Roll Result Log</a><BR>"
			if(dice_sum)
				dat += "<HR>Dice saved result: [dice_sum]"
			if(result_log)
				dat += "<HR><CENTER>Dice Result Log</CENTER>[result_log]"
			if(interaction_mode == DICE_ROLL_MODE) // There can't be any other, but let's be sure
				dat += "<HR>Dice roll amount: [interaction_number]"
	if(report_time > world.time)
		dat += "<HR>Time before next log can be printed: <B>[round((report_time - world.time)/10)]</B> seconds."
	else
		dat += "<HR>The next log can be printed now."
	update_icon()
	data = dat

/obj/item/device/tabletop_assistant/attack_ai(mob/user)
	return interact(user)

/obj/item/device/tabletop_assistant/interact(mob/user)
	user.machine = src
	update()
	user << browse(data, "window=tabletop_assistant")
	onclose(user, "tabletop_assistant")

/obj/item/device/tabletop_assistant/Topic(href, href_list)
	..()

	if(usr.incapacitated())
		return

	if(!(usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))))
		return

	if(href_list["mode"])
		switch(mode)
			if(CARD_MODE)
				mode = GAMEKIT_MODE
			if(GAMEKIT_MODE)
				mode = DICE_MODE
			if(DICE_MODE)
				mode = CARD_MODE
		interaction_mode = 1 // There is no define for any mode that's one. It's just balanced so, the mode 1 of every tabletop assistant mode is the less griefy one.
		interaction_number = 1 // In case somebody sets it to 52 using cards, and tries rolling 52 dice.
	if(href_list["cardpickup"])
		var/unfiltered = input(usr, "Choose card pickup number from 1 to 52", "Tabletop Assistant") as null|num
		if(!unfiltered)
			add_fingerprint(usr)
			interact(usr)
			return
		if(unfiltered > 52)
			to_chat(usr, "<span class='warning'>[unfiltered] is too big of a number for [src] to process.</span>")
			add_fingerprint(usr)
			update()
			return
		if(unfiltered < 1)
			to_chat(usr, "<span class='warning'>[unfiltered] is too small of a number for [src] to process.</span>")
			add_fingerprint(usr)
			interact(usr)
			return
		interaction_number = unfiltered
		interaction_mode = CARD_PICKUP_MODE
		to_chat(usr, "<span class='notice'>[src] now will pick up [interaction_number] amount of cards.</span>")
	if(href_list["cardremovecasino"])
		interaction_mode = REMOVE_CASINO_MODE
		to_chat(usr, "<span class='notice'>[src] now will remove additional cards from the deck.</span>")
	if(href_list["cardsort"])
		interaction_mode = SORT_DECK_MODE
		to_chat(usr, "<span class='notice'>[src] now will sort the card deck out.</span>")
	if(href_list["carddeductlost"])
		interaction_mode = DEDUCT_CARD_MODE
		to_chat(usr, "<span class='notice'>[src] now will print a report on missing cards from the deck.</span>")
	if(href_list["cardtakecertain"])
		interaction_mode = CARD_PICK_MODE
		to_chat(usr, "<span class='notice'>[src] now will try to take out the card you've chosen out of the deck.</span>")
	if(href_list["gamekitselect"])
		var/layout = input(usr,"Choose Layout", "Tabletop Assistant") as null|anything in determined_layouts
		if(!layout)
			add_fingerprint(usr)
			interact(usr)
			return
		board_stat = determined_layouts[layout]
		to_chat(usr, "<span class='notice'>[src] now has [layout] layout chosen.</span>")
	if(href_list["gamekitsave"])
		interaction_mode = SAVE_LAYOUT_MODE
	if(href_list["gamekitoutput"])
		interaction_mode = OUTPUT_KIT_MODE
	if(href_list["diceroll"])
		var/unfiltered = input(usr, "Choose a number of dice to roll from 1 to 20", "Tabletop Assistant") as null|num
		if(!unfiltered)
			add_fingerprint(usr)
			interact(usr)
			return
		if(unfiltered > 20)
			to_chat(usr, "<span class='warning'>[unfiltered] is too big of a number for [src] to process.</span>")
			add_fingerprint(usr)
			update()
			return
		if(unfiltered < 1)
			to_chat(usr, "<span class='warning'>[unfiltered] is too small of a number for [src] to process.</span>")
			add_fingerprint(usr)
			interact(usr)
			return
		interaction_number = unfiltered
		interaction_mode = DICE_ROLL_MODE
		to_chat(usr, "<span class='notice'>[src] now will roll [interaction_number] number of dice.</span>")
	if(href_list["diceoutputsum"])
		usr.visible_message("<span class='notice'>[src] hums and beeps, as calculations are made.</span>", "<span class='notice'>The last saved result is [dice_sum]</span>.")
	if(href_list["diceclearsum"])
		dice_sum = 0
	if(href_list["diceoutputresult"])
		if(report_time > world.time)
			to_chat(usr, "<span class='notice'>[src]'s ink storage is regenerating, please wait.</span>")
			add_fingerprint(usr)
			interact(usr)
			return
		visible_message("<span class='notice'>[src] hums and beeps, as it prints the results.</span>")
		var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
		P.info = result_log
		P.name = "Dice Roll Log"
		P.update_icon()
		report_time = world.time + 100 // Ten seconds delay.
	if(href_list["diceclearresult"])
		result_log = ""
	add_fingerprint(usr)
	interact(usr)

/obj/item/device/tabletop_assistant/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	interact(user)

/obj/item/device/tabletop_assistant/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!isobj(target))
		return
	var/obj/O = target
	if(!(istype(user, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	switch(mode)
		if(CARD_MODE)
			if(istype(O, /obj/item/toy/cards))
				var/obj/item/toy/cards/C = O
				switch(interaction_mode)
					if(CARD_PICKUP_MODE)
						var/obj/item/toy/cardhand/CH = new/obj/item/toy/cardhand(get_turf(src))
						for(var/i in 1 to interaction_number)
							if(C.cards.len < i)
								break
							CH.currenthand += C.cards[1]
							C.cards -= C.cards[1]
						CH.parentdeck = C
						C.update_icon()
					if(REMOVE_CASINO_MODE)
						if(C.cards.len < C.normal_deck_size || C.cards.len > C.normal_deck_size)
							to_chat(user, "<span class='warning'>It seems [C] is not at it's playing size. It's playing size is [C.normal_deck_size]!</span>")
							return
						C.cards = list()
						C.fill_deck(2, 10)
						var/obj/item/toy/cardhand/CH = new/obj/item/toy/cardhand(get_turf(src))
						for(var/i in 2 to 5)
							C.cards -= "[i] of Hearts"
							C.cards -= "[i] of Spades"
							C.cards -= "[i] of Clubs"
							C.cards -= "[i] of Diamonds"
							CH.currenthand += "[i] of Hearts"
							CH.currenthand += "[i] of Spades"
							CH.currenthand += "[i] of Clubs"
							CH.currenthand += "[i] of Diamonds"
						CH.parentdeck = C
						C.update_icon()
						to_chat(user, "<span class='notice'>The [C] has been sorted, with spare cards removed into [CH]</span>")
					if(SORT_DECK_MODE)
						if(C.cards.len < C.normal_deck_size || C.cards.len > C.normal_deck_size)
							to_chat(user, "<span class='warning'>It seems [C] is not at it's playing size. It's playing size is [C.normal_deck_size]!</span>")
							return
						C.cards = list() // Nullifying all the cards before sorting them.
						C.fill_deck(2, 10)
						to_chat(user, "<span class='notice'>The [C] has been sorted</span>")
					if(DEDUCT_CARD_MODE)
						if(report_time > world.time)
							to_chat(user, "<span class='notice'>[src]'s ink storage is regenerating, please wait.</span>")
							return
						var/list/missing_list = C.integrity ^ C.cards
						var/output_message = ""
						if(missing_list.len)
							output_message = "There are <B>[missing_list.len]</B> cards missing. Here is the list of them:<BR><ul>"
							for(var/i in missing_list)
								output_message += "<li><B>[i]</B> is missing."
							output_message += "</ul><BR>"
						else
							output_message = "All required cards are present in the deck."
						visible_message("<span class='notice'>[src] hums and beeps, as it prints the results.</span>")
						var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
						P.info = output_message
						P.name = "Missing Cards Report"
						P.update_icon()
						report_time = world.time + 100 // 10 seconds delay.
					if(CARD_PICK_MODE)
						if(C.cards.len == 0)
							to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
							return
						var/pick_mode = input(user,"Picking Type.", "Tabletop Assistant") as null|anything in list("By Name", "In List")
						var/card_choice
						switch(pick_mode)
							if("By Name")
								card_choice = input(user, "Type in the name of the card you're looking for. Case-sensitive.", "Tabletop Assistant") as null|text
							if("In List")
								card_choice = input(user, "Pick a card out of the deck.", "Tabletop Assistant") as null|anything in C.cards
						if(!card_choice || !(locate(card_choice) in C.cards))
							to_chat(user, "<span class='notice'>There is no card to draw.</span>")
							return
						var/obj/item/toy/singlecard/H = new/obj/item/toy/singlecard(user.loc)
						H.cardname = card_choice
						H.parentdeck = C
						C.cards -= card_choice
						H.pickup(user)
						user.put_in_active_hand(H)
						user.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
						C.update_icon()
		if(GAMEKIT_MODE)
			if(istype(O, /obj/item/weapon/game_kit))
				var/obj/item/weapon/game_kit/G = O
				switch(interaction_mode)
					if(SAVE_LAYOUT_MODE)
						var/choice_name = sanitize_safe(input(user, "Give a name to this layout, please!", "Tabletop Assistant") as null|text, MAX_NAME_LEN)
						if(!choice_name)
							return
						if(choice_name in determined_layouts)
							switch(alert("The name [choice_name] is already taken, override?","Tabletop Assistant.","Yes","No"))
								if("Yes")
									determined_layouts[choice_name] = G.board_stat
								else
									return
						determined_layouts[choice_name] = G.board_stat
						to_chat(user, "<span class='notice'>[G]'s layout has been succesfully saved.</span>")
					if(OUTPUT_KIT_MODE)
						to_chat(user, "<span class='notice'>[G]'s layout has been succesfully loaded.</span>")
						G.board_stat = board_stat
						G.update()
						G.interact(user)
		if(DICE_MODE)
			if(istype(O, /obj/item/weapon/dice))
				if(interaction_mode == DICE_ROLL_MODE)
					if(interaction_time > world.time)
						to_chat(user, "<span class='warning'>[src]'s manipulator needs some time before doing this again.</span>")
						return
					var/obj/item/weapon/dice/D = O
					interaction_time = world.time + interaction_number // A delay of what it'll take to roll the dice.
					result_log += "<ul>"
					for(var/i in 1 to interaction_number)
						D.diceroll()
						dice_sum += D.result
						result_log += "<li>Roll [i]'s result is [D.result]. <span class=\"paper_field\"></span>.<BR>"
						sleep(1)
					result_log += "</ul><BR><B>Total roll sum is [dice_sum]</B><BR><BR>"
					interaction_time = world.time + 30 // Another 3 seconds delay, so people won't spam.
