/obj/item/weapon/syndie
	icon = 'icons/obj/syndieweapons.dmi'

/*C-4 explosive charge and etc, replaces the old syndie transfer valve bomb.*/


/*The explosive charge itself.  Flashes for five seconds before exploding.*/

/obj/item/weapon/syndie/c4explosive
	name = "normal-sized package"
	cases = list("взрывчатка", "взрывчатки", "взрывчатке", "взрывчатку", "взрывчаткой", "взрывчатке")
	desc = "Небольшой завернутый пакет."
	icon_state = "c-4small_0"
	item_state = "c-4small"
	w_class = SIZE_SMALL

	var/power = 1  /*Size of the explosion.*/
	var/size = "small"  /*Used for the icon, this one will make c-4small_0 for the off state.*/

/obj/item/weapon/syndie/c4explosive/heavy
	icon_state = "c-4large_0"
	item_state = "c-4large"
	desc = "Таинственный пакет, он довольно тяжелый."
	power = 2
	size = "large"

/obj/item/weapon/syndie/c4explosive/atom_init()
	. = ..()
	var/K = rand(1,2000)
	K = md5(num2text(K)+name)
	K = copytext(K,1,7)
	src.desc += "\n Вы видите [K], выгравированное на [CASE(src ,PREPOSITIONAL_CASE)]."
	var/obj/item/weapon/syndie/c4detonator/detonator = new(src.loc)
	detonator.desc += "\n Вы видите [K], выгравированное на зажигалке."
	detonator.bomb = src

/obj/item/weapon/syndie/c4explosive/proc/detonate()
	icon_state = "c-4[size]_1"
	spawn(50)
		explosion(get_turf(src), power, power*2, power*3, power*4)
		for(var/dirn in cardinal)		//This is to guarantee that C4 at least breaks down all immediately adjacent walls and doors.
			var/turf/simulated/wall/T = get_step(src,dirn)
			if(locate(/obj/machinery/door/airlock) in T)
				var/obj/machinery/door/airlock/D = locate() in T
				if(D.density)
					D.open()
			if(iswallturf(T))
				T.dismantle_wall(1)
		qdel(src)


/*Detonator, disguised as a lighter*/
/*Click it when closed to open, when open to bring up a prompt asking you if you want to close it or press the button.*/

/obj/item/weapon/syndie/c4detonator
	name = "Zippo lighter"  /*Sneaky, thanks Dreyfus.*/
	desc = "Зиппо."
	cases = list("зажигалка", "зажигалки", "зажигалке", "зажигалку", "зажигалкой", "зажигалке")
	icon_state = "c-4detonator_0"
	item_state = "c-4detonator"
	w_class = SIZE_MINUSCULE

	var/obj/item/weapon/syndie/c4explosive/bomb
	var/pr_open = 0  /*Is the "What do you want to do?" prompt open?*/

/obj/item/weapon/syndie/c4detonator/attack_self(mob/user)
	switch(src.icon_state)
		if("c-4detonator_0")
			src.icon_state = "c-4detonator_1"
			to_chat(user, "Вы открываете зажигалку.")

		if("c-4detonator_1")
			if(!pr_open)
				pr_open = 1
				switch(tgui_alert(user, "What would you like to do?", "Lighter", list("Press the button.", "Close the lighter.")))
					if("Press the button.")
						to_chat(user, "<span class='warning'>Вы нажимаете на кнопку.</span>")
						flick("c-4detonator_click", src)
						if(src.bomb)
							bomb.detonate()
							log_admin("[user.real_name]([user.ckey]) has triggered [src.bomb] with [src].")
							message_admins("<span class='warning'>[user.real_name]([user.ckey]) has triggered [src.bomb] with [src]. [ADMIN_JMP(src)]</span>")

					if("Close the lighter.")
						src.icon_state = "c-4detonator_0"
						to_chat(user, "Вы закрываете зажигалку.")
				pr_open = 0
