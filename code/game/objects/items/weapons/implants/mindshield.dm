/obj/item/weapon/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."

/obj/item/weapon/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device are much more resistant to brainwashing.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that protects the host's mental functions from manipulation.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat

/obj/item/weapon/implant/mindshield/implanted(mob/M)
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if((H.mind in (ticker.mode.head_revolutionaries | ticker.mode.A_bosses | ticker.mode.B_bosses)) || is_shadow_or_thrall(H))
		M.visible_message("<span class='warning'>[M] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE

	if(H.mind in ticker.mode.revolutionaries)
		ticker.mode.remove_revolutionary(H.mind)

	if(H.mind in (ticker.mode.A_gang | ticker.mode.B_gang))
		ticker.mode.remove_gangster(H.mind, exclude_bosses=1)
		H.visible_message("<span class='warning'>[src] was destroyed in the process!</span>", "<span class='userdanger'>You feel a surge of loyalty towards Nanotrasen.</span>")
		return FALSE

	if(H.mind in ticker.mode.cult)
		to_chat(H, "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE
	else
		to_chat(H, "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")
	return TRUE
