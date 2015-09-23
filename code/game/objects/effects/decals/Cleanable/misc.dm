/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/effect/decal/cleanable/ash/attack_hand(mob/user as mob)
	user << "<span class='notice'>[src] sifts through your fingers.</span>"
	var/turf/simulated/floor/F = get_turf(src)
	if (istype(F))
		F.dirt += 4
	qdel(src)

/obj/effect/decal/cleanable/greenglow

	New()
		..()
		spawn(1200)// 2 minutes
			qdel(src)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"
	mouse_opacity = 0

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	light_range = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	var/list/viruses = list()

	Destroy()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()

	Destroy()
		set_light(0)
		..()

	proc/stop_light()
		sleep(rand(150,300))
		if(!src) return
		set_light(0)

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/water
	name = "water"
	desc = ""
	gender = PLURAL
	density = 0
	anchored = 1
	alpha = 0
	color = "#66D1FF"
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = ""
	var/depth = 0.5
	var/depth_max = 10.0
	var/electrocuted = 0
	var/turf/simulated/floor/base_turf

	var/overlay_light = 0
	var/overlay_medium = 0
	var/overlay_high = 0
	var/reset_stage = 0

/obj/effect/decal/cleanable/water/New()
	..()

	base_turf = get_turf(src)
	if(!istype(base_turf))
		qdel(src)
		return

	processing_objects |= src
	processing_water |= src

	overlays |= get_water_icon("water")
	update_icon()

/obj/effect/decal/cleanable/water/Destroy()
	processing_objects -= src
	processing_water -= src
	..()

/obj/effect/decal/cleanable/water/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(ishuman(mover) && mover.checkpass(PASSCRAWL))
		mover.layer = 2.7
	return 1

/obj/effect/decal/cleanable/water/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSCRAWL))
		O.layer = 4.0
	return 1

/obj/effect/decal/cleanable/water/update_icon()
	var/matrix/Mx = matrix()
	Mx.Scale(min(1.0, depth))
	transform = Mx

	if(depth < 0.3)
		return

	var/tmp_alpha = min(180,max(70, 22.5 * depth))
	var/tmp_layer = min(3.5, max(2, depth/2))
	animate(src,time = 10, alpha=tmp_alpha, layer=tmp_layer)

	switch(depth)
		if(0.0 to 2.0)
			overlay_light++
			if(overlay_light > 5)
				overlays.Cut()
				reset_stage = 1
				overlays |= get_water_icon("water")
		if(2.0 to 5.0)
			overlay_medium++
			if(overlay_medium > 5)
				overlays.Cut()
				reset_stage = 1
				overlays |= get_water_icon("water_light")
		if(5.0 to INFINITY)
			overlay_high++
			if(overlay_high > 5)
				overlays.Cut()
				reset_stage = 1
				overlays |= get_water_icon("water_deep")

	if(reset_stage)
		reset_stage = 0
		overlay_light = 0
		overlay_medium = 0
		overlay_high = 0

/proc/create_water(var/atom/A)
	if(!A) return
	var/turf/T = get_turf(A)
	var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
	if(!W)
		PoolOrNew(/obj/effect/decal/cleanable/water,T)
	else
		W.depth += rand(2,5)/10

/obj/effect/decal/cleanable/water/proc/check_flamable()
	var/obj/fire/fire = locate() in loc
	if(fire)
		qdel(fire)
	var/obj/effect/decal/cleanable/liquid_fuel/fuel = locate() in loc
	if(fuel)
		qdel(fuel)

/obj/effect/decal/cleanable/water/proc/try_trans_DNA(var/obj/effect/decal/cleanable/water/W)
	if(!W) return
	if(blood_DNA)
		if(blood_DNA.len)
			if(!W.blood_DNA)
				W.blood_DNA = list()
			W.blood_DNA |= blood_DNA.Copy()
			W.blood_color = blood_color
			animate(W, color = src.color, time = 10)

