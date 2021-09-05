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

	return

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
	return

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
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
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

/obj/item/weapon/twohanded/shockpaddles/robot
	name = "defibrillator paddles"
	desc = "A pair of advanced shockpaddles powered by a robot's internal power cell, able to penetrate thick clothing."
	charge_cost = 50
	combat = TRUE
	cooldown_time = 3 SECONDS

/obj/item/weapon/twohanded/shockpaddles/robot/check_charge(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.charge >= charge_amt)

/obj/item/weapon/twohanded/shockpaddles/robot/checked_use(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.use(charge_amt))

/obj/item/weapon/twohanded/shockpaddles/robot/attack_self(mob/user)
	return //No, this can't be wielded

/obj/item/weapon/twohanded/shockpaddles/robot/try_revive(mob/living/carbon/human/H, mob/user)
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

/obj/item/weapon/AVtool
	name = "AV tool"
	desc = "An AV tool powered by a robot's internal power cell, able to work with masked patients."
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "avtool_idle"
	item_state = "avtool_idle"
	var/charge_cost = 50
	var/busy = FALSE

/obj/item/weapon/AVtool/proc/check_charge(charge_amt)
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		return (R.cell && R.cell.charge >= charge_amt)

/obj/item/weapon/AVtool/proc/can_use(mob/living/silicon/robot/user, mob/living/carbon/human/M)
	var/target_zone = user.get_targetzone()
	if(busy || user.is_busy(M))
		to_chat(user, "<span class='warning'>You are too busy.</span>")
		return FALSE

	if(M.health > config.health_threshold_crit)
		to_chat(user, "<span class='warning'>Patient's condition is not critical.</span>")
		return FALSE

	if(target_zone != O_MOUTH)
		to_chat(user, "<span class='warning'>AV tool works only through the mouth.</span>")
		return FALSE

	if(!check_charge(charge_cost))
		to_chat(user, "<span class='warning'>\The [src] doesn't have enough charge left to do that.</span>")
		return FALSE

	if(M.species && M.species.flags[NO_BREATHE])
		to_chat(user, "<span class='notice bold'>You can not perform AV on these species!</span>")
		return

	return TRUE

/obj/item/weapon/AVtool/attack(mob/living/carbon/human/M, mob/living/silicon/robot/user, def_zone)
	var/mob/living/carbon/human/H = M
	if(!istype(H) || !can_use(user, M))
		return

	busy = TRUE
	icon_state = "avtool_ventilating"

	perform_av(M, user)

	busy = FALSE
	icon_state = "avtool_idle"

/obj/item/weapon/AVtool/proc/perform_av(mob/living/carbon/human/H, mob/living/silicon/robot/user)

	while(H.health < config.health_threshold_crit)
		var/heal_check = H.health

		if(!do_mob(user, H, 2 SECONDS))
			break

		var/suff = min(H.getOxyLoss(), 5)
		H.adjustOxyLoss(-suff)
		visible_message("<span class='warning'>[user] performs AV on [H]!</span>")
		to_chat(H, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
		H.updatehealth()

		if(heal_check == H.health)
			to_chat(user, "<span class='warning'>Further AV is pointless.</span>")
			break

		user.cell.use(charge_cost)
