/obj/item/weapon/plastique/attack_self(mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	timer = newtime
	to_chat(user, "Timer set for [timer] seconds.")

/obj/item/weapon/plastique/afterattack(atom/target, mob/user, proximity, params)
	if (!proximity)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/machinery/nuclearbomb))
		return
	if(user.is_busy()) return
	to_chat(user, "Planting explosives...")
	if(ismob(target))
		var/mob/living/M = target
		M.log_combat(user, "planted (attempt) with [name]")
		user.visible_message("<span class ='red'> [user.name] is trying to plant some kind of explosive on [M.name]!</span>")
	else
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target.name]</font>"
		msg_admin_attack("[user.real_name] ([user.ckey]) [ADMIN_FLW(user)] tried planting [name] on [target.name]", user)

	if(do_after(user, 50, target = target) && in_range(user, target))
		user.drop_item()
		target = target
		loc = null
		var/location
		if(ismob(target))
			var/mob/living/M = target
			M.attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("<span class ='red'> [user.name] finished planting an explosive on [M.name]!</span>")
		else
			location = target
		target.add_overlay(image('icons/obj/assemblies.dmi', "plastic-explosive2"))
		to_chat(user, "Bomb has been planted. Timer counting down from [timer].")
		addtimer(CALLBACK(src, .proc/prime_explosion, target, location), timer * 10)

/obj/item/weapon/plastique/proc/prime_explosion(atom/target, location)
	if(!target)
		return
	if(ismob(target) || isobj(target))
		location = target.loc
	if(istype(target, /turf/simulated/wall))
		var/turf/simulated/wall/W = target
		W.dismantle_wall(1)
	else
		target.ex_act(1)

	explosion(location, 0, 0, 2, 3)
	if(target && !QDELETED(target))
		target.cut_overlay(image('icons/obj/assemblies.dmi', "plastic-explosive2"))
	if(src)
		qdel(src)

/obj/item/weapon/plastique/attack(mob/M, mob/user, def_zone)
	return
