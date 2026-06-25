/***************************************************************
**						Design Datums						  **
**	All the data for building stuff.                          **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc.
The currently supporting non-reagent materials:
- metal (/obj/item/stack/metal).
- glass (/obj/item/stack/glass).
- phoron (/obj/item/stack/phoron).
- silver (/obj/item/stack/silver).
- gold (/obj/item/stack/gold).
- uranium (/obj/item/stack/uranium).
- diamond (/obj/item/stack/diamond).
- Bananium (/obj/item/stack/Bananium).
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

/datum/design/New()
	all_designs += src

///////////////////Computer Boards///////////////////////////////////

/datum/design/seccamera
	name = "Circuit Design (Security)"
	desc = "Плата, используемая для сборки компьютера системы видеонаблюдения."
	id = "seccamera"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/security
	category = list("Computer")

/datum/design/telepad_concole
	name = " Circuit Design (Telescience Console) "
	desc = "Плата, используемая для сборки компьютера телепортации."
	id = "telepad_concole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_console
	category = list("Computer")

/datum/design/aicore
	name = "Circuit Design (AI Core)"
	desc = "Плата, изпользуемая для сборки новых ядер ИИ."
	id = "aicore"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aicore
	category = list("Machine")

/datum/design/aiupload
	name = "Circuit Design (AI Upload)"
	desc = "Плата, используемая для сборки консоли загрузки законов для ИИ."
	id = "aiupload"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/aiupload
	category = list("Computer")

/datum/design/borgupload
	name = "Circuit Design (Cyborg Upload)"
	desc = "Плата, используемая для сборки консоли загрузки законов для боргов."
	id = "borgupload"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/borgupload
	category = list("Computer")

/datum/design/med_data
	name = "Circuit Design (Medical Records)"
	desc = "Плата, используемая для сборки консоли с медицинскими записями."
	id = "med_data"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/med_data
	category = list("Computer")

/datum/design/operating
	name = "Circuit Design (Operating Computer)"
	desc = "Плата, используемая для сборки компьютера хирургического стола."
	id = "operating"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating
	category = list("Computer")

/datum/design/slime_management
	name = "Circuit Design (Slime management console)"
	desc = "Плата, используемая для сборки консоли управления слизью."
	id = "slime_management"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/camera_advanced/xenobio
	category = list("Computer")

/datum/design/scan_console
	name = "Circuit Design (DNA Machine)"
	desc = "Плата, используемая для сборки новой консоли для сканирования ДНК."
	id = "scan_console"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/scan_consolenew
	category = list("Machine")

/datum/design/comconsole
	name = "Circuit Design (Communications)"
	desc = "Плата, используемая для сборки коммуникационной консоли."
	id = "comconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/communications
	category = list("Computer")

/datum/design/idcardconsole
	name = "Circuit Design (ID Computer)"
	desc = "Плата, используемая для сборки компьютера идентификации."
	id = "idcardconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/card
	category = list("Computer")

/datum/design/crewconsole
	name = "Circuit Design (Crew monitoring computer)"
	desc = "Плата, используемая для сборки компьютера мониторинга состояния экипажа."
	id = "crewconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/crew
	category = list("Computer")

/datum/design/teleconsole
	name = "Circuit Design (Teleporter Console)"
	desc = "Плата, используемая для сборки консоли управления телепортатором."
	id = "teleconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter
	category = list("Computer")

/datum/design/secdata
	name = "Circuit Design (Security Records Console)"
	desc = "Плата, используемая для сборки консоли управления записями в системе безопасности."
	id = "secdata"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/secure_data
	category = list("Computer")

/datum/design/atmosalerts
	name = "Circuit Design (Atmosphere Alert)"
	desc = "Плата, используемая для сборки консоли оповещения об атмосферных тревогах."
	id = "atmosalerts"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/atmos_alert
	category = list("Computer")

/datum/design/air_management
	name = "Circuit Design (Atmospheric Monitor)"
	desc = "Плата, используемая для сборки атмосферного монитора."
	id = "air_management"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/air_management
	category = list("Computer")

/datum/design/robocontrol
	name = "Circuit Design (Robotics Control Console)"
	desc = "Плата, используемая для сборки консоли управления боргами."
	id = "robocontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/robotics
	category = list("Computer")

/datum/design/dronecontrol
	name = "Circuit Design (Drone Control Console)"
	desc = "Плата, используемая для сборки консоли управления ремонтными дронами."
	id = "dronecontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/drone_control
	category = list("Computer")

/datum/design/clonecontrol
	name = "Circuit Design (Cloning Machine Console)"
	desc = "Плата, используемая для сборки консоли клонирующей капсулы."
	id = "clonecontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cloning
	category = list("Computer")

/datum/design/clonepod
	name = "Circuit Design (Clone Pod)"
	desc = "Плата, используемая для сборки клонирующей капсулы."
	id = "clonepod"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonepod
	category = list("Machine")

/datum/design/clonescanner
	name = "Circuit Design (Cloning Scanner)"
	desc = "Плата, используемая для сборки сканера для клонирования."
	id = "clonescanner"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/clonescanner
	category = list("Machine")

/datum/design/arcademachine
	name = "Circuit Design (Arcade Machine)"
	desc = "Плата, используемая для сборки новых игровых автоматов."
	id = "arcademachine"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/arcade
	category = list("Computer")

/datum/design/powermonitor
	name = "Circuit Design (Power Monitor)"
	desc = "Плата, используемая для сборки консоли измерения энергопотребления."
	id = "powermonitor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/powermonitor
	category = list("Computer")

/datum/design/solarcontrol
	name = "Circuit Design (Solar Control)"
	desc = "Плата, используемая для сборки консоли управления солнечной батареей."
	id = "solarcontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/solar_control
	category = list("Computer")

/datum/design/prisonmanage
	name = "Circuit Design (Prisoner Management Console)"
	desc = "Плата, используемая для сборки консоли управления имплантами заключенных."
	id = "prisonmanage"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/prisoner
	category = list("Computer")

/datum/design/mechacontrol
	name = "Circuit Design (Exosuit Control Console)"
	desc = "Плата, используемая для сборки консоли мониторинга экзоскелетов."
	id = "mechacontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha_control
	category = list("Computer")

/datum/design/mechrecharger
	name = "circuit board (Mechbay Recharger)"
	desc = "Плата, используемая для сборки зарядного устройства для экзоскелетов."
	id = "mechrecharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_recharger
	category = list("Mech")

/datum/design/mechapower
	name = "Circuit Design (Mech Bay Power Control Console)"
	desc = "Плата, используемая для сборки консоли зарядного устройства для экзоскелетов."
	id = "mechapower"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mech_bay_power_console
	category = list("Mech")

/datum/design/rdconsole
	name = "Circuit Design (R&D Console)"
	desc = "Платп, используемая для сборки новой научно-исследовательской консоли."
	id = "rdconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdconsole
	category = list("Computer")

/datum/design/ordercomp
	name = "Circuit Design (Supply ordering console)"
	desc = "Плата, используемая для сборки консоли заказа товаров."
	id = "ordercomp"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/computer/cargo/request
	category = list("Computer")

/datum/design/supplycomp
	name = "Circuit Design (Supply shuttle console)"
	desc = "Плата, используемая для сборки консоли управления грузовым челноком."
	id = "supplycomp"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/computer/cargo
	category = list("Computer")

/datum/design/comm_monitor
	name = "Circuit Design (Telecommunications Monitoring Console)"
	desc = "Плата, используемая для сборки телекоммуникационного монитора."
	id = "comm_monitor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_monitor
	category = list("Telecomms")

/datum/design/comm_server
	name = "Circuit Design (Telecommunications Server Monitoring Console)"
	desc = "Плата, используемая для сборки устройства просмотра и мониторинга телекоммуникационного сервера."
	id = "comm_server"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/comm_server
	category = list("Telecomms")

/datum/design/message_monitor
	name = "Circuit Design (Messaging Monitor Console)"
	desc = "Плата, используемая для сборки консоли мониторинга сообщений."
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
	desc = "Плата, используемая для сборки новой библиотечной консоли."
	id = "libraryconsole"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/libraryconsole
	category = list("Computer")

/datum/design/cmf_console
	name = "Circuit Design (CMF Console)"
	desc = "Плата, используемая для сборки консоли модификаторов CMF."
	id = "cmf_console"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/skills_console
	category = list("Computer")

/datum/design/cmf_scanner
	name = "Circuit Design (CMF table)"
	desc = "Плата, используемая для сборки стола манипулирования CMF."
	id = "cmf_scanner"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/skill_scanner
	category = list("Machine")

///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////
/datum/design/safeguard_module
	name = "AI Module(Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."//
	id = "safeguard_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/safeguard
	category = list("AI")

/datum/design/onentemploye_module
	name = "AI Module (One NT Employe)"
	desc = "Allows for the construction of a 'One NT Employe' AI Module."//
	id = "onentemploye_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/onentemploye
	category = list("AI")

/datum/design/protectstation_module
	name = "AI Module (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."//
	id = "protectstation_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/protectStation
	category = list("AI")

/datum/design/notele_module
	name = "AI Module (TeleporterOffline Module)"
	desc = "Allows for the construction of a TeleporterOffline AI Module."//
	id = "notele_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/teleporterOffline
	category = list("AI")

/datum/design/quarantine_module
	name = "AI Module (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."//
	id = "quarantine_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/quarantine
	category = list("AI")

/datum/design/oxygen_module
	name = "AI Module (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."//
	id = "oxygen_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/oxygen
	category = list("AI")

/datum/design/freeform_module
	name = "AI Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."//
	id = "freeform_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/freeform
	category = list("AI")

/datum/design/reset_module
	name = "AI Module (Reset)"
	desc = "Allows for the construction of a Reset AI Module."//
	id = "reset_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/reset
	category = list("AI")

/datum/design/purge_module
	name = "AI Module (Purge)"
	desc = "Allows for the construction of a Purge AI Module."//
	id = "purge_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/purge
	category = list("AI")

/datum/design/freeform/core_module
	name = "AI Core Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."//
	id = "freeformcore_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/freeform/core
	category = list("AI")

/datum/design/asimov
	name = "AI Core Module (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."//
	id = "asimov_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/asimov
	category = list("AI")

/datum/design/paladin_module
	name = "AI Core Module (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."//
	id = "paladin_module"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_DIAMOND = 100, "sacid" = 20)
	build_path = /obj/item/weapon/aiModule/paladin
	category = list("AI")

/datum/design/tyrant_module
	name = "AI Core Module (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."//
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
	desc = "Плата, используемая для сборки Allows for the construction of Subspace Receiver equipment."//
	id = "s-receiver"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/receiver
	category = list("Telecomms")

/datum/design/telecomms_bus
	name = "Circuit Design (Bus Mainframe)"
	desc = "Плата, используемая для сборки Allows for the construction of Telecommunications Bus Mainframes."//
	id = "s-bus"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/bus
	category = list("Telecomms")

/datum/design/telecomms_hub
	name = "Circuit Design (Hub Mainframe)"
	desc = "Плата, используемая для сборки Allows for the construction of Telecommunications Hub Mainframes."//
	id = "s-hub"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/hub
	category = list("Telecomms")

/datum/design/telecomms_relay
	name = "Circuit Design (Relay Mainframe)"
	desc = "Плата, используемая для сборки главных узлов телекоммуникационной ретрансляции."
	id = "s-relay"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/relay
	category = list("Telecomms")

/datum/design/telecomms_processor
	name = "Circuit Design (Processor Unit)"
	desc = "Плата, используемая для сборки оборудования телекоммуникационных процессоров."
	id = "s-processor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/processor
	category = list("Telecomms")

/datum/design/telecomms_server
	name = "Circuit Design (Server Mainframe)"
	desc = "Плата, используемая для сборки телекоммуникационных серверов."
	id = "s-server"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telecomms/server
	category = list("Telecomms")

/datum/design/subspace_broadcaster
	name = "Circuit Design (Subspace Broadcaster)"
	desc = "Плата, используемая для сборки оборудования подпространственного вещания."
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
	desc = "Планшет для переноса и хранения личности ИИ."
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	build_path = /obj/item/device/aicard
	category = list("AI")

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Планшет с персональным искусственным интелектом. Искуственный - да, интелект - нет."
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/device/paicard
	category = list("AI")

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "Позитронный мозг - это сложный компьютерный процессор служащий искусственным разумом для роботов и наделяющий их зачатками сознания, логики и эмоций. Авторские права защищены Айзеком Азимовым."
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
	desc = "Плата центрального модуля управления \"Ripley\"."
	id = "ripley_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/main
	category = list("Mech")

/datum/design/ripley_peri
	name = "Circuit Design (APLU \"Ripley\" Peripherals Control module)"
	desc = "Плата переферийного модуля управления \"Ripley\"."
	id = "ripley_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ripley/peripherals
	category = list("Mech")

/datum/design/odysseus_main
	name = "Circuit Design (\"Odysseus\" Central Control module)"
	desc = "Плата центрального модуля управления \"Odysseus\"."
	id = "odysseus_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/main
	category = list("Mech")

/datum/design/odysseus_peri
	name = "Circuit Design (\"Odysseus\" Peripherals Control module)"
	desc = "Плата переферийного модуля управления \"Odysseus\"."
	id = "odysseus_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/odysseus/peripherals
	category = list("Mech")

/datum/design/gygax_main
	name = "Circuit Design (\"Gygax\" Central Control module)"
	desc = "Плата центрального модуля управления \"Gygax\"."
	id = "gygax_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/main
	category = list("Mech")

/datum/design/gygax_peri
	name = "Circuit Design (\"Gygax\" Peripherals Control module)"
	desc = "Плата переферийного модуля управления \"Gygax\"."
	id = "gygax_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/peripherals
	category = list("Mech")

/datum/design/gygax_targ
	name = "Circuit Design (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Плата управления модулем вооружения и наведения \"Gygax\"."
	id = "gygax_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/gygax/targeting
	category = list("Mech")

/datum/design/durand_main
	name = "Circuit Design (\"Durand\" Central Control module)"
	desc = "Плата центрального модуля управления \"Durand\"."
	id = "durand_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/main
	category = list("Mech")

/datum/design/durand_peri
	name = "Circuit Design (\"Durand\" Peripherals Control module)"
	desc = "Плата переферийного модуля управления \"Durand\"."
	id = "durand_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/peripherals
	category = list("Mech")

/datum/design/durand_targ
	name = "Circuit Design (\"Durand\" Weapons & Targeting Control module)"
	desc = "Плата управления модулем вооружения и наведения \"Durand\"."
	id = "durand_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/durand/targeting
	category = list("Mech")

/datum/design/vindicator_main
	name = "Circuit Design (\"Vindicator\" Central Control module)"
	desc = "Плата центрального модуля управления \"Vindicator\"."
	id = "vindicator_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/main
	category = list("Mech")

/datum/design/vindicator_peri
	name = "Circuit Design (\"Vindicator\" Peripherals Control module)"
	desc = "Плата переферийного модуля управления \"Vindicator\"."
	id = "vindicator_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/peripherals
	category = list("Mech")

/datum/design/vindicator_targ
	name = "Circuit Design (\"Vindicator\" Weapons & Targeting Control module)"
	desc = "Плата управления модулем вооружения и наведения \"Vindicator\"."
	id = "vindicator_targ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/vindicator/targeting
	category = list("Mech")

/datum/design/ultra_main
	name = "Circuit Design (\"Gygax Ultra\" Central Control module)"
	desc = "Плата центрального модуля управления \"Gygax Ultra\"."
	id = "ultra_main"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/main
	category = list("Mech")

/datum/design/ultra_peri
	name = "Circuit Design (\"Gygax Ultra\" Peripherals Control module)"
	desc = "Плата переферийного модуля управления \"Gygax Ultra\"."
	id = "ultra_peri"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mecha/ultra/peripherals
	category = list("Mech")

/datum/design/ultra_targ
	name = "Circuit Design (\"Gygax Ultra\" Weapons & Targeting Control module)"
	desc = "Плата управления модулем вооружения и наведения \"Gygax Ultra\"."
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
	desc = "Дополнительные диски для хранения данных прототипа устройств."
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/design_disk
	category = list("Misc")

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Дополнительные диски для хранения технологических данных."
	id = "tech_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weapon/disk/tech_disk
	category = list("Misc")

/datum/design/science_tool
	name = "Science Tool"
	desc = "Портативное устройство, способное оценивать полезные данные из различных источников, таких как бумажные отчеты, образцы слизистых оболочек и др."
	id = "science_tool"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/device/science_tool
	category = list("Misc")

/datum/design/portalgun
	name = "Portal Gun"
	desc = "Экспериментальный блюспейс проектор, способный создавать взаимосвязанные червоточины по желанию пользователя."
	id = "portalgun"
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 5000, MAT_SILVER = 5000, MAT_PHORON = 10000, MAT_URANIUM = 5000)
	build_path = /obj/item/weapon/gun/energy/gun/portal
	category = list("Misc")

////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Механическое устройство, предназначенное для хранения, сортировки и подачи стандартных машиностроительных деталей."
	id = "rped"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer
	category = list("Stock Parts")

/datum/design/BS_RPED
	name = "Bluespace RPED"
	desc = "Используя технологию блюспейс эта модификация RPED позволяет модернизировать устройства дистанционно, не снимая предварительно панель."
	id = "bs_rped"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_SILVER = 2500) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer/bluespace
	category = list("Stock Parts")

//Tier1
/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "basic_capacitor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 400) //2000 material per sheet.
	build_path = /obj/item/weapon/stock_parts/capacitor
	category = list("Stock Parts")

/datum/design/basic_sensor
	name = "Basic Sensor Module"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "basic_sensor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/scanning_module
	category = list("Stock Parts")

/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "micro_mani"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 240)
	build_path = /obj/item/weapon/stock_parts/manipulator
	category = list("Stock Parts")

/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "basic_micro_laser"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 80, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/micro_laser
	category = list("Stock Parts")

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "basic_matter_bin"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 640)
	build_path = /obj/item/weapon/stock_parts/matter_bin
	category = list("Stock Parts")

//Tier 2
/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "adv_capacitor"
	build_type = PROTOLATHE | MECHFAB | AUTOLATHE
	materials = list(MAT_METAL = 650, MAT_GLASS = 400)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv
	category = list("Stock Parts")

/datum/design/adv_sensor
	name = "Advanced Sensor Module"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "adv_sensor"
	build_type = PROTOLATHE | MECHFAB | AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 310)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv
	category = list("Stock Parts")

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "nano_mani"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 240, MAT_GLASS = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano
	category = list("Stock Parts")

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "AСтандартная деталь, используемая при создании различных устройств."
	id = "high_micro_laser"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 330, MAT_GLASS = 160)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high
	category = list("Stock Parts")

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "adv_matter_bin"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 640, MAT_GLASS = 300)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv
	category = list("Stock Parts")

//Tier 3
/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "super_capacitor"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 450)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv/super
	category = list("Stock Parts")

/datum/design/phasic_sensor
	name = "Phasic Sensor Module"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "phasic_sensor"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 600, MAT_GLASS = 390)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv/phasic
	category = list("Stock Parts")

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "pico_mani"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 340, MAT_GLASS = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano/pico
	category = list("Stock Parts")

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "ultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 380, MAT_GLASS = 310)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high/ultra
	category = list("Stock Parts")

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "super_matter_bin"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 840, MAT_GLASS = 300)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv/super
	category = list("Stock Parts")

//Tier 4
/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "quadratic_capacitor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv/super/quadratic
	category = list("Stock Parts")

/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "triphasic_scanning"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 320, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv/phasic/triphasic
	category = list("Stock Parts")

/datum/design/femto_mani
	name = "Femto Manipulator"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "femto_mani"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 480, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano/pico/femto
	category = list("Stock Parts")

/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "quadultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 160, MAT_GLASS = 320, MAT_SILVER = 250, MAT_GOLD = 250, MAT_DIAMOND = 250, MAT_URANIUM = 160)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high/ultra/quadultra
	category = list("Stock Parts")

/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	desc = "Стандартная деталь, используемая при создании различных устройств."
	id = "bluespace_matter_bin"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1280, MAT_SILVER = 300, MAT_GOLD = 300, MAT_DIAMOND = 400)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace
	category = list("Stock Parts")


/datum/design/telesci_gps
	name = "GPS Device"
	desc = "Устройство, способное в любой момент отслеживать свое местоположение."
	id = "telesci_gps"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	build_path = /obj/item/device/gps
	category = list("Equipment")

/datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "Компактный модуль, способный фиксировать внепространственную активность."
	id = "s-ansible"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80, MAT_SILVER = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/ansible
	category = list("Telecomms")

/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "Миниатюрное устройство, способное фильтровать и преобразовывать сверхмощные радиоволны."
	id = "s-filter"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 40, MAT_SILVER = 10)
	build_path = /obj/item/weapon/stock_parts/subspace/filter
	category = list("Telecomms")

/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "Компактное микроустройство, способное усиливать слабые подпространственные сигналы."
	id = "s-amplifier"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GOLD = 30, MAT_URANIUM = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/amplifier
	category = list("Telecomms")

/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "Компактное микроустройство, способное растягивать гиперсжатые радиоволны."
	id = "s-treatment"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_SILVER = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/treatment
	category = list("Telecomms")

/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "Сложный анализатор, способный анализировать скрытые длины волн подпространства."//
	id = "s-analyzer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GOLD = 15)
	build_path = /obj/item/weapon/stock_parts/subspace/analyzer
	category = list("Telecomms")

/datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "Сложный анализатор, способный анализировать скрытые длины волн подпространства."//
	id = "s-crystal"
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 1000, MAT_SILVER = 20, MAT_GOLD = 20)
	build_path = /obj/item/weapon/stock_parts/subspace/crystal
	category = list("Telecomms")

/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "Крупногабаритное оборудование, используемое для открытия «окна» в подпространственное измерение."
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
	desc = "Элемент питания, вмещающий 1000 условных единиц энергии."
	id = "basic_cell"
	build_type = PROTOLATHE | AUTOLATHE |MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/cell
	construction_time=100
	category = list("Stock Parts")

/datum/design/high_cell
	name = "High-Capacity Power Cell"
	desc = "Элемент питания, вмещающий 10000 условных единиц энергии."
	id = "high_cell"
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 60)
	build_path = /obj/item/weapon/stock_parts/cell/high/empty
	construction_time=100
	category = list("Stock Parts")

/datum/design/super_cell
	name = "Super-Capacity Power Cell"
	desc = "Элемент питания, вмещающий 20000 условных единиц энергии."
	id = "super_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 700, MAT_GLASS = 70)
	build_path = /obj/item/weapon/stock_parts/cell/super/empty
	construction_time=100
	category = list("Stock Parts")

/datum/design/hyper_cell
	name = "Hyper-Capacity Power Cell"
	desc = "Элемент питания, вмещающий 30000 условных единиц энергии."
	id = "hyper_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 400, MAT_GLASS = 70, MAT_SILVER = 150, MAT_GOLD = 150)
	build_path = /obj/item/weapon/stock_parts/cell/hyper/empty
	construction_time=100
	category = list("Stock Parts")

/datum/design/bluespace_cell
	name = "Bluespace Power Cell"
	desc = "Элемент питания, вмещающий 40000 условных единиц энергии."
	id = "bluespace_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 800, MAT_GLASS = 160, MAT_SILVER = 300, MAT_GOLD = 300, MAT_DIAMOND = 160)
//	construction_time=100
	build_path = /obj/item/weapon/stock_parts/cell/bluespace/empty
	category = list("Stock Parts")


/datum/design/light_replacer
	name = "Light Replacer"
	desc = "Устройство для автоматической замены ламп. Чтобы восполнить лампы используйте укрепленное стекло."
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
	desc = "Плата, используемая для сборки СПИНа."
	id = "smes"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smes
	category = list("Power")

/datum/design/space_heater
	name = "Machine Design (Space Heater Board)"
	desc = "Плата, используемая для сборки обогревателя."
	id = "space_heater"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/space_heater
	category = list("Machine")

/datum/design/teleport_station
	name = "Teleportation Station Board"
	desc = "Плата, используемая для сборки станции телепортации."
	id = "tele_station"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_station
	category = list("Machine")

/datum/design/teleport_hub
	name = "Teleportation Hub Board"
	desc = "Плата, используемая для сборки телепортационного узла."
	id = "tele_hub"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teleporter_hub
	category = list("Machine")

/datum/design/telepad
	name = "Telepad Board"
	desc = "Плата, используемая для сборки теленаучной телеплатформы."
	id = "telepad"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/telesci_pad
	category = list("Machine")

/datum/design/sleeper
	name = "Sleeper Board"
	desc = "Плата, используемая для сборки слипера."//sleeper
	id = "sleeper"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/sleeper
	category = list("Machine")

/datum/design/cryotube
	name = "Cryotube Board"
	desc = "Плата, используемая для сборки криокапсулы."
	id = "cryotube"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cryo_tube
	category = list("Machine")

/datum/design/board/reagentgrinder
	name = "All-In-One Grinder Board"
	desc = "Плата, используемая для сборки универсального миксера."
	id = "reagentgrinder"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/reagentgrinder
	category = list("Machine")

/datum/design/gas_heater
	name = "gas heating system"
	desc = "Плата, используемая для сборки вентиляционного обогревателя."
	id = "gasheater"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/heater
	category = list("Machine")

/datum/design/gas_cooler
	name = "gas cooling system"
	desc = "Плата, используемая для сборки вентиляционного кондиционера."
	id = "gascooler"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cooler
	category = list("Machine")

/datum/design/biogenerator
	name = "Biogenerator Board"
	desc = "Плата, используемая для сборки биогенератора."
	id = "biogenerator"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/biogenerator
	category = list("Machine")

/datum/design/hydroponics
	name = "Hydroponics Tray Board"
	desc = "Плата, используемая для сборки гидропонного лотка."
	id = "hydro_tray"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/hydroponics
	category = list("Machine")

/datum/design/gibber
	name = "Machine Design (Gibber Board)"
	desc = "Плата, используемая для сборки мясорубки."//gibber
	id = "gibber"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/gibber
	category = list("Machine")

/datum/design/smartfridge
	name = "Machine Design (Smartfridge Board)"
	desc = "Плата, используемая для сборки умного холодильника."
	id = "smartfridge"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smartfridge
	category = list("Machine")

/datum/design/bluespace_storage
	name = "Machine Design (Bluespace Storage)"
	desc = "Плата, используемая для сборки Блюспейс хранилища."
	id = "bluespace_storage"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1500, MAT_DIAMOND = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/smartfridge/secure/bluespace
	category = list("Machine")

/datum/design/monkey_recycler
	name = "Machine Design (Monkey Recycler Board)"
	desc = "Плата, используемая для сборки устройства по переработке обезьян."
	id = "monkey_recycler"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/monkey_recycler
	category = list("Machine")

/datum/design/seed_extractor
	name = "Machine Design (Seed Extractor Board)"
	desc = "Плата, используемая для сборки устройства извлечения семян различных культур."
	id = "seed_extractor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/seed_extractor
	category = list("Machine")

/datum/design/processor
	name = "Machine Design (Processor Board)"
	desc = "Плата, используемая для сборки кухонного комбайна"
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
	desc = "Плата, используемая для сборки голопанели."
	id = "holopad"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/holopad
	category = list("Machine")

/datum/design/deepfryer
	name = "Deep Fryer Board"
	desc = "Плата, используемая для сборки фритюрницы."
	id = "deepfryer"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/deepfryer
	category = list("Machine")

/datum/design/microwave
	name = "Microwave Board"
	desc = "Плата, используемая для сборки микроволновки."
	id = "microwave"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microwave
	category = list("Machine")

/datum/design/oven
	name = "Oven Board"
	desc = "Плата, используемая для сборки духовки."
	id = "oven"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/oven
	category = list("Machine")

/datum/design/grill
	name = "Grill Board"
	desc = "Плата, используемая для сборки гриля."
	id = "grill"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grill
	category = list("Machine")

/datum/design/candymaker
	name = "Candy Machine Board"
	desc = "Плата, используемая для сборки кондитерской машины."
	id = "candymaker"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/candymaker
	category = list("Machine")

/datum/design/chem_dispenser
	name = "Portable Chem Dispenser Board"
	desc = "Плата, используемая для сборки портативного дозатора химических веществ."
	id = "chem_dispenser"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_dispenser
	category = list("Machine")

/datum/design/chem_master
	name = "Machine Design (Chem Master Board)"
	desc = "Плата, используемая для сборки Chem Master 2999."
	id = "chem_master"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/chem_master
	category = list("Machine")

/datum/design/operating_table
	name = "Machine Design (Operating Table)"
	desc = "Плата, используемая для сборки операционного стола."
	id = "operating_table"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 3000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/operating_table
	category = list("Machine")

/datum/design/destructive_analyzer
	name = "Destructive Analyzer Board"
	desc = "Плата, используемая для сборки destructive analyzer."//Обратный инжиниринг?
	id = "destructive_analyzer"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/destructive_analyzer
	category = list("Machine")

/datum/design/protolathe
	name = "Protolathe Board"
	desc = "Плата, используемая для сборки protolathe."//ЧПУ станок для прототипов?
	id = "protolathe"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/protolathe
	category = list("Machine")

/datum/design/circuit_imprinter
	name = "Circuit Imprinter Board"
	desc = "Плата, используемая для сборки устройства оттиска печатных дорожек."
	id = "circuit_imprinter"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circuit_imprinter
	category = list("Machine")

/datum/design/emitter
	name = "Circuit Board Emitter"
	desc = "Плата, используемая для сборки излучателя."
	id = "emitter"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/emitter
	category = list("Machine")

/datum/design/autolathe
	name = "Autolathe Board"
	desc = "Плата, используемая для сборки autolathe."//ЧПУ станок?
	id = "autolathe"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/autolathe
	category = list("Machine")

/datum/design/recharger
	name = "Machine Design (Weapon Recharger Board)"
	desc = "Плата, используемая для сборки устройства перезарядки энергетического оружия."
	id = "recharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20, MAT_GOLD = 100)
	build_path = /obj/item/weapon/circuitboard/recharger
	category = list("Machine")
/datum/design/cell_recharger
	name = "Cell Recharger Board"
	desc = "Плата, используемая для сборки устройства зарядки аккумуляторов."
	id = "cellcharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 500, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cell_recharger
	category = list("Machine")
/datum/design/vendor
	name = "Machine Design (Vendor Board)"
	desc = "Плата, используемая для сборки торгового автомата."
	id = "vendor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/vendor
	category = list("Machine")

/datum/design/ore_redemption
	name = "Machine Design (Ore Redemption Board)"
	desc = "Плата, используемая для сборки устройства выкупа руды."
	id = "ore_redemption"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/ore_redemption
	category = list("Machine")

/datum/design/mining_equipment_vendor
	name = "Machine Design (Mining Rewards Vender Board)"
	desc = "Плата, используемая для сборки шахтёрского торгового автомата."
	id = "mining_equipment_vendor"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mining_equipment_vendor
	category = list("Machine")

/datum/design/rdservercontrol
	name = "R&D Server Control Console Board"
	desc = "Плата, используемая для сборки консоли управления научно-исследовательским сервером."
	id = "rdservercontrol"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdservercontrol
	category = list("Computer")

/datum/design/rdserver
	name = "R&D Server Board"
	desc = "Плата, используемая для сборки научно-исследовательского сервера."
	id = "rdserver"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/rdserver
	category = list("Machine")

/datum/design/mechfab
	name = "Exosuit Fabricator Board"
	desc = "Плата, используемая для сборки фабрикатора экзокостюмов."
	id = "mechfab"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/mechfab
	category = list("Mech")

/datum/design/cyborgrecharger
	name = "Cyborg Recharger Board"
	desc = "Плата, используемая для сборки зарядной станции боргов."
	id = "cyborgrecharger"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/cyborgrecharger
	category = list("Machine")

/datum/design/tesla_coil
	name = "Machine Design (Tesla Coil Board)"
	desc = "Плата, используемая для сборки катушки Теслы."
	id = "tesla_coil"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/tesla_coil
	category = list("Power")

/datum/design/grounding_rod
	name = "Machine Design (Grounding Rod Board)"
	desc = "Плата, используемая для сборки заземляющего стержня."
	id = "grounding_rod"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/grounding_rod
	category = list("Power")

/datum/design/mining_drill
	name = "Machine Design (Mining Drill Head)"
	desc = "Крупная дрель для горных работ."
	id = "mining_drill"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/miningdrill
	category = list("Machine")

/datum/design/expshovel
	name = "Experimental shovel"
	desc = "Экспериментальная лопата, которая копает чертовски быстро!"
	id = "expshovel"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/weapon/shovel/experimental
	category = list("Equipment")

/datum/design/mining_drill_brace
	name = "Machine Design (Mining Drill Brace)"
	desc = "Упор для буровой коронки."
	id = "mining_drill_brace"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/miningdrillbrace
	category = list("Machine")

/datum/design/mining_fabricator
	name = "Machine Design (Mining fabricator)"
	desc = "Плата, используемая для сборки шахтёрского фабрикатора."
	id = "mining_fabricator"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/minefab
	category = list("Machine")

/datum/design/microscope
	name = "Microscope Board"
	desc = "Плата, используемая для сборки криминалистического микроскопа."
	id = "microscope"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/microscope
	category = list("Machine")

/////////////////////////////////////////
////////////Power Stuff//////////////////
/////////////////////////////////////////

/datum/design/pacman
	name = "PACMAN-type Generator Board"
	desc = "Плата, используемая для сборки портативного генератора типа PACMAN."
	id = "pacman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman
	category = list("Power")

/datum/design/superpacman
	name = "SUPERPACMAN-type Generator Board"
	desc = "Плата, используемая для сборки портативного генератора типа SUPERPACMAN."
	id = "superpacman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/super
	category = list("Power")

/datum/design/mrspacman
	name = "MRSPACMAN-type Generator Board"
	desc = "Плата, используемая для сборки портативного генератора типа MRSPACMAN."
	id = "mrspacman"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/pacman/mrs
	category = list("Power")

/datum/design/circulator
	name = "Circulator Board"
	desc = "The circuit board for a TEG circulator."//
	id = "circ"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/circulator
	category = list("Power")

/datum/design/teg
	name = "TEG Board"
	desc = "The circuit board for a TEG generator."//
	id = "teg"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, "sacid" = 20)
	build_path = /obj/item/weapon/circuitboard/teg
	category = list("Power")

/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "Устройство для анализа химических веществ в крови."
	id = "mass_spectrometer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/mass_spectrometer
	category = list("Tools")

/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "Устройство для анализа химических веществ в крови и определения их количества."
	id = "adv_mass_spectrometer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/mass_spectrometer/adv
	category = list("Tools")

/datum/design/reagent_scanner
	name = "Reagent Scanner"
	desc = "Устройство для определения химических веществ."
	id = "reagent_scanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/reagent_scanner
	category = list("Tools")

/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "Устройство для определения химических веществ и их соотношения."
	id = "adv_reagent_scanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/device/reagent_scanner/adv
	category = list("Tools")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "Невзрачная аббревиатура MMI скрывает подлинный ужас этого устройства."//ЧМИ
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/device/mmi
	category = list("Misc")

/datum/design/mmi_radio
	name = "Radio-enabled Man-Machine Interface"
	desc = "Невзрачная аббревиатура MMI скрывает подлинный ужас этого устройства. Эта версия оснащена встроенным радиоприемником."//ЧМИ
	id = "mmi_radio"
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1200, MAT_GLASS = 500)
	build_path = /obj/item/device/mmi/radio_enabled
	category = list("Misc")

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "Когда возникает проблема, решение — это наука."
	id = "sflash"
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	build_path = /obj/item/device/flash/synthetic
	category = list("Misc")

/datum/design/cyborg_analyzer
	name = "Cyborg Analyzer"
	desc = "Ручной сканер, способный диагностировать повреждения у боргов."
	id = "cyborg_analyzer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000, MAT_SILVER = 1500, MAT_DIAMOND = 1000)
	build_path = /obj/item/device/robotanalyzer
	category = list("Tools")

/datum/design/nanopaste
	name = "nanopaste"
	desc = "Тюбик с пастой, содержащей рои ремонтных нанитов. Очень эффективен при ремонте роботизированной техники."
	id = "nanopaste"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	category = list("Support")

/datum/design/implanter
	name = "implanter"
	desc = "Имплантер, используемый для введения имплантатов."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implanter
	category = list("Support")

/datum/design/implant_loyal
	name = "Glass Case- 'Loyalty'"
	desc = "Футляр с имплантатом лояльности."
	id = "implant_loyal"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/implantcase/loyalty
	category = list("Support")

/datum/design/implant_mindshield
	name = "Glass Case- 'MindShield'"
	desc = "Футляр с имплантатом защиты разума."
	id = "implant_mindshield"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/implantcase/mindshield
	category = list("Support")

/datum/design/implant_chem
	name = "Glass Case- 'Chem'"
	desc = "Футляр с химическим имплантатом."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000,)
	build_path = /obj/item/weapon/implantcase/chem
	category = list("Support")

/datum/design/implant_death
	name = "Glass Case- 'Death Alarm'"
	desc = "Футляр с имплантатом 'сигнализатор о смерти'."//
	id = "implant_death"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implantcase/death_alarm
	category = list("Support")

/datum/design/implant_tracking
	name = "Glass Case- 'Tracking'"
	desc = "Футляр с имплантатом отслеживания."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/implantcase/tracking
	category = list("Support")

/datum/design/implant_free
	name = "Glass Case- 'Freedom'"
	desc = "Футляр с имплантатом освобождения."
	id = "implant_free"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/implantcase/freedom
	category = list("Illegal")

/datum/design/chameleon
	name = "Chameleon Kit"
	desc = "Комплект одежды хамелеон."
	id = "chameleon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/weapon/storage/box/syndie_kit/chameleon
	category = list("Illegal")

/datum/design/ai_detector
	name = "Artificial Intelligence Detector"
	desc = "Устройство, замаскированное под мультитул. Обнаруживает активность искусственного интеллекта."
	id = "ai_detector"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 500, MAT_GOLD = 500)
	build_path = /obj/item/device/multitool/ai_detect
	category = list("Illegal")

/datum/design/smuggler_satch
	name = "Smuggler's Satchel"
	desc = "Необычная сумка, которую можно поместить под напольной плиткой."
	id = "smuggler_satch"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/weapon/storage/backpack/satchel/flat
	category = list("Illegal")

/datum/design/voice_changer
	name = "Voice Changer"
	desc = "Противогаз с дополнительными фильтрами, влияющими на тембр вашего голоса."
	id = "voice_changer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_SILVER = 500)
	build_path = /obj/item/clothing/mask/gas/voice
	category = list("Illegal")

/datum/design/camera_bug
	name = "Camera Bug"
	desc = "Незаконное устройство для тайного наблюдения через сеть камер."
	id = "camera_bug"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 3000, MAT_DIAMOND = 2000, MAT_SILVER = 1000, MAT_GOLD = 500)
	build_path = /obj/item/device/camera_bug
	category = list("Illegal")

/datum/design/bluespacebeaker
	name = "bluespace beaker"
	desc = "Блюспейс-колба, работающая на экспериментальной блюспейс-технологии и Element Cuban в сочетании с Compound Pete."//
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_PHORON = 3000, MAT_DIAMOND = 500)
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Misc")

/datum/design/bluespacebeaker/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B = build_path
	desc += "Can hold up to [initial(B.volume)] units."

/datum/design/noreactbeaker
	name = "cryostasis beaker"
	desc = "Криостатическая емкость, позволяющая хранить различные вещества избегая химических реакций."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = list("Misc")

/datum/design/noreactbeaker/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B = build_path
	desc += "Can hold up to [initial(B.volume)] units."

/datum/design/defibrillators_back
	name = "Defibrillators"
	desc = "Дефибриллятор для реанимации людей."
	id = "defibrillators_back"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 50)
	build_path = /obj/item/weapon/defibrillator
	category = list("Support")

/datum/design/defibrillators_belt
	name = "Compact defibrillators"
	desc = "Дефибриллятор для реанимации людей."
	id = "defibrillators_compact"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 50)
	build_path = /obj/item/weapon/defibrillator/compact
	category = list("Support")

/datum/design/defibrillators_standalone
	name = "Standalone defibrillators"
	desc = "Дефибриллятор для реанимации людей."
	id = "defibrillators_standalone"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/weapon/shockpaddles/standalone
	category = list("Support")

/datum/design/sensor_device
	name = "Handheld Crew Monitor"
	desc = "Устройство для отслеживания экипажа на станции."
	id = "sensor_device"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/device/sensor_device
	category = list("Support")

/datum/design/detective_scanner
	name = "Forensic Scanner"
	desc = "Используется для дистанционного сканирования объектов и биомассы на предмет наличия ДНК и отпечатков. Позволяет распечатать отчет о результатах сканирования."
	id = "detective_scanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/device/detective_scanner
	category = list("Equipment")

/datum/design/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером для более точного разреза без разбрызгивания крови на операционном столе. Эта модель выглядит простой и может быть усовершенствована."
	id = "scalpel_laser1"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500)
	build_path = /obj/item/weapon/scalpel/laser1
	category = list("Support")

/datum/design/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером для более точного разреза без разбрызгивания крови на операционном столе. Эта модель выглядит довольно продвинуто."
	id = "scalpel_laser2"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500)
	build_path = /obj/item/weapon/scalpel/laser2
	category = list("Support")

/datum/design/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "Скальпель, дополненный направленным лазером для более точного разреза без разбрызгивания крови на операционном столе. Похоже, это вершина высокоточных энергетических хирургических скальпелей!"
	id = "scalpel_laser3"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500, MAT_SILVER = 2000, MAT_GOLD = 1500)
	build_path = /obj/item/weapon/scalpel/laser3
	category = list("Support")

/datum/design/scalpel_manager
	name = "Incision Management System"
	desc = "Будучи подлинным продолжением тела хирурга, это чудо техники мгновенно и безупречно подготавливает разрез, позволяя незамедлительно приступить к хирургическим манипуляциям."
	id = "scalpel_manager"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GLASS = 7500, MAT_SILVER = 1500, MAT_GOLD = 1500, MAT_DIAMOND = 750)
	build_path = /obj/item/weapon/scalpel/manager
	category = list("Support")

/datum/design/biocan
	name = "Biogel can"
	desc = "Медицинское устройство для поддержания жизни головы."
	id = "biocan"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1200, MAT_GLASS = 1000)
	build_path = /obj/item/device/biocan
	category = list("Support")

/datum/design/changeling_test
	name = "Changeling test"
	desc = "Позволяет выявлять скрытых подменышей."//
	id = "changtest"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 2000, MAT_DIAMOND = 3750, MAT_URANIUM = 4000)
	build_path = /obj/item/weapon/changeling_test
	category = list("Support")

/////////////////////////////////////////
/////////////////Weapons/////////////////
/////////////////////////////////////////

/datum/design/nuclear_gun
	name = "Advanced Energy Gun"
	desc = "Энергетическое оружие с экспериментальным миниатюрным реактором."
	id = "nuclear_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_URANIUM = 500)
	build_path = /obj/item/weapon/gun/energy/gun/nuclear
	category = list("Weapons")

/datum/design/stunrevolver
	name = "Stun Revolver"
	desc = "Награда начальника службы безопасности."
	id = "stunrevolver"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/weapon/gun/energy/taser/stunrevolver
	category = list("Weapons")

/datum/design/laserrifle
	name = "Extended-Capacity Laser Rifle"
	desc = "Стандартное оружие, предназначенное для убийства с помощью концентрированных энергетических зарядов. Эта модель имеет батарейку повышенной емкости и обладает большим размером."
	id = "laserrifle"
	build_type = PROTOLATHE
	materials = list (MAT_METAL = 8000, MAT_GLASS = 1000, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/gun/energy/laser/big
	category = list("Weapons")

/datum/design/laserpractice
	name = "Practice Laser Gun"
	desc = "Модифицированная версия стандартной лазерной винтовки, стреляет менее концентрированными энергетическими зарядами, предназначенными для стрельбы по мишеням."
	id = "laserpractice"
	build_type = PROTOLATHE
	materials = list (MAT_METAL = 1250, MAT_GLASS = 250)
	build_path = /obj/item/weapon/gun/energy/laser/practice
	category = list("Weapons")

/datum/design/lasercannon
	name = "Laser Cannon"
	desc = "В пушке Л.А.З.Е.Р. излучающая среда заключена в трубку с ураном-235 и подвергается воздействию высокого потока нейтронов в активной зоне ядерного реактора. Эта невероятная технология может помочь ВАМ достичь высоких скоростей электронного излучения при малых объемах лазера!"
	id = "lasercannon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 1000, MAT_DIAMOND = 2000, MAT_URANIUM = 100)
	build_path = /obj/item/weapon/gun/energy/lasercannon
	category = list("Weapons")

/datum/design/decloner
	name = "Decloner"
	desc = "Оружие, которое за счет большого количества контролируемого излучения постепенно разрушает цель на составные элементы."
	id = "decloner"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 5000,MAT_URANIUM = 10000)
	build_path = /obj/item/weapon/gun/energy/decloner
	category = list("Weapons")

/datum/design/chemsprayer
	name = "Chem Sprayer"
	desc = "Усовершенствованное устройство для распыления химикатов на большую площадь."
	id = "chemsprayer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/reagent_containers/spray/chemsprayer
	category = list("Weapons")

/datum/design/rapidsyringe
	name = "Rapid Syringe Gun"
	desc = "Оружие, стреляющее множеством шприцев."
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
	desc = "Оружие, стреляющее снарядами, которые меняют температуру."//Change it if you want
	id = "temp_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 500, MAT_SILVER = 3000)
	build_path = /obj/item/weapon/gun/energy/temperature
	category = list("Weapons")

/datum/design/emp_mine
	name = "EMP Mine"
	desc = "Мина, которая при активации генерирует ионный импульс."
	id = "emp_mine"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1500, MAT_GLASS = 100, MAT_URANIUM = 150)
	build_path = /obj/item/mine/emp
	category = list("Weapons")

/datum/design/tesla_gun
	name = "Tesla Cannon"
	desc = "Оружие, использующие электрический заряд для поражения нескольких целей. Вращайте рукоятку генератора, чтобы зарядить её."
	id = "tesla_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GOLD = 1000, MAT_SILVER = 4000)
	build_path = /obj/item/weapon/gun/tesla
	category = list("Weapons")

/datum/design/flora_gun
	name = "Floral Somatoray"
	desc = "Инструмент, чей принцип работы основывается на управляемом излучениее, вызывающий мутации в клетках растений."
	id = "flora_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_URANIUM = 500)
	build_path = /obj/item/weapon/gun/energy/floragun
	category = list("Weapons")

/datum/design/large_grenade
	name = "Large Grenade"
	desc = "Крупная граната, поражающая большую область."
	id = "large_Grenade"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/weapon/grenade/chem_grenade/large
	category = list("Weapons")

/datum/design/plasma_10_gun
	name = "plasma 10-bc"
	desc = "Стандартный плазменный карабин типа булл-пап обладающий высокой скорострельностью."
	id = "plasma_10_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 4500, MAT_DIAMOND = 500, MAT_URANIUM = 1000)
	build_path = /obj/item/weapon/gun/plasma
	category = list("Weapons")

/datum/design/plasma_104_gun
	name = "plasma 104-sass"
	desc = "Полуавтоматический короткоствольный дробовик на основе плазмы."
	id = "plasma_104_gun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 8000, MAT_DIAMOND = 750, MAT_URANIUM = 5000)
	build_path = /obj/item/weapon/gun/plasma/p104sass
	category = list("Weapons")

/datum/design/plasma_mag
	name = "plasma weapon battery pack"
	desc = "Специальный корпус аккумулятора с защитой от ЭМИ. Используется метод быстрой зарядки. Имеет стандартизированные размеры и может использоваться с любым плазмотроном данной серии. Возможна замена элемента питания."
	id = "plasma_mag"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_GOLD = 2000, MAT_SILVER = 1500)
	build_path = /obj/item/ammo_box/magazine/plasma
	category = list("Weapons")

/datum/design/smg
	name = "Submachine Gun"
	desc = "Легкий, скорострельный пистолет-пулемёт. Использует патроны калибра 9мм."
	id = "smg"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 8000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/gun/projectile/automatic/saber
	category = list("Weapons")

/datum/design/msmg9mm
	name = "SMG magazine (9mm)"
	desc = "Коробка с патронами, полный боеприпасов 9-мм для пистолета-пулемета."
	id = "smg_ammo_9mm"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3750, MAT_SILVER = 100)
	build_path = /obj/item/ammo_box/magazine/smg
	category = list("Weapons")

/datum/design/stunshot
	name = "Stun Shot"
	desc = "Коробка для ружейных патронов 'Электрошок'."
	id = "stunshell"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000)
	build_path = /obj/item/ammo_box/eight_shells/stunshot
	category = list("Weapons")

/datum/design/phoronpistol
	name = "phoron pistol"
	desc = "Специализированное огнестрельное оружие, предназначенное для стрельбы смертоносными зарядами форона."
	id = "ppistol"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000, MAT_PHORON = 3000)
	build_path = /obj/item/weapon/gun/energy/toxgun
	category = list("Weapons")

/datum/design/medigun
	name = "Medigun"
	desc = "Прототип лечебной пушки, которая медленно возвращает органику в прежнее состояние, исцеляя их."
	id = "medigun"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000, MAT_PHORON = 5000, MAT_GOLD = 1500, MAT_SILVER = 1500, MAT_DIAMOND = 2000)
	build_path = /obj/item/weapon/gun/medbeam
	category = list("Weapons")

/datum/design/sniperrifle
	name = "Sniper rifle"
	desc = "Снайперская винтовка W2500-E, разработанная компанией W&J, изготовлена из легких материалов и оснащена прицелом системы SMART."
	id = "sniperrifle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_GLASS = 7000, MAT_URANIUM = 5000, MAT_GOLD = 2500, MAT_SILVER = 2500, MAT_DIAMOND = 2000)
	build_path = /obj/item/weapon/gun/energy/sniperrifle
	category = list("Weapons")

/datum/design/pulse_rifle
	name = "Pulse rifle"
	desc = "Сверхмощное, импульсно-энергетическое оружие, используемое военными."
	id = "pulse_rifle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30000, MAT_GLASS = 15000, MAT_URANIUM = 12500, MAT_GOLD = 5000, MAT_SILVER = 5000, MAT_DIAMOND = 5000, MAT_PHORON = 20000)
	build_path = /obj/item/weapon/gun/energy/pulse_rifle
	category = list("Weapons")

/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////

/datum/design/jackhammer
	name = "Sonic Jackhammer"
	desc = "Раскалывает камни звуковыми импульсами — идеально подходит для уничтожения пещерных ящериц."
	id = "jackhammer"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 2000, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/weapon/pickaxe/drill/jackhammer
	construction_time=100
	category = list("Tools")


/datum/design/drill
	name = "Mining Drill"
	desc = "Твой бур пронзит скалы."
	id = "drill"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 6000, MAT_GLASS = 1000) //expensive, but no need for miners.
	build_path = /obj/item/weapon/pickaxe/drill
	construction_time=100
	category = list("Tools")

/datum/design/excavation_drill
	name = "Excavation Drill"
	desc = "Базовый археологический бур, сочетающий ультразвуковое воздействие и манипуляцию с блюспейс пространством для обеспечения высочайшей точности."
	id = "excavation_drill"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 5000, MAT_GLASS = 1000)
	build_path = /obj/item/weapon/pickaxe/excavationdrill
	construction_time = 100
	category = list("Tools")

/datum/design/excavation_drill_diamond
	name = "Diamond Excavation Drill"
	desc = "Усовершенствованный археологический бур, сочетающий ультразвуковое воздействие и манипуляцию с блюспейс пространством для обеспечения исключительно высокой точности."
	id = "excavation_drill_diamond"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 3750)
	build_path = /obj/item/weapon/pickaxe/excavationdrill/adv
	construction_time = 200
	category = list("Tools")

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "Этим можно отсекать конечности ксеносам! Или, ну, добывать ресурсы."
	id = "plasmacutter"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 1500, MAT_GLASS = 500, MAT_GOLD = 500, MAT_PHORON = 500)
	build_path = /obj/item/weapon/gun/energy/laser/cutter
	construction_time=300
	category = list("Tools")

/datum/design/pick_diamond
	name = "Diamond Pickaxe"
	desc = "Кирка с алмазным наконечником — прямо как в Minecraft."
	id = "pick_diamond"
	build_type = PROTOLATHE
	materials = list(MAT_DIAMOND = 3000)
	build_path = /obj/item/weapon/pickaxe/diamond
	category = list("Tools")

/datum/design/drill_diamond
	name = "Diamond Mining Drill"
	desc = "Твой бур пронзит небеса!"
	id = "drill_diamond"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_DIAMOND = 3750) //Yes, a whole diamond is needed.
	build_path = /obj/item/weapon/pickaxe/drill/diamond_drill
	construction_time=100
	category = list("Tools")


/datum/design/mesons
	name = "Optical Meson Scanners"
	desc = "Используется для того, чтобы видеть стены, полы и прочие объекты сквозь любые преграды."
	id = "mesons"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/meson
	construction_time=100
	category = list("Tools")

/datum/design/scaner_imp
	name = "Improved ore scaner"
	desc = "Сложное устройство, используемое для обнаружения руды глубоко под землей."
	id = "scaner_imp"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 2000)
	build_path = /obj/item/weapon/mining_scanner/improved
	construction_time=300
	category = list("Tools")

/datum/design/scaner_adv
	name = "Advanced ore scaner"
	desc = "Сложное устройство, используемое для обнаружения руды глубоко под землей."
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
	desc = "Блюспейс маяк для отслеживания в космосе."
	id = "beacon"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 10)
	build_path = /obj/item/device/radio/beacon
	category = list("Misc")

/datum/design/bag_holding
	name = "Bag of Holding"
	desc = "Рюкзак, который при открытии образует локализованный карман блюспейса."
	id = "bag_holding"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 3000, MAT_DIAMOND = 1500, MAT_URANIUM = 250)
	build_path = /obj/item/weapon/storage/backpack/holding
	category = list("Equipment")

/datum/design/bluespace_crystal
	name = "Artificial Bluespace Crystal"
	desc = "Небольшой синий кристалл с мистическими свойствами."
	id = "bluespace_crystal"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_DIAMOND = 3000, MAT_PHORON = 1500)
	build_path = /obj/item/bluespace_crystal/artificial
	category = list("Misc")

/datum/design/bluespacesatchel_holding
	name = "Bluespace Satchel"
	desc = "Блюспейс-cумка, способная вместить ОГРОМНОЕ количество растений, руды и тому подобного."
	id = "bluespacesatchel_holding"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 500) //quite cheap, for more convenience
	build_path = /obj/item/weapon/storage/bag/holding
	category = list("Tools")

/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/health_hud
	name = "Health Scanner HUD"
	desc = "Вспомогательный монокль со встроенным сканером на стекле линз, который сканирует находящихся в поле зрения людей и предоставляет точные данные о состоянии их здоровья."
	id = "health_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/health
	category = list("Support")

/datum/design/security_hud
	name = "Security HUD"
	desc = "Вспомогательный монокль со встроенным сканером на стекле линз, который сканирует находящихся в поле зрения людей и предоставляет сведения о правовом статусе личности."
	id = "security_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/security
	category = list("Support")

/datum/design/secmed_hud
	name = "Mixed HUD"
	desc = "Вспомогательные очки со встроенными сканерами на стекле линз, которые сканируют находящихся в поле зрения людей и предоставляют точные данные о состоянии их здоровья и сведения о правовом статусе личности."
	id = "secmed_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/sunglasses/hud/secmed
	category = list("Support")

/datum/design/mining_hud
	name = "Geological Optical Scanner"
	desc = "Вспомогательный монокль со встроенным сканером на стекле линз, который сканирует попадающие в поле зрения камни и предоставляет данные об их составе."
	id = "mining_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/clothing/glasses/hud/mining
	category = list("Support")

/datum/design/holochip
	name = "Holographic chip"
	desc = "Голографический чип для системы индикации карты станции и положения вас на ней на лобовом стекле шлема."
	id = "holochip"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100, MAT_GOLD = 200)
	build_path = /obj/item/holochip
	category = list("Support")

/datum/design/hud_calibrator
	name = "Рекалибратор дисплея"
	desc = "Рекалибрует дисплей с помощью интерференции волн, улучшая опыт пользования визуальным интерфейсом."
	id = "hud_calibrator"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 150)
	build_path = /obj/item/device/hud_calibrator
	category = list("Support")

/datum/design/hud_advanced
	name = "Advanced HUD"
	desc = "Продвинутый HUD с возможностью гибкой настройки."//что это?
	id = "advanced_hud"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	build_path = /obj/item/clothing/glasses/sunglasses/hud/advanced
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

/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////
/datum/design/borg_syndicate_module
	name = "Borg Illegal Weapons Upgrade"
	desc = "Модуль незаконного улучшения для боргов."
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
	desc = "Ключ шифрования для радиогарнитуры. Содержит шифровальные ключи."
	id = "standart_encrypt"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 600)
	build_path = /obj/item/device/encryptionkey
	category = list("Telecomms")

/datum/design/binaryencrypt
	name = "Binary Encrpytion Key"
	desc = "Ключ шифрования для радиогарнитуры. Содержит шифровальные ключи."
	id = "binaryencrypt"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 600)
	build_path = /obj/item/device/encryptionkey/binary
	category = list("Illegal")

/datum/design/pda
	name = "PDA"
	desc = "Портативный микрокомпьютер производства Thinktronic Systems, LTD. Функциональные возможности определяются предварительно запрограммированным картриджем с ПЗУ."
	id = "pda"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/device/pda
	category = list("PDA")

/datum/design/cart_basic
	name = "Generic Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_basic"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge
	category = list("PDA")

/datum/design/cart_engineering
	name = "Power-ON Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_engineering"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/engineering
	category = list("PDA")

/datum/design/cart_atmos
	name = "BreatheDeep Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_atmos"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/atmos
	category = list("PDA")

/datum/design/cart_medical
	name = "Med-U Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_medical"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/medical
	category = list("PDA")

/datum/design/cart_chemistry
	name = "ChemWhiz Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_chemistry"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/chemistry
	category = list("PDA")

/datum/design/cart_security
	name = "R.O.B.U.S.T. Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_security"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/security
	category = list("PDA")

/datum/design/cart_janitor
	name = "CustodiPRO Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_janitor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/janitor
	category = list("PDA")

/datum/design/radio_grid
	name = "Radio Grid"
	desc = "Металлическая сетка, которая защищает электронику гарнитуры от ЭМИ."
	id = "radio_grid"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 50)
	build_path = /obj/item/device/radio_grid
	category = list("Telecomms")

/*
/datum/design/cart_clown
	name = "Honkworks 5.0 Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_clown"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/clown
	category = list("PDA")

/datum/design/cart_mime
	name = "Gestur-O 1000 Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_mime"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/mime
	category = list("PDA")
*/

