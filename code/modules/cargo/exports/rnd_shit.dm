//Items from RnD. NOT techs!

/datum/export/rnd/bluespace_crystal
	cost = 10000
	include_subtypes = FALSE
	unit_name = "bluespace crystal"
	export_types = list(/obj/item/bluespace_crystal)

/datum/export/rnd/artificial_bluespace_crystal
	cost = 3000
	unit_name = "artificial bluespace crystal"
	export_types = list(/obj/item/bluespace_crystal/artificial)

/datum/export/rnd/synthetic_flash
	cost = 100
	unit_name = "synthetic flash"
	export_types = list(/obj/item/device/flash/synthetic)

/datum/export/rnd/mass_spectrometer
	cost = 400
	include_subtypes = FALSE
	unit_name = "mass spectrometer"
	export_types = list(/obj/item/device/mass_spectrometer)

/datum/export/rnd/advanced_mass_spectrometer
	cost = 700
	unit_name = "advanced mass spectrometer"
	export_types = list(/obj/item/device/mass_spectrometer/adv)

/datum/export/rnd/slime_extract
	cost = 150
	unit_name = "slime extract"
	export_types = list(/obj/item/slime_extract)
	exclude_types = list(/obj/item/slime_extract/adamantine,
									/obj/item/slime_extract/bluespace)

/datum/export/rnd/slime_extract/get_amount(obj/O)
	var/obj/item/slime_extract/SI = O
	return SI.uses

/datum/export/rnd/slime_extract/adamantine
	cost = 1000
	unit_name = "adamantine slime extract"
	export_types = list(/obj/item/slime_extract/adamantine)
	exclude_types = list()

/datum/export/rnd/slime_extract/bluespace
	cost = 1400
	unit_name = "bluespace slime extract"
	export_types = list(/obj/item/slime_extract/bluespace)
	exclude_types = list()
