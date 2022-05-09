/obj/vehicle/space/spacebike/horse
		name = "horse"
		desc = "≈сли тебе кажетс€ что это корова, € теб€ забаню"
		icon_state = "horse_off"
		land_speed = 2
		bike_icon = "horse"
		kickstand = 0
		light_range = 0
		on = 1

/obj/vehicle/space/spacebike/horse/atom_init()
	..()
	turn_on()

/obj/vehicle/space/spacebike/horse/white
	icon_state ="horseWhite_off"
	bike_icon = "horseWhite"
