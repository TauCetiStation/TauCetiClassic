/obj/item/weapon/implant/freedom
	name = "freedom implant"
	cases = list("имплант освобождения", "импланта освобождения", "импланту освобождения", "имплант освобождения", "имплантом освобождения", "импланте освобождения")
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
		to_chat(source, "Имплант освобождения не работает, пока вы не связаны.")
		return
	uses--
	to_chat(source, "Вы слышите как что-то легонько щёлкнуло.")
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
		<b>Характеристики импланта:</b><BR>
		<b>Наименование:</b> Маяк Свободы<BR>
		<b>Срок годности:</b> оптимально до 5 применений<BR>
		<b>Важные примечания:</b> <font color='red'>Нелегален</font><BR>
		<HR>
		<b>Подробности:</b> <BR>
		<b>Функционал:</b> Издаёт специализированный набор сигналов, призванных обойти замки в наручниках.<BR>
		<b>Особенности:</b><BR>
		<i>Нейросканирование</i>- Активируется от определённых теневых сигналов, подаваемых нервной системой носителя.<BR>
		<b>Целостность:</b> Заряд аккумулятора в импланте очень слаб, часто сокращая его количество
		применений лишь до одного использования.<HR>"}
	return dat