/datum/design/cart_science
	name = "Signal Ace 2 Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_science"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/signal/science
	category = list("PDA")

/datum/design/cart_quartermaster
	name = "Space Parts & Space Vendors Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_quartermaster"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/quartermaster
	category = list("PDA")

/datum/design/cart_hop
	name = "Human Resources 9001 Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_hop"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/hop
	category = list("PDA")

/datum/design/cart_hos
	name = "R.O.B.U.S.T. DELUXE Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_hos"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/hos
	category = list("PDA")

/datum/design/cart_ce
	name = "Power-On DELUXE Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_ce"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/ce
	category = list("PDA")

/datum/design/cart_cmo
	name = "Med-U DELUXE Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_cmo"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/cmo
	category = list("PDA")

/datum/design/cart_rd
	name = "Signal Ace DELUXE Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
	id = "cart_rd"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/cartridge/rd
	category = list("PDA")

/datum/design/cart_captain
	name = "Value-PAK Cartridge"
	desc = "Картридж с данными для портативного микрокомпьютера."
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
	desc = "Маяк, используемый телепортером тел."
	id = "beacon_warp"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000)
	build_path = /obj/item/device/beacon/medical
	category = list("Support")

/datum/design/body_warp
	name = "Medical Body Teleporter Device"
	desc = "Устройство, используемое для телепортации раненых или погибших людей."
	id = "body_warp"
	build_type = PROTOLATHE | MINEFAB
	materials = list(MAT_METAL = 3500, MAT_GLASS = 3500)
	build_path = /obj/item/weapon/medical/teleporter
	construction_time=100
	category = list("Support")

