/atom/movable/var/waterproof

/obj/machinery/atmospherics
	waterproof = TRUE

/obj/machinery/door
	waterproof = TRUE

/mob/living/water_act(depth)
	..()
	if(on_fire)
		visible_message("<span class='danger'>A cloud of steam rises up as the water hits \the [src]!</span>")
		ExtinguishMob()
	if(fire_stacks > 0)
		adjust_fire_stacks(-round(depth / 2))

/mob/living/carbon/slime/water_act(depth)
	..()
	adjustToxLoss(max(1, depth * 0.1))

/mob/living/carbon/human/water_act(depth)
	species.water_act(src, depth)
	..(depth)

/datum/species/proc/water_act(mob/living/carbon/human/H, depth)
	return

/datum/species/skrell/water_act(mob/living/carbon/human/H, depth)
	..()
	if(depth >= 40)
		if(H.traumatic_shock)
			H.traumatic_shock -= 25 // Slightly more than being drunk because it fires less often (10 ticks as opposed to 4)
		if(H.getBruteLoss() || H.getFireLoss())
			H.adjustBruteLoss(-(rand(1, 3)))
			H.adjustFireLoss(-(rand(1, 3)))
		if(prob(5)) // Might be too spammy.
			to_chat(H, "<span class='notice'>The water ripples gently over your skin in a soothing balm.</span>")

/obj/fire/water_act(depth)
	..()
	qdel(src)

/obj/effect/decal/cleanable/water_act(depth)
	..()
	qdel(src)

// This is really pretty crap and should be overridden for specific machines.
/obj/machinery/water_act(depth)
	if(!(stat & (NOPOWER|BROKEN)) && !waterproof && (depth > FLUID_DEEP))
		ex_act(3)

/obj/item/weapon/match/water_act(depth)
	if(!waterproof && lit)
		burn_out()

// todo lighters
