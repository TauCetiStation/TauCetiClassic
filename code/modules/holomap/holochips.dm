//Holochip filters for different roles and marker_prefixes

/obj/item/holochip/deathsquad
	desc = "A small holomap module, attached to helmets. There is a NT logo and a skull on its case"
	icon_state = "holochip_nt"
	color_filter = HOLOMAP_DEATHSQUAD_COLOR

/obj/item/holochip/deathsquad/atom_init(obj/item/I)
	. = ..()
	frequency = SSholomaps.deathsquad_transport_layer["frequency"]
	encryption = SSholomaps.deathsquad_transport_layer["encryption"]

/obj/item/holochip/nuclear
	desc = "A small holomap module, attached to helmets."
	icon_state = "holochip_syndi"
	color_filter = HOLOMAP_NUCLEAR_COLOR

/obj/item/holochip/nuclear/atom_init(obj/item/I)
	. = ..()
	frequency = SSholomaps.nuclear_transport_layer["frequency"]
	encryption = SSholomaps.nuclear_transport_layer["encryption"]

/obj/item/holochip/nuclear/handle_markers_extra()
	for(var/obj/machinery/computer/syndicate_station/shuttle in SSholomaps.holomap_landmarks)
		if(!SSholomaps.holomap_cache[shuttle])
			continue
		var/image/I = SSholomaps.holomap_cache[shuttle]
		I.loc = activator.holomap_obj
		holomap_images += I

/obj/item/holochip/ert
	desc = "A small holomap module, attached to helmets. There is a NT logo on it"
	icon_state = "holochip_nt"
	color_filter = HOLOMAP_ERT_COLOR

/obj/item/holochip/ert/atom_init(obj/item/I)
	. = ..()
	frequency = SSholomaps.ert_transport_layer["frequency"]
	encryption = SSholomaps.ert_transport_layer["encryption"]

/obj/item/holochip/vox
	color_filter = HOLOMAP_VOX_COLOR

/obj/item/holochip/vox/atom_init(obj/item/I)
	. = ..()
	frequency = SSholomaps.vox_transport_layer["frequency"]
	encryption = SSholomaps.vox_transport_layer["encryption"]

/obj/item/holochip/vox/handle_markers_extra()
	for(var/obj/machinery/computer/vox_stealth/shuttle in SSholomaps.holomap_landmarks)
		if(!SSholomaps.holomap_cache[shuttle])
			continue
		var/image/I = SSholomaps.holomap_cache[shuttle]
		I.loc = activator.holomap_obj
		holomap_images += I

/obj/item/holochip/team_red
	color_filter = HOLOMAP_TEAM_COLOR
	holomap_custom_key = TEAM_NAME_RED

/obj/item/holochip/team_red/atom_init()
	. = ..()
	frequency = "[FREQ_TEAM_RED]"

/obj/item/holochip/team_blue
	color_filter = HOLOMAP_TEAM_COLOR
	holomap_custom_key = TEAM_NAME_BLUE

/obj/item/holochip/team_red/atom_init()
	. = ..()
	frequency = "[FREQ_TEAM_BLUE]"
