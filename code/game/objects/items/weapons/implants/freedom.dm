/obj/item/weapon/implant/freedom
	name = "freedom implant"
	cases = list("имплант свободы", "импланта свободы", "импланту свободы", "имплант свободы", "имплантом свободы", "импланте свободы")
	desc = "Используйте это, чтоб удрать от злых Красных рубашек."
	legal = FALSE
	delete_after_use = TRUE
	uses = 1

	implant_data = {"
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

/obj/item/weapon/implant/freedom/atom_init()
	if(prob(reliability))
		uses = rand(3, 5)

	. = ..()

/obj/item/weapon/implant/freedom/pre_inject(mob/living/carbon/implant_mob, mob/operator)
	. = ..()
	if(!. || !operator)
		return FALSE

	activation_emote = input(operator, "Выберите, от какой эмоции должна произойти активация:") in list("blink", "eyebrow", "twitch", "frown", "nod", "giggle", "grin", "groan", "shrug", "smile", "sniff", "whimper", "wink")
	operator.mind.store_memory("Имплантат свободы можно активировать с помощью эмоции [activation_emote], <B>скажите *[activation_emote]</B> чтобы попытаться активировать его.", 0)
	to_chat(operator, "Имплантат свободы можно активировать с помощью эмоции [activation_emote], <B>скажите *[activation_emote]</B> чтобы попытаться активировать его.")

	return TRUE

/obj/item/weapon/implant/freedom/activate()
	to_chat(implanted_mob, "Вы слышите, как что-то легонько щёлкнуло.")
	if(implanted_mob.handcuffed)
		implanted_mob.uncuff()
	implanted_mob.SetParalysis(0)
	implanted_mob.SetStunned(0)
	implanted_mob.SetWeakened(0)
	implanted_mob.reagents.add_reagent("oxycodone", 5)
	implanted_mob.reagents.add_reagent("stimulants", 5)
	implanted_mob.reagents.add_reagent("tramadol", 10)
	implanted_mob.reagents.add_reagent("paracetamol", 20)
