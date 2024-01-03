/obj/item/weapon/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	var/activation_emote = "blink"
	uses = 1.0

	implant_type = "r"

/obj/item/weapon/implant/freedom/atom_init()
	activation_emote = pick("blink", "eyebrow", "twitch", "frown", "nod", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	uses = rand(3, 5)
	. = ..()


/obj/item/weapon/implant/freedom/trigger(emote, mob/living/carbon/source)
	if (uses < 1)
		return 0
	if (emote != activation_emote)
		return
	if (!source.handcuffed)
		to_chat(source, "You need to be restricted to use freedom implant.")
		return
	uses--
	to_chat(source, "You feel a faint click.")
	source.uncuff()
	source.SetParalysis(0)
	source.SetStunned(0)
	source.SetWeakened(0)
	source.reagents.add_reagent("oxycodone", 5)
	source.reagents.add_reagent("stimulants", 5)
	source.reagents.add_reagent("tramadol", 10)
	source.reagents.add_reagent("paracetamol", 20)
	return


/obj/item/weapon/implant/freedom/implanted(mob/living/carbon/source)
	source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0)
	to_chat(source, "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1


/obj/item/weapon/implant/freedom/get_data()
	var/dat = {"
		<b>Implant Specifications:</b><BR>
		<b>Name:</b> Freedom Beacon<BR>
		<b>Life:</b> optimum 5 uses<BR>
		<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
		<HR>
		<b>Implant Details:</b> <BR>
		<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
		mechanisms<BR>
		<b>Special Features:</b><BR>
		<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
		<b>Integrity:</b> The battery is extremely weak and commonly after injection its
		life can drive down to only 1 use.<HR>
		No Implant Specifics"}
	return dat


