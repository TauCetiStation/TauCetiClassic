/obj/item/device/taperecorder
	name = "universal recorder"
	desc = "A device that can record up to an hour of dialogue and play it back. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorderidle"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
	m_amt = 60
	g_amt = 30
	var/emagged = FALSE
	var/recording = FALSE
	var/playing = FALSE
	var/timerecorded = FALSE
	var/playsleepseconds = 0
	var/list/storedinfo = new/list()
	var/list/timestamp = new/list()
	var/canprint = TRUE
	flags = CONDUCT
	throwforce = 2
	throw_speed = 4
	throw_range = 20

	var/timer_to_destruct

	var/list/icons_available
	var/icon_directory = 'icons/mob/radial.dmi'

	action_button_name = "Toggle Recorder"

/obj/item/device/taperecorder/Destroy()
	deltimer(timer_to_destruct)
	return ..()

/obj/item/device/taperecorder/proc/update_available_icons()
	icons_available = list()
	if(recording)
		icons_available["Stop Recording"] = image(icon = icon_directory, icon_state = "radial_stop")
	else
		if(!playing)
			icons_available["Record"] = image(icon = icon_directory, icon_state = "radial_start")

	if(playing)
		icons_available["Stop Playback"] = image(icon = icon_directory, icon_state = "radial_stop")
	else
		if(!recording)
			icons_available["Playback Memory"] = image(icon = icon_directory, icon_state = "radial_sound")

	if(!recording && !playing)
		icons_available["Clear Memory"] = image(icon = icon_directory, icon_state = "radial_delet")

	if(canprint && !recording && !playing)
		icons_available["Print Transcript"] = image(icon = icon_directory, icon_state = "radial_print")
	
	if(emagged)
		icons_available["Explode"] = image(icon = icon_directory, icon_state = "radial_hack")
	
	UNSETEMPTY(icons_available)

/obj/item/device/taperecorder/get_current_temperature()
	. = 0
	if(recording || playing)
		. += 10
	if(emagged)
		. += 10

/obj/item/device/taperecorder/hear_talk(mob/living/M, msg, verb="says")
	if(recording)
		timestamp+= timerecorded
		if(isanimal(M) || isIAN(M)) // Temporary fix before refactor. Needs to actually pass languages or something like that here and when we see paper or hear audioplayback it depends whenever we can actually understand that language.
			msg = M.get_scrambled_message(msg)
		if(!msg)
			return

		storedinfo += "\[[time2text(timerecorded * 10,"mm:ss")]\] [M.name] [verb], \"[msg]\""

/obj/item/device/taperecorder/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		recording = FALSE
		to_chat(user, "<span class='warning'>PZZTTPFFFT</span>")
		icon_state = "taperecorderidle"
		return TRUE
	else
		to_chat(user, "<span class='warning'>It is already emagged!</span>")
		return FALSE

/obj/item/device/taperecorder/proc/explode()
	var/turf/T = get_turf(loc)
	if(ismob(loc))
		var/mob/M = loc
		to_chat(M, "<span class='danger'>\The [src] explodes!</span>")
	if(T)
		T.hotspot_expose(700, 125)
		explosion(T, -1, -1, 0, 4)
	qdel(src)
	return

/obj/item/device/taperecorder/proc/start_exp(sec)
	switch(sec)
		if(5)
			visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: This tape recorder will self-destruct in... Five.</font>")
		if(4)
			visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: Four.</font>")
		if(3)
			visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: Three.</font>")
		if(2)
			visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: Two.</font>")
		if(1)
			visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: One.</font>")
		if(0)
			explode()

	timer_to_destruct = addtimer(CALLBACK(src, .proc/start_exp, sec - 1), 1 SECOND, TIMER_STOPPABLE)

/obj/item/device/taperecorder/proc/record()
	if(usr.incapacitated())
		return
	if(emagged)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	icon_state = "taperecorderrecording"
	if(timerecorded < 3600 && !playing)
		to_chat(usr, "<span class='notice'>Recording started.</span>")
		recording = TRUE
		timestamp += timerecorded
		storedinfo += "\[[time2text(timerecorded * 10,"mm:ss")]\] Recording started."
		for(timerecorded, timerecorded < 3600)
			if(!recording)
				break
			timerecorded++
			sleep(10)
		recording = FALSE
		icon_state = "taperecorderidle"
		return
	else
		to_chat(usr, "<span class='notice'>Either your tape recorder's memory is full, or it is currently playing back its memory.</span>")

