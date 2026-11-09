var/global/list/telephones = list()
var/global/new_private_phone_number = 1

ADD_TO_GLOBAL_LIST(/obj/item/device/telephone, telephones)
/obj/item/device/telephone
	name = "telephone"
	cases = list("телефон", "телефона", "телефону", "телефон", "телефоном", "телефоне")
	desc = "Используется для общения между отделами."
	icon = 'icons/obj/device.dmi'
	icon_state = "telephone_full"
	w_class = SIZE_NORMAL

	var/obj/item/device/radio/telephone_handset/handset
	var/obj/item/device/telephone/phone_caller

	var/call_timer
	var/istalking = FALSE

	var/list/recordings = list()
	var/display_numbers = 0

	var/datum/beam/phone_cord = null

	var/phone_frequency = 0

/*
10 - engineering
11 - ce
20 - medbay
21 - cmo
22 - psych
23 - geneticist
24 - virologist
30 - brig
31 - hos
32 - warden
33 - detective
40 - rnd
41 - rd
42 - telecsience
43 - xenobiologist
50 - bridge
51 - captain
52 - hop
53 - iaa
60 - cargo
61 - qm
70-99 - private phone channels
*/

/obj/effect/ebeam/phone_cord
	name = "telephone cord"
	icon_state = "telephone_cord"

/obj/item/device/telephone/atom_init()
	. = ..()

	AddComponent(/datum/component/wrench_to_table, null, CALLBACK(src, PROC_REF(retract_handset)))

	if(!phone_frequency)
		if(global.new_private_phone_number >= 31)
			return INITIALIZE_HINT_QDEL

		phone_frequency = 69 + global.new_private_phone_number
		global.new_private_phone_number++

	handset = new(src)
	handset.telephone = src
	handset.set_frequency(BASIC_PHONE_FREQUENCY + phone_frequency)

/obj/item/device/telephone/proc/retract_handset()
	if(handset)
		if(ismob(handset.loc))
			var/mob/user = handset.loc
			visible_message("<span class='notice'>[user] кладёт [CASE(handset, ACCUSATIVE_CASE)].</span>")
			user.drop_from_inventory(handset, src)
		else
			handset.forceMove(src)

	icon_state = "telephone_full"

	if(phone_cord)
		phone_cord.End()

	SStgui.close_uis(src)
	reject_call()
	if(phone_caller)
		phone_caller.reject_call()

/obj/item/device/telephone/Destroy()
	retract_handset()

	if(handset)
		qdel(handset)
		handset = null

	return ..()

/obj/item/device/telephone/attack_hand(mob/user)
	. = ..()

	if(!isturf(loc))
		return

	if((handset.loc == src) && user.put_in_hands(handset))
		handset.add_fingerprint(user)
		icon_state = "telephone_empty"
		visible_message("<span class='notice'>[user] берёт [CASE(handset, ACCUSATIVE_CASE)].</span>")

		phone_cord = Beam(user, icon_state = "telephone_cord", time = INFINITY, maxdistance = 4, beam_type = /obj/effect/ebeam/phone_cord)

		AddComponent(/datum/component/bounded, user, 0, 2, CALLBACK(src, PROC_REF(resolve_stranded)))

		if(phone_caller)
			approve_call(phone_frequency)
			phone_caller.approve_call(phone_frequency)

	tgui_interact(user)

/obj/item/device/telephone/proc/resolve_stranded(datum/component/bounded/bounds)
	if(get_dist(bounds.master, src) == 3 && !anchored)
		step_towards(bounds.master, src)
		var/dist = get_dist(src, get_turf(bounds.master))
		if(dist >= bounds.min_dist && dist <= bounds.max_dist)
			return TRUE

	retract_handset()
	return TRUE

/obj/item/device/telephone/attackby(obj/item/I, mob/user, params)
	if(I == handset)
		retract_handset()
	else
		return ..()

/obj/item/device/telephone/examine(mob/user)
	. = ..()
	to_chat(user, "Номер: [phone_frequency]")

/obj/item/device/telephone/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telephone", "Телефон")
		ui.open()

/obj/item/device/telephone/tgui_data(mob/user)
	var/list/data = list()
	data["numbers"] = display_numbers
	data["phone_frequency"] = phone_frequency
	data["call_timer"] = timeleft(call_timer)
	data["istalking"] = istalking
	data["recording"] = handset.recording_call
	return data

/obj/item/device/telephone/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("pressnumber")
			var/num = params["number"]
			if(isnum(num))
				press_number(num)
				playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
				return TRUE

		if("clearnumbers")
			clear_numbers()
			playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
			return TRUE

		if("approveprice")
			approve()
			return TRUE

		if("listen_records")
			if(!recordings.len)
				to_chat(usr, "<span class='info'>Автоответчик не имеет записей.</span>")
			else
				to_chat(usr, "<span class='info'>Автоответчик начинает проигрывать записи.</span>")
				play_recordings()

			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
			return TRUE

/obj/item/device/telephone/proc/press_number(num)
	num = clamp(num, 0, 9)
	display_numbers *= 10
	display_numbers += num

	if(display_numbers > 99)
		display_numbers %= 100