/datum/design/spraycan
	name = "Spraycan"
	id = "spraycan"
	desc = "Металлический контейнер с вкусной краской."
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list("Tools")

/datum/design/welding_mask
	name = "Welding Gas Mask"
	desc = "Противогаз со встроенными сварочными очками и защитным щитком для лица. Напоминает череп — явно работа какого-то гика."
	id = "weldingmask"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/clothing/mask/gas/welding
	category = list("Equipment")

/datum/design/exwelder
	name = "Experimental Welding Tool"
	desc = "Экспериментальный сварочный аппарат, способный самостоятельно вырабатывать топливо."
	id = "exwelder"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_PHORON = 1500, MAT_URANIUM = 200)
	build_path = /obj/item/weapon/weldingtool/experimental
	category = list("Tools")

/datum/design/jawsoflife
	name = "Jaws of Life"
	desc = "Небольшой, компактный инструмент Челюсти Жизни со сменными насадками: разжимными и режущими."
	id = "jawsoflife"
	build_path = /obj/item/weapon/multi/jaws_of_life
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2000, MAT_GOLD = 1000)
	category = list("Tools")

/datum/design/handdrill
	name = "Hand Drill"
	desc = "Небольшая электрическая ручная дрель со сменными насадками для болтов и винтиков."
	id = "handdrill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 2000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/multi/hand_drill
	category = list("Tools")

