/obj/item/weapon/implant/uplink
	name = "uplink"
	cases = list("аплинк имплант", "аплинк импланта", "аплинк импланту", "аплинк имплант", "аплинк имплантом", "аплинк импланте")
	desc = "Призывает всякое."
	var/activation_emote = "blink"

/obj/item/weapon/implant/uplink/atom_init()
	activation_emote = pick("blink", "eyebrow", "twitch", "frown", "nod", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	. = ..()

/obj/item/weapon/implant/uplink/implanted(mob/source)
	activation_emote = input("Выберите, от какой эмоции должна произойти активация:") in list("blink", "eyebrow", "twitch", "frown", "nod", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	source.mind.store_memory("Имплантат аплинка можно активировать с помощью эмоции [src.activation_emote], <B>скажите *[src.activation_emote]</B> чтобы попытаться активировать его.", 0)
	to_chat(source, "Имплантат свободы можно активировать с помощью эмоции [src.activation_emote], <B>скажите *[src.activation_emote]</B> чтобы попытаться активировать его.")
	return 1


/obj/item/weapon/implant/uplink/trigger(emote, mob/source)
	if(hidden_uplink && usr == source) // Let's not have another people activate our uplink
		hidden_uplink.check_trigger(source, emote, activation_emote)
	return
