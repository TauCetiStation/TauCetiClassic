/obj/item/station_map
	name = "Station map"
	desc = "Поможет вам не заблудиться на станции."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "station_map"
	w_class = SIZE_TINY
	var/icon/nanomap = 'nano/images/nanomap_exodus_1_small.png'
	var/nanomap_size = 600

/obj/item/station_map/attack_self(mob/user)
	..()
	user << browse_rsc(nanomap, "nanomap.png")
	sleep(5) // wait for it to load
	var/datum/browser/popup = new(user, "window=[name]", "[name]", nanomap_size-30, nanomap_size, ntheme = CSS_THEME_DARK)
	popup.set_content("<img src='nanomap.png' style='height:100%;width:auto;-ms-interpolation-mode:nearest-neighbor'>")
	popup.open()

/obj/item/station_map/gamma
	icon_state = "gamma"
	nanomap = 'nano/images/nanomap_gamma_1_small.png'

/obj/item/station_map/falcon
	icon_state = "falcon"
	nanomap = 'nano/images/nanomap_falcon_1_small.png'

/obj/item/station_map/prometheus
	icon_state = "prometheus"
	nanomap = 'nano/images/nanomap_prometheus_1_small.png'

/obj/item/station_map/delta
	icon_state = "delta"
	nanomap = 'nano/images/nanomap_delta_1_small.png'
