/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	if(loc && loc.check_fluid_depth(30))
		var/total_depth = loc.get_fluid_depth()
		water_act(total_depth)
		for(var/obj/item/I in contents)
			I.water_act(total_depth)

/obj/effect/fluid/Crossed(atom/movable/AM)
	. = ..()
	if(!iscarbon(AM))
		return
	var/mob/living/carbon/C = AM
	if(fluid_amount > FLUID_SHALLOW)
		return

	if(prob(2))
		if(C.m_intent == "run" && !C.buckled)
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(istype(H.shoes, /obj/item/clothing/shoes) && H.shoes.flags & NOSLIP)
					return
				if(istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && H.wear_suit.flags & NOSLIP)
					return
				var/list/inv_contents = list()
				for(var/obj/item/I in H.contents)
					if(istype(I, /obj/item/weapon/implant))
						continue
					inv_contents += I
				if(inv_contents.len)
					for(var/n = 3, n > 0, n--)
						var/obj/item/I = pick(inv_contents)
						I.make_wet()

			C.stop_pulling()
			to_chat(C, "<span class='notice'>You slipped on the wet floor!</span>")
			playsound(src, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER, null, null, -3)
			C.Stun(5)
			C.Weaken(2)

	if(prob(5))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.shoes, /obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = H.shoes
				S.make_wet()

/obj/effect/fluid/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/energy/electrode) || istype(Proj, /obj/item/projectile/beam/stun))
		var/power = Proj.agony * 5
		electrocute_act(power)

/obj/effect/fluid/attack_hand(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves && istype(H.gloves,/obj/item/clothing/gloves))
			H.do_attack_animation(src)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.cell)
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					visible_message("<span class='wet'>[src] has been touched with the stun gloves by [H]!</span>")
					electrocute_act(150)

/* requires new implementation method.
/obj/effect/fluid/attackby(obj/item/W, mob/user)
	..()
	var/item_to_discharge = 0
	var/power = 120
	if(istype(W, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = W
		if(B.status)
			if(B.charges)
				B.charges--
				if(B.charges < 1)
					B.status = 0
					B.update_icon()
				item_to_discharge = 1
	else if(istype(W, /obj/item/weapon/melee/cattleprod))
		var/obj/item/weapon/melee/cattleprod/CP = W
		if(CP.status)
			if(CP.bcell.charge)
				if(isrobot(CP.loc))
					var/mob/living/silicon/robot/R = CP.loc
					if(R && R.cell)
						R.cell.use(2500)
				else
					CP.deductcharge(2500)
				item_to_discharge = 1
	else if(istype(W, /obj/item/weapon/defibrillator))
		var/obj/item/weapon/defibrillator/D = W
		if(D.charged == 2)
			D.discharge()
			power = 150
			item_to_discharge = 1
	else
		W.make_wet()
	if(item_to_discharge)
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Electrified water with [W.name]</font>"
		msg_admin_attack("[key_name(user)] <font color='red'>electrified</font> water with [W.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
		electrocute_act(power)
*/

/obj/effect/fluid/var/electrocuted = FALSE
/obj/effect/fluid/proc/electrocute_act(power, range = 0)
	if(power < 1)
		return
	if(electrocuted)
		return
	if(!isturf(loc))
		return

	electrocuted = TRUE
	addtimer(CALLBACK(src, .proc/reset_electrocuted), 10)

	if(prob(80))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, loc)
		s.start()

	for(var/mob/living/L in loc.contents)
		var/power_calculated = power
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(istype(H.shoes, /obj/item/clothing/shoes) && H.shoes.flags & NOSLIP)
				power_calculated = 0
				continue

			if(istype(H.wear_suit, /obj/item/clothing/suit/space/rig && H.wear_suit.flags & NOSLIP))
				power_calculated = 0
				continue

			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_CHEST]
			if(H.check_thickmaterial(BP))
				power_calculated = 0
			else
				power_calculated *= H.get_siemens_coefficient_organ(BP)

		if(power_calculated)
			L.apply_effect(power_calculated,AGONY,0)

	for(var/direction in list(1,2,4,8,5,6,9,10))
		var/turf/T = get_turf(get_step(src, direction))
		var/obj/effect/fluid/F = locate(/obj/effect/fluid) in T
		if(F)
			F.electrocute_act(power - 15)

/obj/effect/fluid/proc/reset_electrocuted()
	electrocuted = FALSE
