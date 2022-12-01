/obj/machinery/vending/eva
	name = "Hardsuit Kits"
	desc = "Conversion kits for your alien hardsuit needs."
	products = list(
		/obj/item/device/modkit/tajaran = 5,
		/obj/item/device/modkit/unathi = 5,
		/obj/item/device/modkit/skrell = 5,
		/obj/item/device/modkit/vox = 5,
		/obj/item/device/modkit = 10,
	)

/obj/machinery/vending/eva/mining
	name = "Mining Hardsuit Kits"
	desc = "Conversion kits for your alien mining hardsuits."
	icon_state = "evamine"
	products = list(
		/obj/item/device/modkit/tajaran = 3,
		/obj/item/device/modkit/unathi = 3,
		/obj/item/device/modkit/skrell = 3,
		/obj/item/device/modkit/vox = 3,
		/obj/item/device/modkit = 5,
	)

/obj/machinery/vending/eva/engineering
	name = "Engineering Hardsuit Kits"
	desc = "Conversion kits for your alien engineering and atmos hardsuits."
	icon_state = "evaengi"
	// why the fuck do we have CE modifications here, if we don't have xeno-heads? and why are they not in CE's office or sumthin smh.
	products = list(
		/obj/item/device/modkit/tajaran = 3,
		/obj/item/device/modkit/unathi = 3,
		/obj/item/device/modkit/skrell = 3,
		/obj/item/device/modkit/vox = 3,
		/obj/item/device/modkit = 6,
	)
