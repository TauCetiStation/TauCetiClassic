//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/***************************************************************
**						Design Datums						  **
**	All the data for building stuff.                          **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials:
- $metal (/obj/item/stack/metal).
- $glass (/obj/item/stack/glass).
- $phoron (/obj/item/stack/phoron).
- $silver (/obj/item/stack/silver).
- $gold (/obj/item/stack/gold).
- $uranium (/obj/item/stack/uranium).
- $diamond (/obj/item/stack/diamond).
- $Bananium (/obj/item/stack/Bananium).
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

/datum/design                       //Datum for object designs, used in construction
	var/name = "Name"               //Name of the created object.
	var/desc = "Desc"               //Description of the created object.
	var/id = "id"                   //ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/build_type = null           //Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()     //List of materials. Format: "id" = amount.
	var/construction_time           //Amount of time required for building the object
	var/build_path = null           //The file path of the object that gets created
	var/list/category = null        //Primarily used for Mech Fabricators, but can be used for anything
	var/starts_unlocked = FALSE     //If true does not require any technologies and unlocked from the start

///////////////////Computer Boards///////////////////////////////////

/datum/design/seccamera
	name = "Circuit Design (Security)"
	desc = "Allows for the construction of circuit boards used to build security camera computers."
	id = "seccamera"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/security
	category = list("Computer")

/datum/design/telepad_concole
	name = " Circuit Design (Telescience Console) "
	desc = "Allows for the construction of circuit boards used to build telescience computers."
	id = "telepad_concole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_console
	category = list("Computer")

/datum/design/aicore
	name = "Circuit Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore
	category = list("Machine")

/datum/design/aiupload
	name = "Circuit Design (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload
	category = list("Computer")

/datum/design/borgupload
	name = "Circuit Design (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload
	category = list("Computer")

/datum/design/med_data
	name = "Circuit Design (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data
	category = list("Computer")

/datum/design/operating
	name = "Circuit Design (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating
	category = list("Computer")

/datum/design/slime_management
	name = "Circuit Design (Slime management console)"
	desc = "Allows for the construction of circuit boards used to build a slime management console."
	id = "slime_management"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/camera_advanced/xenobio
	category = list("Computer")


/datum/design/pandemic
	name = "Circuit Design (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pandemic
	category = list("Machine")

/datum/design/scan_console
	name = "Circuit Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew
	category = list("Machine")

/datum/design/comconsole
	name = "Circuit Design (Communications)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications
	category = list("Computer")

/datum/design/idcardconsole
	name = "Circuit Design (ID Computer)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card
	category = list("Computer")

/datum/design/crewconsole
	name = "Circuit Design (Crew monitoring computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew
	category = list("Computer")

/datum/design/teleconsole
	name = "Circuit Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter
	category = list("Computer")

/datum/design/secdata
	name = "Circuit Design (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data
	category = list("Computer")

/datum/design/atmosalerts
	name = "Circuit Design (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console."
	id = "atmosalerts"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert
	category = list("Computer")

/datum/design/air_management
	name = "Circuit Design (Atmospheric Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
	id = "air_management"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management
	category = list("Computer")

/datum/design/robocontrol
	name = "Circuit Design (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics
	category = list("Computer")

/datum/design/dronecontrol
	name = "Circuit Design (Drone Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Drone Control console."
	id = "dronecontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/drone_control
	category = list("Computer")

/datum/design/clonecontrol
	name = "Circuit Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning
	category = list("Computer")

/datum/design/clonepod
	name = "Circuit Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod
	category = list("Machine")

/datum/design/clonescanner
	name = "Circuit Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner
	category = list("Machine")

/datum/design/arcademachine
	name = "Circuit Design (Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new arcade machine."
	id = "arcademachine"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade
	category = list("Computer")

/datum/design/powermonitor
	name = "Circuit Design (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor."
	id = "powermonitor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor
	category = list("Computer")

/datum/design/solarcontrol
	name = "Circuit Design (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console."
	id = "solarcontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control
	category = list("Computer")

/datum/design/prisonmanage
	name = "Circuit Design (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner
	category = list("Computer")

/datum/design/mechacontrol
	name = "Circuit Design (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control
	category = list("Computer")

/datum/design/mechrecharger
	name = "circuit board (Mechbay Recharger)"
	desc = "Allows for the construction of circuit boards used to build a mechbay recharger."
	id = "mechrecharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger
	category = list("Mech")

/datum/design/mechapower
	name = "Circuit Design (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console
	category = list("Mech")

/datum/design/rdconsole
	name = "Circuit Design (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole
	category = list("Computer")

/datum/design/ordercomp
	name = "Circuit Design (Supply ordering console)"
	desc = "Allows for the construction of circuit boards used to build a Supply ordering console."
	id = "ordercomp"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/computer/cargo/request
	category = list("Computer")

/datum/design/supplycomp
	name = "Circuit Design (Supply shuttle console)"
	desc = "Allows for the construction of circuit boards used to build a Supply shuttle console."
	id = "supplycomp"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/computer/cargo
	category = list("Computer")

/datum/design/comm_monitor
	name = "Circuit Design (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor
	category = list("Telecomms")

/datum/design/comm_server
	name = "Circuit Design (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server
	category = list("Telecomms")

/datum/design/message_monitor
	name = "Circuit Design (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/message_monitor
	category = list("Telecomms")

/datum/design/aifixer
	name = "Circuit Design (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aifixer
	category = list("AI")

