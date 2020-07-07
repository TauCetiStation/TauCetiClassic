/obj/item/cardboard_cutout
	name = "cardboard cutout"
	desc = "A vaguely humanoid cardboard cutout. It's completely blank."
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	w_class = ITEM_SIZE_LARGE
	var/list/possible_appearances = list("Assistant", "Clown", "Mime",
		"Traitor", "Nuke Op", "Cultist","Revolutionary", "Wizard", "Shadowling", "Xenomorph", "Deathsquad Officer", "Ian")
	var/pushed_over = FALSE //If the cutout is pushed over and has to be righted
	var/painting = FALSE
	var/lastattacker = null

/obj/item/cardboard_cutout/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HELP || pushed_over)
		return ..()
	user.SetNextMove(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] pushes over [src]!</span>", "<span class='danger'>You push over [src]!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
	push_over()

/obj/item/cardboard_cutout/proc/push_over()
	name = initial(name)
	desc = "[initial(desc)] It's been pushed over."
	icon = initial(icon)
	icon_state = "cutout_pushed_over"
	alpha = initial(alpha)
	pushed_over = TRUE

/obj/item/cardboard_cutout/attack_self(mob/living/user)
	if(!pushed_over)
		return
	to_chat(user,"<span class='notice'>You right [src].</span>")
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state)
	pushed_over = FALSE

/obj/item/cardboard_cutout/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		if(painting)
			return
		painting = TRUE
		change_appearance(I, user)
		painting = FALSE
		return

	if(!I.force)
		playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER)
	else if(length(I.hitsound))
		playsound(loc, pick(I.hitsound), VOL_EFFECTS_MASTER)
	if(I.force && prob(I.force))
		push_over()
	return ..()

/obj/item/cardboard_cutout/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>[src] has been hit by [P]!</span>")
	playsound(src, 'sound/weapons/slice.ogg', VOL_EFFECTS_MASTER)
	if(prob(P.damage))
		push_over()

/obj/item/cardboard_cutout/proc/change_appearance(obj/item/toy/crayon/crayon, mob/living/user)
	if(!user)
		return
	if(pushed_over)
		to_chat(user,"<span class='warning'>Right [src] first!</span>")
		return
	var/new_appearance = input(user, "Choose a new appearance for [src].", "26th Century Deception") as null|anything in possible_appearances
	if(!new_appearance || !crayon)
		return
	if(!user.Adjacent(src))
		return
	if(!do_after(user, 10, FALSE, src, FALSE))
		return
	user.visible_message("<span class='notice'>[user] gives [src] a new look.</span>", "<span class='notice'>Voila! You give [src] a new look.</span>")
	alpha = 255
	icon = initial(icon)
	switch(new_appearance)
		if("Assistant")
			name = "[pick(first_names_male)] [pick(last_names)]"
			desc = "A cardboat cutout of an assistant."
			icon_state = "cutout_greytide"
		if("Clown")
			name = pick(clown_names)
			desc = "A cardboard cutout of a clown. You get the feeling that it should be in a corner."
			icon_state = "cutout_clown"
		if("Mime")
			name = "[pick(first_names_male)] [pick(last_names)]"
			desc = "...(A cardboard cutout of a mime.)"
			icon_state = "cutout_mime"
		if("Traitor")
			name = "[pick("Unknown", "Captain")]"
			desc = "A cardboard cutout of a traitor."
			icon_state = "cutout_traitor"
		if("Nuke Op")
			name = "[pick("Unknown", "COMMS", "Telecomms", "AI", "stealthy op", "STEALTH", "sneakybeaky", "MEDIC", "Medic")]"
			desc = "A cardboard cutout of a nuclear operative."
			icon_state = "[pick("cutout_flukecombat", "cutout_flukespace")]"
		if("Cultist")
			name = "Unknown"
			desc = "A cardboard cutout of a cultist."
			icon_state = "cutout_cultist"
		if("Revolutionary")
			name = "Unknown"
			desc = "A cardboard cutout of a revolutionary."
			icon_state = "cutout_viva"
		if("Wizard")
			name = "[pick(wizard_first)], [pick(wizard_second)]"
			desc = "A cardboard cutout of a wizard."
			icon_state = "cutout_wizard"
		if("Shadowling")
			name = pick(possibleShadowlingNames)
			desc = "A cardboard cutout of a shadowling."
			icon_state = "cutout_shadowling"
		if("Xenomorph")
			name = "alien hunter ([rand(1, 999)])"
			desc = "A cardboard cutout of a xenomorph."
			icon_state = "cutout_fukken_xeno"
			if(prob(25))
				alpha = 75 //Spooky sneaking!
		if("Deathsquad Officer")
			name = pick(commando_names)
			desc = "A cardboard cutout of a death commando."
			icon_state = "cutout_deathsquad"
		if("Ian")
			name = "Ian"
			desc = "A cardboard cutout of the HoP's beloved corgi."
			icon_state = "cutout_ian"
	return 1
