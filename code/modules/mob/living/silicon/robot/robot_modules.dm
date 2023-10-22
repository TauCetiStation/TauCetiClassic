/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = SIZE_LARGE
	item_state = "electronic"
	flags = CONDUCT
	var/list/channels = list()
	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null
	var/list/stacktypes

/obj/item/weapon/robot_module/atom_init()
	. = ..()

	var/mob/living/silicon/robot/R = loc

	add_languages(R)

/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emplode(severity)
	if(emag)
		emag.emplode(severity)
	..()
	return

/obj/item/weapon/robot_module/Destroy()
	for(var/obj/O in modules)
		qdel(O)
	modules.Cut()
	qdel(emag)
	qdel(jetpack)
	emag = null
	jetpack = null
	return ..()


/obj/item/weapon/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R)
	var/obj/item/device/flash/F = locate() in src.modules
	if(F)
		if(F.broken)
			F.broken = 0
			F.times_used = 0
			F.icon_state = "flash"
		else if(F.times_used)
			F.times_used--

	if(!stacktypes || !stacktypes.len) return

	for(var/T in stacktypes)
		var/O = locate(T) in src.modules
		var/obj/item/stack/S = O

		if(!S)
			src.modules -= null
			S = new T(src, 1)
			add_item(S)

		if(S.get_amount() < stacktypes[T])
			S.add(1)

/obj/item/weapon/robot_module/proc/add_languages(mob/living/silicon/robot/R)
	R.add_language(LANGUAGE_TRADEBAND)
	R.add_language(LANGUAGE_TRINARY)
	R.add_language(LANGUAGE_SOLCOMMON)

/obj/item/weapon/robot_module/proc/add_item(obj/O)
	O.forceMove(src)
	modules += O
	var/mob/living/silicon/robot/R = loc
	R.hud_used.update_robot_modules_display()

/obj/item/weapon/robot_module/proc/remove_item(obj/O)
	if(!(locate(O) in modules))
		return
	modules -= O
	var/mob/living/silicon/robot/R = loc
	R.unequip_module(O)
	qdel(O)

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
	stacktypes = list(
		/obj/item/stack/medical/ointment = 5,
		/obj/item/stack/medical/bruise_pack = 5
		)

