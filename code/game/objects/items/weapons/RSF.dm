/*
CONTAINS:
RSF

*/
/obj/item/weapon/rsf
	name = "Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/rsf/atom_init()
	. = ..()
	desc = "A RSF. It currently holds [matter]/30 fabrication-units."

/obj/item/weapon/rsf/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/rcd_ammo))
		if(matter + 10 > 30)
			to_chat(user, "The RSF cant hold any more matter.")
			return
		qdel(I)
		matter += 10
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."

	else
		return ..()

/obj/item/weapon/rsf/attack_self(mob/user)
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	if (mode == 1)
		mode = 2
		to_chat(user, "Changed dispensing mode to 'Drinking Glass'")
		return
	if (mode == 2)
		mode = 3
		to_chat(user, "Changed dispensing mode to 'Paper'")
		return
	if (mode == 3)
		mode = 4
		to_chat(user, "Changed dispensing mode to 'Pen'")
		return
	if (mode == 4)
		mode = 5
		to_chat(user, "Changed dispensing mode to 'Dice Pack'")
		return
	if (mode == 5)
		mode = 6
		to_chat(user, "Changed dispensing mode to 'Cigarette'")
		return
	if (mode == 6)
		mode = 1
		to_chat(user, "Changed dispensing mode to 'Dosh'")
		return
	// Change mode

/obj/item/weapon/rsf/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if (!(istype(target, /obj/structure/table) || istype(target, /turf/simulated/floor)))
		return

	if (istype(target, /obj/structure/table) && mode == 1)
		if (istype(target, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Dosh...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/spacecash/c10( target.loc )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200 //once money becomes useful, I guess changing this to a high ammount, like 500 units a kick, till then, enjoy dosh!
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /turf/simulated/floor) && mode == 1)
		if (istype(target, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Dosh...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/spacecash/c10( target )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200 //once money becomes useful, I guess changing this to a high ammount, like 500 units a kick, till then, enjoy dosh!
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /obj/structure/table) && mode == 2)
		if (istype(target, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Drinking Glass...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass( target.loc )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /turf/simulated/floor) && mode == 2)
		if (istype(target, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Drinking Glass...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass( target )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /obj/structure/table) && mode == 3)
		if (istype(target, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Paper Sheet...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/paper( target.loc )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /turf/simulated/floor) && mode == 3)
		if (istype(target, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Paper Sheet...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/paper( target )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /obj/structure/table) && mode == 4)
		if (istype(target, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Pen...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/pen( target.loc )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /turf/simulated/floor) && mode == 4)
		if (istype(target, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Pen...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/pen( target )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 50
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /obj/structure/table) && mode == 5)
		if (istype(target, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Dice Pack...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/storage/pill_bottle/dice( target.loc )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /turf/simulated/floor) && mode == 5)
		if (istype(target, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Dice Pack...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/weapon/storage/pill_bottle/dice( target )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 200
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /obj/structure/table) && mode == 6)
		if (istype(target, /obj/structure/table) && matter >= 1)
			to_chat(user, "Dispensing Cigarette...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/clothing/mask/cigarette( target.loc )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

	else if (istype(target, /turf/simulated/floor) && mode == 6)
		if (istype(target, /turf/simulated/floor) && matter >= 1)
			to_chat(user, "Dispensing Cigarette...")
			playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
			new /obj/item/clothing/mask/cigarette( target )
			if (isrobot(user))
				var/mob/living/silicon/robot/engy = user
				engy.cell.charge -= 10
			else
				matter--
				to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
				desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return
