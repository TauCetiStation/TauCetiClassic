#define CHARS_PER_LINE 6
#define FONT_SIZE "3"
#define FONT_COLOR "#09f"
#define FONT_STYLE "StatusDisplays"
#define SCROLL_SPEED 2
#define LINE_HEIGHT 0.75

#define AD_LENGTH 100
#define AD_DELAY 120

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer

/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/mode = 5	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer
					// 5 = default N picture
					// 6 = Queue_Mode

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

	frequency = 1435		// radio frequency
	var/supply_display = FALSE		// true if a supply shuttle display
	var/queue_display = FALSE
	var/queue_number = 0

	var/friendc = 0      // track if Friend Computer mode

	maptext_height = 28
	maptext_width = 32
	maptext_y = 3

	var/ad_item_name
	var/obj/effect/ad_part/ad_background
	var/obj/effect/ad_part/ad_item

	var/datum/music_player/chiptune_player

	// new display
	// register for radio system

/obj/machinery/status_display/atom_init()
	. = ..()
	status_display_list += src
	radio_controller.add_object(src, frequency)
	update()

	addtimer(CALLBACK(src, PROC_REF(show_ad_1)), rand(1, AD_DELAY) * AD_LENGTH)

	ad_background = new
	ad_background.layer = layer
	ad_background.maptext_y = 8
	ad_background.maptext_x = -2
	ad_item = new
	ad_item.layer = layer + 0.01

	chiptune_player = new(src, "sound/musical_instruments/synth/space")
	chiptune_player.parse_song_text(/datum/music_composition/cargo_ad::melody)
	chiptune_player.volume = 20

/obj/machinery/status_display/unable_to_play(mob/living/user)
	return FALSE


/obj/machinery/status_display/Destroy()
	status_display_list -= src
	if(radio_controller)
		radio_controller.remove_object(src,frequency)

	QDEL_NULL(ad_background)
	QDEL_NULL(ad_item)

	QDEL_NULL(chiptune_player)
	return ..()

/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return
	update()

/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

// set what is displayed

/obj/machinery/status_display/proc/update()
	if(friendc && mode != 4 && mode != 7)	//Makes all status displays except supply shuttle timer display the eye -- Urist
		set_picture("ai_friend")
		return

	if(mode == 3 && overlays.len)	//Why we must update diplay if picture is already set?
		return

	if(mode != 7)
		vis_contents -= ad_background
		vis_contents -= ad_item
		if(chiptune_player)
			chiptune_player.playing = FALSE

	if(overlays.len && !friendc || mode == 4)
		cut_overlays()

	switch(mode)
		if(0)				//blank
			remove_display()
		if(1)				//emergency shuttle timer
			if(SSshuttle.online)
				var/line1
				var/line2 = get_shuttle_timer()
				if(SSshuttle.location == 1)
					line1 = "-ETD-"
				else
					line1 = "-ETA-"
				if(length_char(line2) > CHARS_PER_LINE)
					line2 = "Error!"
				update_display(line1, line2)
			else
				remove_display()
		if(2)				//custom messages
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext_char(message1+" "+message1, index1, index1+CHARS_PER_LINE)
				var/message1_len = length(message1)
				index1 += SCROLL_SPEED
				if(index1 > message1_len)
					index1 -= message1_len

			if(!index2)
				line2 = message2
			else
				line2 = copytext_char(message2+" "+message2, index2, index2+CHARS_PER_LINE)
				var/message2_len = length_char(message2)
				index2 += SCROLL_SPEED
				if(index2 > message2_len)
					index2 -= message2_len
			update_display(line1, line2)
		if(4)				// supply shuttle timer
			var/line1 = "SUPPLY"
			var/line2
			if(SSshuttle.moving)
				line2 = get_SSshuttle_timer()
				if(length_char(line2) > CHARS_PER_LINE)
					line2 = "Error"
			else
				if(SSshuttle.at_station)
					line2 = "Docked"
				else
					line1 = ""
			update_display(line1, line2)
		if(5)				// default picture
			set_picture("default")
		if(6)
			var/line1 = "Ticket:"
			var/line2 = "-[queue_number]-"
			update_display(line1, line2)
		if(7)
			return