/datum/design/magboots
	name = "Magnetic Boots"
	desc = "Магнитные ботинки, часто используемые при работе в открытом космосе для надежного удержания космонавта на поверхности космического аппарата."
	id = "magboots"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4500, MAT_SILVER = 1500, MAT_GOLD = 2500)
	build_path = /obj/item/clothing/shoes/magboots
	category = list("Equipment")

/datum/design/airbag
	name = "Personal airbag"
	desc = "Одноразовая защита от сногсшибательных порывов ветра и низкого давления."
	id = "airbag"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_SILVER = 500)
	build_path = /obj/item/clothing/neck/airbag
	category = list("Support")

/datum/design/universal_pyrometer
	name = "Universal pyrometer"
	desc = "Пирометр со всеми возможными встроенными режимами. Элемент питания и модуль микролазера в комплект не входят!"
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
	desc = "Усовершенствованная швабра с большим внутренним резервуаром для воды или других чистящих средств."
	id = "advmop"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 200)
	build_path = /obj/item/weapon/mop/advanced
	category = list("Equipment")

/datum/design/blutrash
	name = "Trashbag of Holding"
	desc = "Усовершенствованный мешок для мусора с технологией блюспейс, способный вместить огромное количество мусора."
	id = "blutrash"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 1500, MAT_URANIUM = 250, MAT_PHORON = 1500)
	build_path = /obj/item/weapon/storage/bag/trash/bluespace
	category = list("Equipment")