/datum/design/libraryconsole
	name = "Computer Design (Library Console)"
	desc = "Allows for the construction of circuit boards used to build a new library console."
	id = "libraryconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/libraryconsole
	category = list("Computer")

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
/datum/design/safeguard_module
	name = "AI Module(Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/safeguard
	category = list("AI")

/datum/design/onehuman_module
	name = "AI Module (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/oneHuman
	category = list("AI")

/datum/design/protectstation_module
	name = "AI Module (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/protectStation
	category = list("AI")

/datum/design/notele_module
	name = "AI Module (TeleporterOffline Module)"
	desc = "Allows for the construction of a TeleporterOffline AI Module."
	id = "notele_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/teleporterOffline
	category = list("AI")

/datum/design/quarantine_module
	name = "AI Module (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/quarantine
	category = list("AI")

/datum/design/oxygen_module
	name = "AI Module (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/oxygen
	category = list("AI")

/datum/design/freeform_module
	name = "AI Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/freeform
	category = list("AI")

/datum/design/reset_module
	name = "AI Module (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/reset
	category = list("AI")

/datum/design/purge_module
	name = "AI Module (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/purge
	category = list("AI")

/datum/design/freeform/core_module
	name = "AI Core Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/freeform/core
	category = list("AI")

/datum/design/asimov
	name = "AI Core Module (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/asimov
	category = list("AI")

/datum/design/paladin_module
	name = "AI Core Module (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/paladin
	category = list("AI")

/datum/design/tyrant_module
	name = "AI Core Module (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/tyrant
	category = list("AI")



///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////
/datum/design/subspace_receiver
	name = "Circuit Design (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/receiver
	category = list("Telecomms")

/datum/design/telecomms_bus
	name = "Circuit Design (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/bus
	category = list("Telecomms")

/datum/design/telecomms_hub
	name = "Circuit Design (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/hub
	category = list("Telecomms")

/datum/design/telecomms_relay
	name = "Circuit Design (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/relay
	category = list("Telecomms")

/datum/design/telecomms_processor
	name = "Circuit Design (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/processor
	category = list("Telecomms")

/datum/design/telecomms_server
	name = "Circuit Design (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/server
	category = list("Telecomms")

/datum/design/subspace_broadcaster
	name = "Circuit Design (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/broadcaster
	category = list("Telecomms")


///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/device/aicard
	category = list("AI")

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/device/paicard
	category = list("AI")

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "Allows for the construction of a positronic brain."
	id = "posibrain"

	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 500, MAT_DIAMOND = 100, MAT_PHORON = 500)
	build_path = /obj/item/device/mmi/posibrain
	category = list("AI")

///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

/datum/design/ripley_main
	name = "Circuit Design (APLU \"Ripley\" Central Control module)"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/main
	category = list("Mech")

/datum/design/ripley_peri
	name = "Circuit Design (APLU \"Ripley\" Peripherals Control module)"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/peripherals
	category = list("Mech")

/datum/design/odysseus_main
	name = "Circuit Design (\"Odysseus\" Central Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/main
	category = list("Mech")

/datum/design/odysseus_peri
	name = "Circuit Design (\"Odysseus\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/peripherals
	category = list("Mech")

/datum/design/gygax_main
	name = "Circuit Design (\"Gygax\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/main
	category = list("Mech")

/datum/design/gygax_peri
	name = "Circuit Design (\"Gygax\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/peripherals
	category = list("Mech")

/datum/design/gygax_targ
	name = "Circuit Design (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/targeting
	category = list("Mech")

/datum/design/durand_main
	name = "Circuit Design (\"Durand\" Central Control module)"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/main
	category = list("Mech")

/datum/design/durand_peri
	name = "Circuit Design (\"Durand\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/peripherals
	category = list("Mech")

/datum/design/durand_targ
	name = "Circuit Design (\"Durand\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/targeting
	category = list("Mech")

/datum/design/vindicator_main
	name = "Circuit Design (\"Vindicator\" Central Control module)"
	desc = "Allows for the construction of a \"Vindicator\" Central Control module."
	id = "vindicator_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/main
	category = list("Mech")

/datum/design/vindicator_peri
	name = "Circuit Design (\"Vindicator\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Vindicator\" Peripheral Control module."
	id = "vindicator_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/peripherals
	category = list("Mech")

/datum/design/vindicator_targ
	name = "Circuit Design (\"Vindicator\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Vindicator\" Weapons & Targeting Control module."
	id = "vindicator_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/targeting
	category = list("Mech")

/datum/design/ultra_main
	name = "Circuit Design (\"Gygax Ultra\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax Ultra\" Central Control module."
	id = "ultra_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/main
	category = list("Mech")

/datum/design/ultra_peri
	name = "Circuit Design (\"Gygax Ultra\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax Ultra\" Peripheral Control module."
	id = "ultra_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/peripherals
	category = list("Mech")

/datum/design/ultra_targ
	name = "Circuit Design (\"Gygax Ultra\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax Ultra\" Weapons & Targeting Control module."
	id = "ultra_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/targeting
	category = list("Mech")

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/design_disk
	category = list("Misc")

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/tech_disk
	category = list("Misc")

/datum/design/science_tool
	name = "Science Tool"
	desc = "A hand-held device capable of extracting usefull data from various sources, such as paper reports and slime cores."
	id = "science_tool"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/device/science_tool
	category = list("Misc")

////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standart machine parts."
	id = "rped"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer
	category = list("Stock Parts")

