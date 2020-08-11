/obj/item/weapon/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."

/obj/item/weapon/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device are much more resistant to brainwashing and propaganda.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that protects the host's mental functions from manipulation.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing and propaganda.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/weapon/implant/mindshield/implanted(mob/M)
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.mind && (H.mind in (SSticker.mode.head_revolutionaries | SSticker.mode.A_bosses | SSticker.mode.B_bosses)) || is_shadow_or_thrall(H)|| H.mind.special_role == "Wizard")
		M.visible_message("<span class='warning'>[M] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE

	if(H.mind && (H.mind in SSticker.mode.revolutionaries))
		SSticker.mode.remove_revolutionary(H.mind)

	if(H.mind && (H.mind in (SSticker.mode.A_gang | SSticker.mode.B_gang)))
		SSticker.mode.remove_gangster(H.mind, exclude_bosses=1)
		H.visible_message("<span class='warning'>[src] was destroyed in the process!</span>", "<span class='userdanger'>You feel a surge of loyalty towards Nanotrasen.</span>")
		return FALSE

	if(H.mind && (H.mind in SSticker.mode.cult))
		to_chat(H, "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE
	else
		to_chat(H, "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")

	if(prob(50))
		H.visible_message("[H] suddenly goes very red and starts writhing. There is a strange smell in the air...", \
		"<span class='userdanger'>Suddenly the horrible pain strikes your body! Your mind is in complete disorder! Blood pulses and starts burning! The pain is impossible!!!</span>")
		H.adjustBrainLoss(80)

	return TRUE



/obj/item/weapon/implant/mindshield/loyalty
	name = "loyalty implant"
	desc = "Makes you loyal or such."

/obj/item/weapon/implant/mindshield/loyalty/inject(mob/living/carbon/C, def_zone)
	. = ..()
	START_PROCESSING(SSobj, C)

/obj/item/weapon/implant/mindshield/loyalty/get_data()
	var/dat = {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Nanotrasen Employee Management Implant<BR>
	<b>Life:</b> Ten years.<BR>
	<b>Important Notes:</b> Personnel injected with this device tend to be much more loyal to the company.<BR>
	<b>Warning:</b> Usage without special equipment may cause heavy injuries and severe brain damage.<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
	<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
	<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/weapon/implant/mindshield/loyalty/implanted(mob/M)
	. = ..()
	if(.)
		if(M.mind)
			var/cleared_role = TRUE
			switch(M.mind.special_role)
				if("traitor")
					SSticker.mode.remove_traitor(M.mind)
					M.mind.remove_objectives()
				if("Syndicate")
					SSticker.mode.remove_nuclear(M.mind)
					M.mind.remove_objectives()
				else
					cleared_role = FALSE
			if(cleared_role)
				// M.mind.remove_objectives() Uncomment this if you're feeling suicidal, and inable to see player's objectives.
				to_chat(M, "<span class='danger'>You were implanted with [src] and now you must serve NT. Your old mission doesn't matter now.</span>")
				SSticker.reconverted_antags[M.key] = M.mind

		START_PROCESSING(SSobj, src)
		to_chat(M, "NanoTrasen - is the best corporation in the whole Universe!")

/obj/item/weapon/implant/mindshield/loyalty/process()
	if (!implanted || !imp_in)
		STOP_PROCESSING(SSobj, src)
		return
	if(imp_in.stat == DEAD)
		return

	if(prob(1) && prob(25))//1/400
		switch(rand(1, 4))
			if(1)
				to_chat(imp_in, "\italic You [pick("are sure", "think")] that NanoTrasen - is the best corporation in the whole Universe!")
			if(2)
				to_chat(imp_in, "\italic You [pick("are sure", "think")] that Captain is the greatest man who ever lived!")
			if(3)
				to_chat(imp_in, "\italic You want to give your life away in the name of NanoTrasen!")
			if(4)
				to_chat(imp_in, "\italic You are confident that all what Heads of station do - is for a greater good!")