/datum/design/holosign
	name = "Holographic Sign Projector"
	desc = "Голографический проектор, используемый для проецирования предупреждающих знаков."
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
	desc = "Система, помогающая пользователям РИГов."
	id = "rigsimpleai"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/simple_ai
	category = list("Rig Modules")

/datum/design/rigadvancedai
	name = "Hardsuit Advanced Diagnostic System"
	desc = "Система, помогающая пользователям РИГов."
	id = "rigadvancedai"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 500)
	build_path = /obj/item/rig_module/simple_ai/advanced
	category = list("Rig Modules")

/datum/design/rigflash
	name = "Hardsuit Mounted Flash"
	desc = "Ты — закон."
	id = "rigflash"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/device/flash
	category = list("Rig Modules")

/datum/design/riggrenadelauncherflashbang
	name = "Hardsuit Mounted Flashbang Grenade Launcher"
	desc = "Плечевая установка для отстрела микрозарядов, предназначенное исключительно для использования стандартных светошумовых гранат."
	id = "riggrenadelauncherflashbang"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GOLD = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/rig_module/grenade_launcher/flashbang
	category = list("Rig Modules")

/datum/design/rigmountedlaserrifle
	name = "Hardsuit Mounted Laser Rifle"
	desc = "Плечевая установка для лазерной винтовки с питанием от аккумулятора."
	id = "rigmountedlaserrifle"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 12500, MAT_GOLD = 6000, MAT_SILVER = 4500, MAT_DIAMOND = 500, MAT_URANIUM = 1000)
	build_path = /obj/item/rig_module/mounted
	category = list("Rig Modules")

