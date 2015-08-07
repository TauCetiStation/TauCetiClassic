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
	alpha = 70
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "water"
	var/depth = 0.5
	var/electrocuted = 0

/obj/effect/decal/cleanable/water/New()
	..()
	processing_objects.Add(src)

	var/matrix/Mx = matrix()
	Mx.Scale(depth)
	transform = Mx

/obj/effect/decal/cleanable/water/Destroy()
	processing_objects.Remove(src)
	..()

/obj/effect/decal/cleanable/water/process()

	var/obj/fire/fire = locate() in loc
	if(fire)
		qdel(fire)

	var/obj/effect/decal/cleanable/liquid_fuel/fuel = locate() in loc
	if(fuel)
		qdel(fuel)

	var/obj/effect/decal/cleanable/blood/B = locate() in loc
	if(B)
		if(B.basecolor)
			color = B.basecolor
		if(B.blood_DNA)
			if(B.blood_DNA.len)
				if(!blood_DNA)
					blood_DNA = list()
				blood_DNA |= B.blood_DNA.Copy()
		qdel(B)

	if(depth < 0.3)
		qdel(src)
		return
	if(depth > 1.5)
		depth = 1
		for(var/direction in cardinal)
			var/turf/T = get_step(src,direction)
			if(T.density) continue
			var/dense_obj = 0
			for(var/atom/movable/AM in T.contents)
				if(isturf(AM) || istype(AM, /obj/machinery/door) || istype(AM, /obj/structure/window))
					if(AM.density)
						dense_obj = 1
						break
			if(dense_obj == 1)
				continue
			var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
			if(!W)
				W = PoolOrNew(/obj/effect/decal/cleanable/water,T)
			else
				W.depth += rand(1,3)/10
			if(blood_DNA)
				if(blood_DNA.len)
					if(!W.blood_DNA)
						W.blood_DNA = list()
					W.blood_DNA |= blood_DNA.Copy()
					W.blood_color = blood_color
					if(color) W.color = color

	depth -= rand(1,12)/800
	var/matrix/Mx = matrix()
	Mx.Scale(min(1, max(0.3, depth)))
	transform = Mx

/obj/effect/decal/cleanable/water/Crossed(var/mob/living/carbon/C)
	if(!istype(C)) return
	if(prob(2))
		var/mob/living/carbon/human/H = C
		if(istype(H) && (istype(H.shoes, /obj/item/clothing/shoes) && H.shoes.flags&NOSLIP))
			return
		if(istype(H) && (istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && H.wear_suit.flags&NOSLIP))
			return

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
		electrocute_act(power)

/obj/effect/decal/cleanable/water/proc/electrocute_act(var/power, var/range = 0)
	if(power < 1) return
	if(electrocuted) return
	electrocuted = 1
	spawn(10)
		electrocuted = 0

	var/turf/T = get_turf(src)
	if(prob(80))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, T)
		s.start()

	for(var/mob/living/L in T.contents)
		var/power_calculated = power
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/rnd_foot = pick("l_foot","r_foot")
			var/datum/organ/external/select_area = H.get_organ(rnd_foot) // We're checking the outside, buddy!
			power_calculated *= H.get_siemens_coefficient_organ(select_area)

		L.apply_effect(power_calculated,AGONY,0)

	for(var/direction in list(1,2,4,8,5,6,9,10))
		var/turf/TS = get_turf(get_step(src,direction))
		var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, TS)
		if(W)
			W.electrocute_act(power-3)
