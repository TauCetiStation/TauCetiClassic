//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_BIOMASS 150
#define CLONE_INITIAL_DAMAGE     190    //Clones in clonepods start with 190 cloneloss damage and 190 brainloss damage, thats just logical


/obj/machinery/clonepod
	anchored = 1
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = 1
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(access_genetics) //For premature unlocking.
	allowed_checks = ALLOWED_CHECK_NONE
	var/heal_level = 90 //The clone is released once its health reaches this level.
	var/locked = 0
	var/obj/machinery/computer/cloning/connected = null //So we remember the connected clone machine.
	var/mess = 0 //Need to clean out it if it's full of exploded clone.
	var/attempting = 0 //One clone attempt at a time thanks
	var/eject_wait = 0 //Don't eject them as soon as they are created fuckkk
	var/biomass = CLONE_BIOMASS * 3
	var/speed_coeff
	var/efficiency
	light_color = "#00ff00"

/obj/machinery/clonepod/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonepod(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/weapon/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	heal_level = (efficiency * 15) + 10
	if(heal_level > 100)
		heal_level = 100

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/weapon/disk/data
	name = "Cloning Data Disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = ITEM_SIZE_SMALL
	var/datum/dna2/record/buf=null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/weapon/disk/data/proc/Initialize()
	buf = new
	buf.dna=new

/obj/item/weapon/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

/obj/item/weapon/disk/data/demo/atom_init()
	. = ..()
	Initialize()
	buf.types=DNA2_BUF_UE|DNA2_BUF_UI
	buf.dna.real_name="God Emperor of Mankind"
	buf.dna.unique_enzymes = md5(buf.dna.real_name)
	buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x000,0x000,0x000,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
	buf.dna.UpdateUI()

/obj/item/weapon/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

/obj/item/weapon/disk/data/monkey/atom_init()
	. = ..()
	Initialize()
	buf.types=DNA2_BUF_SE
	var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
	for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
		new_SE += rand(1,1024)
	buf.dna.SE=new_SE
	buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)


//Find a dead mob with a brain and client.
/proc/find_dead_player(find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/M in player_list)
		//Dead people only thanks!
		if ((M.stat != DEAD) || (!M.client))
			continue
		//They need a brain!
		if (istype(M, /mob/living/carbon/human) && !M:has_brain())
			continue

		if (M.ckey == find_key)
			selected = M
			break
	return selected

//Disk stuff.
/obj/item/weapon/disk/data/atom_init()
	. = ..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadisk[diskcolor]"

/obj/item/weapon/disk/data/attack_self(mob/user)
	src.read_only = !src.read_only
	to_chat(user, "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"].")

/obj/item/weapon/disk/data/examine(mob/user)
	..()
	to_chat(user, "The write-protect tab is set to [src.read_only ? "protected" : "unprotected"].")

//Health Tracker Implant

/obj/item/weapon/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if (!src.implanted)
		return "ERROR"
	else
		if(isliving(src.implanted))
			var/mob/living/L = src.implanted
			src.healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if (!src.healthstring)
			src.healthstring = "ERROR"
		return src.healthstring

/obj/machinery/clonepod/examine(mob/user)
	if(..(user, 3))
		if ((isnull(occupant)) || (stat & NOPOWER))
			return
		if ((!isnull(occupant)) && (occupant.stat != DEAD))
			var/completion = (100 * ((occupant.health + 100) / (heal_level + 100)))
			to_chat(user, "Current clone cycle is [round(completion)]% complete.")

