/obj/item/weapon/implant/freedom
	name = "freedom implant"
	cases = list("имплант свободы", "импланта свободы", "импланту свободы", "имплант свободы", "имплантом свободы", "импланте свободы")
	desc = "Используйте это, чтоб удрать от злых Красных рубашек."
	gender = MALE
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
		to_chat(source, "Имплант свободы не работает, пока вы не связаны.")
		return
	uses--
	to_chat(source, "Вы слышите, как что-то легонько щёлкнуло.")
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
	source.mind.store_memory("Имплантат свободы можно активировать с помощью эмоции [src.activation_emote], <B>скажите *[src.activation_emote]</B> чтобы попытаться активировать его.", 0)
	to_chat(source, "Имплантат свободы можно активировать с помощью эмоции [src.activation_emote], <B>скажите *[src.activation_emote]</B> чтобы попытаться активировать его.")
	return 1


/obj/item/weapon/implant/freedom/get_data()
	var/dat = {"
		<b>Характеристики импланта:</b><BR>
		<b>Наименование: </b>Имплант свободы<BR>
		<b>Срок годности: </b>оптимально до 5 применений<BR>
		<b>Важные примечания: </b><font color='red'>Нелегален</font><BR>
		<HR>
		<b>Подробности:</b> <BR>
		<b>Функционал:</b> Издаёт специализированный набор сигналов, призванных обойти замки в наручниках.<BR>
		<b>Особенности:</b><BR>
		<i>Нейросканирование</i>- Активируется от определённых теневых сигналов, подаваемых нервной системой носителя.<BR>
		<b>Целостность:</b> Несовершенство технологии не позволяет установить более лучший аккумулятор, из-за чего имплант достаточно быстро выходит из строя.
		применений лишь до одного использования.<HR>"}
	return dat


