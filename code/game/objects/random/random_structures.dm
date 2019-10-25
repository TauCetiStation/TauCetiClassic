/obj/random/structures/common_crates
	name = "Common crates "
	desc = "This is a common crate supply."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
/obj/random/structures/common_crates/item_to_spawn()
	return pick(\
					/obj/structure/closet/crate/dwarf_agriculture,\
					/obj/structure/closet/crate/hydroponics/prespawned,\
					/obj/structure/closet/crate/freezer/rations,\
					/obj/structure/closet/crate/radiation,\
					/obj/structure/closet/wardrobe/red,\
					/obj/structure/closet/wardrobe/pink,\
					/obj/structure/closet/wardrobe/black,\
					/obj/structure/closet/wardrobe/chaplain_black,\
					/obj/structure/closet/wardrobe/green,\
					/obj/structure/closet/wardrobe/xenos,\
					/obj/structure/closet/wardrobe/orange,\
					/obj/structure/closet/wardrobe/yellow,\
					/obj/structure/closet/wardrobe/atmospherics_yellow,\
					/obj/structure/closet/wardrobe/engineering_yellow,\
					/obj/structure/closet/wardrobe/white,\
					/obj/structure/closet/wardrobe/pjs,\
					/obj/structure/closet/wardrobe/science_white,\
					/obj/structure/closet/wardrobe/robotics_black,\
					/obj/structure/closet/wardrobe/chemistry_white,\
					/obj/structure/closet/wardrobe/genetics_white,\
					/obj/structure/closet/wardrobe/virology_white,\
					/obj/structure/closet/wardrobe/medic_white,\
					/obj/structure/closet/wardrobe/grey,\
					/obj/structure/closet/wardrobe/mixed,\
					/obj/structure/closet/emcloset,\
					/obj/structure/closet/firecloset,\
					/obj/structure/closet/toolcloset,\
					/obj/structure/closet/radiation,\
					/obj/structure/closet/bombcloset,\
					/obj/structure/closet/bombclosetsecurity,\
					/obj/structure/closet/secure_closet/brig,\
					/obj/structure/closet/secure_closet/courtroom,\
					/obj/structure/closet/theatrecloset,\
					/obj/structure/closet/lawcloset,\
					/obj/structure/closet/jcloset,\
					/obj/structure/closet/gmcloset,\
					/obj/structure/closet/gimmick/tacticool,\
					/obj/structure/closet/gimmick/russian,\
					/obj/structure/closet/cabinet,\
					/obj/structure/closet/lasertag/blue,\
					/obj/structure/closet/lasertag/red,\
					/obj/structure/closet/masks,\
					/obj/structure/closet/boxinggloves,\
					/obj/structure/closet/athletic_mixed,\
					/obj/structure/closet/coffin,\
					/obj/structure/closet/crate/juice,\
					/obj/structure/closet/l3closet/general,\
					/obj/structure/closet/l3closet/virology,\
					/obj/structure/closet/l3closet/security,\
					/obj/structure/closet/l3closet/janitor,\
					/obj/structure/closet/l3closet/scientist,\
					/obj/structure/closet/secure_closet/freezer/kitchen,\
					/obj/structure/closet/secure_closet/freezer/meat,\
					/obj/structure/closet/secure_closet/freezer/fridge,\
					/obj/structure/closet/secure_closet/freezer/money\
				)

/obj/random/structures/proffessions_crates
	name = "Professions crates "
	desc = "This is a common crate supply."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
