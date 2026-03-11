// Various tools and handheld engineering devices.

/datum/export/toolbox
	cost = 2
	unit_name = "toolbox"
	export_types = list(/obj/item/weapon/storage/toolbox)

// mechanical toolbox:	22cr
// emergency toolbox:	17-20cr
// electrical toolbox:	36cr
// robust: priceless

// Basic tools
/datum/export/screwdriver
	cost = 1
	unit_name = "screwdriver"
	export_types = list(/obj/item/weapon/screwdriver)
	include_subtypes = FALSE

/datum/export/wrench
	cost = 1
	unit_name = "wrench"
	export_types = list(/obj/item/weapon/wrench)

/datum/export/crowbar
	cost = 1
	unit_name = "crowbar"
	export_types = list(/obj/item/weapon/crowbar)

/datum/export/wirecutters
	cost = 1
	unit_name = "pair"
	message = "of wirecutters"
	export_types = list(/obj/item/weapon/wirecutters)

/datum/export/hand_drill
	cost = 150
	unit_name = "hand drill"
	export_types = list(/obj/item/weapon/multi/hand_drill)
	include_subtypes = FALSE

/datum/export/jaws
	cost = 150
	unit_name = "jaws of life"
	export_types = list(/obj/item/weapon/multi/jaws_of_life)
	include_subtypes = FALSE

/datum/export/multitool
	cost = 150
	unit_name = "multitool"
	export_types = list(/obj/item/device/multitool)
	include_subtypes = FALSE


// Welding tools
/datum/export/weldingtool
	cost = 2
	unit_name = "welding tool"
	export_types = list(/obj/item/weapon/weldingtool)
	include_subtypes = FALSE

/datum/export/weldingtool/industrial
	cost = 4
	unit_name = "industrial welding tool"
	export_types = list(/obj/item/weapon/weldingtool/largetank, /obj/item/weapon/weldingtool/hugetank)


// Fire extinguishers
/datum/export/extinguisher
	cost = 2
	unit_name = "fire extinguisher"
	export_types = list(/obj/item/weapon/reagent_containers/spray/extinguisher)
	include_subtypes = FALSE

/datum/export/extinguisher/mini
	cost = 1
	unit_name = "pocket fire extinguisher"
	export_types = list(/obj/item/weapon/reagent_containers/spray/extinguisher/mini)


// Flashlights
/datum/export/flashlight
	cost = 30
	unit_name = "flashlight"
	export_types = list(/obj/item/device/flashlight)
	include_subtypes = FALSE

/datum/export/flashlight/flare
	cost = 1
	unit_name = "flare"
	export_types = list(/obj/item/device/flashlight/flare)

/datum/export/flashlight/seclite
	cost = 50
	unit_name = "seclite"
	export_types = list(/obj/item/device/flashlight/seclite)

// Analyzers and Scanners
/datum/export/analyzer
	cost = 1
	unit_name = "analyzer"
	export_types = list(/obj/item/device/analyzer)

/datum/export/analyzer/t_scanner
	cost = 2
	unit_name = "t-ray scanner"
	export_types = list(/obj/item/device/t_scanner)


/datum/export/radio
	cost = 1
	unit_name = "radio"
	export_types = list(/obj/item/device/radio)

/datum/export/detective_scanner
	cost = 25
	unit_name = "investigator scanner"
	export_types = list(/obj/item/device/radio)

// High-tech tools.
/datum/export/rcd
	cost = 20
	unit_name = "rapid construction device"
	export_types = list(/obj/item/weapon/rcd)

/datum/export/rcd_ammo
	cost = 3
	unit_name = "compressed matter cardridge"
	export_types = list(/obj/item/weapon/rcd_ammo)

// Kitchen utensils

/datum/export/knife
	cost = 4
	unit_name = "kitchen knife"
	export_types = list(/obj/item/weapon/kitchenknife)

// mining

/datum/export/mining_charge
	cost = 50
	unit_name = "mining charge"
	export_types = list(/obj/item/weapon/mining_charge)

/datum/export/jackhammer
	cost = 120
	unit_name = "sonic jackhammer"
	export_types = list(/obj/item/weapon/pickaxe/drill/jackhammer)

/datum/export/improved_deep_scanner
	cost = 100
	unit_name = "improved deep scanner"
	export_types = list(/obj/item/weapon/mining_scanner/improved)


// misc

/datum/export/cryobag
	cost = 150
	unit_name = "stasis bag"
	export_types = list(/obj/item/bodybag/cryobag)

/datum/export/monkey_cube
	cost = 50
	unit_name = "monkey cube"
	export_types = list(/obj/item/weapon/storage/box/monkeycubes)

/datum/export/toolbox
	cost = 150
	unit_name = "toolbox"
	export_types = list(/obj/item/weapon/storage/toolbox, /obj/item/weapon/storage/toolbox/mechanical, /obj/item/weapon/storage/toolbox/electrical)

/datum/export/beartrap
	cost = 200
	unit_name = "beartrap"
	export_types = list(/obj/item/weapon/legcuffs/beartrap)

/datum/export/splint
	cost = 100
	unit_name = "splint"
	export_types = list(/obj/item/stack/medical/splint)

/datum/export/pda
	cost = 200
	unit_name = "pda"
	export_types = list(/obj/item/device/pda)
	include_subtypes = TRUE

/datum/export/occult
	cost = 100
	unit_name = "occult"
	export_types = list(/obj/item/device/occult_scanner, /obj/item/weapon/occult_pinpointer)

/datum/export/woodenclock
	cost = 100
	unit_name = "woodenclock"
	export_types = list(/obj/item/woodenclock)

/datum/export/modkit
	cost = 150
	unit_name = "modkit"
	export_types = list(/obj/item/device/modkit)
