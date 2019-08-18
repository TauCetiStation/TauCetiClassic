/obj/item/weapon/implant/adrenaline
	name = "adrenaline implant"
	desc = "Removes all stuns and knockdowns."
	var/activation_emote = "chuckle"
	var/uses = 1.0

/obj/item/weapon/implant/adrenaline/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Cybersun Industries Adrenalin Implant<BR>
<b>Life:</b> Five days.<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> Subjects injected with implant can activate a massive injection of adrenalin.<BR>
<b>Function:</b> Contains nanobots to stimulate body to mass-produce Adrenalin.<BR>
<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
<b>Integrity:</b> Implant can only be used three times before the nanobots are depleted."}
	return dat

/obj/item/weapon/implant/adrenaline/atom_init()
	activation_emote = pick("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	uses = (3)
	. = ..()

/obj/item/weapon/implant/adrenaline/trigger(emote, mob/living/carbon/user)
	if (uses < 1)
		return 0
	if (emote == activation_emote)
		to_chat(user, "<span class='notice'>You feel the energy flows.</span>")
		uses--
		user.stat = CONSCIOUS
		user.SetParalysis(0)
		user.SetStunned(0)
		user.SetWeakened(0)
		user.lying = 0
		user.update_canmove()
		user.reagents.add_reagent("hyperzine", 1.0)
		user.reagents.add_reagent("stimulants", 2.0)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.halloss = 0
			H.shock_stage = 0
	return

/obj/item/weapon/implant/adrenaline/implanted(mob/living/carbon/source)
	source.mind.store_memory("Adrenaline implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0)
	to_chat(source, "The implanted adrenaline implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1


