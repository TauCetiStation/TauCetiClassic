/obj/item/weapon/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	item_color = "r"
	var/activation_emote = "blink"
	uses = 1.0

/obj/item/weapon/implant/freedom/atom_init()
	activation_emote = pick("blink", "eyebrow", "twitch", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	uses = rand(1, 5)
	. = ..()


/obj/item/weapon/implant/freedom/trigger(emote, mob/living/carbon/source)
	if (uses < 1)
		return 0
	if (emote == activation_emote)
		uses--
		to_chat(source, "You feel a faint click.")
		source.uncuff()
	return


/obj/item/weapon/implant/freedom/implanted(mob/living/carbon/source)
	source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0)
	to_chat(source, "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.")
	return 1


/obj/item/weapon/implant/freedom/get_data()
	var/dat = {"
		<b>Характеристики Импланта:</b><BR>
		<b>Название:</b> Имплант Освобождения Cybersun Industries класса "Freedom Beacon".<BR>
		<b>Активация:</b> До пяти использований.<BR>
		<b>Важные примечания:</b> <font color='red'>Контрабанда.</font><BR>
		<HR>
		<b>Детали:</b> <BR>
		<b>Функции:</b> Передача специализированного набора сигналов для обхода механизмов блокировки наручников.<BR>
		<b>Особые возможности:</b><BR>
		<i>Нейро-Скан</i> - Анализ определенных скрытых сигналов нервной системы.<BR>
		<b>Надежность:</b> Батарея чрезвычайно слаба, и иногда после инъекции ее срок службы может сократиться до 1 использования.<HR>"}
	return dat