/obj/random/structures/proffessions_crates/item_to_spawn()
	return pick(\
					/obj/structure/closet/secure_closet/detective,\
					/obj/structure/closet/secure_closet/forensics,\
					/obj/structure/closet/secure_closet/warden,\
					/obj/structure/closet/secure_closet/security,\
					/obj/structure/closet/secure_closet/engineering_electrical,\
					/obj/structure/closet/secure_closet/engineering_welding,\
					/obj/structure/closet/secure_closet/engineering_personal,\
					/obj/structure/closet/secure_closet/atmos_personal,\
					/obj/structure/closet/secure_closet/bar,\
					/obj/structure/closet/secure_closet/cargotech,\
					/obj/structure/closet/secure_closet/recycler,\
					/obj/structure/closet/secure_closet/bar,\
					/obj/structure/closet/secure_closet/hydroponics,\
					/obj/structure/closet/secure_closet/scientist\
				)

/obj/random/structures/critters_crate
	name = "Professions critters crates "
	desc = "This is a critter crate supply."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
/obj/random/structures/critters_crate/item_to_spawn()
	return pick(\
					/obj/structure/closet/critter/corgi,\
					/obj/structure/closet/critter/cow,\
					/obj/structure/closet/critter/goat,\
					/obj/structure/closet/critter/chick,\
					/obj/structure/closet/critter/cat,\
					/obj/structure/closet/critter/pug\
				)


/obj/random/structures/rare_crates
	name = "Random SCIENCE Supply"
	desc = "This is a random piece of science supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
/obj/random/structures/rare_crates/item_to_spawn()
	return pick(\
					prob(20);/obj/structure/closet/secure_closet/medical1,\
					prob(20);/obj/structure/closet/secure_closet/medical2,\
					prob(20);/obj/structure/closet/secure_closet/medical3,\
					prob(20);/obj/structure/closet/secure_closet/animal,\
					prob(20);/obj/structure/closet/secure_closet/chemical,\
					prob(20);/obj/structure/closet/secure_closet/injection,\
					prob(10);/obj/structure/closet/wardrobe/tactical,\
					prob(5);/obj/structure/closet/syndicate/personal,\
					prob(3);/obj/structure/closet/syndicate/nuclear,\
					prob(15);/obj/structure/closet/syndicate/resources,\
					prob(1);/obj/structure/closet/syndicate/resources/everything,\
/*					prob(4);/obj/structure/closet/secure_closet/ert/commander,\
					prob(4);/obj/structure/closet/secure_closet/ert/security,\
					prob(4);/obj/structure/closet/secure_closet/ert/engineer,\
					prob(4);/obj/structure/closet/secure_closet/ert/medical,\*/
					prob(3);/obj/structure/closet/abductor,\
					prob(20);/obj/structure/closet/malf/suits,\
					prob(2);/obj/structure/closet/thunderdome/tdgreen,\
					prob(2);/obj/structure/closet/thunderdome/tdred\
				)


/obj/random/structures/generators
	name = "Professions critters crates "
	desc = "This is a critter crate supply."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
/obj/random/structures/generators/item_to_spawn()
	return pick(\
					prob(80);/obj/structure/stool/bed/chair/pedalgen,\
					prob(1);/obj/machinery/power/port_gen/riteg,\
					prob(20);/obj/machinery/power/port_gen/pacman,\
					prob(5);/obj/machinery/power/port_gen/pacman/super,\
					prob(5);/obj/machinery/power/port_gen/pacman/mrs,\
					prob(10);/obj/machinery/power/port_gen/pacman/scrap\
				)

/obj/random/structures/vendings
	name = "Random vendings "
	desc = "This is a critter crate supply."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