/obj/machinery/status_display/examine(mob/user)
	..()
	switch(mode)
		if(1,2,4)
			to_chat(user, "The display says:<br>&emsp;<xmp>[message1]</xmp><br>&emsp;<xmp>[message2]</xmp>")
		if(7)
			to_chat(user, "Успейте купить [ad_item_name] в магазине <a href='byond://?src=\ref[src];pda_onlineshop=1;referrer_account=[null]'>'[CARGOSHOPNAME]' в КПК</a>!")

/obj/machinery/status_display/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["pda_onlineshop"])

		if(usr.incapacitated())
			return

		var/obj/item/device/pda/PDA = astype(usr, /mob/living/carbon/human)?.get_pda_or_null()
		if(!PDA)
			return

		PDA.open_shop_page(usr)

/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length_char(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length_char(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

/obj/machinery/status_display/proc/set_picture(state)
	picture_state = state
	remove_display()
	add_overlay(image('icons/obj/status_display.dmi', icon_state=picture_state))

/obj/machinery/status_display/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];line-height:[LINE_HEIGHT];font-family:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/status_display/proc/get_shuttle_timer()
	var/timeleft = SSshuttle.timeleft()
	if(timeleft)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/get_SSshuttle_timer()
	if(SSshuttle.moving)
		var/timeleft = round((SSshuttle.eta_timeofday - REALTIMEOFDAY) / 10,1)
		if(timeleft < 0)
			return "Late"
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/remove_display()
	if(overlays.len)
		cut_overlays()
	if(maptext)
		maptext = ""


/obj/machinery/status_display/receive_signal(datum/signal/signal)

	switch(signal.data["command"])
		if("blank")
			mode = 0

		if("shuttle")
			mode = 1

		if("message")
			mode = 2
			set_message(signal.data["msg1"], signal.data["msg2"])

		if("alert")
			mode = 3
			set_picture(signal.data["picture_state"])

		if("supply")
			if(supply_display)
				mode = 4

		if("default")
			mode = 5

		if("queue")
			if(queue_display)
				mode = 6
				if(queue_number < global.ticket_machine_number)
					queue_number++
					playsound(src, 'sound/misc/notice2.ogg', VOL_EFFECTS_MASTER, 100, FALSE)


	update()

/obj/machinery/status_display/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, 2)
	new /obj/item/weapon/shard(loc)
	new /obj/item/weapon/shard(loc)
	// new /obj/item/wallframe/status_display(loc) // TODO add?
	..()

/obj/effect/ad_part
	name = "item ad"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

	icon = 'icons/obj/status_display.dmi'
	icon_state = "ad_middle"

	vis_flags = VIS_INHERIT_ID

/obj/effect/ad_part/singularity_act()
	return

/obj/effect/ad_part/singularity_pull()
	return


/obj/machinery/status_display/proc/show_ad_1(ads_in_a_row = 1)
	if(!global.online_shop_ads || !check_active_cargonauts())
		addtimer(CALLBACK(src, PROC_REF(show_ad_1)), AD_DELAY * AD_LENGTH)
		return

	if(ads_in_a_row < 3) //Show 5 ads in a row
		addtimer(CALLBACK(src, PROC_REF(show_ad_1), ads_in_a_row + 1), AD_LENGTH)
	else
		addtimer(CALLBACK(src, PROC_REF(show_ad_1)), AD_DELAY * AD_LENGTH)

	var/datum/shop_lot/lot = SScargoshop.get_advertisement_lot()
	if(!lot)
		return

	VARSET_IN(src, mode, mode, AD_LENGTH - 1)
	mode = 7

	chiptune_player.playing = TRUE
	INVOKE_ASYNC(chiptune_player, TYPE_PROC_REF(/datum/music_player, playsong), null)
	ad_background.icon_state = "ad_middle"

	vis_contents += ad_background
	flick("ad_start", ad_background)
	addtimer(CALLBACK(src, PROC_REF(show_ad_2)), 26)

