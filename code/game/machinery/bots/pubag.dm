/obj/machinery/bot/pubag
	name = "Punching bag"
	desc = "You too weak to punch it"
	icon = 'icons/obj/pubag.dmi'
	icon_state = "pubag"
	layer = 5.0
	density = 1
	anchored = 1
	health = 200
	maxhealth = 300

/obj/machinery/bot/pubag/atom_init()
  . = ..()
  color = list(rand(0, 255), rand(0, 255), rand(0, 255), 255)