/obj/random/structures/vendings/item_to_spawn()
	return pick(\
					/obj/machinery/vending/boozeomat,\
					/obj/machinery/vending/assist,\
					/obj/machinery/vending/coffee,\
					/obj/random/vending/cola,\
					/obj/random/vending/snack,\
					/obj/machinery/vending/cart,\
					/obj/machinery/vending/cigarette,\
					/obj/machinery/vending/medical,\
					/obj/machinery/vending/phoronresearch,\
					/obj/machinery/vending/security,\
					/obj/machinery/vending/hydronutrients,\
					/obj/machinery/vending/hydroseeds,\
					/obj/machinery/vending/magivend,\
					/obj/machinery/vending/dinnerware,\
					/obj/machinery/vending/sovietsoda,\
					/obj/machinery/vending/tool,\
					/obj/machinery/vending/engivend,\
					/obj/machinery/vending/engineering,\
					/obj/machinery/vending/robotics,\
					/obj/machinery/vending/clothing,\
					/obj/machinery/vending/blood,\
					/obj/machinery/vending/holy,\
					/obj/machinery/vending/eva,\
					/obj/machinery/vending/omskvend,\
					/obj/machinery/vending/sustenance,\
					/obj/machinery/vending/theater,\
					/obj/machinery/vending/weirdomat\
				)

/obj/random/structures/misc
	name = "Random mixed structures "
	desc = "This is a critter crate supply."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
/obj/random/structures/misc/item_to_spawn()
	return pick(\
					prob(100);/obj/machinery/floodlight,\
					prob(100);/obj/machinery/space_heater,\
					prob(100);/obj/machinery/computer/arcade,\
					prob(100);/obj/structure/reagent_dispensers/fueltank,\
					prob(100);/obj/structure/reagent_dispensers/watertank,\
					prob(100);/obj/machinery/hydroponics/constructable,\
					prob(100);/obj/structure/stool/bed/chair/wheelchair,\
					prob(100);/obj/structure/stool/bed/roller,\
					prob(100);/obj/machinery/portable_atmospherics/powered/pump,\
					prob(100);/obj/machinery/portable_atmospherics/powered/scrubber,\
					prob(100);/obj/structure/kitchenspike,\
					prob(75);/obj/structure/stool/bed/chair/janitorialcart,\
					prob(40);/obj/machinery/power/grounding_rod,\
					prob(40);/obj/machinery/field_generator,\
					prob(40);/obj/machinery/power/rad_collector,\
					prob(40);/obj/machinery/iv_drip,\
					prob(30);/obj/machinery/power/emitter,\
					prob(30);/obj/machinery/flasher/portable,\
					prob(20);/obj/machinery/cell_charger,\
					prob(20);/obj/machinery/recharger,\
					prob(15);/obj/machinery/icecream_vat,\
					prob(15);/obj/structure/particle_accelerator/power_box,\
					prob(15);/obj/structure/particle_accelerator/particle_emitter/right,\
					prob(15);/obj/structure/particle_accelerator/particle_emitter/center,\
					prob(15);/obj/structure/particle_accelerator/particle_emitter/left,\
					prob(15);/obj/structure/particle_accelerator/fuel_chamber,\
					prob(15);/obj/structure/particle_accelerator/end_cap,\
					prob(15);/obj/machinery/particle_accelerator/control_box,\
				//	prob(10);/obj/machinery/atmospherics/binary/circulator,
					prob(10);/obj/machinery/power/tesla_coil,\
				//	prob(5);/obj/machinery/power/generator_type2,
					prob(5);/obj/structure/safe,\
					prob(5);/obj/machinery/the_singularitygen/tesla,\
					prob(5);/obj/machinery/the_singularitygen,\
					prob(1);/obj/machinery/nuclearbomb\
				)


/obj/random/structures/structure_pack
	name = "Random structures"
	desc = "This is a random piece of science supplies."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"

/obj/random/structures/structure_pack/item_to_spawn()
	return pick(\
					prob(100);/obj/random/structures/misc,\
					prob(65);/obj/random/structures/common_crates,\
					prob(33);/obj/random/structures/proffessions_crates,\
					prob(33);/obj/random/structures/critters_crate,\
					prob(33);/obj/random/structures/generators,\
					prob(33);/obj/random/structures/vendings,\
					prob(20);/obj/random/mecha/wreckage,\
					prob(7);/obj/random/structures/rare_crates,\
					prob(2);/obj/random/mecha/working\
				)
