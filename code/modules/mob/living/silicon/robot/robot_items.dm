/obj/item/weapon/storage/visuals/tray/robotray
	name = "RoboTray"
	desc = "An autoloading tray specialized for carrying refreshments."

// A special pen for service droids. Can be toggled to switch between normal writting mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/weapon/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/weapon/pen/robopen/attack_self(mob/user)

	var/choice = input("Would you like to change colour or mode?") as null|anything in list("Colour","Mode")
	if(!choice) return

	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	switch(choice)
		if("Colour")
			var/newcolour = input("Which colour would you like to use?") as null|anything in list("black","blue","red","green","yellow")
			if(newcolour) colour = newcolour

		if("Mode")
			if (mode == 1)
				mode = 2
			else
				mode = 1
			to_chat(user, "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'")

// Copied over from paper's rename verb
// see code\modules\paperwork\paper.dm line 62

/obj/item/weapon/pen/robopen/proc/RenamePaper(mob/user,obj/paper)
	if ( !user || !paper )
		return
	var/n_name = sanitize_safe(input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text, MAX_NAME_LEN)
	if ( !user || !paper )
		return

	if(( get_dist(user,paper) <= 1  && user.stat == CONSCIOUS))
		paper.name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(user)

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/weapon/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"

/obj/item/weapon/form_printer/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/obj/item/weapon/form_printer/afterattack(atom/target, mob/user, proximity, params)

	if(!target || !proximity)
		return

	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))

/obj/item/weapon/form_printer/attack_self(mob/user)
	deploy_paper(get_turf(src))

/obj/item/weapon/form_printer/proc/deploy_paper(turf/T)
	T.visible_message("<span class='notice'>\The [src.loc] dispenses a sheet of crisp white paper.</span>")
	new /obj/item/weapon/paper(T)

