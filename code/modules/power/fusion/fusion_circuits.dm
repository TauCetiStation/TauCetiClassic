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
	name = "fusion core control console"
	id = "fusion_core_control"
	build_path = /obj/item/weapon/circuitboard/fusion_core_control
	req_tech = list("powerstorage" = 3, "engineering" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)

/datum/design/fusion/fuel_compressor
	name = "fusion fuel compressor"
	id = "fusion_fuel_compressor"
	build_path = /obj/item/weapon/circuitboard/fusion_fuel_compressor

/datum/design/fusion/fuel_control
	name = "fusion fuel control console"
	id = "fusion_fuel_control"
	build_path = /obj/item/weapon/circuitboard/fusion_fuel_control

/datum/design/fusion/gyrotron_control
	name = "gyrotron control console"
	id = "gyrotron_control"
	build_path = /obj/item/weapon/circuitboard/gyrotron_control

/datum/design/fusion/core
	name = "fusion core"
	id = "fusion_core"
	build_path = /obj/item/weapon/circuitboard/fusion_core

/datum/design/fusion/injector
	name = "fusion fuel injector"
	id = "fusion_injector"
	build_path = /obj/item/weapon/circuitboard/fusion_injector