/datum/design/BS_RPED
	name = "Bluespace RPED"
	desc = "Powered by bluespace technology, this RPED variant can upgrade buildings from a distance, without needing to remove the panel first."
	id = "bs_rped"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_SILVER = 2500) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer/bluespace
	category = list("Stock Parts")

	//Tier1
/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 400) //2000 material per sheet.
	build_path = /obj/item/weapon/stock_parts/capacitor
	category = list("Stock Parts")

/datum/design/basic_sensor
	name = "Basic Sensor Module"
	desc = "A stock part used in the construction of various devices."
	id = "basic_sensor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/scanning_module
	category = list("Stock Parts")

/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 240)
	build_path = /obj/item/weapon/stock_parts/manipulator
	category = list("Stock Parts")

/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/micro_laser
	category = list("Stock Parts")

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 640)
	build_path = /obj/item/weapon/stock_parts/matter_bin
	category = list("Stock Parts")

	//Tier 2
/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 400, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv
	category = list("Stock Parts")

/datum/design/adv_sensor
	name = "Advanced Sensor Module"
	desc = "A stock part used in the construction of various devices."
	id = "adv_sensor"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 160, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv
	category = list("Stock Parts")

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 240, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano
	category = list("Stock Parts")

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high
	category = list("Stock Parts")

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 640, MAT_SILVER = 300)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv
	category = list("Stock Parts")

	//Tier 3
/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	build_type = PROTOLATHE  |MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 400, MAT_GOLD = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/super
	category = list("Stock Parts")

/datum/design/phasic_sensor
	name = "Phasic Sensor Module"
	desc = "A stock part used in the construction of various devices."
	id = "phasic_sensor"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 160, MAT_SILVER = 80, MAT_GOLD = 250)
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic
	category = list("Stock Parts")

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 240, MAT_GOLD = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/pico
	category = list("Stock Parts")

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160, MAT_GOLD = 250, MAT_URANIUM = 80)
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra
	category = list("Stock Parts")

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 640, MAT_GOLD = 300)
	build_path = /obj/item/weapon/stock_parts/matter_bin/super
	category = list("Stock Parts")

	//Tier 4
/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "quadratic_capacitor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/quadratic
	category = list("Stock Parts")

/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "triphasic_scanning"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 320, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/scanning_module/triphasic
	category = list("Stock Parts")

/datum/design/femto_mani
	name = "Femto Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "femto_mani"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 480, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/femto
	category = list("Stock Parts")

/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "quadultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 160, MAT_GLASS = 320, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250, MAT_URANIUM = 160)
	build_path = /obj/item/weapon/stock_parts/micro_laser/quadultra
	category = list("Stock Parts")

/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "bluespace_matter_bin"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1280, MAT_SILVER = 300, MAT_GOLD = 300, MAT_DIAMOND = 400)
	build_path = /obj/item/weapon/stock_parts/matter_bin/bluespace
	category = list("Stock Parts")


/datum/design/telesci_gps
	name = "GPS Device"
	desc = "Little thingie that can track its position at all times."
	id = "telesci_gps"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/device/gps
	category = list("Equipment")

/datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	id = "s-ansible"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_SILVER = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/ansible
	category = list("Telecomms")

/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	id = "s-filter"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 40, MAT_SILVER = 10)
	build_path = /obj/item/weapon/stock_parts/subspace/filter
	category = list("Telecomms")

/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	id = "s-amplifier"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GOLD = 30, MAT_URANIUM = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/amplifier
	category = list("Telecomms")

/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	id = "s-treatment"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_SILVER = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/treatment
	category = list("Telecomms")

/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-analyzer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GOLD = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/analyzer
	category = list("Telecomms")

/datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-crystal"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_SILVER = 20, MAT_GOLD = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/crystal
	category = list("Telecomms")

/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	id = "s-transmitter"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 100, MAT_SILVER = 10, MAT_URANIUM = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/transmitter
	category = list("Telecomms")

////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

/datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1000 units of energy"
	id = "basic_cell"
	build_type = PROTOLATHE | AUTOLATHE |MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/cell
	construction_time=100
	category = list("Stock Parts")

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10000 units of energy"
	id = "high_cell"
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 60)
	build_path = /obj/item/weapon/stock_parts/cell/high
	construction_time=100
	category = list("Stock Parts")

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20000 units of energy"
	id = "super_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 70)
	build_path = /obj/item/weapon/stock_parts/cell/super
	construction_time=100
	category = list("Stock Parts")

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30000 units of energy"
	id = "hyper_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 70, MAT_SILVER = 150, MAT_GOLD = 150)
	build_path = /obj/item/weapon/stock_parts/cell/hyper
	construction_time=100
	category = list("Stock Parts")

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 40000 units of energy."
	id = "bluespace_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 800, MAT_GLASS = 160, MAT_SILVER = 300, MAT_GOLD = 300, MAT_DIAMOND = 160)
//	construction_time=100
	build_path = /obj/item/weapon/stock_parts/cell/bluespace
	category = list("Stock Parts")


/datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 3000, MAT_SILVER = 150)
	build_path = /obj/item/device/lightreplacer
	category = list("Equipment")

////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

/datum/design/smes
	name = "SMES Board"
	desc = "The circuit board for a SMES."
	id = "smes"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes
	category = list("Power")

/datum/design/space_heater
	name = "Machine Design (Space Heater Board)"
	desc = "The circuit board for a space heater."
	id = "space_heater"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/space_heater
	category = list("Machine")

