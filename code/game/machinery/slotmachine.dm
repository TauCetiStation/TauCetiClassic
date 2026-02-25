// Probability of each win, multiplied by max_roll to get the threshold
#define SLOTMACHINE_JACKPOT 0.001
#define SLOTMACHINE_BIG_WIN 0.005
#define SLOTMACHINE_MED_WIN 0.020
#define SLOTMACHINE_SMALL_WIN 0.200

/obj/machinery/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater-off"
	density = TRUE
	anchored = TRUE
	var/balance = 0 // uses gusev caps lol
	var/working = FALSE
	var/max_roll = 1000
	var/plays = 0
	var/cost = 20 // wager

/obj/machinery/slot_machine/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/toy/caps))
		var/obj/item/toy/caps/C = I
		balance += C.capsAmount
		to_chat(user, "<span class='notice'>You put [I] inside [src].</span>")
		playsound(src, 'sound/machines/slots/caps_insert.ogg', VOL_EFFECTS_MASTER)
		qdel(I)
		SStgui.update_uis(src)
		return

/obj/machinery/slot_machine/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/slot_machine/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlotMachine", name)
		ui.open()

/obj/machinery/slot_machine/tgui_data(mob/user)
	var/list/data = list()
	data["working"] = working
	data["plays"] = plays
	data["balance"] = balance
	data["cost"] = cost
	if(working)
		data["busy"] = "Spinning!"
	return data

/obj/machinery/slot_machine/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("spin")
			if(working)
				return TRUE
			if(cost <= 0 || balance < cost)
				return TRUE
			spin()
			return TRUE
		if("cashout")
			if(working)
				return TRUE
			if(balance > 0)
				give_cashout()
			return TRUE
		if("set_cost")
			if(params["bet"])
				cost = clamp(round(text2num(params["bet"])), 20, 1000)
				SStgui.update_uis(src)
			return TRUE

/obj/machinery/slot_machine/proc/spin()
	balance -= cost
	icon_state = "[initial(icon_state)]-on"
	working = TRUE
	playsound(src, 'sound/machines/slots/slots_spin.ogg', VOL_EFFECTS_MASTER)

	sleep(50)
	if(QDELETED(src))
		return
	plays += 1
	var/roll = rand(1, max_roll)
	var/multiplier = 0
	var/congrats = ""
	// it just works
	// Jackpot: 0.1% | Big: 0.5% | Med: 2% | Loss: ~87%
	var/jack = CEIL(SLOTMACHINE_JACKPOT * max_roll)
	var/big = CEIL(SLOTMACHINE_BIG_WIN * max_roll) + jack
	var/med = CEIL(SLOTMACHINE_MED_WIN * max_roll) + big
	var/small = CEIL(SLOTMACHINE_SMALL_WIN * max_roll) + med

	if(roll <= jack)
		congrats = "JAACKPOT!!"
		multiplier = 100
		var/datum/announcement/station/jackpot/A = new
		A.message = "[usr] сорвал джекпот [cost * multiplier] фишек на игровом автомате. Руководство просит победителя вернуться на рабочее место."
		A.play()
	else if(roll <= big)
		congrats = "BIG WIN!!"
		multiplier = 8
	else if(roll <= med)
		congrats = "Winner!"
		multiplier = 4
	else if(roll <= small)
		congrats = "Small Winner!"
		multiplier = 2
	else
		multiplier = 0

	var/win = cost * multiplier

	if(win > 0)
		visible_message("<b>Slot Machine</b> says, \"[congrats] You won [win] credits!\"")
		balance += win
		playsound(src, 'sound/machines/slots/slots_win.ogg', VOL_EFFECTS_MASTER)
	else
		visible_message("<b>Slot Machine</b> says, \"No luck!\"")
		playsound(src, 'sound/machines/slots/slots_nah.ogg', VOL_EFFECTS_MASTER)
	icon_state = "[initial(icon_state)]"
	working = FALSE
	SStgui.update_uis(src)

/obj/machinery/slot_machine/proc/give_cashout()
	new /obj/item/toy/caps(get_turf(src), balance)
	balance = 0
	SStgui.update_uis(src)

#undef JACKPOT
#undef BIG_WIN
#undef MED_WIN
#undef SMALL_WIN
