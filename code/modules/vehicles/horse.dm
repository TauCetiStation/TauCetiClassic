/obj/vehicle/space/spacebike/horse
		name = "Лошадь"
		desc = "Это треть бюджета всего селения"
		icon = 'icons/obj/Events/horse.dmi'
		icon_state = "horse_off"
		land_speed = 2
		bike_icon = "horse"
		kickstand = 0
		light_range = 0
		on = 1
		pixel_x = -5
		pixel_y = -5

/obj/vehicle/space/spacebike/horse/atom_init()
	..()
	turn_on()

/obj/vehicle/space/spacebike/update_icon()
	cut_overlays()
	if(on)
		add_overlay(image('icons/obj/Events/horse.dmi', "[bike_icon]_on_overlay", MOB_LAYER + 1))
		icon_state = "[bike_icon]_on"
	else
		icon_state = "[bike_icon]_off"
