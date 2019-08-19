/obj/item/weapon/implant/adrenaline
	name = "adrenaline implant"
	desc = "Removes all stuns and knockdowns."
	icon_state = "implant"
	var/uses = 3

	action_button_name = "Adrenaline implant"
	action_button_is_hands_free = 1

/obj/item/weapon/implant/adrenaline/ui_action_click()
	trigger()

/obj/item/weapon/implant/adrenaline/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Adrenalin Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate a massive injection of adrenalin.<BR>
				<b>Function:</b> Contains nanobots to stimulate body to mass-produce Adrenalin.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant can only be used three times before the nanobots are depleted."}
	return dat

/obj/item/weapon/implant/adrenaline/trigger()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel the energy flows.</span>")
	if(ishuman(imp_in))
		var/mob/living/carbon/human/H = imp_in
		H.halloss = 0
		H.shock_stage = 0
	imp_in.stat = CONSCIOUS
	imp_in.SetParalysis(0)
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.lying = 0
	imp_in.update_canmove()
	imp_in.reagents.add_reagent("hyperzine", 1)
	imp_in.reagents.add_reagent("stimulants", 4)
	if (!uses)
		qdel(src)



