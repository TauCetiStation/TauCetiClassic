/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT

	action_button_name = "Toggle Megaphone"

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/device/megaphone/attack_self(mob/living/user)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return
	if(user.silent || isabductor(user) || HAS_TRAIT(user, TRAIT_MUTE))
		to_chat(user, "<span class='userdange'>You can't speak.</span>")
		return
	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		return

	playsound(src, 'sound/items/megaphone.ogg', VOL_EFFECTS_MASTER)
	var/message = sanitize(input(user, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = (capitalize(message))
	if ((src.loc == user && usr.stat == CONSCIOUS))
		if(emagged)
			if(insults)
				user.audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>")
				insults--
			else
				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
		else
			user.audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>")

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/item/device/megaphone/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	emagged = 1
	insults = rand(1, 3)//to prevent dickflooding
	return TRUE
