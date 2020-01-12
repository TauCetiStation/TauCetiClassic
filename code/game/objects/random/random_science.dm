//SCIENCE
/obj/random/science/matter_bin
	name = "Random matter bin"
	desc = "This is a random tool."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "matter_bin"
/obj/random/science/matter_bin/item_to_spawn()
	return pick(\
					prob(75);/obj/item/weapon/stock_parts/matter_bin,\
					prob(25);/obj/item/weapon/stock_parts/matter_bin/adv,\
					prob(4);/obj/item/weapon/stock_parts/matter_bin/super,\
					prob(1);/obj/item/weapon/stock_parts/matter_bin/bluespace\
				)

/obj/random/science/micro_laser
	name = "Random micro laser"
	desc = "This is a random micro laser."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "micro_laser"
/obj/random/science/micro_laser/item_to_spawn()
	return pick(\
					prob(75);/obj/item/weapon/stock_parts/micro_laser,\
					prob(25);/obj/item/weapon/stock_parts/micro_laser/high,\
					prob(4);/obj/item/weapon/stock_parts/micro_laser/ultra,\
					prob(1);/obj/item/weapon/stock_parts/micro_laser/quadultra\
				)

/obj/random/science/capacitor
	name = "Random capacitor"
	desc = "This is a random capacitor."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
/obj/random/science/capacitor/item_to_spawn()
	return pick(\
					prob(75);/obj/item/weapon/stock_parts/capacitor,\
					prob(25);/obj/item/weapon/stock_parts/capacitor/adv,\
					prob(4);/obj/item/weapon/stock_parts/capacitor/super,\
					prob(1);/obj/item/weapon/stock_parts/capacitor/quadratic\
				)

/obj/random/science/scanning_module
	name = "Random matter scanning module"
	desc = "This is a random scanning module."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "scanning_module"
/obj/random/science/scanning_module/item_to_spawn()
	return pick(\
					prob(75);/obj/item/weapon/stock_parts/scanning_module,\
					prob(25);/obj/item/weapon/stock_parts/scanning_module/adv,\
					prob(4);/obj/item/weapon/stock_parts/scanning_module/phasic,\
					prob(1);/obj/item/weapon/stock_parts/scanning_module/triphasic\
				)

/obj/random/science/manipulator
	name = "Random matter manipulator"
	desc = "This is a random manipulator."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "manipulator"
/obj/random/science/manipulator/item_to_spawn()
	return pick(\
					prob(75);/obj/item/weapon/stock_parts/manipulator,\
					prob(25);/obj/item/weapon/stock_parts/manipulator/nano,\
					prob(4);/obj/item/weapon/stock_parts/manipulator/pico,\
					prob(1);/obj/item/weapon/stock_parts/manipulator/femto\
				)

/obj/random/science/stock_part
	name = "Random part"
	desc = "This is a random manipulator."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "manipulator"

/obj/random/science/stock_part/item_to_spawn()
	return pick(\
					/obj/random/science/manipulator,\
					/obj/random/science/scanning_module,\
					/obj/random/science/capacitor,\
					/obj/random/science/matter_bin,\
					/obj/random/science/micro_laser,\
					/obj/random/tools/powercell,\
					/obj/item/weapon/stock_parts/console_screen\
				)
/obj/random/science/common_circuit
	name = "Random machine circuit"
	desc = "This is a random machine circuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
/obj/random/science/common_circuit/item_to_spawn()
	return pick(\
					/obj/item/weapon/module/power_control,\
					/obj/item/weapon/airalarm_electronics,\
					/obj/item/weapon/firealarm_electronics,\
					/obj/item/weapon/airlock_electronics,\
					/obj/item/weapon/circuitboard/circuit_imprinter,\
					/obj/item/weapon/circuitboard/rdconsole,\
					/obj/item/weapon/circuitboard/destructive_analyzer,\
					/obj/item/weapon/circuitboard/protolathe,\
					/obj/item/weapon/circuitboard/autolathe,\
					/obj/item/weapon/circuitboard/chem_dispenser,\
					/obj/item/weapon/circuitboard/pandemic,\
					/obj/item/weapon/circuitboard/message_monitor,\
					/obj/item/weapon/circuitboard/arcade,\
					/obj/item/weapon/circuitboard/secure_data,\
					/obj/item/weapon/circuitboard/security,\
					/obj/item/weapon/circuitboard/skills\
				)
