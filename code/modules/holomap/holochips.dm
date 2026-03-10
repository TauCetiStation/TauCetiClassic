/*
Files of holomap module:
code/modules/holomap/holochip.dm
code/datums/components/holomap.dm
code/modules/holomap/holochips.dm
*/
//Holochip filters for different roles and marker_prefixes
/obj/item/holochip/deathsquad
	desc = "A small holomap module, attached to helmets. There is a NT logo and a skull on its case"
	icon_state = "holochip_nt"

/obj/item/holochip/deathsquad/atom_init(obj/item/I)
	. = ..()
	map.color_filter = HOLOMAP_DEATHSQUAD_COLOR
	map.frequency = SSholomaps.deathsquad_transport_layer["frequency"]
	map.encryption = SSholomaps.deathsquad_transport_layer["encryption"]

/obj/item/holochip/nuclear
	desc = "A small holomap module, attached to helmets."
	icon_state = "holochip_syndi"

/obj/item/holochip/nuclear/atom_init(obj/item/I)
	. = ..()
	map.color_filter = HOLOMAP_NUCLEAR_COLOR
	map.frequency = SSholomaps.nuclear_transport_layer["frequency"]
	map.encryption = SSholomaps.nuclear_transport_layer["encryption"]
/*
/obj/item/holochip/nuclear/handle_markers_extra()
	for(var/obj/machinery/computer/syndicate_station/shuttle in SSholomaps.holomap_landmarks)
		if(!SSholomaps.holomap_cache[shuttle])
			continue
		var/image/I = SSholomaps.holomap_cache[shuttle]
		I.loc = map.activator.holomap_obj
		map.holomap_images += I*/

/obj/item/holochip/ert
	desc = "A small holomap module, attached to helmets. There is a NT logo on it"
	icon_state = "holochip_nt"

/obj/item/holochip/ert/atom_init(obj/item/I)
	. = ..()
	map.color_filter = HOLOMAP_ERT_COLOR
	map.frequency = SSholomaps.ert_transport_layer["frequency"]
	map.encryption = SSholomaps.ert_transport_layer["encryption"]

/obj/item/holochip/vox
/obj/item/holochip/vox/atom_init(obj/item/I)
	. = ..()
	map.color_filter = HOLOMAP_VOX_COLOR
	map.frequency = SSholomaps.vox_transport_layer["frequency"]
	map.encryption = SSholomaps.vox_transport_layer["encryption"]
/*
/obj/item/holochip/vox/handle_markers_extra()
	for(var/obj/machinery/computer/vox_stealth/shuttle in SSholomaps.holomap_landmarks)
		if(!SSholomaps.holomap_cache[shuttle])
			continue
		var/image/I = SSholomaps.holomap_cache[shuttle]
		I.loc = map.activator.holomap_obj
		map.holomap_images += I
*/
/obj/item/holochip/team_red
/obj/item/holochip/team_red/atom_init()
	. = ..()
	map.color_filter = HOLOMAP_TEAM_COLOR
	map.holomap_custom_key = TEAM_NAME_RED
	map.frequency = "[FREQ_TEAM_RED]"

/obj/item/holochip/team_blue
/obj/item/holochip/team_red/atom_init()
	. = ..()
	map.color_filter = HOLOMAP_TEAM_COLOR
	map.holomap_custom_key = TEAM_NAME_BLUE
	map.frequency = "[FREQ_TEAM_BLUE]"