//Clonepod

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(datum/dna2/record/R)
	if(panel_open)
		return 0
	if(mess || attempting)
		return 0
	var/datum/mind/clonemind = locate(R.mind)
	if(!istype(clonemind,/datum/mind))	//not a mind
		return 0
	if( clonemind.current && clonemind.current.stat != DEAD )	//mind is associated with a non-dead body
		return 0
	if(clonemind.active)	//somebody is using that mind
		if( ckey(clonemind.key)!=R.ckey )
			return 0
	else
		for(var/mob/dead/observer/G in player_list)
			if(G.ckey == R.ckey)
				if(G.can_reenter_corpse)
					break
				else
					return 0


	src.attempting = 1 //One at a time!!
	src.locked = 1

	src.eject_wait = 1
	spawn(30)
		src.eject_wait = 0

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src, R.dna.species)
	occupant = H

	if(!R.dna.real_name)	//to prevent null names
		R.dna.real_name = "clone ([rand(0,999)])"
	H.real_name = R.dna.real_name

	src.icon_state = "pod_1"
	//Get the clone body ready
	H.adjustCloneLoss(CLONE_INITIAL_DAMAGE)     //Yeah, clones start with very low health, not with random, because why would they start with random health
	H.adjustBrainLoss(CLONE_INITIAL_DAMAGE)
	H.Paralyse(4)

	//Here let's calculate their health so the pod doesn't immediately eject them!!!
	H.updatehealth()

	clonemind.transfer_to(H)
	H.ckey = R.ckey
	to_chat(H, "<span class='notice'><b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i></span>")

	for(var/V in R.quirks)
		new V(H)

	// -- Mode/mind specific stuff goes here
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if(mode)
		mode.update_icon(H)

	if((H.mind in SSticker.mode.revolutionaries) || (H.mind in SSticker.mode.head_revolutionaries))
		SSticker.mode.update_all_rev_icons() //So the icon actually appears
	if((H.mind in SSticker.mode.A_bosses) || ((H.mind in SSticker.mode.A_gang) || (H.mind in SSticker.mode.B_bosses)) || (H.mind in SSticker.mode.B_gang))
		SSticker.mode.update_all_gang_icons()
	if(H.mind in SSticker.mode.syndicates)
		SSticker.mode.update_all_synd_icons()
	if (H.mind in SSticker.mode.cult)
		SSticker.mode.add_cultist(src.occupant.mind)
		SSticker.mode.update_all_cult_icons() //So the icon actually appears

	// -- End mode specific stuff

	if(!R.dna)
		H.dna = new /datum/dna()
		H.dna.real_name = H.real_name
	else
		H.dna=R.dna
	H.UpdateAppearance()
	//if(efficiency > 2)
	//	for(var/A in bad_se_blocks)
	//		setblock(H.dna.struc_enzymes, A, construct_block(0,2))
	if(efficiency > 5 && prob(20))
		randmutg(H)
	if(efficiency < 3 && prob(50))
		randmutb(H)
	H.dna.UpdateSE()
	H.dna.UpdateUI()

	H.f_style = "Shaved"
	if(R.dna.species == HUMAN) //no more xenos losing ears/tentacles
		H.h_style = pick("Bedhead", "Bedhead 2", "Bedhead 3")

	for(var/datum/language/L in R.languages)
		H.add_language(L.name)
	H.suiciding = 0
	src.attempting = 0
	return 1

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()

	if(stat & NOPOWER) //Autoeject if power is lost
		if (src.occupant)
			src.locked = 0
			src.go_out()
		return

	if((src.occupant) && (src.occupant.loc == src))

		if((src.occupant.stat == DEAD) || (src.occupant.suiciding) || !occupant.key)  //Autoeject corpses and suiciding dudes.
			src.locked = 0
			src.go_out()
			src.connected_message("Clone Rejected: Deceased.")
			return

		else if(src.occupant.cloneloss > (100 - src.heal_level))
			src.occupant.Paralyse(4)

			 //Slowly get that clone healed and finished.
			src.occupant.adjustCloneLoss(-((speed_coeff/2)))

			//Premature clones may have brain damage.
			src.occupant.adjustBrainLoss(-((speed_coeff/2)))

			//So clones don't die of oxyloss in a running pod.
			if (src.occupant.reagents.get_reagent_amount("inaprovaline") < 30)
				src.occupant.reagents.add_reagent("inaprovaline", 60)

			//So clones will remain asleep for long enough to get them into cryo (Bay RP edit)
			if (src.occupant.reagents.get_reagent_amount("stoxin") < 10)
				src.occupant.reagents.add_reagent("stoxin", 5)
			if (src.occupant.reagents.get_reagent_amount("chloralhydrate") < 1)
				src.occupant.reagents.add_reagent("chloralhydrate", 1)

			//Also heal some oxyloss ourselves because inaprovaline is so bad at preventing it!!
			src.occupant.adjustOxyLoss(-4)

			use_power(7500) //This might need tweaking.
			return

		else if((src.occupant.cloneloss <= (100 - src.heal_level)) && (!src.eject_wait) || src.occupant.health >= 100)
			src.connected_message("Cloning Process Complete.")
			src.locked = 0
			src.go_out()
			return

	else if ((!src.occupant) || (src.occupant.loc != src))
		src.occupant = null
		if (src.locked)
			src.locked = 0
		if (!src.mess && !panel_open)
			icon_state = "pod_0"
		use_power(200)
		return

	return

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/weapon/W, mob/user)
	if(!(occupant || mess || locked))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]",W))
			return

	if(exchange_parts(user, W))
		return

	default_deconstruction_crowbar(W)

	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (!src.check_access(W))
			to_chat(user, "<span class='danger'>Access Denied.</span>")
			return
		if ((!src.locked) || (isnull(src.occupant)))
			return
		if ((src.occupant.health < -20) && (src.occupant.stat != DEAD))
			to_chat(user, "<span class='danger'>Access Refused.</span>")
			return
		else
			src.locked = 0
			to_chat(user, "System unlocked.")
	else if (istype(W, /obj/item/weapon/reagent_containers/food/snacks/meat))
		to_chat(user, "<span class='notice'>\The [src] processes \the [W].</span>")
		biomass += 50
		user.drop_item()
		qdel(W)
		return
	else
		..()

