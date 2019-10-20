/obj/item/weapon/circuitboard/fusion_core_control
	name = "circuit board (fusion core controller)"
	build_path = /obj/machinery/computer/fusion_core_control
	origin_tech = "programming=4;engineering=4"

/obj/item/weapon/circuitboard/fusion_fuel_compressor
	name = "circuit board (fusion fuel compressor)"
	build_path = /obj/machinery/fusion_fuel_compressor
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=4;materials=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator/pico = 2,
							/obj/item/weapon/stock_parts/matter_bin/super = 2,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 5
							)

/obj/item/weapon/circuitboard/fusion_fuel_control
	name = "circuit board (fusion fuel controller)"
	build_path = /obj/machinery/computer/fusion_fuel_control
	origin_tech = "programming=4;engineering=4"

/obj/item/weapon/circuitboard/gyrotron_control
	name = "circuit board (gyrotron controller)"
	build_path = /obj/machinery/computer/gyrotron_control
	origin_tech = "programming=4;engineering=4"

/obj/item/weapon/circuitboard/emitter/gyrotron
	name = "circuit board (gyrotron)"
	build_path = /obj/machinery/power/emitter/gyrotron
	origin_tech = "programming=5;powerstorage=6;engineering=6"

/obj/item/weapon/circuitboard/fusion_core
	name = "internal circuitry (fusion core)"
	build_path = /obj/machinery/power/fusion_core
	board_type = "machine"
	origin_tech = "bluespace=2;magnets=4;powerstorage=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator/pico = 2,
							/obj/item/weapon/stock_parts/micro_laser/ultra = 1,
							/obj/item/weapon/stock_parts/subspace/crystal = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 5
							)

/obj/item/weapon/circuitboard/fusion_injector
	name = "internal circuitry (fusion fuel injector)"
	build_path = /obj/machinery/fusion_fuel_injector
	board_type = "machine"
	origin_tech = "powerstorage=3;engineering=4;materials=4"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator/pico = 2,
							/obj/item/weapon/stock_parts/scanning_module/phasic = 1,
							/obj/item/weapon/stock_parts/matter_bin/super = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/cable_coil = 5
							)

/datum/design/fusion
	name = "Fusion Core Control Console"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "fusion_core_control"
	build_path = /obj/item/weapon/circuitboard/fusion_core_control
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

/datum/design/fusion/fuel_compressor
	name = "Fusion Fuel Compressor"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "fusion_fuel_compressor"
	build_path = /obj/item/weapon/circuitboard/fusion_fuel_compressor
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

/datum/design/fusion/fuel_control
	name = "Fusion Fuel Control Console"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "fusion_fuel_control"
	build_path = /obj/item/weapon/circuitboard/fusion_fuel_control
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

/datum/design/fusion/gyrotron_control
	name = "Gyrotron Control Console"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "gyrotron_control"
	build_path = /obj/item/weapon/circuitboard/gyrotron_control
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

/datum/design/fusion/core
	name = "Fusion Core"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "fusion_core"
	build_path = /obj/item/weapon/circuitboard/fusion_core
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

/datum/design/fusion/injector
	name = "Fusion Fuel Injector"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "fusion_injector"
	build_path = /obj/item/weapon/circuitboard/fusion_injector
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

/datum/design/fusion/emitter/gyrotron
	name = "Circuit Board (Gyrotron)"
	desc = "Part of the R-UST Mk. 8 Tokamak power generator"
	id = "gyrotron"
	build_path = /obj/item/weapon/circuitboard/emitter/gyrotron
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	category = list("Power")

