/*
CONTAINS:
RSF

*/
#define RSF_CIG 1
#define RSF_GLASS 2
#define RSF_PAPER 3
#define RSF_PEN 4
#define RSF_DICE 5

/obj/item/weapon/rsf
	name = "Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = RSF_CIG
	w_class = ITEM_SIZE_NORMAL
	var/static/list/mode2type = list(
		RSF_CIG = /obj/item/clothing/mask/cigarette,
		RSF_GLASS = /obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
		RSF_PAPER = /obj/item/weapon/paper,
		RSF_PEN = /obj/item/weapon/pen,
		RSF_DICE = /obj/item/weapon/storage/pill_bottle/dice
	)
	var/static/list/mode2name = list(
		RSF_CIG = "Ciggarette",
		RSF_GLASS = "Drinking Glass",
		RSF_PAPER = "Paper Sheet",
		RSF_PEN = "Pen",
		RSF_DICE = "Dice Pack"
	)
	var/static/list/mode2res = list(
		RSF_CIG = 1,
		RSF_GLASS = 2,
		RSF_PAPER = 1,
		RSF_PEN = 2,
		RSF_DICE = 5
	)

/obj/item/weapon/rsf/atom_init()
	. = ..()
	desc = "A RSF. It currently holds [matter]/30 fabrication-units."

/obj/item/weapon/rsf/attackby(obj/item/weapon/W, mob/user)
	..()
	if (istype(W, /obj/item/weapon/rcd_ammo))
		if ((matter + 10) > 30)
			to_chat(user, "The RSF cant hold any more matter.")
			return
		qdel(W)
		matter += 10
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
		to_chat(user, "The RSF now holds [matter]/30 fabrication-units.")
		desc = "A RSF. It currently holds [matter]/30 fabrication-units."
		return

/obj/item/weapon/rsf/attack_self(mob/user)
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	mode++
	if (mode > mode2name.len)
		mode = RSF_CIG
	var/modename = mode2name[mode]
	to_chat(user, "Changed dispensing mode to '[modename]'.")
	// Change mode

/obj/item/weapon/rsf/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if (!(istype(A, /obj/structure/table) || istype(A, /turf/simulated/floor)))
		return
	var/obj/item/I = null
	if (mode2type[mode] && useResources(mode2res[mode], user))
		var/modename = mode2name[mode]
		var/modetype = mode2type[mode]
		to_chat(user, "Dispensing [modename]...")
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 10)
		I = new modetype(user)
		if (istype(A, /obj/structure/table))
			I.forceMove(A.loc)
		else
			I.forceMove(A)

/obj/item/weapon/rsf/proc/checkResources(amount, mob/user)
	if (isrobot(user))
		return user:cell:charge >= (amount * 30)
	return matter >= amount

/obj/item/weapon/rsf/proc/useResources(amount, mob/user)
	if (checkResources(amount, user))
		if (isrobot(user))
			user:cell:use(amount * 30)
		else
			matter -= amount
			desc = "A RCD. It currently holds [matter]/30 matter-units."
		return 1
	return 0

#undef RSF_CIG
#undef RSF_GLASS
#undef RSF_PAPER
#undef RSF_PEN
#undef RSF_DICE