/datum/design/teleport_station
	name = "Teleportation Station Board"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station
	category = list("Machine")

/datum/design/teleport_hub
	name = "Teleportation Hub Board"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub
	category = list("Machine")

/datum/design/telepad
	name = "Telepad Board"
	desc = "The circuit board for a telescience telepad."
	id = "telepad"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad
	category = list("Machine")

/datum/design/sleeper
	name = "Sleeper Board"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper
	category = list("Machine")

/datum/design/cryotube
	name = "Cryotube Board"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube
	category = list("Machine")

/datum/design/gas_heater
	name = "gas heating system"
	desc = "The circuit board for a heater."
	id = "gasheater"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/heater
	category = list("Machine")

/datum/design/gas_cooler
	name = "gas cooling system"
	desc = "The circuit board for a freezer."
	id = "gascooler"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cooler
	category = list("Machine")

/datum/design/biogenerator
	name = "Biogenerator Board"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator
	category = list("Machine")

/datum/design/hydroponics
	name = "Hydroponics Tray Board"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics
	category = list("Machine")

/datum/design/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/gibber
	category = list("Machine")

/datum/design/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "The circuit board for a smartfridge."
	id = "smartfridge"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smartfridge
	category = list("Machine")

/datum/design/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "The circuit board for a monkey recycler."
	id = "monkey_recycler"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/monkey_recycler
	category = list("Machine")

/datum/design/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "The circuit board for a seed extractor."
	id = "seed_extractor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/seed_extractor
	category = list("Machine")

/datum/design/processor
	name = "Machine Design (Processor Board)"
	desc = "The circuit board for a processor."
	id = "processor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/processor
	category = list("Machine")

//datum/design/recycler
//	name = "Machine Design (Recycler Board)"
//	desc = "The circuit board for a recycler."
//	id = "recycler"
//	build_type = IMPRINTER
//	materials = list(MAT_GLASS = 1000, "sacid" = 20)
//	build_path = /obj/item/weapon/circuitboard/recycler
//	category = list("Machine")

/datum/design/holopad
	name = "Machine Design (AI Holopad Board)"
	desc = "The circuit board for a holopad."
	id = "holopad"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/holopad
	category = list("Machine")

/datum/design/deepfryer
	name = "Deep Fryer Board"
	desc = "The circuit board for a deep fryer."
	id = "deepfryer"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/deepfryer
	category = list("Machine")

/datum/design/microwave
	name = "Microwave Board"
	desc = "The circuit board for a microwave."
	id = "microwave"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave
	category = list("Machine")

/datum/design/oven
	name = "Oven Board"
	desc = "The circuit board for a oven."
	id = "oven"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/oven
	category = list("Machine")

/datum/design/grill
	name = "Grill Board"
	desc = "The circuit board for a grill."
	id = "grill"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grill
	category = list("Machine")

/datum/design/candymaker
	name = "Candy Machine Board"
	desc = "The circuit board for a candy machine."
	id = "candymaker"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/candymaker
	category = list("Machine")

/datum/design/chem_dispenser
	name = "Portable Chem Dispenser Board"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser
	category = list("Machine")

/datum/design/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "The circuit board for a Chem Master 2999."
	id = "chem_master"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_master
	category = list("Machine")

/datum/design/destructive_analyzer
	name = "Destructive Analyzer Board"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer
	category = list("Machine")

/datum/design/protolathe
	name = "Protolathe Board"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe
	category = list("Machine")

/datum/design/circuit_imprinter
	name = "Circuit Imprinter Board"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter
	category = list("Machine")

/datum/design/emitter
	name = "Circuit Board Emitter"
	desc = "The circuit board for a emitter."
	id = "emitter"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/emitter
	category = list("Machine")

/datum/design/autolathe
	name = "Autolathe Board"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe
	category = list("Machine")

/datum/design/recharger
	name = "Machine Design (Weapon Recharger Board)"
	desc = "The circuit board for a Weapon Recharger."
	id = "recharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20, MAT_GOLD = 100)
	build_path = /obj/item/weapon/circuitboard/recharger
	category = list("Machine")

/datum/design/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor
	category = list("Machine")

/datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ore_redemption
	category = list("Machine")

/datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "The circuit board for a Mining Rewards Vender."
	id = "mining_equipment_vendor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining_equipment_vendor
	category = list("Machine")

/datum/design/rdservercontrol
	name = "R&D Server Control Console Board"
	desc = "The circuit board for an R&D Server Control Console"
	id = "rdservercontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol
	category = list("Computer")

/datum/design/rdserver
	name = "R&D Server Board"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver
	category = list("Machine")

/datum/design/mechfab
	name = "Exosuit Fabricator Board"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab
	category = list("Mech")

/datum/design/cyborgrecharger
	name = "Cyborg Recharger Board"
	desc = "The circuit board for a Cyborg Recharger"
	id = "cyborgrecharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger
	category = list("Machine")

/datum/design/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	desc = "The circuit board for a tesla coil."
	id = "tesla_coil"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/tesla_coil
	category = list("Power")

/datum/design/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	desc = "The circuit board for a grounding rod."
	id = "grounding_rod"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grounding_rod
	category = list("Power")

/datum/design/mining_drill
	name = "Machine Design (Mining Drill Head)"
	desc = "Large drill for mining."
	id = "mining_drill"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/miningdrill
	category = list("Machine")