/datum/design/rigmountedtaser
	name = "Hardsuit Mounted Taser"
	desc = "Плечевая установка для излучателя энергии нелетального действия."
	id = "rigmountedtaser"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_SILVER = 500)
	build_path = /obj/item/rig_module/mounted/taser
	category = list("Rig Modules")

/datum/design/righealthscanner
	name = "Hardsuit Health Scanner Module"
	desc = "Сканер здоровья, установленный на РИГе"
	id = "righealthscanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 100)
	build_path = /obj/item/rig_module/device/healthscanner
	category = list("Rig Modules")

/datum/design/rigdrill
	name = "Hardsuit Drill Mount"
	desc = "Установка на которой очень тяжелый бур с алмазным наконечником."
	id = "rigdrill"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 2000, MAT_DIAMOND = 2000)
	build_path = /obj/item/rig_module/device/drill
	category = list("Rig Modules")

/datum/design/riganomalyscanner
	name = "Hardsuit Anomaly Scanner Module"
	desc = "Кажется, это называется Elder Sarsparilla или что-то в этом роде."
	id = "riganomalyscanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/device/anomaly_scanner
	category = list("Rig Modules")

/datum/design/rigorescanner
	name = "Hardsuit Ore Scanner Module"
	desc = "Громоздкий старый сканер руды."
	id = "rigorescanner"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/device/orescanner
	category = list("Rig Modules")

