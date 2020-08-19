/obj/machinery/media/receiver/boombox
	name = "Boombox"
	desc = "Tune in and tune out."

	icon='icons/obj/radio.dmi'
	icon_state="radio"

	var/on=0

/obj/machinery/media/receiver/boombox/atom_init()
	. = ..()
	if(on)
		update_on()
	update_icon()

/obj/machinery/media/receiver/boombox/ui_interact(mob/user)
	var/dat = "<TT>"
	dat += {"
				Power: <a href="?src=\ref[src];power=1">[on ? "On" : "Off"]</a><BR>
				Frequency: <A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(media_frequency)]</a><BR>
				"}
	dat+={"</TT>"}

	var/datum/browser/popup = new(user, "radio-recv", "[src]")
	popup.set_content(dat)
	popup.open()

	onclose(user, "radio-recv")

/obj/machinery/media/receiver/boombox/proc/update_on()
	if(on)
		visible_message("\The [src] hisses to life!")
		playing=1
		connect_frequency()
	else
		visible_message("\The [src] falls quiet.")
		playing=0
		disconnect_frequency()

/obj/machinery/media/receiver/boombox/Topic(href,href_list)
	. = ..()
	if(!.)
		return
	if("power" in href_list)
		on = !on
		update_on()
	if("set_freq" in href_list)
		var/newfreq=media_frequency
		if(href_list["set_freq"]!="-1")
			newfreq = text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", src, media_frequency) as null|num
		if(newfreq)
			if(!IS_INTEGER(newfreq))
				newfreq *= 10 // shift the decimal one place
			if(newfreq > 900 && newfreq < 2000) // Between (90.0 and 100.0)
				disconnect_frequency()
				media_frequency = newfreq
				connect_frequency()
			else
				to_chat(usr, "<span class='warning'>Invalid FM frequency. (90.0, 200.0)</span>")
	updateDialog()


/obj/machinery/media/receiver/boombox/wallmount
	name = "Sound System"
	desc = "This plays music for this room."

	icon='icons/obj/radio.dmi'
	icon_state="wallradio"
	anchored=1

/obj/machinery/media/receiver/boombox/wallmount/muzak
	on=1
	media_frequency=1015

/obj/machinery/media/receiver/boombox/wallmount/update_on()
	..()
	if(on)
		icon_state="wallradio-p"
	else
		icon_state="wallradio"