/datum/design/mining_drill_brace
	name = "Machine Design (Mining Drill Brace)"
	desc = "Brace for mining drill."
	id = "mining_drill_brace"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/miningdrillbrace
	category = list("Machine")

/datum/design/mining_fabricator
	name = "Machine Design (Mining fabricator)"
	desc = "For mining staff"
	id = "mining_fabricator"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/minefab
	category = list("Machine")

/////////////////////////////////////////
////////////Power Stuff//////////////////
/////////////////////////////////////////

/datum/design/pacman
	name = "PACMAN-type Generator Board"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman
	category = list("Power")

/datum/design/superpacman
	name = "SUPERPACMAN-type Generator Board"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/super
	category = list("Power")

/datum/design/mrspacman
	name = "MRSPACMAN-type Generator Board"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/mrs
	category = list("Power")


/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/mass_spectrometer
	category = list("Tools")

/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/mass_spectrometer/adv
	category = list("Tools")

/datum/design/reagent_scanner
	name = "Reagent Scanner"
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/reagent_scanner
	category = list("Tools")

/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/reagent_scanner/adv
	category = list("Tools")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/device/mmi
	category = list("Misc")

/datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1200, MAT_GLASS = 500)
	build_path = /obj/item/device/mmi/radio_enabled
	category = list("Misc")

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	build_path = /obj/item/device/flash/synthetic
	category = list("Misc")

/datum/design/cyborg_analyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "cyborg_analyzer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000, MAT_SILVER = 1500, MAT_DIAMOND = 1000)
	build_path = /obj/item/device/robotanalyzer
	category = list("Tools")

/datum/design/nanopaste
	name = "nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	category = list("Support")

/datum/design/implanter
	name = "implanter"
	desc = "Implanter, used to inject implants."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implanter
	category = list("Support")

/datum/design/implant_loyal
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	id = "implant_loyal"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/implantcase/loyalty
	category = list("Support")

/datum/design/implant_mindshield
	name = "Glass Case- 'MindShield'"
	desc = "A case containing a mindshield implant."
	id = "implant_mindshield"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/implantcase/mindshield
	category = list("Support")

/datum/design/implant_chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/weapon/implantcase/chem
	category = list("Support")

/datum/design/implant_death
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	id = "implant_death"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implantcase/death_alarm
	category = list("Support")

/datum/design/implant_tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implantcase/tracking
	category = list("Support")

/datum/design/implant_free
	name = "Glass Case- 'Freedom'"
	desc = "A case containing a freedom implant."
	id = "implant_free"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/implantcase/freedom
	category = list("Illegal")

/datum/design/chameleon
	name = "Chameleon Kit"
	desc = "It's a set of clothes with dials on them."
	id = "chameleon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/weapon/storage/box/syndie_kit/chameleon
	category = list("Illegal")


/datum/design/bluespacebeaker
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PHORON = 3000, MAT_DIAMOND = 500)
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Misc")

/datum/design/noreactbeaker
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = list("Misc")

/datum/design/defibrillators_back
	name = "Defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators_back"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 50)
	build_path = /obj/item/weapon/defibrillator
	category = list("Support")

/datum/design/defibrillators_belt
	name = "Compact defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators_compact"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 50)
	build_path = /obj/item/weapon/defibrillator/compact
	category = list("Support")

/datum/design/defibrillators_standalone
	name = "Standalone defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators_standalone"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/weapon/twohanded/shockpaddles/standalone
	category = list("Support")

/datum/design/sensor_device
	name = "Handheld Crew Monitor"
	desc = "A device for tracking crew members on the station."
	id = "sensor_device"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/device/sensor_device
	category = list("Support")

/datum/design/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	id = "scalpel_laser1"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500)
	build_path = /obj/item/weapon/scalpel/laser1
	category = list("Support")

/datum/design/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	id = "scalpel_laser2"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500)
	build_path = /obj/item/weapon/scalpel/laser2
	category = list("Support")

/datum/design/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500, MAT_SILVER = 2000, MAT_GOLD = 1500)
	build_path = /obj/item/weapon/scalpel/laser3
	category = list("Support")

/datum/design/scalpel_manager
	name = "Incision Management System"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	id = "scalpel_manager"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500, MAT_SILVER = 1500, MAT_GOLD = 1500, MAT_DIAMOND = 750)
	build_path = /obj/item/weapon/scalpel/manager
	category = list("Support")

/datum/design/biocan
	name = "Biogel can"
	desc = "Medical device for sustaining life in head"
	id = "biocan"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1200, MAT_GLASS = 1000)
	build_path = /obj/item/device/biocan
	category = list("Support")

/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_URANIUM = 500)
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	category = list("Weapons")

/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/weapon/gun/energy/taser/stunrevolver
	category = list("Weapons")

/datum/design/laserrifle
	name = "Laser Rifle"
	desc = "An energy weapon with concentrated energy bolts."
	id = "laserrifle"
	build_type = PROTOLATHE
	materials = list (MAT_METAL = 8000, MAT_GLASS = 1000, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/gun/energy/laser
	category = list("Weapons")

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000, MAT_URANIUM = 100)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	build_path = /obj/item/weapon/gun/energy/decloner
	category = list("Weapons")

/datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/reagent_containers/spray/chemsprayer
	category = list("Weapons")

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe
	category = list("Support")