/obj/effect/decal/cleanable/water/proc/spread_and_eat()
	var/obj/effect/decal/cleanable/blood/B = locate() in loc
	if(B)
		if(B.basecolor)
			animate(src, color = B.basecolor, time = 10)
		if(B.blood_DNA)
			if(B.blood_DNA.len)
				if(!blood_DNA)
					blood_DNA = list()
				blood_DNA |= B.blood_DNA.Copy()
		qdel(B)

	if(depth > 1.5)
		var/depth_compared = 0
		var/obj/effect/decal/cleanable/water/most_dry
		var/list/clean_turf = list()

		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(istype(T, /turf/simulated/floor))
				var/dense_obj = 0
				for(var/atom/movable/AM in T.contents)
					if(istype(AM, /obj/effect/decal/cleanable/water))
						dense_obj = 1
						break
					if(isturf(AM) || istype(AM, /obj/machinery/door) || istype(AM, /obj/structure/window))
						if(AM.density)
							dense_obj = 1
							break
				if(!dense_obj)
					clean_turf += T
		if(clean_turf.len)
			var/turf/T = pick(clean_turf)
			var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
			if(!W)
				W = PoolOrNew(/obj/effect/decal/cleanable/water,T)
				W.depth += depth/10
				depth -= 0.5+depth/10
				try_trans_DNA(W)
		else
			for(var/direction in cardinal)
				var/turf/T = get_step(src,direction)
				if(istype(T, /turf/simulated/floor))
					var/dense_obj = 0
					for(var/atom/movable/AM in T.contents)
						if(isturf(AM) || istype(AM, /obj/machinery/door) || istype(AM, /obj/structure/window))
							if(AM.density)
								dense_obj = 1
								break
					if(!dense_obj)
						var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
						if(W)
							if(!depth_compared)
								if(depth > W.depth)
									depth_compared = W.depth
									most_dry = W
							else
								if(depth_compared > W.depth)
									depth_compared = W.depth
									most_dry = W
			if(depth_compared)
				if(most_dry.depth + 0.5 + depth/10 < depth_max)
					most_dry.depth += 0.5+depth/10
					depth -= 0.5+depth/10
					try_trans_DNA(most_dry)

/obj/effect/decal/cleanable/water/process()
	if(!base_turf || !istype(base_turf))
		qdel(src)
		return

	if(depth > depth_max)
		depth = depth_max

	depth -= rand(1,12)/800

	if(depth < 0.3)
		qdel(src)
		return

/obj/effect/decal/cleanable/water/Crossed(var/mob/living/carbon/C)
	if(!istype(C)) return
	if(prob(2))
		if(C.m_intent == "run")
			var/mob/living/carbon/human/H = C
			if(istype(H) && (istype(H.shoes, /obj/item/clothing/shoes) && H.shoes.flags&NOSLIP))
				return
			if(istype(H) && (istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && H.wear_suit.flags&NOSLIP))
				return
			if(istype(H))
				var/list/inv_contents = list()
				for(var/obj/item/I in H.contents)
					if(istype(I, /obj/item/weapon/implant)) continue
					inv_contents += I
				if(inv_contents.len)
					for(var/n=3,n>0,n--)
						var/obj/item/I = pick(inv_contents)
						I.make_wet()

			C.stop_pulling()
			C << "\blue You slipped on the wet floor!"
			playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
			C.Stun(5)
			C.Weaken(2)
	else
		playsound(src.loc, 'sound/effects/waterstep.ogg', 50, 1, -3)
	if(prob(5))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.shoes, /obj/item/clothing/shoes))
				var/obj/item/clothing/shoes/S = H.shoes
				S.make_wet()

/obj/effect/decal/cleanable/water/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/energy/electrode) || istype(Proj, /obj/item/projectile/beam/stun))
		var/power = Proj.agony * 5
		electrocute_act(power)

/obj/effect/decal/cleanable/water/attack_hand(mob/user as mob)
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

/obj/effect/decal/cleanable/water/attackby(obj/item/W as obj, mob/user as mob)
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

/obj/effect/decal/cleanable/water/proc/electrocute_act(var/power, var/range = 0)
	if(power < 1) return
	if(electrocuted) return
	electrocuted = 1
	spawn(10)
		electrocuted = 0

	if(prob(80))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, base_turf)
		s.start()

	for(var/mob/living/L in base_turf.contents)
		var/power_calculated = power
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			//var/rnd_foot = pick("l_foot","r_foot")
			if(istype(H) && (istype(H.shoes, /obj/item/clothing/shoes) && H.shoes.flags&NOSLIP))
				power_calculated = 0
				continue
			if(istype(H) && (istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && H.wear_suit.flags&NOSLIP))
				power_calculated = 0
				continue
			var/datum/organ/external/select_area = H.get_organ("chest")
			if(H.check_thickmaterial(select_area))
				power_calculated = 0
			else
				power_calculated *= H.get_siemens_coefficient_organ(select_area)
		if(power_calculated)
			L.apply_effect(power_calculated,AGONY,0)

	for(var/direction in list(1,2,4,8,5,6,9,10))
		var/turf/TS = get_turf(get_step(src,direction))
		var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, TS)
		if(W)
			W.electrocute_act(power-15)
