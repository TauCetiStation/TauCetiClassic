var/list/GPS_list = list()
/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=2;engineering=2"
	var/gpstag = "COM0"
	var/emped = 0
	var/turf/locked_location

/obj/item/device/gps/atom_init()
	. = ..()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"
	add_overlay("working")

/obj/item/device/gps/Destroy()
	GPS_list.Remove(src)
	return ..()

/obj/item/device/gps/emp_act(severity)
	emped = 1
	cut_overlay("working")
	add_overlay("emp")
	spawn(300)
		emped = 0
		cut_overlay("emp")
		add_overlay("working")

/obj/item/device/gps/attack_self(mob/user)

	var/obj/item/device/gps/t = ""
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"
		if(locked_location && locked_location.loc)
			t += "<BR>Bluespace coordinates saved: [locked_location.loc]"

		for(var/obj/item/device/gps/G in GPS_list)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1)
				t += "<BR>[tracked_gpstag]: ERROR"
			else
				t += "<BR>[tracked_gpstag]: [gps_area.name] ([pos.x], [pos.y], [pos.z])"

	var/datum/browser/popup = new(user, "GPS", name, 600, 450)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"] )
		var/a = uppertext(sanitize_safe(input("Please enter desired tag.", name, input_default(gpstag)) as text, 5))
		if(a && src.loc == usr)
			gpstag = a
			name = "global positioning system ([gpstag])"
			attack_self(usr)

/obj/item/device/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"