/obj/machinery/clonepod/emag_act(mob/user)
	if(isnull(src.occupant))
		return FALSE
	user.SetNextMove(CLICK_CD_INTERACT)
	to_chat(user, "You force an emergency ejection.")
	src.locked = 0
	src.go_out()
	return TRUE

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if ((isnull(src.connected)) || (!istype(src.connected, /obj/machinery/computer/cloning)))
		return 0
	if (!message)
		return 0

	src.connected.temp = message
	src.connected.updateUsrDialog()
	return 1

/obj/machinery/clonepod/verb/eject()
	set name = "Eject Cloner"
	set category = "Object"
	set src in oview(1)

	if(!usr)
		return
	if (usr.incapacitated())
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/clonepod/proc/go_out()
	if (src.locked)
		return

	if (src.mess) //Clean that mess and dump those gibs!
		src.mess = 0
		gibs(src.loc)
		src.icon_state = "pod_0"
		return

	if (!(src.occupant))
		return
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.icon_state = "pod_0"
	src.eject_wait = 0 //If it's still set somehow.
	domutcheck(src.occupant) //Waiting until they're out before possible monkeyizing.
//	src.occupant.add_side_effect("Bad Stomach") // Give them an extra side-effect for free.
	src.occupant = null

	src.biomass -= CLONE_BIOMASS

	return

/obj/machinery/clonepod/proc/malfunction()
	if(src.occupant)
		src.connected_message("Critical Error!")
		src.mess = 1
		src.icon_state = "pod_g"
		src.occupant.ghostize()
		spawn(5)
			qdel(src.occupant)
			src.occupant = null
	return

/obj/machinery/clonepod/relaymove(mob/user)
	if (user.incapacitated())
		return
	src.go_out()
	return

/obj/machinery/clonepod/emp_act(severity)
	if(prob(100/(severity*efficiency))) malfunction()
	..()

/obj/machinery/clonepod/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		else
	return

/*
 *	Diskette Box
 */

/obj/item/weapon/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_box"

/obj/item/weapon/storage/box/disks/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/disk/data(src)

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/weapon/paper/Cloning
	name = "H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

#undef CLONE_INITIAL_DAMAGE