//Personal shielding for the combat module.
/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/objects.dmi'
	icon_state = "oldshieldon"
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if (N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/device/lustmodule
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	item_state = "locator"
	name = "Slime bloodlust pulse emitter"
	desc = "Highly dangeroues experimental device that makes nearby slimes completely loose it. Has 5 uses."
	var/uses = 5
	var/mobu

/obj/item/device/lustmodule/attack_self(mob/user)
	if(uses > 0)
		for(var/mob/living/carbon/slime/slime in viewers(get_turf_loc(user), null))
			slime.tame = 0
			slime.rabid = 1
			user.visible_message("<span class='warning'>The [slime] is driven into a frenzy!.</span>")
		uses -= 1
		to_chat(user, "Bloodlust emitter sends a pulse.")
	else
		to_chat(user, "You have spent device's capabilities.")//To limit number of uses.
		return 0
	return 1

/obj/item/weapon/pickaxe/cyb
	name = "cyborg pickaxe"
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "pick_hand"
	toolspeed = 0.6
	desc = "A smaller, more precise version of the pickaxe (30 centimetre excavation depth)."
	excavation_amount = 15
	usesound = 'sound/items/Crowbar.ogg'
	drill_verb = "clearing"
	w_class = SIZE_SMALL

/obj/item/weapon/pickaxe/cyb/attack_self(mob/user)
	var/ampr = input(user,"Excavation depth?","Set excavation depth","") as num
	excavation_amount = 0 + ampr/2
	desc = "A smaller, more precise version of the pickaxe ([ampr] centimetre excavation depth)."

/obj/item/weapon/shockpaddles/robot
	name = "defibrillator paddles"
	desc = "A pair of advanced shockpaddles powered by a robot's internal power cell, able to penetrate thick clothing."
	charge_cost = 50
	combat = TRUE
	cooldown_time = 3 SECONDS

/obj/item/weapon/shockpaddles/robot/check_charge(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.charge >= charge_amt)

/obj/item/weapon/shockpaddles/robot/checked_use(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.use(charge_amt))

/obj/item/weapon/shockpaddles/robot/attack_self(mob/user)
	return //No, this can't be wielded

/obj/item/weapon/shockpaddles/robot/try_revive(mob/living/carbon/human/H, mob/user)
	var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
	if(IO.heart_status == HEART_FAILURE)
		if(IO.damage < 50)
			if(do_mob(user, H, 2 SECONDS))
				visible_message("<span class='danger'>[user] performs a heart massage on [H]!</span>")
				if(H.health > config.health_threshold_dead)
					IO.heart_fibrillate()
					to_chat(user, "<span class='notice'>You detect an irregular heartbeat coming form [H]'s body. It is in need of defibrillation you assume!</span>")
				else
					to_chat(user, "<span class='warning'>[H]'s body seems to be too weak, you do not feel a heart beat.</span>")
		else
			to_chat(user, "<span class='warning'>It seems [H]'s [IO] is too squishy... It doesn't beat at all!</span>")
	..()

/obj/item/weapon/card/emag/borg
	name = "robotic cryptographic sequencer"

/obj/item/weapon/card/emag/borg/emag_break(mob/user)
	var/mob/living/silicon/robot/R = user
	user.visible_message("[src] fizzles and sparks - it seems it's been used once too often, and is now broken.")
	R.module.remove_item(src)

//Agent ID card for cyborgs, so they wont put it in silly places. Let's pretend that its a device, not just a card.
/obj/item/weapon/card/access_grabber
	name = "robotic access grabber device"
	desc = "Устройство, используемое для копирования станционного доступа с ID карт."
	icon_state = "id"

/obj/item/weapon/card/access_grabber/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/mob/living/silicon/robot/R = user
	if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/S = target
		if(istype(S.module, R.module.type))
			R.req_access |= S.req_access
	if(istype(target, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = target
		R.req_access |= I.access
		if(isliving(user) && user.mind)
			to_chat(user, "<span class='notice'>The device's microscanners activate as you pass it over the ID, copying its access.</span>")

/obj/item/weapon/tool_package
	name = "tool package"
	desc = "Инновационная RedSpace разработка для синтетиков, позволяющая владельцу выбрать 1 из 2 наборов инструментов: для боя или для поддержки. Первый сочитает в себе все необходимое для медицины и инженерии, второй обладает встроенным вооружением."
	icon_state = "id"

/obj/item/weapon/tool_package/attack_self(mob/user)
	. = ..()
	if(!isrobot(user))
		CRASH("Предмет для киборгов оказался в руках не-киборга [loc]!")
	var/mob/living/silicon/robot/R = user
	switch(tgui_input_list(usr,"Select a role!","Custom Setup Creation", list("combat", "support")))
		if("combat")
			R.module.modules += new /obj/item/weapon/handcuffs/cyborg(src)
			R.module.modules += new /obj/item/weapon/melee/baton(src)
			R.module.modules += new /obj/item/weapon/melee/cultblade(src)
			R.module.modules += new /obj/item/borg/sight/night(src)

			var/obj/item/device/hailer/H = new(src)
			H.emagged = TRUE
			H.insults = 2
			R.module.modules += H
		if("support")
			//Engineer
			R.module.modules += new /obj/item/borg/sight/meson(src)
			R.module.modules += new /obj/item/weapon/reagent_containers/spray/extinguisher/cyborg(src)
			R.module.modules += new /obj/item/weapon/airlock_painter(src)
			R.module.modules += new /obj/item/weapon/weldingtool/largetank(src)
			R.module.modules += new /obj/item/weapon/screwdriver(src)
			R.module.modules += new /obj/item/weapon/wrench(src)
			R.module.modules += new /obj/item/weapon/wirecutters(src)
			R.module.modules += new /obj/item/device/multitool(src)
			R.module.modules += new /obj/item/weapon/rcd/borg(src)
			R.module.modules += new /obj/item/device/t_scanner(src)
			R.module.modules += new /obj/item/device/analyzer(src)
			R.module.modules += new /obj/item/weapon/gripper(src)
			R.module.modules += new /obj/item/weapon/matter_decompiler(src)
			//Medic
			R.module.modules += new /obj/item/device/healthanalyzer(src)
			R.module.modules += new /obj/item/weapon/reagent_containers/borghypo/medical(src)
			R.module.modules += new /obj/item/weapon/scalpel/manager(src)
			R.module.modules += new /obj/item/weapon/FixOVein(src)
			R.module.modules += new /obj/item/weapon/hemostat(src)
			R.module.modules += new /obj/item/weapon/retractor(src)
			R.module.modules += new /obj/item/weapon/cautery(src)
			R.module.modules += new /obj/item/weapon/bonegel(src)
			R.module.modules += new /obj/item/weapon/bonesetter(src)
			R.module.modules += new /obj/item/weapon/circular_saw(src)
			R.module.modules += new /obj/item/weapon/surgicaldrill(src)
			R.module.modules += new /obj/item/weapon/razor(src)
			R.module.modules += new /obj/item/weapon/gripper/medical(src)
			R.module.modules += new /obj/item/device/reagent_scanner/adv(src)
			R.module.modules += new /obj/item/roller_holder(src)
			R.module.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
			R.module.modules += new /obj/item/weapon/reagent_containers/dropper/robot(src)
			R.module.modules += new /obj/item/weapon/reagent_containers/syringe(src)
			R.module.modules += new /obj/item/weapon/shockpaddles/robot(src)
			R.module.modules += new /obj/item/weapon/reagent_containers/spray/cleaner/cyborg(src)

			R.module.stacktypes = list(
				/obj/item/stack/sheet/metal/cyborg = 50,
				/obj/item/stack/sheet/glass/cyborg = 50,
				/obj/item/stack/sheet/rglass/cyborg = 50,
				/obj/item/stack/cable_coil/cyborg = 50,
				/obj/item/stack/rods = 15,
				/obj/item/stack/tile/plasteel = 15,
				/obj/item/stack/medical/advanced/bruise_pack = 6,
				/obj/item/stack/medical/advanced/ointment = 6,
				/obj/item/stack/nanopaste = 10,
				/obj/item/stack/medical/splint = 5
				)
			for(var/T in R.module.stacktypes)
				var/obj/item/stack/W = new T(src)
				W.set_amount(R.module.stacktypes[T])
				R.module.modules += W
/*
/obj/item/stone_of_aura
	name = "Stone of Healing aura"
	desc = "The stone is made of a complex material, if you look closely, the surface structure is fractal."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultstone"

/obj/item/stone_of_aura*/
