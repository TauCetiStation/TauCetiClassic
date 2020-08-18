/obj/item/weapon/implant/uplink
	name = "uplink"
	desc = "Summon things."
	var/activation_emote = "blink"

/obj/item/weapon/implant/uplink/atom_init()
	activation_emote = pick("blink", "eyebrow", "twitch", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	. = ..()

/obj/item/weapon/implant/uplink/implanted(mob/source)
	activation_emote = input("Choose activation emote:") in list("blink", "eyebrow", "twitch", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	source.mind.store_memory("Uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0)
	to_chat(source, "The implanted uplink implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1


/obj/item/weapon/implant/uplink/trigger(emote, mob/source)
	if(hidden_uplink && usr == source) // Let's not have another people activate our uplink
		hidden_uplink.check_trigger(source, emote, activation_emote)
	return
