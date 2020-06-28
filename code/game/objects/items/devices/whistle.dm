/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	action_button_name = "Toggle Hailer"
	w_class = ITEM_SIZE_TINY
	flags = CONDUCT

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0//just in case

/obj/item/device/hailer/attack_self(mob/living/carbon/user)
	if (spamcheck)
		return

	if(emagged)
		if(insults >= 1)
			playsound(src, 'sound/voice/beepsky/insult.ogg', VOL_EFFECTS_MASTER, null, FALSE)//hueheuheuheuheuheuhe
			audible_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"</span>")
			insults--
		else
			to_chat(user, "<span class='warning'>*BZZZZcuntZZZZT*</span>")
	else
		playsound(src, 'sound/voice/halt.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		audible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>")
	if(user)
		var/list/halt_recipients = list()
		for(var/mob/M in viewers(user, null))
			if ((M.client && !( M.blinded )))
				halt_recipients.Add(M.client)
		var/image/I = image('icons/mob/talk.dmi', user, "halt", MOB_LAYER+1)
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		flick_overlay(I, halt_recipients, 14)
	spamcheck = 1
	spawn(20)
		spamcheck = 0

/obj/item/device/hailer/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	emagged = 1
	insults = rand(1, 3)//to prevent dickflooding
	return TRUE