/obj/item/weapon/robot_module/standard/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/reagent_containers/spray/extinguisher/cyborg(src)
	modules += new /obj/item/weapon/weldingtool(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/stack/medical/ointment(src)
	modules += new /obj/item/stack/medical/bruise_pack(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/medical(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/reagent_containers/food/snacks/soap/nanotrasen(src)
	modules += new /obj/item/device/gps/cyborg(src)
	emag = new /obj/item/weapon/melee/energy/sword(src)

/obj/item/weapon/robot_module/medical
	name = "medical robot module"
	stacktypes = list(
		/obj/item/stack/medical/advanced/bruise_pack = 6,
		/obj/item/stack/medical/advanced/ointment = 6,
		/obj/item/stack/nanopaste = 10,
		/obj/item/stack/medical/splint = 5
		)

/obj/item/weapon/robot_module/medical/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/medical(src)
	modules += new /obj/item/weapon/scalpel/manager(src)
	modules += new /obj/item/weapon/FixOVein(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/bonegel(src)
	modules += new /obj/item/weapon/bonesetter(src)
	modules += new /obj/item/weapon/circular_saw(src)
	modules += new /obj/item/weapon/surgicaldrill(src)
	modules += new /obj/item/weapon/razor(src)
	modules += new /obj/item/weapon/reagent_containers/spray/extinguisher/cyborg/mini(src)
	modules += new /obj/item/stack/medical/advanced/bruise_pack(src)
	modules += new /obj/item/stack/medical/advanced/ointment(src)
	modules += new /obj/item/stack/nanopaste(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/gripper/medical(src)
	modules += new /obj/item/device/reagent_scanner/adv(src)
	modules += new /obj/item/roller_holder(src)
	modules += new /obj/item/stack/medical/splint(src)
	modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	modules += new /obj/item/weapon/reagent_containers/dropper/robot(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/weapon/shockpaddles/robot(src)
	modules += new /obj/item/device/gps/cyborg(src)
	modules += new /obj/item/weapon/reagent_containers/spray/cleaner/cyborg(src)

	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent("pacid", 250)
	emag.name = "Polyacid spray"

/obj/item/weapon/robot_module/medical/respawn_consumable(mob/living/silicon/robot/R)
	if(emag)
		var/obj/item/weapon/reagent_containers/spray/PS = emag
		PS.reagents.add_reagent("pacid", 2)
	var/obj/item/weapon/reagent_containers/syringe/S = locate() in src.modules
	if(S.mode == 2)
		S.reagents.clear_reagents()
		S.mode = initial(S.mode)
		S.desc = initial(S.desc)
		S.update_icon()
	..()

/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

	stacktypes = list(
		/obj/item/stack/sheet/metal/cyborg = 50,
		/obj/item/stack/sheet/glass/cyborg = 50,
		/obj/item/stack/sheet/rglass/cyborg = 50,
		/obj/item/stack/cable_coil/cyborg = 50,
		/obj/item/stack/rods = 15,
		/obj/item/stack/tile/plasteel = 15
		)

/obj/item/weapon/robot_module/engineering/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/borg/sight/meson(src)
	modules += new /obj/item/weapon/reagent_containers/spray/extinguisher/cyborg(src)
	modules += new /obj/item/weapon/airlock_painter(src)
	modules += new /obj/item/weapon/weldingtool/largetank(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/weapon/rcd/borg(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/taperoll/engineering(src)
	modules += new /obj/item/weapon/gripper(src)
	modules += new /obj/item/weapon/matter_decompiler(src)
	modules += new /obj/item/device/gps/cyborg(src)

	emag = new /obj/item/borg/stun(src)

	for(var/T in stacktypes)
		var/obj/item/stack/W = new T(src)
		W.set_amount(stacktypes[T])
		modules += W

/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/security/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/handcuffs/cyborg(src)
	modules += new /obj/item/weapon/melee/baton(src)
	modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
	modules += new /obj/item/taperoll/police(src)
	modules += new /obj/item/device/gps/cyborg(src)
	modules += new /obj/item/device/hailer(src)
	emag = new /obj/item/weapon/gun/energy/laser/selfcharging/cyborg(src)

/obj/item/weapon/robot_module/security/respawn_consumable(mob/living/silicon/robot/R)
	..()
	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in src.modules
	if(T.power_supply.charge < T.power_supply.maxcharge)
		var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
		T.power_supply.give(S.e_cost)
		T.update_icon()
	else
		T.charge_tick = 0
	var/obj/item/weapon/melee/baton/B = locate() in src.modules
	if(B.charges < 10)
		B.charges += 1

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"

/obj/item/weapon/robot_module/janitor/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/reagent_containers/food/snacks/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash(src)
	modules += new /obj/item/weapon/mop(src)
	modules += new /obj/item/device/lightreplacer/robot(src)
	modules += new /obj/item/device/gps/cyborg(src)
	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent("lube", 250)
	emag.name = "Lube spray"

/obj/item/weapon/robot_module/janitor/respawn_consumable(mob/living/silicon/robot/R)
	..()
	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/spray/S = src.emag
		S.reagents.add_reagent("lube", 2)

/obj/item/weapon/robot_module/butler
	name = "service robot module"

/obj/item/weapon/robot_module/butler/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/gripper/service(src)
	modules += new /obj/item/weapon/gripper/paperwork(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
	modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)

	var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
	M.matter = 30
	modules += M

	modules += new /obj/item/weapon/reagent_containers/dropper/robot(src)

	var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
	L.lit = 1
	L.icon_state = L.icon_on
	L.item_state = L.icon_on
	modules += L

	modules += new /obj/item/weapon/storage/visuals/tray/robotray(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
	modules += new /obj/item/weapon/pen/robopen(src)
	modules += new /obj/item/weapon/razor(src)
	modules += new /obj/item/device/gps/cyborg(src)

	emag = new /obj/item/weapon/reagent_containers/food/drinks/bottle/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	emag.reagents = R
	R.my_atom = emag
	R.add_reagent("beer2", 50)
	emag.name = "Mickey Finn's Special Brew"

/obj/item/weapon/robot_module/butler/add_languages(mob/living/silicon/robot/R)
	//full set of languages
	R.add_language(LANGUAGE_SOLCOMMON)
	R.add_language(LANGUAGE_SINTAUNATHI)
	R.add_language(LANGUAGE_SIIKMAAS)
	R.add_language(LANGUAGE_SIIKTAJR, LANGUAGE_CAN_UNDERSTAND)
	R.add_language(LANGUAGE_SKRELLIAN)
	R.add_language(LANGUAGE_ROOTSPEAK)
	R.add_language(LANGUAGE_TRADEBAND)
	R.add_language(LANGUAGE_TRINARY)
	R.add_language(LANGUAGE_GUTTER)

/obj/item/weapon/robot_module/butler/respawn_consumable(mob/living/silicon/robot/R)
	..()
	var/obj/item/weapon/reagent_containers/food/condiment/enzyme/E = locate() in src.modules
	E.reagents.add_reagent("enzyme", 2)
	if(src.emag)
		var/obj/item/weapon/reagent_containers/food/drinks/bottle/beer/B = src.emag
		B.reagents.add_reagent("beer2", 2)

/obj/item/weapon/robot_module/miner
	name = "miner robot module"

/obj/item/weapon/robot_module/miner/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/borg/sight/meson(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/storage/bag/ore(src)
	modules += new /obj/item/weapon/pickaxe/drill/borgdrill(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/geoscanner(src)
	modules += new /obj/item/weapon/shovel(src)//Need to buff borgdrill, so it can get sand instead shovel
	modules += new /obj/item/device/gps/cyborg(src)
	emag = new /obj/item/borg/stun(src)

/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"

/obj/item/weapon/robot_module/syndicate/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/crossbow/cyborg(src)
	modules += new /obj/item/weapon/card/emag/borg(src)
	modules += new /obj/item/borg/sight/night(src)
	modules += new /obj/item/weapon/gun/projectile/automatic/borg(src)
	modules += new /obj/item/weapon/tank/jetpack/carbondioxide(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/gun/energy/laser/cutter/emagged(src)

/obj/item/weapon/robot_module/syndicate/add_languages(mob/living/silicon/robot/R)
	//basic set+Sy-Code
	. = ..()
	R.add_language(LANGUAGE_SYCODE)

/obj/item/weapon/robot_module/syndidrone
	name = "syndicate drone module"

/obj/item/weapon/robot_module/syndidrone/add_languages(mob/living/silicon/robot/R)
	. = ..()
	R.add_language(LANGUAGE_SYCODE)

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

/obj/item/weapon/robot_module/combat/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/borg/sight/night(src)
	modules += new /obj/item/weapon/gun/energy/laser/selfcharging/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/laser/cutter/emagged(src)
	modules += new /obj/item/borg/combat/shield(src)
	modules += new /obj/item/borg/combat/mobility(src)
	modules += new /obj/item/weapon/wrench(src)
	emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)

/obj/item/weapon/robot_module/science
	name = "science robot module"

/obj/item/weapon/robot_module/science/atom_init()
	. = ..()
	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/gripper/science(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/taperoll/science(src)
	modules += new /obj/item/device/assembly/signaler(src)
	modules += new /obj/item/device/ano_scanner(src)
	modules += new /obj/item/device/science_tool(src)
//To fuck anomalies up

	modules += new /obj/item/device/reagent_scanner/adv(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src) //To fuck chemistry up

	modules += new /obj/item/device/depth_scanner(src)
	modules += new /obj/item/weapon/pickaxe/cyb(src)
	modules += new /obj/item/device/measuring_tape(src) //To unfuck xenoarcheology up

	modules += new /obj/item/weapon/circular_saw(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/reagent_containers/spray/extinguisher/cyborg(src) //To unfuck xenobiology up

	modules += new /obj/item/weapon/crowbar/red(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/weapon/weldingtool/largetank(src) //To fuck and unfuck (but mostly fuck) shit up
	modules += new /obj/item/device/gps/cyborg(src)

	emag = new /obj/item/weapon/hand_tele(src) //To fuck people's shit up

	emag.name = "Hand tele"

/obj/item/weapon/robot_module/peacekeeper
	name = "peacekeeper robot module"

/obj/item/weapon/robot_module/peacekeeper/atom_init()
	. = ..()

	modules += new /obj/item/device/flash(src)
	modules += new /obj/item/weapon/rsf/cookiesynth(src)
	modules += new /obj/item/harmalarm(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/peace(src)
	modules += new /obj/item/weapon/cyborghug(src)
	modules += new /obj/item/borg/bubble_creator(src)
	modules += new /obj/item/weapon/reagent_containers/spray/extinguisher/cyborg(src)
	modules += new /obj/item/weapon/crowbar/red(src)
	modules += new /obj/item/device/gps/cyborg(src)

	emag = new /obj/item/weapon/gun/grenadelauncher/cyborg(src)

/obj/item/weapon/robot_module/drone
	name = "drone module"
	stacktypes = list(
		/obj/item/stack/sheet/wood/cyborg = 1,
		/obj/item/stack/sheet/mineral/plastic/cyborg = 1,
		/obj/item/stack/sheet/rglass/cyborg = 5,
		/obj/item/stack/tile/wood = 5,
		/obj/item/stack/rods = 15,
		/obj/item/stack/tile/plasteel = 15,
		/obj/item/stack/sheet/metal/cyborg = 20,
		/obj/item/stack/sheet/glass/cyborg = 20,
		/obj/item/stack/cable_coil/cyborg = 30
		)

/obj/item/weapon/robot_module/drone/atom_init()
	. = ..()
	modules += new /obj/item/weapon/weldingtool(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)
	modules += new /obj/item/device/multitool(src)
	modules += new /obj/item/device/lightreplacer/robot(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/weapon/gripper(src)
	modules += new /obj/item/weapon/matter_decompiler(src)
	modules += new /obj/item/weapon/reagent_containers/spray/cleaner/cyborg/drone(src)

	emag = new /obj/item/weapon/gun/energy/laser/cutter/emagged(src)
	emag.name = "Plasma Cutter"

	for(var/T in stacktypes)
		var/obj/item/stack/W = new T(src)
		W.set_amount(stacktypes[T])
		modules += W

/obj/item/weapon/robot_module/drone/add_languages(mob/living/silicon/robot/R)
	return	//not much ROM to spare in that tiny microprocessor!

/obj/item/weapon/robot_module/drone/respawn_consumable(mob/living/silicon/robot/R)
	var/obj/item/weapon/reagent_containers/spray/cleaner/C = locate() in src.modules
	C.reagents.add_reagent("cleaner", 3)

	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R)

	..()

	return

//checks whether this item is a module of the robot it is located in.
/obj/item/proc/is_robot_module()
	if (!isrobot(src.loc))
		return 0

	var/mob/living/silicon/robot/R = src.loc

	return (src in R.module.modules)
