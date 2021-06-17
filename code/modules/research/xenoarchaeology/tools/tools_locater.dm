
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GPS Locater - locks into a radio frequency and tracks it

/obj/item/device/beacon_locator
	name = "locater device"
	desc = "Used to scan and locate signals on a particular frequency according ."
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "newpinoff" // pinonfar, pinonmedium, pinonclose, pinondirect, pinonnull
	item_state = "electronic"
	var/frequency = 1459
	var/scan_ticks = 0
	var/obj/item/device/radio/target_radio

/obj/item/device/beacon_locator/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/device/beacon_locator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/beacon_locator/process()
	if(target_radio)
		dir = get_dir(src,target_radio)
		switch(get_dist(src,target_radio))
			if(0 to 3)
				icon_state = "newpinondirect"
			if(4 to 10)
				icon_state = "newpinonclose"
			if(11 to 30)
				icon_state = "newpinonmedium"
			if(31 to INFINITY)
				icon_state = "newpinonfar"
	else
		if(scan_ticks)
			icon_state = "newpinonnull"
			scan_ticks++
			if(prob(scan_ticks * 10))
				spawn(0)
					//set background = 1
					if(SSobj.processing.Find(src))
						//scan radios in the world to try and find one
						var/cur_dist = 999
						for(var/obj/item/device/radio/beacon/R in radio_beacon_list)
							if(R.z == src.z && R.frequency == src.frequency)
								var/check_dist = get_dist(src,R)
								if(check_dist < cur_dist)
									cur_dist = check_dist
									target_radio = R

						scan_ticks = 0
						var/turf/T = get_turf(src)
						if(target_radio)
							T.visible_message("[bicon(src)] [src] [pick("chirps", "chirrups", "cheeps")] happily.")
						else
							T.visible_message("[bicon(src)] [src] [pick("chirps", "chirrups", "cheeps")] sadly.")
		else
			icon_state = "newpinoff"

/obj/item/device/beacon_locator/attack_self(mob/user)
	return interact(user)

/obj/item/device/beacon_locator/interact(mob/user)
	var/dat = ""
	dat += {"
				<A href='byond://?src=\ref[src];reset_tracking=1'>Reset tracker</A><BR>
				Frequency:
				<A href='byond://?src=\ref[src];freq=-10'>-</A>
				<A href='byond://?src=\ref[src];freq=-2'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];freq=2'>+</A>
				<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
				"}

	var/datum/browser/popup = new(user, "locater", "Radio frequency tracker", 300, 150)
	popup.set_content(dat)
	popup.open()

/obj/item/device/beacon_locator/Topic(href, href_list)
	..()
	usr.set_machine(src)

	if(href_list["reset_tracking"])
		scan_ticks = 1
		target_radio = null
	else if(href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if (frequency < 1200 || frequency > 1600)
			new_frequency = sanitize_frequency(new_frequency, 1499)
		frequency = new_frequency

	updateSelfDialog()