/*
/datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favoured by syndicate infiltration teams."
	id = "largecrossbow"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_URANIUM = 1000)
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
	category = list("Weapons")
*/
/datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energythings to change temperature."//Change it if you want
	id = "temp_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature
	category = list("Weapons")

/datum/design/tesla_gun
	name = "Tesla Cannon"
	desc = "A gun which uses electrical discharges to hit multiple targets"
	id = "tesla_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GOLD = 1000, MAT_SILVER = 4000)
	build_path = /obj/item/weapon/gun/tesla
	category = list("Weapons")

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_URANIUM = 500)
	build_path = /obj/item/weapon/gun/energy/floragun
	category = list("Weapons")

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/weapon/grenade/chem_grenade/large
	category = list("Weapons")

/datum/design/plasma_10_gun
	name = "plasma 10-bc"
	desc = "A basic plasma-based bullpup carbine with fast rate of fire."
	id = "plasma_10_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 4500, MAT_DIAMOND = 500, MAT_URANIUM = 1000)
	build_path = /obj/item/weapon/gun/plasma
	category = list("Weapons")

/datum/design/plasma_104_gun
	name = "plasma 104-sass"
	desc = "A plasma-based semi-automatic short shotgun."
	id = "plasma_104_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 8000, MAT_DIAMOND = 750, MAT_URANIUM = 5000)
	build_path = /obj/item/weapon/gun/plasma/p104sass
	category = list("Weapons")

/datum/design/plasma_mag
	name = "plasma weapon battery pack"
	desc = "A special battery case with protection against EM pulse. Has standardized dimensions and can be used with any plasma type gun of this series."
	id = "plasma_mag"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_GOLD = 2000, MAT_SILVER = 1500)
	build_path = /obj/item/ammo_box/magazine/plasma
	category = list("Weapons")

/datum/design/smg
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun."
	id = "smg"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic
	category = list("Weapons")

/datum/design/ammo_9mm
	name = "Ammunition Box (9mm)"
	desc = "A box of prototype 9mm ammunition."
	id = "ammo_9mm"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3750, MAT_SILVER = 100)
	build_path = /obj/item/ammo_box/magazine/msmg9mm
	category = list("Weapons")

/datum/design/stunslug
	name = "Stun Slug"
	desc = "A stunning, electrified slug for a shotgun."
	id = "stunshell"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/stunslug
	category = list("Weapons")

/datum/design/phoronpistol
	name = "phoron pistol"
	desc = "A specialized firearm designed to fire lethal bolts of phoron."
	id = "ppistol"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PHORON = 3000)
	build_path = /obj/item/weapon/gun/energy/toxgun
	category = list("Weapons")

/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	id = "jackhammer"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/weapon/pickaxe/drill/jackhammer
	construction_time=100
	category = list("Tools")


/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill
	construction_time=100
	category = list("Tools")

/datum/design/excavation_drill
	name = "Excavation Drill"
	desc = "Basic archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision."
	id = "excavation_drill"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/pickaxe/excavationdrill
	construction_time = 100
	category = list("Tools")

/datum/design/excavation_drill_diamond
	name = "Diamond Excavation Drill"
	desc = "Advanced archaeological drill combining ultrasonic excitation and bluespace manipulation to provide extreme precision."
	id = "excavation_drill_diamond"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 3750)
	build_path = /obj/item/weapon/pickaxe/excavationdrill/adv
	construction_time = 200
	category = list("Tools")

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 1500, MAT_GLASS = 500, MAT_GOLD = 500, MAT_PHORON = 500)
	build_path = /obj/item/weapon/pickaxe/plasmacutter
	construction_time=300
	category = list("Tools")

/datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."
	id = "pick_diamond"
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 3000)
	build_path = /obj/item/weapon/pickaxe/diamond
	category = list("Tools")

/datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 3750) //Yes, a whole diamond is needed.
	build_path = /obj/item/weapon/pickaxe/drill/diamond_drill
	construction_time=100
	category = list("Tools")


/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/meson
	construction_time=100
	category = list("Tools")

/datum/design/scaner_imp
	name = "Improved ore scaner"
	desc = "A complex device used to locate ore deep underground."
	id = "scaner_imp"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 2000)
	build_path = /obj/item/weapon/mining_scanner/improved
	construction_time=300
	category = list("Tools")

/datum/design/scaner_adv
	name = "Advanced ore scaner"
	desc = "A complex device used to locate ore deep underground."
	id = "scaner_adv"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 8000, MAT_SILVER = 200, MAT_DIAMOND = 100)
	build_path = /obj/item/weapon/mining_scanner/improved/adv
	construction_time=450
	category = list("Tools")

/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

/datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 10)
	build_path = /obj/item/device/radio/beacon
	category = list("Misc")

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Equipment")

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_DIAMOND = 3000, MAT_PHORON = 1500)
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Misc")

/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 500) //quite cheap, for more convenience
	build_path = /obj/item/weapon/storage/bag/ore/holding
	category = list("Tools")

/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Support")

/datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Support")

/datum/design/secmed_hud
	name = "Mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	id = "secmed_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/sunglasses/hud/secmed
	category = list("Support")

/datum/design/mining_hud
	name = "Geological Optical Scanner"
	desc = "A heads-up display that scans the rocks in view and provides some data about their composition."
	id = "mining_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/mining
	category = list("Support")