/datum/design/rigrcd
	name = "Hardsuit RCD Mount"
	desc = "Устройство для быстрого возведения конструкций, работающее от энергоячейки и предназначенное для использования с РИГом."
	id = "rigrcd"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_GOLD = 4000, MAT_SILVER = 2000, MAT_DIAMOND = 1000)
	build_path = /obj/item/rig_module/device/rcd
	category = list("Rig Modules")

/datum/design/rigcombatinjector
	name = "Hardsuit Combat Chemical Injector"
	desc = "Сложная сеть трубок и игл, пригодная для использования в РИГе."
	id = "rigcombatinjector"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 500, MAT_SILVER = 500)
	build_path = /obj/item/rig_module/chem_dispenser/combat
	category = list("Rig Modules")

/datum/design/rigmedicalinjector
	name = "Hardsuit Medical Chemical Injector"
	desc = "Сложная сеть трубок и игл, пригодная для использования в РИГе."
	id = "rigmedicalinjector"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000, MAT_GOLD = 1000, MAT_SILVER = 1000)
	build_path = /obj/item/rig_module/chem_dispenser/medical
	category = list("Rig Modules")

/datum/design/rigselfrepair
	name = "Hardsuit Self-Repair Module"
	desc = "Выглядящий довольно сложным комплект, полный инструментов."
	id = "rigselfrepair"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20000, MAT_GLASS = 2000, MAT_GOLD = 1000)
	build_path = /obj/item/rig_module/selfrepair
	category = list("Rig Modules")

