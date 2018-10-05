//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
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
- The reliability formula for all R&D built items is reliability_base (a fixed number) + total tech levels required to make it +
- The reliability formula for all R&D built items is reliability (a fixed number) + total tech levels required to make it +
(3 phorontech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to
*/

datum/design						//Datum for object designs, used in construction
	var/name = "Name"				//Name of the created object.
	var/desc = "Desc"				//Description of the created object.
	var/id = "id"					//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()		//IDs of that techs the object originated from and the minimum level requirements.
	var/reliability = 100			//Reliability of the device.
	var/build_type = null			//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()		//List of materials. Format: "id" = amount.
	var/construction_time			//Amount of time required for building the object
	var/build_path = null			//The file path of the object that gets created
	var/list/category = null		//Primarily used for Mech Fabricators, but can be used for anything

//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
datum/design/proc/CalcReliability(list/temp_techs)
	var/new_reliability
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = Clamp(new_reliability, reliability, 100)
	reliability = new_reliability
	return


///////////////////Computer Boards///////////////////////////////////

datum/design/seccamera
	name = "Circuit Design (Security)"
	desc = "Allows for the construction of circuit boards used to build security camera computers."
	id = "seccamera"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/security

datum/design/telepad_concole
	name = " Circuit Design (Telescience Console) "
	desc = "Allows for the construction of circuit boards used to build telescience computers."
	id = "telepad_concole"
	req_tech = list("programming" = 4, "bluespace" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_console

datum/design/aicore
	name = "Circuit Design (AI Core)"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	req_tech = list("programming" = 4, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore

datum/design/aiupload
	name = "Circuit Design (AI Upload)"
	desc = "Allows for the construction of circuit boards used to build an AI Upload Console."
	id = "aiupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload

datum/design/borgupload
	name = "Circuit Design (Cyborg Upload)"
	desc = "Allows for the construction of circuit boards used to build a Cyborg Upload Console."
	id = "borgupload"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload

datum/design/med_data
	name = "Circuit Design (Medical Records)"
	desc = "Allows for the construction of circuit boards used to build a medical records console."
	id = "med_data"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data

datum/design/operating
	name = "Circuit Design (Operating Computer)"
	desc = "Allows for the construction of circuit boards used to build an operating computer console."
	id = "operating"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating

datum/design/pandemic
	name = "Circuit Design (PanD.E.M.I.C. 2200)"
	desc = "Allows for the construction of circuit boards used to build a PanD.E.M.I.C. 2200 console."
	id = "pandemic"
	req_tech = list("programming" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pandemic

datum/design/scan_console
	name = "Circuit Design (DNA Machine)"
	desc = "Allows for the construction of circuit boards used to build a new DNA scanning console."
	id = "scan_console"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew

datum/design/comconsole
	name = "Circuit Design (Communications)"
	desc = "Allows for the construction of circuit boards used to build a communications console."
	id = "comconsole"
	req_tech = list("programming" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications

datum/design/idcardconsole
	name = "Circuit Design (ID Computer)"
	desc = "Allows for the construction of circuit boards used to build an ID computer."
	id = "idcardconsole"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card

datum/design/crewconsole
	name = "Circuit Design (Crew monitoring computer)"
	desc = "Allows for the construction of circuit boards used to build a Crew monitoring computer."
	id = "crewconsole"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew

datum/design/teleconsole
	name = "Circuit Design (Teleporter Console)"
	desc = "Allows for the construction of circuit boards used to build a teleporter control console."
	id = "teleconsole"
	req_tech = list("programming" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter

datum/design/secdata
	name = "Circuit Design (Security Records Console)"
	desc = "Allows for the construction of circuit boards used to build a security records console."
	id = "secdata"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data

datum/design/atmosalerts
	name = "Circuit Design (Atmosphere Alert)"
	desc = "Allows for the construction of circuit boards used to build an atmosphere alert console."
	id = "atmosalerts"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert

datum/design/air_management
	name = "Circuit Design (Atmospheric Monitor)"
	desc = "Allows for the construction of circuit boards used to build an Atmospheric Monitor."
	id = "air_management"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management

datum/design/robocontrol
	name = "Circuit Design (Robotics Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Robotics Control console."
	id = "robocontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics

datum/design/dronecontrol
	name = "Circuit Design (Drone Control Console)"
	desc = "Allows for the construction of circuit boards used to build a Drone Control console."
	id = "dronecontrol"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/drone_control

datum/design/clonecontrol
	name = "Circuit Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning

datum/design/clonepod
	name = "Circuit Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod

datum/design/clonescanner
	name = "Circuit Design (Cloning Scanner)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Scanner."
	id = "clonescanner"
	req_tech = list("programming" = 3, "biotech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner

datum/design/arcademachine
	name = "Circuit Design (Arcade Machine)"
	desc = "Allows for the construction of circuit boards used to build a new arcade machine."
	id = "arcademachine"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade
	//category = list("Misc. Machinery")

datum/design/powermonitor
	name = "Circuit Design (Power Monitor)"
	desc = "Allows for the construction of circuit boards used to build a new power monitor."
	id = "powermonitor"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor

datum/design/solarcontrol
	name = "Circuit Design (Solar Control)"
	desc = "Allows for the construction of circuit boards used to build a solar control console."
	id = "solarcontrol"
	req_tech = list("programming" = 2, "powerstorage" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control

datum/design/prisonmanage
	name = "Circuit Design (Prisoner Management Console)"
	desc = "Allows for the construction of circuit boards used to build a prisoner management console."
	id = "prisonmanage"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner

datum/design/mechacontrol
	name = "Circuit Design (Exosuit Control Console)"
	desc = "Allows for the construction of circuit boards used to build an exosuit control console."
	id = "mechacontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control

datum/design/mechrecharger
	name = "circuit board (Mechbay Recharger)"
	desc = "Allows for the construction of circuit boards used to build a mechbay recharger."
	id = "mechrecharger"
	req_tech = list("programming" = 4, "powerstorage" = 4, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger

datum/design/mechapower
	name = "Circuit Design (Mech Bay Power Control Console)"
	desc = "Allows for the construction of circuit boards used to build a mech bay power control console."
	id = "mechapower"
	req_tech = list("programming" = 2, "powerstorage" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console

datum/design/rdconsole
	name = "Circuit Design (R&D Console)"
	desc = "Allows for the construction of circuit boards used to build a new R&D console."
	id = "rdconsole"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole

datum/design/ordercomp
	name = "Circuit Design (Supply ordering console)"
	desc = "Allows for the construction of circuit boards used to build a Supply ordering console."
	id = "ordercomp"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/computer/cargo/request

datum/design/supplycomp
	name = "Circuit Design (Supply shuttle console)"
	desc = "Allows for the construction of circuit boards used to build a Supply shuttle console."
	id = "supplycomp"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/computer/cargo

datum/design/comm_monitor
	name = "Circuit Design (Telecommunications Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunications monitor."
	id = "comm_monitor"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor

datum/design/comm_server
	name = "Circuit Design (Telecommunications Server Monitoring Console)"
	desc = "Allows for the construction of circuit boards used to build a telecommunication server browser and monitor."
	id = "comm_server"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server

datum/design/message_monitor
	name = "Circuit Design (Messaging Monitor Console)"
	desc = "Allows for the construction of circuit boards used to build a messaging monitor console."
	id = "message_monitor"
	req_tech = list("programming" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/message_monitor

datum/design/aifixer
	name = "Circuit Design (AI Integrity Restorer)"
	desc = "Allows for the construction of circuit boards used to build an AI Integrity Restorer."
	id = "aifixer"
	req_tech = list("programming" = 3, "biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aifixer

/datum/design/libraryconsole
	name = "Computer Design (Library Console)"
	desc = "Allows for the construction of circuit boards used to build a new library console."
	id = "libraryconsole"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/libraryconsole
	//category = list("Computer Boards")

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
datum/design/safeguard_module
	name = "AI Module(Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	req_tech = list("programming" = 3, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/safeguard

datum/design/onehuman_module
	name = "AI Module (OneHuman)"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/oneHuman

datum/design/protectstation_module
	name = "AI Module (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/protectStation

datum/design/notele_module
	name = "AI Module (TeleporterOffline Module)"
	desc = "Allows for the construction of a TeleporterOffline AI Module."
	id = "notele_module"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/teleporterOffline

datum/design/quarantine_module
	name = "AI Module (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/quarantine

datum/design/oxygen_module
	name = "AI Module (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/oxygen

datum/design/freeform_module
	name = "AI Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/freeform

datum/design/reset_module
	name = "AI Module (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/reset

datum/design/purge_module
	name = "AI Module (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/purge

datum/design/freeformcore_module
	name = "AI Core Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/freeformcore

datum/design/asimov
	name = "AI Core Module (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	req_tech = list("programming" = 3, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/asimov

datum/design/paladin_module
	name = "AI Core Module (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/paladin

datum/design/tyrant_module
	name = "AI Core Module (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 4, "syndicate" = 2, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/tyrant



///////////////////////////////////
/////Subspace Telecomms////////////
///////////////////////////////////
datum/design/subspace_receiver
	name = "Circuit Design (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	req_tech = list("programming" = 4, "engineering" = 3, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/receiver

datum/design/telecomms_bus
	name = "Circuit Design (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/bus

datum/design/telecomms_hub
	name = "Circuit Design (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/hub

datum/design/telecomms_relay
	name = "Circuit Design (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	req_tech = list("programming" = 3, "engineering" = 4, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/relay

datum/design/telecomms_processor
	name = "Circuit Design (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/processor

datum/design/telecomms_server
	name = "Circuit Design (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	req_tech = list("programming" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/server

datum/design/subspace_broadcaster
	name = "Circuit Design (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	req_tech = list("programming" = 4, "engineering" = 4, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/broadcaster


///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	req_tech = list("programming" = 4, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/device/aicard

datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	req_tech = list("programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/device/paicard

datum/design/posibrain
	name = "Positronic Brain"
	desc = "Allows for the construction of a positronic brain."
	id = "posibrain"
	req_tech = list("engineering" = 4, "materials" = 6, "bluespace" = 2, "programming" = 4)

	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 500, MAT_DIAMOND = 100, MAT_PHORON = 500)
	build_path = /obj/item/device/mmi/posibrain

///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////

datum/design/ripley_main
	name = "Circuit Design (APLU \"Ripley\" Central Control module)"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/main

datum/design/ripley_peri
	name = "Circuit Design (APLU \"Ripley\" Peripherals Control module)"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/peripherals

datum/design/odysseus_main
	name = "Circuit Design (\"Odysseus\" Central Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	req_tech = list("programming" = 3,"biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/main

datum/design/odysseus_peri
	name = "Circuit Design (\"Odysseus\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	req_tech = list("programming" = 3,"biotech" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/peripherals

datum/design/gygax_main
	name = "Circuit Design (\"Gygax\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/main

datum/design/gygax_peri
	name = "Circuit Design (\"Gygax\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/peripherals

datum/design/gygax_targ
	name = "Circuit Design (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	req_tech = list("programming" = 4, "combat" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/targeting

datum/design/durand_main
	name = "Circuit Design (\"Durand\" Central Control module)"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/main

datum/design/durand_peri
	name = "Circuit Design (\"Durand\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	req_tech = list("programming" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/peripherals

datum/design/durand_targ
	name = "Circuit Design (\"Durand\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	req_tech = list("programming" = 4, "combat" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/targeting

datum/design/vindicator_main
	name = "Circuit Design (\"Vindicator\" Central Control module)"
	desc = "Allows for the construction of a \"Vindicator\" Central Control module."
	id = "vindicator_main"
	req_tech = list("programming" = 4, "combat" =4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/main

datum/design/vindicator_peri
	name = "Circuit Design (\"Vindicator\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Vindicator\" Peripheral Control module."
	id = "vindicator_peri"
	req_tech = list("programming" = 4, "combat" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/peripherals

datum/design/vindicator_targ
	name = "Circuit Design (\"Vindicator\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Vindicator\" Weapons & Targeting Control module."
	id = "vindicator_targ"
	req_tech = list("programming" = 4, "combat" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/targeting

datum/design/ultra_main
	name = "Circuit Design (\"Gygax Ultra\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax Ultra\" Central Control module."
	id = "ultra_main"
	req_tech = list("programming" = 4, "combat" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/main

datum/design/ultra_peri
	name = "Circuit Design (\"Gygax Ultra\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax Ultra\" Peripheral Control module."
	id = "ultra_peri"
	req_tech = list("programming" = 4, "combat" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/peripherals

datum/design/ultra_targ
	name = "Circuit Design (\"Gygax Ultra\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax Ultra\" Weapons & Targeting Control module."
	id = "ultra_targ"
	req_tech = list("programming" = 4, "combat" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/targeting

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/design_disk

datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	req_tech = list("programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/tech_disk

////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standart machine parts."
	id = "rped"
	req_tech = list("engineering" = 3,
					"materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer

/datum/design/BS_RPED
	name = "Bluespace RPED"
	desc = "Powered by bluespace technology, this RPED variant can upgrade buildings from a distance, without needing to remove the panel first."
	id = "bs_rped"
	req_tech = list("engineering" = 3, "materials" = 5, "programming" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_SILVER = 2500) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer/bluespace
	category = list("Stock Parts")

	//Tier1
datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 400) //2000 material per sheet.
	build_path = /obj/item/weapon/stock_parts/capacitor

datum/design/basic_sensor
	name = "Basic Sensor Module"
	desc = "A stock part used in the construction of various devices."
	id = "basic_sensor"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/scanning_module

datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	req_tech = list("materials" = 1, "programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 240)
	build_path = /obj/item/weapon/stock_parts/manipulator

datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/micro_laser

datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 640)
	build_path = /obj/item/weapon/stock_parts/matter_bin

	//Tier 2
datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 400, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv
	category = list("Misc")

datum/design/adv_sensor
	name = "Advanced Sensor Module"
	desc = "A stock part used in the construction of various devices."
	id = "adv_sensor"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 160, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv
	category = list("Misc")

datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 240, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano

datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160, MAT_SILVER = 250)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high

datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 640, MAT_SILVER = 300)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv

	//Tier 3
datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	build_type = PROTOLATHE  |MECHFAB
	reliability = 71
	materials = list(MAT_METAL = 400, MAT_GLASS = 400, MAT_GOLD = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/super
	category = list("Misc")

datum/design/phasic_sensor
	name = "Phasic Sensor Module"
	desc = "A stock part used in the construction of various devices."
	id = "phasic_sensor"
	req_tech = list("magnets" = 5, "materials" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 160, MAT_SILVER = 80, MAT_GOLD = 250)
	reliability = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic
	category = list("Misc")

datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 240, MAT_GOLD = 250)
	reliability = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/pico

datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160, MAT_GOLD = 250, MAT_URANIUM = 80)
	reliability = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra

datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	req_tech = list("materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 640, MAT_GOLD = 300)
	reliability = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/super

	//Tier 4
/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "quadratic_capacitor"
	req_tech = list("powerstorage" = 6, "materials" = 5)
	build_type = PROTOLATHE
	reliability = 71
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/quadratic
//	category = list("Stock Parts")

/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "triphasic_scanning"
	req_tech = list("magnets" = 6, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 320, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	reliability = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/triphasic
//	category = list("Stock Parts")

/datum/design/femto_mani
	name = "Femto Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "femto_mani"
	req_tech = list("materials" = 6, "programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 480, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	reliability = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/femto
//	category = list("Stock Parts")

/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "quadultra_micro_laser"
	req_tech = list("magnets" = 6, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 160, MAT_GLASS = 320, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250, MAT_URANIUM = 160)
	reliability = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/quadultra
//	category = list("Stock Parts")

/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "bluespace_matter_bin"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1280, MAT_SILVER = 300, MAT_GOLD = 300, MAT_DIAMOND = 400)
	reliability = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/bluespace
//	category = list("Stock Parts")


datum/design/telesci_gps
	name = "GPS Device"
	desc = "Little thingie that can track its position at all times."
	id = "telesci_gps"
	req_tech = list("materials" = 2, "magnets" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/device/gps

datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	id = "s-ansible"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_SILVER = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/ansible

datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	id = "s-filter"
	req_tech = list("programming" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 40, MAT_SILVER = 10)
	build_path = /obj/item/weapon/stock_parts/subspace/filter

datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	id = "s-amplifier"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GOLD = 30, MAT_URANIUM = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/amplifier

datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	id = "s-treatment"
	req_tech = list("programming" = 3, "magnets" = 2, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_SILVER = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/treatment

datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-analyzer"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GOLD = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/analyzer

datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-crystal"
	req_tech = list("magnets" = 4, "materials" = 4, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_SILVER = 20, MAT_GOLD = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/crystal

datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	id = "s-transmitter"
	req_tech = list("magnets" = 5, "materials" = 5, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 100, MAT_SILVER = 10, MAT_URANIUM = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/transmitter

////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

datum/design/basic_cell
	name = "Basic Power Cell"
	desc = "A basic power cell that holds 1000 units of energy"
	id = "basic_cell"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE |MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/cell
	construction_time=100
	category = list("Misc")

datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "A power cell that holds 10000 units of energy"
	id = "high_cell"
	req_tech = list("powerstorage" = 2)
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 60)
	build_path = /obj/item/weapon/stock_parts/cell/high
	construction_time=100
	category = list("Misc")

datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "A power cell that holds 20000 units of energy"
	id = "super_cell"
	req_tech = list("powerstorage" = 3, "materials" = 2)
	reliability = 75
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 70)
	build_path = /obj/item/weapon/stock_parts/cell/super
	construction_time=100
	category = list("Misc")

datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "A power cell that holds 30000 units of energy"
	id = "hyper_cell"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	reliability = 70
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 70, MAT_SILVER = 150, MAT_GOLD = 150)
	build_path = /obj/item/weapon/stock_parts/cell/hyper
	construction_time=100
	category = list("Misc")

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "A power cell that holds 40000 units of energy."
	id = "bluespace_cell"
	req_tech = list("powerstorage" = 6, "materials" = 5)
	reliability = 70
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 800, MAT_GLASS = 160, MAT_SILVER = 300, MAT_GOLD = 300, MAT_DIAMOND = 160)
//	construction_time=100
	build_path = /obj/item/weapon/stock_parts/cell/bluespace
//	category = list("Misc","Power Designs")
	category = list("Misc")


datum/design/light_replacer
	name = "Light Replacer"
	desc = "A device to automatically replace lights. Refill with working lightbulbs."
	id = "light_replacer"
	req_tech = list("magnets" = 3, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 3000, MAT_SILVER = 150)
	build_path = /obj/item/device/lightreplacer

////////////////////////////////////////
//////////////MISC Boards///////////////
////////////////////////////////////////

datum/design/smes
	name = "SMES Board"
	desc = "The circuit board for a SMES."
	id = "smes"
	req_tech = list("programming" = 4, "powerstorage" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes

/datum/design/space_heater
	name = "Machine Design (Space Heater Board)"
	desc = "The circuit board for a space heater."
	id = "space_heater"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/space_heater
	//category = list("Engineering Machinery")

datum/design/teleport_station
	name = "Teleportation Station Board"
	desc = "The circuit board for a teleportation station."
	id = "tele_station"
	req_tech = list("programming" = 4, "bluespace" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station

datum/design/teleport_hub
	name = "Teleportation Hub Board"
	desc = "The circuit board for a teleportation hub."
	id = "tele_hub"
	req_tech = list("programming" = 3, "bluespace" = 5, "materials" = 4, "engineering" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub

datum/design/telepad
	name = "Telepad Board"
	desc = "The circuit board for a telescience telepad."
	id = "telepad"
	req_tech = list("programming" = 4, "bluespace" = 4, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad

datum/design/sleeper
	name = "Sleeper Board"
	desc = "The circuit board for a sleeper."
	id = "sleeper"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper

datum/design/cryotube
	name = "Cryotube Board"
	desc = "The circuit board for a cryotube."
	id = "cryotube"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube

/datum/design/gas_heater
	name = "gas heating system"
	desc = "The circuit board for a heater."
	id = "gasheater"
	req_tech = list("powerstorage" = 2, "engineering" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/heater

/datum/design/gas_cooler
	name = "gas cooling system"
	desc = "The circuit board for a freezer."
	id = "gascooler"
	req_tech = list("magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cooler

datum/design/biogenerator
	name = "Biogenerator Board"
	desc = "The circuit board for a biogenerator."
	id = "biogenerator"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator

datum/design/hydroponics
	name = "Hydroponics Tray Board"
	desc = "The circuit board for a hydroponics tray."
	id = "hydro_tray"
	req_tech = list("programming" = 1, "biotech" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics

/datum/design/gibber
	name = "Machine Design (Gibber Board)"
	desc = "The circuit board for a gibber."
	id = "gibber"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/gibber
	//category = list ("Misc. Machinery")

/datum/design/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "The circuit board for a smartfridge."
	id = "smartfridge"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smartfridge
	//category = list ("Misc. Machinery")

/datum/design/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "The circuit board for a monkey recycler."
	id = "smartfridge"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/monkey_recycler
	//category = list("Misc. Machinery")

/datum/design/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "The circuit board for a seed extractor."
	id = "seed_extractor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/seed_extractor
	//category = list("Misc. Machinery")

/datum/design/processor
	name = "Machine Design (Processor Board)"
	desc = "The circuit board for a processor."
	id = "processor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/processor
	//category = list("Misc. Machinery")

//datum/design/recycler
//	name = "Machine Design (Recycler Board)"
//	desc = "The circuit board for a recycler."
//	id = "recycler"
//	req_tech = list("programming" = 1)
//	build_type = IMPRINTER
//	materials = list(MAT_GLASS = 1000, "sacid" = 20)
//	build_path = /obj/item/weapon/circuitboard/recycler
//	category = list("Misc. Machinery")

/datum/design/holopad
	name = "Machine Design (AI Holopad Board)"
	desc = "The circuit board for a holopad."
	id = "holopad"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/holopad
	//category = list("Misc. Machinery")

/datum/design/deepfryer
	name = "Deep Fryer Board"
	desc = "The circuit board for a deep fryer."
	id = "deepfryer"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/deepfryer

/datum/design/microwave
	name = "Microwave Board"
	desc = "The circuit board for a microwave."
	id = "microwave"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave

/datum/design/oven
	name = "Oven Board"
	desc = "The circuit board for a oven."
	id = "oven"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/oven

/datum/design/grill
	name = "Grill Board"
	desc = "The circuit board for a grill."
	id = "grill"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grill

/datum/design/candymaker
	name = "Candy Machine Board"
	desc = "The circuit board for a candy machine."
	id = "candymaker"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/candymaker

datum/design/chem_dispenser
	name = "Portable Chem Dispenser Board"
	desc = "The circuit board for a portable chem dispenser."
	id = "chem_dispenser"
	req_tech = list("programming" = 4, "biotech" = 3, "engineering" = 4, "materials" = 4, "phorontech" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser

/datum/design/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "The circuit board for a Chem Master 2999."
	id = "chem_master"
	req_tech = list("biotech" = 1, "materials" = 2, "programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_master
	//category = list("Medical Machinery")

datum/design/destructive_analyzer
	name = "Destructive Analyzer Board"
	desc = "The circuit board for a destructive analyzer."
	id = "destructive_analyzer"
	req_tech = list("programming" = 2, "magnets" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer

datum/design/protolathe
	name = "Protolathe Board"
	desc = "The circuit board for a protolathe."
	id = "protolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe

datum/design/circuit_imprinter
	name = "Circuit Imprinter Board"
	desc = "The circuit board for a circuit imprinter."
	id = "circuit_imprinter"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter

datum/design/emitter
	name = "Circuit Board Emitter"
	desc = "The circuit board for a emitter."
	id = "emitter"
	req_tech = list("programming" = 5, "engineering" = 5, "powerstorage" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/emitter

datum/design/autolathe
	name = "Autolathe Board"
	desc = "The circuit board for an autolathe."
	id = "autolathe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe

/datum/design/recharger
	name = "Machine Design (Weapon Recharger Board)"
	desc = "The circuit board for a Weapon Recharger."
	id = "recharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20, MAT_GOLD = 100)
	build_path = /obj/item/weapon/circuitboard/recharger
//	category = list("Misc. Machinery")

/datum/design/vendor
	name = "Machine Design (Vendor Board)"
	desc = "The circuit board for a Vendor."
	id = "vendor"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor
//	category = list("Misc. Machinery")

/datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "The circuit board for an Ore Redemption machine."
	id = "ore_redemption"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ore_redemption
//	category = list("Misc. Machinery")

/datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "The circuit board for a Mining Rewards Vender."
	id = "mining_equipment_vendor"
	req_tech = list("programming" = 1, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining_equipment_vendor
//	category = list("Misc. Machinery")

datum/design/rdservercontrol
	name = "R&D Server Control Console Board"
	desc = "The circuit board for an R&D Server Control Console"
	id = "rdservercontrol"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol

datum/design/rdserver
	name = "R&D Server Board"
	desc = "The circuit board for an R&D Server"
	id = "rdserver"
	req_tech = list("programming" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver

datum/design/mechfab
	name = "Exosuit Fabricator Board"
	desc = "The circuit board for an Exosuit Fabricator"
	id = "mechfab"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab

datum/design/cyborgrecharger
	name = "Cyborg Recharger Board"
	desc = "The circuit board for a Cyborg Recharger"
	id = "cyborgrecharger"
	req_tech = list("powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger

/datum/design/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	desc = "The circuit board for a tesla coil."
	id = "tesla_coil"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/tesla_coil
	//category = list("Misc. Machinery")

/datum/design/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	desc = "The circuit board for a grounding rod."
	id = "grounding_rod"
	req_tech = list("programming" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grounding_rod
	//category = list("Misc. Machinery")

/datum/design/mining_drill
	name = "Machine Design (Mining Drill Head)"
	desc = "Large drill for mining."
	id = "mining_drill"
	req_tech = list("powerstorage" = 3, "programming" = 3, "engineering" = 4, "magnets" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/miningdrill

/datum/design/mining_drill_brace
	name = "Machine Design (Mining Drill Brace)"
	desc = "Brace for mining drill."
	id = "mining_drill_brace"
	req_tech = list("powerstorage" = 3, "programming" = 3, "engineering" = 4, "magnets" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/miningdrillbrace

/datum/design/mining_fabricator
	name = "Machine Design (Mining fabricator)"
	desc = "For mining staff"
	id = "mining_fabricator"
	req_tech = list("powerstorage" = 3, "programming" = 3, "engineering" = 4, "magnets" = 4, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/minefab

/////////////////////////////////////////
////////////Power Stuff//////////////////
/////////////////////////////////////////

datum/design/pacman
	name = "PACMAN-type Generator Board"
	desc = "The circuit board that for a PACMAN-type portable generator."
	id = "pacman"
	req_tech = list("programming" = 3, "phorontech" = 3, "powerstorage" = 3, "engineering" = 3)
	build_type = IMPRINTER
	reliability = 79
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman

datum/design/superpacman
	name = "SUPERPACMAN-type Generator Board"
	desc = "The circuit board that for a SUPERPACMAN-type portable generator."
	id = "superpacman"
	req_tech = list("programming" = 3, "powerstorage" = 4, "engineering" = 4)
	build_type = IMPRINTER
	reliability = 76
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/super

datum/design/mrspacman
	name = "MRSPACMAN-type Generator Board"
	desc = "The circuit board that for a MRSPACMAN-type portable generator."
	id = "mrspacman"
	req_tech = list("programming" = 3, "powerstorage" = 5, "engineering" = 5)
	build_type = IMPRINTER
	reliability = 74
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/mrs


/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/mass_spectrometer

datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 74
	build_path = /obj/item/device/mass_spectrometer/adv

datum/design/reagent_scanner
	name = "Reagent Scanner"
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/reagent_scanner

datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 74
	build_path = /obj/item/device/reagent_scanner/adv

datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	reliability = 76
	build_path = /obj/item/device/mmi
	category = list("Misc")

datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1200, MAT_GLASS = 500)
	reliability = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = list("Misc")

datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	reliability = 76
	build_path = /obj/item/device/flash/synthetic
	category = list("Misc")

datum/design/cyborg_analyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "cyborg_analyzer"
	req_tech = list("materials" = 4, "engineering" = 5, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000, MAT_SILVER = 1500, MAT_DIAMOND = 1000)
	build_path = /obj/item/device/robotanalyzer

datum/design/nanopaste
	name = "nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste

datum/design/implanter
	name = "implanter"
	desc = "Implanter, used to inject implants."
	id = "implanter"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implanter

datum/design/implant_loyal
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	id = "implant_loyal"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/implantcase/loyalty

datum/design/implant_mindshield
	name = "Glass Case- 'MindShield'"
	desc = "A case containing a mindshield implant."
	id = "implant_mindshield"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/implantcase/mindshield

datum/design/implant_chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	id = "implant_chem"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/weapon/implantcase/chem

datum/design/implant_death
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	id = "implant_death"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implantcase/death_alarm

datum/design/implant_tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	id = "implant_tracking"
	req_tech = list("materials" = 2, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implantcase/tracking

datum/design/implant_free
	name = "Glass Case- 'Freedom'"
	desc = "A case containing a freedom implant."
	id = "implant_free"
	req_tech = list("syndicate" = 3, "biotech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/implantcase/freedom

datum/design/chameleon
	name = "Chameleon Kit"
	desc = "It's a set of clothes with dials on them."
	id = "chameleon"
	req_tech = list("syndicate" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/weapon/storage/box/syndie_kit/chameleon


datum/design/bluespacebeaker
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PHORON = 3000, MAT_DIAMOND = 500)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Misc")

datum/design/noreactbeaker
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = list("Misc")

datum/design/defibrillators_back
	name = "Defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators_back"
	req_tech = list("biotech" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 50)
	reliability = 76
	build_path = /obj/item/weapon/defibrillator

datum/design/defibrillators_belt
	name = "Compact defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators_compact"
	req_tech = list("biotech" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 50)
	reliability = 76
	build_path = /obj/item/weapon/defibrillator/compact

datum/design/defibrillators_standalone
	name = "Standalone defibrillators"
	desc = "Defibrillators to revive people."
	id = "defibrillators_standalone"
	req_tech = list("biotech" = 4, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/weapon/twohanded/shockpaddles/standalone

/datum/design/sensor_device
	name = "Handheld Crew Monitor"
	desc = "A device for tracking crew members on the station."
	id = "sensor_device"
	req_tech = list("biotech" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	reliability = 76
	build_path = /obj/item/device/sensor_device

datum/design/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	id = "scalpel_laser1"
	req_tech = list("biotech" = 2, "materials" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500)
	build_path = /obj/item/weapon/scalpel/laser1

datum/design/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	id = "scalpel_laser2"
	req_tech = list("biotech" = 3, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500)
	build_path = /obj/item/weapon/scalpel/laser2

datum/design/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500, MAT_SILVER = 2000, MAT_GOLD = 1500)
	build_path = /obj/item/weapon/scalpel/laser3

datum/design/scalpel_manager
	name = "Incision Management System"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	id = "scalpel_manager"
	req_tech = list("biotech" = 4, "materials" = 7, "magnets" = 5, "programming" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500, MAT_SILVER = 1500, MAT_GOLD = 1500, MAT_DIAMOND = 750)
	build_path = /obj/item/weapon/scalpel/manager

/datum/design/biocan
	name = "Biogel can"
	desc = "Medical device for sustaining life in head"
	id = "biocan"
	req_tech = list("biotech" = 3, "materials" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1200, MAT_GLASS = 1000)
	build_path = /obj/item/device/biocan

/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	id = "nuclear_gun"
	req_tech = list("combat" = 3, "materials" = 5, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_URANIUM = 500)
	reliability = 76
	build_path = /obj/item/weapon/gun/energy/gun/nuclear

datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "The prize of the Head of Security."
	id = "stunrevolver"
	req_tech = list("combat" = 3, "materials" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/weapon/gun/energy/stunrevolver

datum/design/lasercannon
	name = "Laser Cannon"
	desc = "A heavy duty laser cannon."
	id = "lasercannon"
	req_tech = list("combat" = 4, "materials" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000, MAT_URANIUM = 100)
	build_path = /obj/item/weapon/gun/energy/lasercannon

datum/design/decloner
	name = "Decloner"
	desc = "Your opponent will bubble into a messy pile of goop."
	id = "decloner"
	req_tech = list("combat" = 7, "materials" = 7, "biotech" = 5, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	build_path = /obj/item/weapon/gun/energy/decloner

datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "An advanced chem spraying device."
	id = "chemsprayer"
	req_tech = list("materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	reliability = 100
	build_path = /obj/item/weapon/reagent_containers/spray/chemsprayer

datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "A gun that fires many syringes."
	id = "rapidsyringe"
	req_tech = list("combat" = 3, "materials" = 3, "engineering" = 3, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/gun/syringe/rapidsyringe
/*
datum/design/largecrossbow
	name = "Energy Crossbow"
	desc = "A weapon favoured by syndicate infiltration teams."
	id = "largecrossbow"
	req_tech = list("combat" = 4, "materials" = 5, "engineering" = 3, "biotech" = 4, "syndicate" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_URANIUM = 1000)
	build_path = /obj/item/weapon/gun/energy/crossbow/largecrossbow
*/
datum/design/temp_gun
	name = "Temperature Gun"
	desc = "A gun that shoots temperature bullet energythings to change temperature."//Change it if you want
	id = "temp_gun"
	req_tech = list("combat" = 3, "materials" = 4, "powerstorage" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature

datum/design/tesla_gun
	name = "Tesla Cannon"
	desc = "A gun which uses electrical discharges to hit multiple targets"
	id = "tesla_gun"
	req_tech = list("combat" = 4, "materials" = 4, "powerstorage" = 5, "magnets" = 4, "engineering" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GOLD = 1000, MAT_SILVER = 4000)
	build_path = /obj/item/weapon/gun/tesla

datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells. Harmless to other organic life."
	id = "flora_gun"
	req_tech = list("materials" = 2, "biotech" = 3, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_URANIUM = 500)
	build_path = /obj/item/weapon/gun/energy/floragun

datum/design/large_grenade
	name = "Large Grenade"
	desc = "A grenade that affects a larger area and use larger containers."
	id = "large_Grenade"
	req_tech = list("combat" = 3, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	reliability = 79
	build_path = /obj/item/weapon/grenade/chem_grenade/large

/datum/design/l10
	name = "L10-c"
	desc = "A basic energy-based carbine with fast rate of fire."
	id = "l10"
	req_tech = list("combat" = 5, "materials" = 6, "magnets" = 4, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 4500, MAT_DIAMOND = 500, MAT_URANIUM = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic/l10c

/datum/design/l10_mag
	name = "L10-c battery"
	desc = "A special battery with protection from EM pulse."
	id = "l10_mag"
	req_tech = list("combat" = 4, "materials" = 5, "magnets" = 4, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_GOLD = 2000, MAT_SILVER = 1500)
	build_path = /obj/item/ammo_box/magazine/l10mag

datum/design/smg
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun."
	id = "smg"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic

datum/design/ammo_9mm
	name = "Ammunition Box (9mm)"
	desc = "A box of prototype 9mm ammunition."
	id = "ammo_9mm"
	req_tech = list("combat" = 4, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3750, MAT_SILVER = 100)
	build_path = /obj/item/ammo_box/magazine/msmg9mm

datum/design/stunslug
	name = "Stun Slug"
	desc = "A stunning, electrified slug for a shotgun."
	id = "stunshell"
	req_tech = list("combat" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/stunslug

datum/design/phoronpistol
	name = "phoron pistol"
	desc = "A specialized firearm designed to fire lethal bolts of phoron."
	id = "ppistol"
	req_tech = list("combat" = 5, "phorontech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PHORON = 3000)
	build_path = /obj/item/weapon/gun/energy/toxgun
/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	id = "jackhammer"
	req_tech = list("materials" = 3, "powerstorage" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/weapon/pickaxe/drill/jackhammer
	construction_time=100
	category = list("Tools")


datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	req_tech = list("materials" = 2, "powerstorage" = 3, "engineering" = 2)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill
	construction_time=100
	category = list("Tools")


datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	req_tech = list("materials" = 4, "phorontech" = 3, "engineering" = 3)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 1500, MAT_GLASS = 500, MAT_GOLD = 500, MAT_PHORON = 500)
	reliability = 79
	build_path = /obj/item/weapon/pickaxe/plasmacutter
	construction_time=300
	category = list("Tools")


datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."
	id = "pick_diamond"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 3000)
	build_path = /obj/item/weapon/pickaxe/diamond

datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	req_tech = list("materials" = 6, "powerstorage" = 4, "engineering" = 4)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 3750) //Yes, a whole diamond is needed.
	reliability = 79
	build_path = /obj/item/weapon/pickaxe/drill/diamond_drill
	construction_time=100
	category = list("Tools")


datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Used for seeing walls, floors, and stuff through anything."
	id = "mesons"
	req_tech = list("magnets" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/meson
	construction_time=100
	category = list("Tools")

datum/design/scaner_imp
	name = "Improved ore scaner"
	desc = "A complex device used to locate ore deep underground."
	id = "scaner_imp"
	req_tech = list("magnets" = 2, "engineering" = 3)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 2000)
	build_path = /obj/item/weapon/mining_scanner/improved
	construction_time=300
	category = list("Tools")

datum/design/scaner_adv
	name = "Advanced ore scaner"
	desc = "A complex device used to locate ore deep underground."
	id = "scaner_adv"
	req_tech = list("magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 8000, MAT_SILVER = 200, MAT_DIAMOND = 100)
	build_path = /obj/item/weapon/mining_scanner/improved/adv
	construction_time=450
	category = list("Tools")

/////////////////////////////////////////
//////////////Blue Space/////////////////
/////////////////////////////////////////

datum/design/beacon
	name = "Tracking Beacon"
	desc = "A blue space tracking beacon."
	id = "beacon"
	req_tech = list("bluespace" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 10)
	build_path = /obj/item/device/radio/beacon

datum/design/bag_holding
	name = "Bag of Holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	id = "bag_holding"
	req_tech = list("bluespace" = 4, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	reliability = 80
	build_path = /obj/item/weapon/storage/backpack/holding

datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_crystal"
	req_tech = list("bluespace" = 5, "materials" = 7)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_DIAMOND = 3000, MAT_PHORON = 1500)
	reliability = 100
	build_path = /obj/item/bluespace_crystal/artificial

/datum/design/miningsatchel_holding
	name = "Mining Satchel of Holding"
	desc = "A mining satchel that can hold an infinite amount of ores."
	id = "minerbag_holding"
	req_tech = list("bluespace" = 4, "materials" = 3, "engineering" = 4)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 500) //quite cheap, for more convenience
	build_path = /obj/item/weapon/storage/bag/ore/holding
	category = list("Tools")

/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	id = "health_hud"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/health

datum/design/security_hud
	name = "Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status."
	id = "security_hud"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security

datum/design/secmed_hud
	name = "Mixed HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and health status."
	id = "secmed_hud"
	req_tech = list("magnets" = 4, "combat" = 3, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/sunglasses/hud/secmed

datum/design/mining_hud
	name = "Geological Optical Scanner"
	desc = "A heads-up display that scans the rocks in view and provides some data about their composition."
	id = "mining_hud"
	req_tech = list("materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/mining

/////////////////////////////////////////
//////////////////Test///////////////////
/////////////////////////////////////////

	/*	test
			name = "Test Design"
			desc = "A design to test the new protolathe."
			id = "protolathe_test"
			build_type = PROTOLATHE
			req_tech = list("materials" = 1)
			materials = list(MAT_SILVER = 2500, MAT_GOLD = 3000, "iron" = 15, "copper" = 10)
			build_path = /obj/item/weapon/banhammer */

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 2.0
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
datum/design/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Allows for the construction of illegal upgrades for cyborgs"
	id = "borg_syndicate_module"
	build_type = MECHFAB
	req_tech = list("combat" = 4, "syndicate" = 3)
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(MAT_METAL = 10000, MAT_GLASS = 15000, MAT_DIAMOND = 10000)
	construction_time = 120
	category = list("Cyborg Upgrade Modules")

/////////////////////////////////////////
/////////////PDA and Radio stuff/////////
/////////////////////////////////////////
datum/design/standart_encrypt
	name = "Standard Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	id = "standart_encrypt"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 600)
	build_path = /obj/item/device/encryptionkey

datum/design/binaryencrypt
	name = "Binary Encrpytion Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."
	id = "binaryencrypt"
	req_tech = list("syndicate" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 600)
	build_path = /obj/item/device/encryptionkey/binary

datum/design/pda
	name = "PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a preprogrammed ROM cartridge."
	id = "pda"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/device/pda

datum/design/cart_basic
	name = "Generic Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_basic"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge

datum/design/cart_engineering
	name = "Power-ON Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_engineering"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/engineering

datum/design/cart_atmos
	name = "BreatheDeep Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_atmos"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/atmos

datum/design/cart_medical
	name = "Med-U Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_medical"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/medical

datum/design/cart_chemistry
	name = "ChemWhiz Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_chemistry"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/chemistry

datum/design/cart_security
	name = "R.O.B.U.S.T. Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_security"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/security

datum/design/cart_janitor
	name = "CustodiPRO Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_janitor"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/janitor

/datum/design/radio_grid
	name = "Radio Grid"
	desc = "A metal grid, attached to circuit to protect it from emitting."
	id = "radio_grid"
	req_tech = list("engineering" = 4, "powerstorage" = 3, "magnets" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 50)
	build_path = /obj/item/device/radio_grid

/*
datum/design/cart_clown
	name = "Honkworks 5.0 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_clown"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/clown

datum/design/cart_mime
	name = "Gestur-O 1000 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_mime"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/mime
*/

datum/design/cart_science
	name = "Signal Ace 2 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_science"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/signal/science

datum/design/cart_quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_quartermaster"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/quartermaster

datum/design/cart_hop
	name = "Human Resources 9001 Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_hop"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/hop

datum/design/cart_hos
	name = "R.O.B.U.S.T. DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_hos"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/hos

datum/design/cart_ce
	name = "Power-On DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_ce"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/ce

datum/design/cart_cmo
	name = "Med-U DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_cmo"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/cmo

datum/design/cart_rd
	name = "Signal Ace DELUXE Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_rd"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/rd

datum/design/cart_captain
	name = "Value-PAK Cartridge"
	desc = "A data cartridge for portable microcomputers."
	id = "cart_captain"
	req_tech = list("engineering" = 2, "powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/captain

///////////////////////////////
/////////////New stuff/////////
///////////////////////////////
datum/design/beacon_warp
	name = "Medical Tracking Beacon"
	desc = "A beacon used by a body teleporter."
	id = "beacon_warp"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000)
	build_path = /obj/item/device/beacon/medical

datum/design/body_warp
	name = "Medical Body Teleporter Device"
	desc = "A device used for teleporting injured or dead people."
	id = "body_warp"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3500, MAT_GLASS = 3500)
	build_path = /obj/item/weapon/medical/teleporter
	construction_time=100
	category = list("Support")

/datum/design/spraycan
	name = "Spraycan"
	id = "spraycan"
	desc = "A metallic container containing tasty paint."
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/toy/crayon/spraycan

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	id = "weldingmask"
	req_tech = list("materials" = 2, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "An experimental welder capable of self-fuel generation."
	id = "exwelder"
	req_tech = list("materials" = 4, "engineering" = 5, "bluespace" = 2, "phorontech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PHORON = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/weldingtool/experimental
	category = list("Equipment")

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "A small, compact Jaws of Life with an interchangable pry jaws and cutting jaws"
	id = "jawsoflife"
	req_tech = list("materials" = 4, "engineering" = 6, "magnets" = 6) // added one more requirment since the Jaws of Life are a bit OP
	build_path = /obj/item/weapon/crowbar/power
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2000, MAT_GOLD = 1000)
	category = list("Equipment")

/datum/design/handdrill
	name = "Hand Drill"
	desc = "A small electric hand drill with an interchangable screwdriver and bolt bit"
	id = "handdrill"
	req_tech = list("materials" = 4, "engineering" = 6, "magnets" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/screwdriver/power
	category = list("Equipment")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	id = "magboots"
	req_tech = list("materials" = 4, "magnets" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/datum/design/airbag
	name = "Personal airbag"
	desc = "One-use protection from high-speed collisions"
	id = "airbag"
	req_tech = list("biotech" = 2, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_SILVER = 500)
	build_path = /obj/item/airbag

/////////////////////////////////////////
////////////Janitor Designs//////////////
/////////////////////////////////////////

datum/design/advmop
	name = "Advanced Mop"
	desc = "An upgraded mop with a large internal capacity for holding water or other cleaning chemicals."
	id = "advmop"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/weapon/mop/advanced

datum/design/blutrash
	name = "Trashbag of Holding"
	desc = "An advanced trashbag with bluespace properties; capable of holding a plethora of garbage."
	id = "blutrash"
	req_tech = list("materials" = 5, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PHORON = 1500)
	build_path = /obj/item/weapon/storage/bag/trash/bluespace

datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "A holograpic projector used to project various warning signs."
	id = "holosign"
	req_tech = list("magnets" = 3, "powerstorage" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/holosign_creator
