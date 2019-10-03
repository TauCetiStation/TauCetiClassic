/obj/item/weapon/implant/syndi_loyalty
	name = "loyalty implant"
	desc = "Makes you loyal or such.."

	var/datum/mind/implant_master
	var/mob/implant_master_mob  //The man who injected the implant
	var/forgotten = FALSE
	var/mob/implant_target_mob //Victim with implant

/obj/item/weapon/implant/syndi_loyalty/implanted(mob/M)
	//Save ref for mobs
	implant_master_mob = usr
	implant_target_mob = M

	syndi_implanted_people += "<b>[implant_master_mob]</b> implanted <b>[implant_target_mob]</b> Syndicate Loyalty implant" //For print in scroreboard.

	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/weapon/implant/syndi_loyalty/inject(mob/living/carbon/C, def_zone)
	. = ..()

	if(ismonkey(C)) //ROFL
		C.visible_message("<b>[C.name]</b> says, \"<span class ='userdanger'>THIS IS A BAD TARGET! SELF DESTRUCTION ACTIVATED</span>\"")
		C.visible_message("<b>[C.name]</b> says, \"<span class ='userdanger'>3 SECONDS TO SELF-DESTRUCT</span>\"")
		C.adjustBrainLoss(100)
		return

	if(isloyal(C)) //reaction to loyalty implant.
		to_chat(C, "<span class='notice'>The loyalty implant suppresses the action of the syndicate</span>")
		to_chat(C, "<span class='notice'>Syndicate loyalty implant deactivated</span>")
		if(prob(80))
			C.adjustBrainLoss(80)
		return

	var/mob/living/carbon/human/imptraitor = C
	implant_master = usr.mind

	if(!istype(imptraitor) || !istype(implant_master))
		return

	ticker.mode.traitors += imptraitor.mind //add in list with traitors

	to_chat(imptraitor, "<span class='userdanger'> <B>ATTENTION:</B>You were implanted with Syndicate loyalty implant...</span>")
	to_chat(imptraitor, "<B>You are now a special traitor.</B>")

	imptraitor.mind.special_role = "traitor" //give traitors

	var/datum/objective/protect/protect_objective = new("Protect [implant_master.current.real_name], the [implant_master.assigned_role].")
	protect_objective.target = implant_master

	var/datum/objective/obey_objective = new("Follow [implant_master.current.real_name]'s orders, even at the cost of living.")
	obey_objective.completed = 1

	imptraitor.mind.objectives += protect_objective //give objectives
	imptraitor.mind.objectives += obey_objective

	to_chat(imptraitor, "<span class='notice'> Your current objectives:</span>") //print objectives in chat
	var/obj_count = 1
	for(var/datum/objective/objective in imptraitor.mind.objectives)
		to_chat(imptraitor, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	ticker.mode.update_all_synd_icons()

	apply_brain_damage() //give 80 brain damage
	
	return TRUE

/obj/item/weapon/implant/syndi_loyalty/process()
	if(!implanted || !imp_in)
		STOP_PROCESSING(SSobj, src)
		return
	if(imp_in.stat == DEAD)
		return

	if(malfunction != MALFUNCTION_PERMANENT)
		if(prob(1) && prob(25))
			switch(rand(1, 3))
				if(1)
					to_chat(imp_in, "<span class='warning'> You [pick("are sure", "think")] that Syndicate - is the best corporation in the whole Universe!</span>")
				if(2)
					to_chat(imp_in, "<span class='warning'> You [pick("are sure", "think")] that [implant_master_mob] is the greatest man who ever lived!</span>")
				if(3)
					to_chat(imp_in, "<span class='warning'> You want to give your life away in the name of Syndicate!</span>")
		if(prob(1) && prob(5))
			//Big, red, ugly messeage
			to_chat(imp_in, "<span class='warning'>You [pick("are sure", "think")] that</span> <span class ='userdanger'>SYNDICATE</span> <span class='warning'>is much [pick("better", "cooler", "stronger")] than NanoTrasen </span>")
	else
		if(istype(imp_in, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = imp_in
			H.hallucination += 10
		if(prob(5))
			switch(rand(1, 3))
				if(1)
					to_chat(imp_in, "\italic <span class ='userdanger'>You wanna cut off [implant_master_mob]'s head!</span>")
				if(2)
					to_chat(imp_in, "\italic <span class ='userdanger'>You [pick("are sure", "think")] that [implant_master_mob] is worthy of death!</span>")
				if(3)
					to_chat(imp_in, "\italic <span class ='userdanger'>ERROR... [implant_master_mob]... DIE, MOTHEFUCKER, DIE!!!</span>")

/obj/item/weapon/implant/syndi_loyalty/meltdown()
	. = ..()
	forget()
	fake_attack(implant_target_mob, implant_master_mob) //Hallucination

/obj/item/weapon/implant/syndi_loyalty/islegal()
	return 0

/obj/item/weapon/implant/syndi_loyalty/proc/forget()
	if(!forgotten)
		ticker.mode.remove_traitor(implant_target_mob) //remove traitors
		imp_in.mind.remove_objectives()
		apply_brain_damage()
		to_chat(imp_in, "<span class='warning'>You forgot everything after installing the implant.</span>")
		forgotten = TRUE

/obj/item/weapon/implant/syndi_loyalty/emp_act(severity)
	if(malfunction)
		return
	malfunction = MALFUNCTION_PERMANENT
	if(severity == 1 && prob(80))
		meltdown()

/obj/item/weapon/implant/syndi_loyalty/Destroy()
	forget()
	..()

/obj/item/weapon/implant/syndi_loyalty/get_data()
	var/dat = {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Unknown.<BR>
	<b>Life:</b> Unknown.<BR>
	<b>Important Notes:</b> Unknown.<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Unknown.<BR>
	<b>Special Features:</b> Unknown.<BR>
	<b>Integrity:</b> Unknown."}
	return dat
