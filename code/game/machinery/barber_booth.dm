#define HAIRCUT_TIME 35

/obj/machinery/barber_booth
	name = "Barber booth"
	desc = "Automated booth for making haircut of your dream."
	icon = 'icons/obj/machines/barber_booth.dmi'
	icon_state = "booth_on_closed"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 800
	power_channel = EQUIP
	interact_offline = 0
	var/is_payed = FALSE
	var/haircut_price = 300
	var/is_working = FALSE

/obj/machinery/barber_booth/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/barber_booth
	component_parts += new /obj/item/weapon/stock_parts/console_screen
	component_parts += new /obj/item/weapon/stock_parts/manipulator

/obj/machinery/barber_booth/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		to_chat(usr, "<span class='notice'>You broke something!</span>")
		emagged = 1
	else if(istype(W, /obj/item/weapon/wrench))
		anchored = !anchored
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		if(!anchored)
			stat |= NOPOWER
			icon_state = "booth_off"
		else
			stat &= ~NOPOWER
	else if(istype(W, /obj/item/device/pda) && W.GetID())
		if(!is_payed && !is_working)
			var/obj/item/weapon/card/C = W.GetID()
			scan_card(C)
	else if(istype(W, /obj/item/weapon/card/id))
		if(!is_payed && !is_working)
			scan_card(W)
	else if(istype(W, /obj/item/weapon/crowbar))
		if(!panel_open)
			playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
			visible_message("<span class='notice'>[usr] pry open \the [src].</span>", "<span class='notice'>You pry open \the [src].</span>")
			open_machine()
		else
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/item/I in component_parts)
				I.loc = src.loc
			qdel(src)
	else if(istype(W, /obj/item/weapon/screwdriver))
		src.panel_open = !src.panel_open
		to_chat(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		if(panel_open)
			close_machine()
			icon_state = "booth_screwed"
		else
			open_machine()

/obj/machinery/barber_booth/update_icon()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "booth_off"
		return

/obj/machinery/barber_booth/proc/scan_card(obj/item/weapon/card/id/I)
	visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
	if(!station_account)
		return
	var/datum/money_account/D = get_account(I.associated_account_number)
	var/attempt_pin = 0
	if(D.security_level > 0)
		attempt_pin = input("Enter pin code", "Transaction") as num
	if(!attempt_pin)
		D = attempt_account_access(I.associated_account_number, attempt_pin, 2)
	if(!D)
		return
	var/transaction_amount = haircut_price
	if(transaction_amount <= D.money)
		//transfer the money
		D.money -= transaction_amount
		station_account.money += transaction_amount
		//create entries in the two account transaction logs
		var/datum/transaction/T = new()
		T.target_name = "[station_account.owner_name] (via [src.name])"
		T.purpose = "Purchase of haircut"
		T.amount = "[transaction_amount]"
		T.source_terminal = src.name
		T.date = current_date_string
		T.time = worldtime2text()
		D.transaction_log.Add(T)
		T = new()
		T.target_name = D.owner_name
		T.purpose = "Purchase haircut"
		T.amount = "[transaction_amount]"
		T.source_terminal = src.name
		T.date = current_date_string
		T.time = worldtime2text()
		station_account.transaction_log.Add(T)
		is_payed = TRUE
		to_chat(usr, "[bicon(src)]Is payed, you may now use it</span>")
	else
		to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")

/obj/machinery/barber_booth/attack_hand(mob/user)
	if(panel_open)
		return
	if(!anchored)
		return
	else if(state_open)
		close_machine()
	else
		if(!is_working)
			open_machine()
		else
			if(!emagged)
				if(user != occupant)
					to_chat(user, "<span class='notice'> [src.name] is occupied! </span>")
				else
					to_chat(user, "<span class='notice'> You abort the procedure </span>")
					open_machine()
			else
				to_chat(user, "<span class='warning'>It won't budge.</span>")
				return

/obj/machinery/barber_booth/close_machine()
	..()
	if(emagged && prob(75))
		icon_state = "booth_emagged_closed"
	else
		icon_state = "booth_on_closed"
	perform_haircut()

/obj/machinery/barber_booth/proc/perform_haircut()
	if(!(occupant && ishuman(occupant) && is_operational()))
		return
	var/mob/living/carbon/human/M = occupant
	if(M.head && M.head.flags & (BLOCKHAIR|HIDEEARS))
		to_chat(M, "<span class='warning'>Please, take the headgear off!</span>")
		open_machine()
		return
	else
		var/list/hairs = list()
		for(var/x in subtypesof(/datum/sprite_accessory/hair))
			var/datum/sprite_accessory/hair/H = x
			hairs += initial(H.name)
		var/list/fhairs = list()
		for(var/x in subtypesof(/datum/sprite_accessory/facial_hair))
			var/datum/sprite_accessory/facial_hair/H = x
			fhairs += initial(H.name)
		if(emagged)
			is_working = TRUE
			audible_message("[src.name] boozes loudly")
			if(do_after(M, HAIRCUT_TIME, target = M))
				audible_message("[src.name] clanks violently")
				if(prob(50))
					M.apply_damage(35, BRUTE, BP_HEAD)
					M.h_style = "Bald"
					M.f_style = "Shaved"
				else
					M.h_style = pick(hairs)
					M.f_style = pick(fhairs)
				to_chat(M, "<span class='notice'>Enjoy your haircut!</span>" )
				M.update_hair()
				M.check_dna()
				is_payed = FALSE
				is_working = FALSE
				playsound(loc, 'sound/items/Welder2.ogg', 20, 1)
				open_machine()
		else if (is_payed)
			var/new_hair_style = input(occupant, "Please select hair style", "Character Generation")  as null|anything in hairs
			var/new_facial_style = input(occupant, "Please select facial style", "Character Generation")  as null|anything in fhairs
			var/new_hair_color = input("Please select hair color.", "Character Generation",rgb(M.r_hair,M.g_hair,M.b_hair)) as color
			var/new_facial_color = input("Please select facial hair color.", "Character Generation",rgb(M.r_facial,M.g_facial,M.b_facial)) as color
			to_chat(M, "<span class='notice'>Please wait... </span>")
			if(do_after(M, HAIRCUT_TIME, target = M))
				if(new_hair_style)
					M.h_style = new_hair_style
				if(new_facial_style)
					M.f_style = new_facial_style
				if(new_hair_color)
					M.r_hair = hex2num(copytext(new_hair_color, 2, 4))
					M.g_hair = hex2num(copytext(new_hair_color, 4, 6))
					M.b_hair = hex2num(copytext(new_hair_color, 6, 8))
				if(new_facial_color)
					M.r_facial = hex2num(copytext(new_facial_color, 2, 4))
					M.g_facial = hex2num(copytext(new_facial_color, 4, 6))
					M.b_facial = hex2num(copytext(new_facial_color, 6, 8))
				to_chat(M, "<span class='notice'> Enjoy your haircut!</span>" )
				M.update_hair()
				M.check_dna()
				is_payed = FALSE
				is_working = FALSE
				playsound(loc, 'sound/items/Welder2.ogg', 20, 1)
				open_machine()

/obj/machinery/barber_booth/open_machine()
	if(emagged && prob(75))
		icon_state = "booth_emagged_open"
	else
		icon_state = "booth_on_open"
	is_working = FALSE
	..()

/obj/machinery/barber_booth/Destroy()
	dropContents()
	return ..()

#undef HAIRCUT_TIME