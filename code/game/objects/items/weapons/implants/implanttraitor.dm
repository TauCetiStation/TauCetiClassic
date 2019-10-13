/obj/item/weapon/implant/syndi_loyalty
	name = "loyalty implant"
	desc = "Makes you loyal or such.."

	var/datum/mind/implant_master
	var/forgotten = FALSE

/obj/item/weapon/implant/syndi_loyalty/implanted(mob/M)
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/item/weapon/implant/syndi_loyalty/inject(mob/living/carbon/C, def_zone)
	if((usr.mind.special_role != "traitor" && usr.mind.special_role != "Syndicate") || isloyalsyndi(C))
		loc = get_turf(usr)
		return

	. = ..(C, def_zone)

	implant_master = usr.mind


	for(var/obj/item/weapon/implant/mindshield/I in imp_in.contents)
		if(I.implanted)
			qdel(I)
	for(var/obj/item/weapon/implant/mindshield/loyalty/I in imp_in.contents)
		if(I.implanted)
			qdel(I)

	ticker.mode.traitors += imp_in.mind

	to_chat(imp_in, "<span class='userdanger'> <B>ATTENTION:</B> You were implanted with Syndicate loyalty implant...</span>")
	to_chat(imp_in, "<B>You are now a special traitor.</B>")

	imp_in.mind.special_role = "traitor"

	var/datum/objective/protect/protect_objective = new("Protect [implant_master.current.real_name], the [implant_master.assigned_role].")
	protect_objective.target = implant_master

	var/datum/objective/obey_objective = new("Follow [implant_master.current.real_name]'s orders, even at the cost of living.")
	obey_objective.completed = 1

	imp_in.mind.objectives += protect_objective
	imp_in.mind.objectives += obey_objective

	to_chat(imp_in, "<span class='notice'> Your current objectives:</span>")
	var/obj_count = 1
	for(var/datum/objective/objective in imp_in.mind.objectives)
		to_chat(imp_in, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	ticker.mode.update_all_synd_icons()

	apply_brain_damage()

	implant_master.syndicate_implanted_minds  += imp_in.mind

	return TRUE

/obj/item/weapon/implant/syndi_loyalty/Destroy()
	forget()
	..()

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
					to_chat(imp_in, "<span class='warning'> You [pick("are sure", "think")] that [implant_master.current.real_name] is the greatest man who ever lived!</span>")
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
					to_chat(imp_in, "\italic <span class ='userdanger'>You wanna cut off [implant_master.current.real_name]'s head!</span>")
				if(2)
					to_chat(imp_in, "\italic <span class ='userdanger'>You [pick("are sure", "think")] that [implant_master.current.real_name] is worthy of death!</span>")
				if(3)
					to_chat(imp_in, "\italic <span class ='userdanger'>ERROR... [implant_master.current.real_name]... DIE, MOTHEFUCKER, DIE!!!</span>")

/obj/item/weapon/implant/syndi_loyalty/meltdown()
	. = ..()
	forget()
	fake_attack(imp_in, implant_master.current) //Hallucination

/obj/item/weapon/implant/syndi_loyalty/islegal()
	return 0

/obj/item/weapon/implant/syndi_loyalty/proc/forget()
	if(!forgotten)
		ticker.mode.remove_traitor(implant_master) //remove traitors
		imp_in.mind.remove_objectives()
		apply_brain_damage()
		to_chat(imp_in, "<span class='warning'>You forgot everything after installing the implant.</span>")
		forgotten = TRUE

/obj/item/weapon/implant/syndi_loyalty/emp_act(severity)
	if(malfunction)
		return
	if(severity == 1 && prob(75))
		meltdown()

/obj/item/weapon/implant/syndi_loyalty/Destroy()
	forget()
	..()

/obj/item/weapon/implant/syndi_loyalty/get_data()
	var/dat = {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Nanotra4en Employee Management Implant<BR>
	<b>Life:</b> T3n years.<BR>
	<b>Important Note7:</b> Pe4s0nne1 14jec1ed w1th thi7 device tend to be much more loyal to the company.<BR>
	<b>Warning:</b> Usage without special equipment may cause heavy injuries and severe brain damage.<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Funct1on:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
	<b>Special Features:</b> W1ll prevent and cure most forms of brainwashing.<BR>
	<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream3333."}
	return dat

