//Holochip filters for different roles and marker_prefixes

/obj/item/holochip/deathsquad
	desc = "A small holomap module, attached to helmets. There is a NT logo and a skull on its case"
	icon_state = "holochip_nt"
	role_filter = HOLOMAP_FILTER_DEATHSQUAD
	color_filter = HOLOMAP_DEATHSQUAD_COLOR
	marker_prefix = "deathsquad"

/obj/item/holochip/deathsquad/atom_init(obj/item/I)
	. = ..()
	frequency = deathsquad_transport_layer["frequency"]
	encryption = deathsquad_transport_layer["encryption"]

/obj/item/holochip/nuclear
	desc = "A small holomap module, attached to helmets."
	icon_state = "holochip_syndi"
	role_filter = HOLOMAP_FILTER_NUCLEAR
	color_filter = HOLOMAP_NUCLEAR_COLOR
	marker_prefix = "nuclear"

/obj/item/holochip/nuclear/atom_init(obj/item/I)
	. = ..()
	frequency = nuclear_transport_layer["frequency"]
	encryption = nuclear_transport_layer["encryption"]

/obj/item/holochip/ert
	desc = "A small holomap module, attached to helmets. There is a NT logo on it"
	icon_state = "holochip_nt"
	role_filter = HOLOMAP_FILTER_ERT
	color_filter = HOLOMAP_ERT_COLOR
	marker_prefix = "ertc"

/obj/item/holochip/ert/atom_init(obj/item/I)
	. = ..()
	frequency = ert_transport_layer["frequency"]
	encryption = ert_transport_layer["encryption"]
