/obj/item/weapon/plastique
	name = "plastic explosives"
	cases = list("взрывчатка", "взрывчатки", "взрывчатке", "взрывчатку", "взрывчаткой", "взрывчатке")
	desc = "Используется для создания точечных взрывов в определенных областях."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = NOBLUDGEON
	w_class = SIZE_TINY
	origin_tech = "syndicate=2"
	var/timer = 10
	var/atom/target = null

/obj/item/weapon/plastique/attack_self(mob/user)
	if(!handle_fumbling(user, src, SKILL_TASK_TRIVIAL, list(/datum/skill/firearms = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around figuring out how to set timer on [src]...</span>"))
		return
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime < 10)
		newtime = 10
	timer = newtime
	to_chat(user, "Таймер установлен на [timer] секунд.")

/obj/item/weapon/plastique/afterattack(atom/target, mob/user, proximity, params)
	if (!proximity)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/machinery/nuclearbomb))
		return
	if(user.is_busy()) return
	to_chat(user, "Устанавливает взрывчатку...")
	if(ismob(target))
		var/mob/living/M = target
		M.log_combat(user, "planted (attempt) with [name]")
		user.visible_message("<span class ='red'> [user.name] пытается установить взрывчатку на [M.name]!</span>")
	else
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target.name]</font>"
		msg_admin_attack("[user.real_name] ([user.ckey]) [ADMIN_FLW(user)] tried planting [name] on [target.name]", user)

	var/planting_time = apply_skill_bonus(user, SKILL_TASK_TOUGH, list(/datum/skill/firearms = SKILL_LEVEL_MASTER, /datum/skill/engineering = SKILL_LEVEL_PRO), -0.1)
	if(do_after(user, planting_time, target = target) && user.Adjacent(target))
		if(ismob(target))
			var/mob/living/M = target
			M.attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("<span class ='red'> [user.name] устанавливает взрывчатку на [M.name]!</span>")
		to_chat(user, "Взрывчатка установлена, отсчет времени [timer].")
		user.drop_item()
		plant_bomb(target)

/obj/item/weapon/plastique/proc/plant_bomb(atom/atom_target)
	target = atom_target
	loc = null
	target.add_overlay(image('icons/obj/assemblies.dmi', "plastic-explosive2"))
	addtimer(CALLBACK(src, PROC_REF(prime_explosion), target), timer SECONDS)

/obj/item/weapon/plastique/proc/prime_explosion(atom/target)
	if(!target)
		return
	var/location = target
	if(ismob(target) || isobj(target))
		location = target.loc
	if(iswallturf(target))
		var/turf/simulated/wall/W = target
		W.dismantle_wall(1)
	else
		target.ex_act(EXPLODE_DEVASTATE)

	explosion(location, 0, 0, 2, 3)
	if(target && !QDELETED(target))
		target.cut_overlay(image('icons/obj/assemblies.dmi', "plastic-explosive2"))
	if(src)
		qdel(src)

/obj/item/weapon/plastique/attack(mob/M, mob/user, def_zone)
	return