/obj/item/device/telephone/proc/clear_numbers()
	display_numbers = 0

	if(phone_caller)
		to_chat(usr, "<span class='info'>Вызов отменён.</span>")
		phone_caller.reject_call()
		reject_call()

/obj/item/device/telephone/proc/approve()
	if(display_numbers < 10 || display_numbers > 99)
		visible_message("<span class='warning'>Номер не существует.</span>")
	try_call(display_numbers)
	display_numbers = 0

/obj/item/device/telephone/proc/try_call(number)
	if(phone_frequency == number)
		return

	for(var/obj/item/device/telephone/T in global.telephones)
		if(T.phone_frequency != number)
			continue

		if(T.phone_caller)
			visible_message("<span class='warning'>В настоящий момент абонент разговаривает.</span>")
		else
			to_chat(usr, "<span class='info'>Устанавливается соединение.</span>")
			T.wait_for(src)
			wait_for(T, i_am_caller = TRUE)
			handset.frequency = BASIC_PHONE_FREQUENCY + number
			handset.listening = TRUE
			handset.broadcasting = TRUE

		break

	visible_message("<span class='warning'>Номер не существует.</span>")

/obj/item/device/telephone/proc/wait_for(obj/item/device/telephone/T, amount = 5, i_am_caller = FALSE)
	if(!istalking && (amount <= 0))
		if(i_am_caller)
			start_recording()
		else
			reject_call()
		return

	phone_caller = T
	amount--

	if(!i_am_caller)
		if(handset.loc != src)
			approve_call(phone_frequency)
			phone_caller.approve_call(phone_frequency)
			return

		flick("telephone_ring", src)
		playsound(src, 'sound/weapons/ring.ogg', VOL_EFFECTS_MASTER, 50, vary = FALSE)
	else if(ismob(handset.loc))
		var/mob/user = handset.loc
		user.playsound_local(null, 'sound/misc/notice2.ogg', VOL_EFFECTS_MASTER, 30, vary = FALSE)

	if(istalking)
		return

	call_timer = addtimer(CALLBACK(src, PROC_REF(wait_for), T, amount, i_am_caller), 3 SECONDS, TIMER_STOPPABLE)

/obj/item/device/telephone/proc/reject_call()
	if(!phone_caller)
		return

	phone_caller = null

	deltimer(call_timer)
	call_timer = null

	istalking = FALSE

	handset.listening = FALSE
	handset.broadcasting = FALSE
	handset.set_frequency(BASIC_PHONE_FREQUENCY + phone_frequency)
	handset.recording_call = FALSE

/obj/item/device/telephone/proc/approve_call(number)
	deltimer(call_timer)

	istalking = TRUE
	handset.set_frequency(BASIC_PHONE_FREQUENCY + number)
	handset.listening = TRUE
	handset.broadcasting = TRUE

/obj/item/device/telephone/proc/start_recording()
	visible_message("<span class='warning'>Абонент не отвечает. Оставьте своё сообщение.</span>")
	handset.recording_call = TRUE
	call_timer = addtimer(CALLBACK(src, PROC_REF(reject_call)), 15 SECONDS, TIMER_STOPPABLE)

/obj/item/device/telephone/proc/play_recordings()
	if(!recordings.len)
		return

	var/recording = recordings[1]
	recordings -= recording

	visible_message("[bicon(src)]<font color=Maroon><B>[CASE(src, NOMINATIVE_CASE)]</B>: [recording]</font>")

	call_timer = addtimer(CALLBACK(src, PROC_REF(play_recordings)), 1 SECONDS, TIMER_STOPPABLE)


/obj/item/device/radio/telephone_handset
	name = "telephone handset"
	cases = list("телефонная трубка", "телефонной трубки", "телефонной трубке", "телефонную трубку", "телефонной трубкой", "телефонной трубке")
	desc = "Хлипкая и дешёвая на ощупь телефонная трубка. Воняет пластиком."
	icon = 'icons/obj/device.dmi'
	icon_state = "telephone_handset"
	item_state = "telephone_handset"
	w_class = SIZE_SMALL

	listening = FALSE
	broadcasting = FALSE

	slot_flags = null

	canhear_range = 0
	grid = TRUE
	freerange = TRUE

	var/recording_call = FALSE

	var/obj/item/device/telephone/telephone

/obj/item/device/radio/telephone_handset/Destroy()
	if(telephone)
		telephone = null
	return ..()

/obj/item/device/radio/telephone_handset/dropped(mob/user)
	if(telephone)
		telephone.retract_handset()

	..()

/obj/item/device/radio/telephone_handset/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()

	if(telephone)
		telephone.retract_handset()

/obj/item/device/radio/telephone_handset/attack_self(mob/user)
	return

/obj/item/device/radio/telephone_handset/attackby(obj/item/I, mob/user, params)
	return

/obj/item/device/radio/telephone_handset/hear_talk(mob/M, msg, verb = "says", datum/language/speaking = null)
	if(recording_call && telephone && telephone.phone_caller)
		telephone.phone_caller.recordings += "\[[worldtime2text()]\] [M.name] [verb], \"[msg]\""
	else
		..()
