
/obj/item/weapon/circuitboard/miningdrill
	name = "circuit board (mining drill head)"
	build_path = /obj/machinery/mining/drill
	board_type = "machine"
	origin_tech =  "powerstorage=3;programming=3;engineering=4;magnets=4"
	req_components = list(
							/obj/item/weapon/stock_parts/capacitor = 1,
							/obj/item/weapon/stock_parts/cell = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/weapon/stock_parts/scanning_module = 1
							)

/obj/item/weapon/circuitboard/miningdrillbrace
	name = "circuit board (mining drill brace)"
	build_path = /obj/machinery/mining/brace
	board_type = "machine"
	origin_tech = "powerstorage=3;programming=3;engineering=4;magnets=4"
	req_components = list()