/obj/machinery/status_display/proc/show_ad_2()
	var/datum/shop_lot/lot = SScargoshop.get_advertisement_lot()
	if(!lot || (mode != 7))
		vis_contents -= ad_background
		chiptune_player.playing = FALSE
		return

	ad_item_name = lot.name

	var/atom/package = locate(lot.lot_item_ref)
	var/atom/lot_item = package.contents[1]

	var/price = lot.get_discounted_price() + lot.get_delivery_cost()
	price = sanitize("[price]", max_length = 5, trim = TRUE)
	price = {"<div style="font-size:[FONT_SIZE];color:#ebebeb;line-height:[LINE_HEIGHT];font-family:'[FONT_STYLE]';text-align:right;" valign="bottom"> [price]$</div>"}
	ad_background.maptext = price

	ad_item.icon = lot_item.icon
	ad_item.icon_state = lot_item.icon_state
	ad_item.alpha = 255
	ad_item.pixel_y = 32
	ad_item.add_filter("monitor", 1, alpha_mask_filter(y = -32, icon = icon('icons/obj/status_display.dmi', "ad_item_mask")))
	vis_contents += ad_item
	animate(ad_item, pixel_y = 4, time = 5, flags = ANIMATION_PARALLEL)
	animate(ad_item.filters[1], y = -4, time = 5, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(show_ad_3)), 50)

/obj/machinery/status_display/proc/show_ad_3()
	ad_background.maptext = ""
	ad_background.icon_state = "outline"
	flick("ad_end", ad_background)
	ad_item.alpha = 0

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = TRUE
	density = FALSE

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"

/obj/machinery/ai_status_display/atom_init()
	. = ..()
	ai_status_display_list += src

/obj/machinery/ai_status_display/Destroy()
	ai_status_display_list -= src
	return ..()

/obj/machinery/ai_status_display/process()
	if(stat & NOPOWER)
		cut_overlays()
		return

	update()

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/ai_status_display/proc/update()

	if(mode==0) //Blank
		cut_overlays()
		return

	if(mode==1)	// AI emoticon
		switch(emotion)
			if("Very Happy")
				set_picture("ai_veryhappy")
			if("Happy")
				set_picture("ai_happy")
			if("Neutral")
				set_picture("ai_neutral")
			if("Unsure")
				set_picture("ai_unsure")
			if("Confused")
				set_picture("ai_confused")
			if("Sad")
				set_picture("ai_sad")
			if("BSOD")
				set_picture("ai_bsod")
			if("Blank")
				set_picture("ai_off")
			if("Problems?")
				set_picture("ai_trollface")
			if("Awesome")
				set_picture("ai_awesome")
			if("Dorfy")
				set_picture("ai_urist")
			if("Facepalm")
				set_picture("ai_facepalm")
			if("Friend Computer")
				set_picture("ai_friend")
			if("Beer mug")
				set_picture("ai_beer")
			if("Dwarf")
				set_picture("ai_dwarf")
			if("Fishtank")
				set_picture("ai_fishtank")
			if("Plump Helmet")
				set_picture("ai_plump")
			if("HAL")
				set_picture("ai_hal")
			if("Tribunal")
				set_picture("ai_tribunal")
			if("Tribunal Malfunctioning")
				set_picture("ai_tribunal_malf")

		return

	if(mode==2)	// BSOD
		set_picture("ai_bsod")
		return


/obj/machinery/ai_status_display/proc/set_picture(state)
	picture_state = state
	if(overlays.len)
		cut_overlays()
	add_overlay(image('icons/obj/status_display.dmi', icon_state=picture_state))

#undef CHARS_PER_LINE
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
#undef LINE_HEIGHT
