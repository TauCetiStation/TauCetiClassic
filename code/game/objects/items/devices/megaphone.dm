/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = 2.0
	flags = CONDUCT

	action_button_name = "Toggle Megaphone"

	var/spamcheck = 0
	var/emagged = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/device/megaphone/attack_self(mob/living/user)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "\red You cannot speak in IC (muted).")
			return
	if(!ishuman(user))
		to_chat(user, "\red You don't know how to use this!")
		return
	if(user.silent || isabductor(user))
		return
	if(spamcheck)
		to_chat(user, "\red \The [src] needs to recharge!")
		return

	playsound(src, 'sound/items/megaphone.ogg', 100, 1, 1)
	var/message = sanitize_plus(copytext(input(user, "Shout a message?", "Megaphone", null)  as text,1,MAX_MESSAGE_LEN))
	if(!message)
		return
	message = sanitize_plus_chat(capitalize(message))
	if ((src.loc == user && usr.stat == CONSCIOUS))
		if(emagged)
			if(insults)
				for(var/mob/O in (viewers(user)))
					O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>",2) // 2 stands for hearable message
				insults--
			else
				to_chat(user, "\red *BZZZZzzzzzt*")
		else
			for(var/mob/O in (viewers(user)))
				O.show_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2) // 2 stands for hearable message

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/item/device/megaphone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		to_chat(user, "\red You overload \the [src]'s voice synthesizer.")
		emagged = 1
		insults = rand(1, 3)//to prevent dickflooding
		return
	return
