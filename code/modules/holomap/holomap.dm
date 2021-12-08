var/global/list/holochips = list()
var/global/image/default_holomap = null
var/global/list/holomap_cache = list()
var/global/list/holomap_landmarks = list()    //List for shuttles and other stuff that might be useful

// Transport layers (frequency/encryption pairs) for predefined holochips

var/global/list/nuclear_transport_layer = list()
var/global/list/ert_transport_layer = list()
var/global/list/deathsquad_transport_layer = list()
var/global/list/vox_transport_layer = list()

/datum/action/toggle_holomap
	name = "Toggle holomap"
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE

/datum/action/toggle_holomap/Activate()
	to_chat(owner, "<span class='notice'>You activate the holomap.</span>")
	var/obj/item/holochip/target_holochip = target
	target_holochip.activate_holomap(owner)
	target_holochip = null
	active = TRUE

/datum/action/toggle_holomap/Deactivate()
	var/obj/item/holochip/target_holochip = target
	target_holochip.deactivate_holomap()
	target_holochip = null
	to_chat(owner, "<span class='notice'>You deactivate the holomap.</span>")
	active = FALSE