/////////////////////////////////////////
//////////////////Test///////////////////
/////////////////////////////////////////

	/*	test
			name = "Test Design"
			desc = "A design to test the new protolathe."
			id = "protolathe_test"
			build_type = PROTOLATHE
			materials = list(MAT_SILVER = 2500, MAT_GOLD = 3000, "iron" = 15, "copper" = 10)
			build_path = /obj/item/weapon/banhammer */

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Empty Disk"
	desc = "Wow. Is that a save icon?"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	m_amt = 30
	g_amt = 10
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)


/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////
/datum/design/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Allows for the construction of illegal upgrades for cyborgs"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(MAT_METAL = 10000, MAT_GLASS = 15000, MAT_DIAMOND = 10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/////////////////////////////////////////
/////////////PDA and Radio stuff/////////
/////////////////////////////////////////
/datum/design/standart_encrypt
	name = "Standard Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	id = "standart_encrypt"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 600)
	build_path = /obj/item/device/encryptionkey
	category = list("Telecomms")

/datum/design/binaryencrypt
	name = "Binary Encrpytion Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	id = "binaryencrypt"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 600)
	build_path = /obj/item/device/encryptionkey/binary
	category = list("Illegal")

/datum/design/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	id = "pda"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/device/pda
	category = list("PDA")

/datum/design/cart_basic
	name = "Generic Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_basic"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge
	category = list("PDA")

/datum/design/cart_engineering
	name = "Power-ON Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_engineering"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/engineering
	category = list("PDA")

/datum/design/cart_atmos
	name = "BreatheDeep Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_atmos"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/atmos
	category = list("PDA")

/datum/design/cart_medical
	name = "Med-U Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_medical"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/medical
	category = list("PDA")

/datum/design/cart_chemistry
	name = "ChemWhiz Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_chemistry"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/chemistry
	category = list("PDA")

/datum/design/cart_security
	name = "R.O.B.U.S.T. Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_security"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/security
	category = list("PDA")

/datum/design/cart_janitor
	name = "CustodiPRO Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_janitor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/janitor
	category = list("PDA")

/datum/design/radio_grid
	name = "Radio Grid"
	desc = "A metal grid, attached to circuit to protect it from emitting."
	id = "radio_grid"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 50)
	build_path = /obj/item/device/radio_grid
	category = list("Telecomms")

/*
/datum/design/cart_clown
	name = "Honkworks 5.0 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_clown"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/clown
	category = list("PDA")

/datum/design/cart_mime
	name = "Gestur-O 1000 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_mime"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/mime
	category = list("PDA")
*/

/datum/design/cart_science
	name = "Signal Ace 2 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_science"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/signal/science
	category = list("PDA")

/datum/design/cart_quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_quartermaster"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/quartermaster
	category = list("PDA")

/datum/design/cart_hop
	name = "Human Resources 9001 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_hop"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/hop
	category = list("PDA")

/datum/design/cart_hos
	name = "R.O.B.U.S.T. DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_hos"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/hos
	category = list("PDA")

/datum/design/cart_ce
	name = "Power-On DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_ce"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/ce
	category = list("PDA")

/datum/design/cart_cmo
	name = "Med-U DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_cmo"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/cmo
	category = list("PDA")

/datum/design/cart_rd
	name = "Signal Ace DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_rd"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/rd
	category = list("PDA")

/datum/design/cart_captain
	name = "Value-PAK Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_captain"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/captain
	category = list("PDA")

///////////////////////////////
/////////////New stuff/////////
///////////////////////////////
/datum/design/beacon_warp
	name = "Medical Tracking Beacon"
	desc = "A beacon used by a body teleporter."
	id = "beacon_warp"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000)
	build_path = /obj/item/device/beacon/medical
	category = list("Support")

/datum/design/body_warp
	name = "Medical Body Teleporter Device"
	desc = "A device used for teleporting injured or dead people."
	id = "body_warp"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3500, MAT_GLASS = 3500)
	build_path = /obj/item/weapon/medical/teleporter
	construction_time=100
	category = list("Support")

/datum/design/spraycan
	name = "Spraycan"
	id = "spraycan"
	desc = "A metallic container containing tasty paint."
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list("Tools")

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PHORON = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/weldingtool/experimental
	category = list("Tools")

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "A small, compact Jaws of Life with an interchangable pry jaws and cutting jaws"
	id = "jawsoflife"
	build_path = /obj/item/weapon/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2000, MAT_GOLD = 1000)
	category = list("Tools")

/datum/design/handdrill
	name = "Hand Drill"
	desc = "A small electric hand drill with an interchangable screwdriver and bolt bit"
	id = "handdrill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/screwdriver/power
	category = list("Tools")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/datum/design/airbag
	name = "Personal airbag"
	desc = "One-use protection from high-speed collisions"
	id = "airbag"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_SILVER = 500)
	build_path = /obj/item/airbag
	category = list("Support")

/datum/design/universal_pyrometer
	name = "Universal pyrometer"
	desc = "A pyrometer with all possible modes built-in. Battery and micro-laser component not included!"
	id = "universal_pyrometer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 100)
	build_path = /obj/item/weapon/gun/energy/pyrometer/universal
	category = list("Tools")

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////

/datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/weapon/mop/advanced
	category = list("Equipment")

/datum/design/blutrash
	name = "Trashbag of Holding"
	desc = "An advanced trashbag with bluespace properties; capable of holding a plethora of garbage."
	id = "blutrash"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PHORON = 1500)
	build_path = /obj/item/weapon/storage/bag/trash/bluespace
	category = list("Equipment")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/holosign_creator
	category = list("Equipment")

