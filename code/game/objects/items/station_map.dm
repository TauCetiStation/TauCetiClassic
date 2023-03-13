/obj/item/station_map
	name = "Station map"
	desc = "Поможет вам не заблудиться на станции."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "station_map"
	w_class = SIZE_TINY
	var/icon/img = 'nano/images/nanomap_exodus_1.png'

/obj/item/station_map/attack_self(mob/user)
	..()
	user << browse_rsc(img, "nanomap.png")
	var/datum/browser/popup = new(user, "window=[name]", "[name]", 700, 700, ntheme = CSS_THEME_DARK)
	popup.set_content("<img src='nanomap.png' style='-ms-interpolation-mode:nearest-neighbor'>")
	popup.open()

/obj/item/station_map/prometheus
	icon_state = "prometheus"
	img = 'nano/images/nanomap_prometheus_1_small.png'
