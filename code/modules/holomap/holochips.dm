//Holochip filters for different roles and marker_prefixes

/obj/item/holochip/deathsquad
	desc = "A small holomap module, attached to helmets. There is a NT logo and a skull on its case"
	icon_state = "holochip_nt"
	color_filter = HOLOMAP_DEATHSQUAD_COLOR

/obj/item/holochip/deathsquad/atom_init(obj/item/I)
	. = ..()
	frequency = deathsquad_transport_layer["frequency"]
	encryption = deathsquad_transport_layer["encryption"]

/obj/item/holochip/nuclear
	desc = "A small holomap module, attached to helmets."
	icon_state = "holochip_syndi"
	color_filter = HOLOMAP_NUCLEAR_COLOR

/obj/item/holochip/nuclear/atom_init(obj/item/I)
	. = ..()
	frequency = nuclear_transport_layer["frequency"]
	encryption = nuclear_transport_layer["encryption"]

/obj/item/holochip/ert
	desc = "A small holomap module, attached to helmets. There is a NT logo on it"
	icon_state = "holochip_nt"
	color_filter = HOLOMAP_ERT_COLOR

/obj/item/holochip/ert/atom_init(obj/item/I)
	. = ..()
	frequency = ert_transport_layer["frequency"]
	encryption = ert_transport_layer["encryption"]
