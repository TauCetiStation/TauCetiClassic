/obj/machinery/vending/eva
	name = "Hardsuit Kits"
	desc = "Conversion kits for your alien hardsuit needs."
	products = list(
		/obj/item/device/modkit/engineering/tajaran = 5,
		/obj/item/device/modkit/engineering/unathi = 5,
		/obj/item/device/modkit/engineering/skrell = 5,
		/obj/item/device/modkit/engineering/vox = 5,
		/obj/item/device/modkit/atmos/tajaran = 5,
		/obj/item/device/modkit/atmos/unathi = 5,
		/obj/item/device/modkit/atmos/skrell = 5,
		/obj/item/device/modkit/atmos/vox = 5,
		/obj/item/device/modkit/med/tajaran = 5,
		/obj/item/device/modkit/med/unathi = 5,
		/obj/item/device/modkit/med/skrell = 5,
		/obj/item/device/modkit/med/vox = 5,
		/obj/item/device/modkit/sec/tajaran = 5,
		/obj/item/device/modkit/sec/unathi = 5,
		/obj/item/device/modkit/sec/skrell = 5,
		/obj/item/device/modkit/sec/vox = 5,
		/obj/item/device/modkit/mining/tajaran = 5,
		/obj/item/device/modkit/mining/unathi = 5,
		/obj/item/device/modkit/mining/skrell = 5,
		/obj/item/device/modkit/mining/vox = 5,
		/obj/item/device/modkit/science/tajaran = 5,
		/obj/item/device/modkit/science/unathi = 5,
		/obj/item/device/modkit/science/skrell = 5,
		/obj/item/device/modkit/science/vox = 5,
		/obj/item/device/modkit/science/rd/tajaran = 1,
		/obj/item/device/modkit/science/rd/unathi = 1,
		/obj/item/device/modkit/science/rd/skrell = 1,
		/obj/item/device/modkit/science/rd/vox = 1,
		/obj/item/device/modkit/engineering/chief/tajaran = 1,
		/obj/item/device/modkit/engineering/chief/unathi = 1,
		/obj/item/device/modkit/engineering/chief/skrell = 1,
		/obj/item/device/modkit/engineering/chief/vox = 1,
		/obj/item/device/modkit/med/cmo/tajaran = 1,
		/obj/item/device/modkit/med/cmo/unathi = 1,
		/obj/item/device/modkit/med/cmo/skrell = 1,
		/obj/item/device/modkit/med/cmo/vox = 1,
		/obj/item/device/modkit/sec/hos/tajaran = 1,
		/obj/item/device/modkit/sec/hos/unathi = 1,
		/obj/item/device/modkit/sec/hos/skrell = 1,
		/obj/item/device/modkit/sec/hos/vox = 1,
		/obj/item/device/modkit = 10,
	)

/obj/machinery/vending/eva/mining
	name = "Mining Hardsuit Kits"
	desc = "Conversion kits for your alien mining hardsuits."
	icon_state = "evamine"
	products = list(
		/obj/item/device/modkit/mining/tajaran = 3,
		/obj/item/device/modkit/mining/unathi = 3,
		/obj/item/device/modkit/mining/skrell = 3,
		/obj/item/device/modkit/mining/vox = 3,
		/obj/item/device/modkit = 5,
	)

/obj/machinery/vending/eva/engineering
	name = "Engineering Hardsuit Kits"
	desc = "Conversion kits for your alien engineering and atmos hardsuits."
	icon_state = "evaengi"
	// why the fuck do we have CE modifications here, if we don't have xeno-heads? and why are they not in CE's office or sumthin smh.
	products = list(
		/obj/item/device/modkit/engineering/tajaran = 3,
		/obj/item/device/modkit/engineering/unathi = 3,
		/obj/item/device/modkit/engineering/skrell = 3,
		/obj/item/device/modkit/engineering/vox = 3,
		/obj/item/device/modkit/atmos/tajaran = 3,
		/obj/item/device/modkit/atmos/unathi = 3,
		/obj/item/device/modkit/atmos/skrell = 3,
		/obj/item/device/modkit/atmos/vox = 3,
		/obj/item/device/modkit/engineering/chief/tajaran = 1,
		/obj/item/device/modkit/engineering/chief/unathi = 1,
		/obj/item/device/modkit/engineering/chief/skrell = 1,
		/obj/item/device/modkit/engineering/chief/vox = 1,
		/obj/item/device/modkit = 6,
	)
