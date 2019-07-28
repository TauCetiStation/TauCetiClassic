/obj/item/weapon/circuitboard/pacman/scrap
	name = "Scrapman Generator Board (PACMAN-type Generator)"
	build_path = /obj/machinery/power/port_gen/pacman/scrap
	board_type = "machine"
	origin_tech = "programming=2:powerstorage=3;phorontech=2;engineering=4"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor = 1)

/datum/design/pacman/scrap
	name = "Scrapman Circuit Board"
	desc = "Scrapman Generator Board (PACMAN-type Generator)"
	id = "scrapman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/scrap
	category = list("Power")

/obj/machinery/power/port_gen/pacman/scrap
	name = "Scrapman Portable Generator"
	icon_state = "portgen_scrap0"
	icon_state_on = "portgen_scrap1"
	sheet_name = "refined scrap"
	sheet_path = /obj/item/stack/sheet/refined_scrap
	power_gen = 5000
	time_per_sheet = 80
	board_path = "/obj/item/weapon/circuitboard/pacman/scrap"

/obj/machinery/power/port_gen/pacman/scrap/overheat()
	explosion(src.loc, 1, 5, 2, -1)
