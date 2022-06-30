/*

Miscellaneous traitor devices

BATTERER


*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/device/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon_state = "batterer"
	throwforce = 5
	w_class = SIZE_MINUSCULE
	throw_speed = 4
	throw_range = 10
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/device/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) 	return
	if(times_used >= max_uses)
		to_chat(user, "<span class='warning'>The mind batterer has been burnt out!</span>")
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [src] to knock down people in the area.</font>")

	for(var/mob/living/carbon/human/M in orange(10, user))
		spawn()
			if(prob(50))

				M.Weaken(rand(10,20))
				if(prob(25))
					M.Stun(rand(5,10))
				to_chat(M, "<span class='warning'><b>You feel a tremendous, paralyzing wave flood your mind.</b></span>")

			else
				to_chat(M, "<span class='warning'><b>You feel a sudden, electric jolt travel through your head.</b></span>")

	playsound(src, 'sound/misc/interference.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You trigger [src].</span>")
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"



//Nuke teleporter
/obj/item/nuke_teleporter
	name = "Recaller"
	desc = "A really strange thing"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-b"
	item_state = "electronic"
	throwforce = 5
	w_class = SIZE_TINY
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	origin_tech = "magnets=3;bluespace=4;syndicate=2"

/obj/item/nuke_teleporter/examine(mob/user, distance)
	. = ..()
	if(isnukeop(user) || isobserver(user))
		to_chat(user, "<span class ='notice'>Nuke teleporter. Teleports a bomb to you after activation. Of course, if the bomb was not destroyed.</span>")

/obj/item/nuke_teleporter/attack_self(mob/user)
	. = ..()
	if(isnukeop(user) || isobserver(user))
		to_chat(user, "<span class ='warning'>Начало калибровки устройства. <span class='boldnotice'>1/5</span></span>")
		if(!do_after(user,100,target = src))
			return
		spark(1, 0, loc)
		to_chat(user, "<span class ='warning'>Поиск ядерного заряда. <span class='boldnotice'>2/5</span></span>")
		if(!do_after(user,100,target = src))
			return
		for(var/obj/machinery/nuclearbomb/N in poi_list)
			if(N.nuketype == "Syndi")
				spark(1, 0, N.loc)
				spark(2, 0, loc)
				to_chat(user, "<span class ='warning'>Заряд найден. Инициализация блюспейс протоколов. <span class='boldnotice'>3/5</span></span>")

				if(!do_after(user,100,target = src))
					return
				spark(2, 0, N.loc)
				spark(3, 0, loc)
				to_chat(user, "<span class ='warning'>Протоколы активны. Вычисление возможных координат для телепорта. <span class='boldnotice'>4/5</span></span>")

				if(!do_after(user,100,target = src)) return
				spark(3, 0, N.loc)
				spark(4, 0, loc)
				to_chat(user, "<span class ='warning'>Вычислено. Инициализация перемещения. <span class='boldnotice'>5/5</span></span>")

				if(!do_after(user,100,target = src))
					return
				spark(5, 0, N.loc)
				spark(5, 0, loc)

				N.forceMove(get_turf(src))
				to_chat(user, "<span class ='warning'>Перемещение завершено.</span>")
				return
		to_chat(user, "<span class ='warning'>Внимание! Бомба не найдена! Предположительная причина: Бомба уничтожена.</span>")

/obj/item/nuke_teleporter/proc/spark(value = 1, cardinals = 0, location = src)
	var/datum/effect/effect/system/spark_spread/spark_system = new
	spark_system.set_up(value, cardinals, location)
	spark_system.start()