/obj/random/science/rare_circuit
	name = "Random machine circuit"
	desc = "This is a random machine circuit."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
/obj/random/science/rare_circuit/item_to_spawn()
	return pick(\
					/obj/item/weapon/circuitboard/mecha_control,\
					/obj/item/weapon/circuitboard/robotics,\
					/obj/item/weapon/circuitboard/communications,\
					/obj/item/weapon/circuitboard/card,\
					/obj/item/weapon/circuitboard/crew,\
					/obj/item/weapon/circuitboard/aiupload,\
					/obj/item/weapon/circuitboard/borgupload\
				)

/obj/random/science/common_ai_module
	name = "Random ai module"
	desc = "This is a random ai module."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
/obj/random/science/common_ai_module/item_to_spawn()
	return pick(\
					/obj/item/weapon/circuitboard/mecha_control,\
					/obj/item/weapon/circuitboard/robotics,\
					/obj/item/weapon/circuitboard/communications,\
					/obj/item/weapon/circuitboard/card,\
					/obj/item/weapon/circuitboard/crew,\
					/obj/item/weapon/circuitboard/aiupload,\
					/obj/item/weapon/circuitboard/borgupload\
				)
/obj/random/science/rare_ai_module
	name = "Random ai module rare"
	desc = "This is a random ai module rare."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
/obj/random/science/rare_ai_module/item_to_spawn()
	return pick(\
					/obj/item/weapon/aiModule/antimov,\
					/obj/item/weapon/aiModule/robocop,\
					/obj/item/weapon/aiModule/freeform/syndicate,\
					/obj/item/weapon/aiModule/freeform/core,\
					/obj/item/weapon/aiModule/tyrant,\
					/obj/item/weapon/aiModule/paladin,\
					/obj/item/weapon/aiModule/oxygen,\
					/obj/item/weapon/aiModule/oneHuman\
				)

/obj/random/science/circuit
	name = "Random circuit"
	desc = "This is a random circuit"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
/obj/random/science/circuit/item_to_spawn()
	return pick(\
					prob(100);/obj/random/science/common_circuit,\
					prob(8);/obj/random/science/rare_circuit,\
					prob(10);/obj/random/science/common_ai_module,\
					prob(2);/obj/random/science/rare_ai_module\
				)

/obj/random/science/slimecore
	name = "Random slime core"
	desc = "This is a random slime core"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
/obj/random/science/slimecore/item_to_spawn()
	return pick(subtypesof(/obj/item/slime_extract))

/obj/random/science/bomb_supply
	name = "Bomb Supply"
	desc = "This is a random bomb supply."
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "signaller"
/obj/random/science/bomb_supply/item_to_spawn()
	return pick(\
					prob(20);/obj/item/device/assembly/mousetrap,\
					prob(20);/obj/item/device/assembly/igniter,\
					prob(20);/obj/item/device/assembly/signaler,\
					prob(20);/obj/item/device/assembly/prox_sensor,\
					prob(20);/obj/item/device/assembly/timer,\
					prob(10);/obj/item/weapon/tank/phoron,\
					prob(10);/obj/item/weapon/tank/oxygen,\
					prob(10);/obj/item/device/transfer_valve,\
					prob(1);/obj/effect/spawner/newbomb/timer/syndicate
				)

/obj/random/science/science_supply
	name = "Random SCIENCE Supply"
	desc = "This is a random piece of science supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
/obj/random/science/science_supply/item_to_spawn()
	return pick(\
					prob(20);/obj/random/science/bomb_supply,\
					prob(5);/obj/random/science/slimecore,\
					prob(10);/obj/random/science/circuit,\
					prob(2);/obj/item/weapon/reagent_containers/spray/extinguisher,\
					prob(50);/obj/random/science/stock_part,\
					prob(1);/obj/item/device/encryptionkey/headset_sec,\
					prob(1);/obj/item/device/encryptionkey/headset_int,\
					prob(1);/obj/item/device/encryptionkey/headset_eng,\
					prob(1);/obj/item/device/encryptionkey/headset_rob,\
					prob(1);/obj/item/device/encryptionkey/headset_med,\
					prob(1);/obj/item/device/encryptionkey/headset_sci,\
					prob(1);/obj/item/device/encryptionkey/headset_medsci,\
					prob(1);/obj/item/device/encryptionkey/headset_com\
				)