/////////////////////////////////////////
//////////////Rig Modules////////////////
/////////////////////////////////////////

/datum/design/rigsimpleai
	name = "Hardsuit Automated Diagnostic System"
	desc = "A system designed to help hardsuit users."
	id = "rigsimpleai"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/simple_ai
	category = list("Rig Modules")

/datum/design/rigadvancedai
	name = "Hardsuit Advanced Diagnostic System"
	desc = "A system designed to help hardsuit users."
	id = "rigadvancedai"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 500)
	build_path = /obj/item/rig_module/simple_ai/advanced
	category = list("Rig Modules")

/datum/design/rigflash
	name = "Hardsuit Mounted Flash"
	desc = "You are the law."
	id = "rigflash"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/device/flash
	category = list("Rig Modules")

/datum/design/riggrenadelauncherflashbang
	name = "Hardsuit Mounted Flashbang Grenade Launcher"
	desc = "A shoulder-mounted micro-explosive dispenser designed only to accept standard flashbang grenades."
	id = "riggrenadelauncherflashbang"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GOLD = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/rig_module/grenade_launcher/flashbang
	category = list("Rig Modules")

/datum/design/rigmountedlaserrifle
	name = "Hardsuit Mounted Laser Rifle"
	desc = "A shoulder-mounted battery-powered laser rifle mount."
	id = "rigmountedlaserrifle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 4500, MAT_DIAMOND = 500, MAT_URANIUM = 1000)
	build_path = /obj/item/rig_module/mounted
	category = list("Rig Modules")

/datum/design/rigmountedtaser
	name = "Hardsuit Mounted Taser"
	desc = "A palm-mounted nonlethal energy projector."
	id = "rigmountedtaser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 500)
	build_path = /obj/item/rig_module/mounted/taser
	category = list("Rig Modules")

/datum/design/righealthscanner
	name = "Hardsuit Health Scanner Module"
	desc = "A hardsuit-mounted health scanner."
	id = "righealthscanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 100)
	build_path = /obj/item/rig_module/device/healthscanner
	category = list("Rig Modules")

/datum/design/rigdrill
	name = "Hardsuit Drill Mount"
	desc = "A very heavy diamond-tipped drill."
	id = "rigdrill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/rig_module/device/drill
	category = list("Rig Modules")

/datum/design/riganomalyscanner
	name = "Hardsuit Anomaly Scanner Module"
	desc = "You think it's called an Elder Sarsparilla or something."
	id = "riganomalyscanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/device/anomaly_scanner
	category = list("Rig Modules")

/datum/design/rigorescanner
	name = "Hardsuit Ore Scanner Module"
	desc = "A clunky old ore scanner."
	id = "rigorescanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/device/orescanner
	category = list("Rig Modules")

/datum/design/rigrcd
	name = "Hardsuit RCD Mount"
	desc = "A cell-powered rapid construction device for a hardsuit."
	id = "rigrcd"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_GOLD = 4000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/rig_module/device/rcd
	category = list("Rig Modules")

/datum/design/rigcombatinjector
	name = "Hardsuit Combat Chemical Injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	id = "rigcombatinjector"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 500, MAT_SILVER = 500)
	build_path = /obj/item/rig_module/chem_dispenser/combat
	category = list("Rig Modules")

/datum/design/rigmedicalinjector
	name = "Hardsuit Medical Chemical Injector"
	desc = "A complex web of tubing and needles suitable for hardsuit use."
	id = "rigmedicalinjector"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000, MAT_GOLD = 1000, MAT_SILVER = 1000)
	build_path = /obj/item/rig_module/chem_dispenser/medical
	category = list("Rig Modules")

/datum/design/rigselfrepair
	name = "Hardsuit Self-Repair Module"
	desc = "A somewhat complicated looking complex full of tools."
	id = "rigselfrepair"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_GLASS = 2000, MAT_GOLD = 1000)
	build_path = /obj/item/rig_module/selfrepair
	category = list("Rig Modules")

/datum/design/rigmedteleport
	name = "Hardsuit Medical Teleport System"
	desc = "System capable of saving the suit owner."
	id = "rigmedteleport"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000, MAT_GOLD = 2000, MAT_DIAMOND = 500)
	build_path = /obj/item/rig_module/med_teleport
	category = list("Rig Modules")

/datum/design/rignuclearreactor
	name = "Hardsuit Nuclear Reactor Module"
	desc = "Passively generates energy. Becomes very unstable if damaged."
	id = "rignuclearreactor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_GOLD = 6000, MAT_URANIUM = 4000)
	build_path = /obj/item/rig_module/nuclear_generator
	category = list("Rig Modules")

/datum/design/rigcoolingunit
	name = "Hardsuit Mounted Cooling Unit"
	desc = "A heat sink with a liquid cooled radiator."
	id = "rigcoolingunit"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_DIAMOND = 200)
	build_path = /obj/item/rig_module/cooling_unit
	category = list("Rig Modules")

/datum/design/rigextinguisher
	name = "Hardsuit Fire Extinguisher"
	desc = "Hardsuit mounted fire extinguisher designed to work in hazardous environments."
	id = "rigextinguisher"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/device/extinguisher
	category = list("Rig Modules")

/datum/design/rigmetalfoamspray
	name = "Hardsuit Metal Foam Spray"
	desc = "Hardsuit mounted metal foam spray designed to quickly patch holes."
	id = "rigmetalfoamspray"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/metalfoam_spray
	category = list("Rig Modules")