/datum/design/rigmedteleport
	name = "Hardsuit Medical Teleport System"
	desc = "Система, способная спасти владельца скафандра."
	id = "rigmedteleport"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 4000, MAT_GOLD = 2000, MAT_DIAMOND = 500)
	build_path = /obj/item/rig_module/med_teleport
	category = list("Rig Modules")

/datum/design/rignuclearreactor
	name = "Hardsuit Nuclear Reactor Module"
	desc = "Пассивно вырабатывает энергию. Становится крайне нестабильным при повреждении."
	id = "rignuclearreactor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_GOLD = 6000, MAT_URANIUM = 4000)
	build_path = /obj/item/rig_module/nuclear_generator
	category = list("Rig Modules")

/datum/design/rigcoolingunit
	name = "Hardsuit Mounted Cooling Unit"
	desc = "Радиатор с жидкостным охлаждением."
	id = "rigcoolingunit"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_DIAMOND = 200)
	build_path = /obj/item/rig_module/cooling_unit
	category = list("Rig Modules")

/datum/design/rigextinguisher
	name = "Hardsuit Fire Extinguisher"
	desc = "Огнетушитель, устанавливаемый на РИГ и предназначенный для работы в опасных условиях."
	id = "rigextinguisher"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/rig_module/device/extinguisher
	category = list("Rig Modules")

/datum/design/rigmetalfoamspray
	name = "Hardsuit Metal Foam Spray"
	desc = "Устройство для распыления металлической пены, устанавливаемое на РИГ и предназначенное для быстрой заделки пробоин."
	id = "rigmetalfoamspray"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/metalfoam_spray
	category = list("Rig Modules")

/datum/design/riganalyzer
	name = "Hardsuit Analyzer Module"
	desc = "Сканер атмосферных явлений и аномалий, устанавливаемый на РИГ."
	id = "riganalyzer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/device/analyzer
	category = list("Rig Modules")

/datum/design/rigsciencetool
	name = "Hardsuit Science Tool Module"
	desc = "Инструмент для сбора очков исследований, устанавливаемый на РИГ."
	id = "rigsciencetool"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/device/science_tool
	category = list("Rig Modules")

/datum/design/rigrelay
	name = "Hardsuit Mounted Relay Module"
	desc = "Может ретранслировать радиосигналы из других секторов."
	id = "rigrelay"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_GOLD = 8000, MAT_URANIUM = 4000, MAT_PHORON = 8000, MAT_DIAMOND = 3000)
	build_path = /obj/item/rig_module/mounted_relay
	category = list("Rig Modules")

/datum/design/rigstabilizer
	name = "Hardsuit Teleporter stabilizer"
	desc = "Специальное устройство для стабилизации помех в блюспейсе, возникающих во время телепортации."
	id = "rigstabilizer"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 2000, MAT_GOLD = 2000, MAT_PHORON = 4000)
	build_path = /obj/item/rig_module/teleporter_stabilizer
	category = list("Rig Modules")

/datum/design/hardsuit_emp_shield
	name = "Hardsuit EMP shield"
	desc = "Устройство для защиты РИГа от электромагнитного импульса."
	id = "rigempshield"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/rig_module/emp_shield
	category = list("Rig Modules")
/datum/design/rigstealth
	name = "Hardsuit stealth system"
	desc = "Система, делающая РИГ и её пользователя невидимым. Картонная коробка в комплект не входит."
	id = "rigstealth"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 10000, MAT_SILVER = 5000, MAT_GOLD = 5000, MAT_DIAMOND = 10000, MAT_PHORON = 5000)
	build_path = /obj/item/rig_module/stealth
	category = list("Rig Modules")

/////////////////////////////////////////
////////////////Upgrades/////////////////
/////////////////////////////////////////

/datum/design/tier1_hud_upgrade
	name = "Damage Scan Upgrade"
	desc = "Модификация, позволяющая HUD отображать повреждения, наносимые кому-либо."
	id = "tier1_hud_upgrade"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/hud_upgrade/medscan
	category = list("Special upgrades")

/datum/design/tier2_hud_upgrade
	name = "Basic Nightvision HUD upgrade"
	desc = "Модификация, позволяющая HUD активировать базовый режим ночного видения. Установка возможна только после установки улучшения для сканирования повреждений."
	id = "tier2_hud_upgrade"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_URANIUM = 2000)
	build_path = /obj/item/hud_upgrade/night
	category = list("Special upgrades")

/datum/design/tier3_hud_upgrade
	name = "Thermal HUD upgrade"
	desc = "Модификация, позволяющая HUD активировать базовый тепловизионного режим и делает использование режима ночного видения более комфортным. Установка возможна только после установки системы ночного видения."
	id = "tier3_hud_upgrade"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_PHORON = 2500)
	build_path = /obj/item/hud_upgrade/thermal
	category = list("Special upgrades")

/datum/design/tier4_hud_upgrade
	name = "Advanced Thermal HUD upgrade"
	desc = "Модификация, делающая использование тепловизионного режима более комфортным и совмещающая его с режимом ночного видения. Установка возможна только после установки тепловизора."
	id = "tier4_hud_upgrade"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_GOLD = 1500, MAT_URANIUM = 3000, MAT_PHORON = 3500)
	build_path = /obj/item/hud_upgrade/thermal_advanced
	category = list("Special upgrades")

/////////////////////////////////////////
//////////////////Armor//////////////////
/////////////////////////////////////////

/datum/design/ds_helmet
	name = "Deathsquad helmet"
	desc = "Это не красная краска. Это кровь."
	id = "ds_helmet"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 8000, MAT_GOLD = 2500, MAT_URANIUM = 4500, MAT_PHORON = 5000)
	build_path = /obj/item/clothing/head/helmet/space/deathsquad
	category = list("Armor")

/datum/design/ds_armor
	name = "SWAT Suit"
	desc = "Тяжелый бронированный костюм, защищающий от умеренного количества повреждений. Используется в специальных операциях."
	id = "ds_armor"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50000, MAT_GLASS = 25000, MAT_GOLD = 8000, MAT_URANIUM = 12500, MAT_PHORON = 15000)
	build_path = /obj/item/clothing/suit/armor/swat
	category = list("Armor")

/datum/design/ds_boots
	name = "SWAT shoes"
	desc = "Когда нужно поддать жару."
	id = "ds_boots"
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GOLD = 2000, MAT_PHORON = 4000)
	build_path = /obj/item/clothing/shoes/boots/swat
	category = list("Armor")
