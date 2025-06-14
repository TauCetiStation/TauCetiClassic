/obj/item/weapon/implant/uplink
	name = "uplink"
	cases = list("имплант аплинка", "импланта аплинка", "импланту аплинка", "имплант аплинка", "имплантом аплинка", "импланте аплинка")
	desc = "Призывает всякое."
	legal = FALSE

/obj/item/weapon/implant/uplink/atom_init()
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	. = ..()

/obj/item/weapon/implant/uplink/pre_inject(mob/living/carbon/implant_mob, mob/operator)
	. = ..()
	if(!. || !operator)
		return FALSE

	activation_emote = input(operator, "Выберите, от какой эмоции должна произойти активация:") in list("blink", "eyebrow", "twitch", "frown", "nod", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	operator.mind.store_memory("Имплантат аплинка можно активировать с помощью эмоции [activation_emote], <B>скажите *[activation_emote]</B> чтобы попытаться активировать его.", 0)
	to_chat(operator, "Имплантат свободы можно активировать с помощью эмоции [activation_emote], <B>скажите *[activation_emote]</B> чтобы попытаться активировать его.")

	return TRUE

/obj/item/weapon/implant/uplink/activate()
	hidden_uplink.trigger(implanted_mob)