/obj/item/device/taperecorder/proc/stop()
	if(usr.incapacitated())
		return
	if(emagged)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(recording)
		recording = FALSE
		timestamp += timerecorded
		storedinfo += "\[[time2text(timerecorded * 10,"mm:ss")]\] Recording stopped."
		to_chat(usr, "<span class='notice'>Recording stopped.</span>")
		icon_state = "taperecorderidle"
		return
	else if(playing)
		playing = FALSE
		var/turf/T = get_turf(src)
		T.visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: Playback stopped.</font>")
		icon_state = "taperecorderidle"
		return

/obj/item/device/taperecorder/proc/clear_memory()
	if(usr.incapacitated())
		return
	if(emagged)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(recording || playing)
		to_chat(usr, "<span class='notice'>You can't clear the memory while playing or recording!</span>")
		return
	else
		if(storedinfo)
			storedinfo.Cut()
		if(timestamp)
			timestamp.Cut()
		timerecorded = FALSE
		to_chat(usr, "<span class='notice'>Memory cleared.</span>")
		return

/obj/item/device/taperecorder/proc/playback_memory()
	if(usr.incapacitated())
		return
	if(recording)
		to_chat(usr, "<span class='notice'>You can't playback when recording!</span>")
		return
	if(playing)
		to_chat(usr, "<span class='notice'>You're already playing!</span>")
		return
	playing = TRUE
	icon_state = "taperecorderplaying"
	to_chat(usr, "<span class='notice'>Playing started.</span>")
	for(var/i = 1, timerecorded < 3600, sleep(10 * (playsleepseconds)))
		if(!playing)
			break
		if(storedinfo.len < i)
			break
		var/turf/T = get_turf(src)
		T.visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: [storedinfo[i]]</font>")
		if(storedinfo.len < i + 1)
			playsleepseconds = 1
			sleep(10)
			T = get_turf(src)
			T.visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: End of recording.</font>")
		else
			playsleepseconds = timestamp[i+1] - timestamp[i]
		if(playsleepseconds > 14)
			sleep(10)
			T = get_turf(src)
			T.visible_message("[bicon(src)]<font color=Maroon><B>Tape Recorder</B>: Skipping [playsleepseconds] seconds of silence</font>")
			playsleepseconds = 1
		i++
	icon_state = "taperecorderidle"
	playing = FALSE
	if(emagged)
		start_exp(5)

/obj/item/device/taperecorder/proc/print_transcript()
	if(usr.incapacitated())
		return
	if(emagged)
		to_chat(usr, "<span class='warning'>The tape recorder makes a scratchy noise.</span>")
		return
	if(!canprint)
		to_chat(usr, "<span class='notice'>The recorder can't print that fast!</span>")
		return
	if(recording || playing)
		to_chat(usr, "<span class='notice'>You can't print the transcript while playing or recording!</span>")
		return
	to_chat(usr, "<span class='notice'>Transcript printed.</span>")
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(get_turf(src))
	var/t1 = "<B>Transcript:</B><BR><BR>"
	for(var/i in 1 to storedinfo.len)
		t1 += "[storedinfo[i]]<BR>"
	P.info = t1
	P.name = "Transcript"
	P.update_icon()
	canprint = FALSE
	sleep(300)
	canprint = TRUE

/obj/item/device/taperecorder/attack_self(mob/user)
	update_available_icons()
	if(icons_available)
		var/selection = show_radial_menu(user, src, icons_available, radius = 38, require_near = TRUE, tooltips = TRUE)
		if(!selection)
			return
		switch(selection)
			if("Stop Playback")
				stop()
			if("Stop Recording")  // yes we actually need 2 seperate stops for the same proc- Hopek
				stop()
			if("Record")
				record()
			if("Print Transcript")
				print_transcript()
			if("Playback Memory")
				playback_memory()
			if("Clear Memory")
				clear_memory()
			if("Explode")
				start_exp(5)
