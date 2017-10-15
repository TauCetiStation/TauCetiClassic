/obj/item/weapon/fuel_assembly
	name = "fuel rod assembly"
	icon = 'icons/obj/machines/power/fusion.dmi'
	icon_state = "fuel_assembly"
	layer = 4

	var/percent_depleted = 1
	var/list/rod_quantities = list()
	var/fuel_type = "composite"
	var/fuel_colour
	var/radioactivity = 0
	var/const/initial_amount = 300

/obj/item/weapon/fuel_assembly/atom_init()
	. = ..()

	name = "[fuel_type] fuel rod assembly"
	desc = "A fuel rod for a fusion reactor. This one is made from [fuel_type]."

	icon_state = "blank"
	var/image/I = image(icon, "fuel_assembly")
	I.color = fuel_colour
	overlays += list(I, image(icon, "fuel_assembly_bracket"))
	rod_quantities[fuel_type] = initial_amount

/proc/get_fuel_assembly_by_material(mat)
	switch(mat)
		if("phoron")
			return /obj/item/weapon/fuel_assembly/phoron
		if("deuterium")
			return /obj/item/weapon/fuel_assembly/deuterium
		if("tritium")
			return /obj/item/weapon/fuel_assembly/tritium
		if("metallic hydrogen")
			return /obj/item/weapon/fuel_assembly/hydrogen

/obj/item/weapon/fuel_assembly/phoron
	fuel_type = "phoron"
	fuel_colour = "#999999"
	origin_tech = "materials=3"

/obj/item/weapon/fuel_assembly/deuterium
	fuel_type = "deuterium"
	fuel_colour = "#999999"
	origin_tech = "materials=3"

/obj/item/weapon/fuel_assembly/tritium
	fuel_type = "tritium"
	fuel_colour = "#777777"
	origin_tech = "materials=5"

/obj/item/weapon/fuel_assembly/hydrogen
	fuel_type = "metallic hydrogen"
	fuel_colour = "#e6c5de"
	origin_tech = "materials=6;powerstorage=5;magnets=5"
