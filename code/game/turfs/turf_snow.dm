/turf/simulated/snow
	icon = 'icons/turf/snow.dmi'
	name = "snow"
	icon_state = "snow"
	dynamic_lighting = TRUE

	basetype = /turf/simulated/snow

	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = TM50C
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	plane = GAME_PLANE

/turf/simulated/snow/atom_init(mapload)
	. = ..()
	if(mapload)
		populate_flora()
	return INITIALIZE_HINT_NORMAL

/turf/simulated/snow/Destroy()
	return QDEL_HINT_LETMELIVE

/turf/simulated/snow/proc/populate_flora()
	if(prob(35))
		var/area/A = get_area(src)
		if(istype(A, /area/shuttle))
			return

		var/snow_flora = pick(
			prob(30);/obj/structure/flora/grass/both,
			prob(22);/obj/structure/flora/bush,
			prob(15);/obj/structure/flora/tree/pine,
			prob(15);/obj/structure/flora/tree/dead
			)

		var/obj/O = new snow_flora(src)

		if(!QDELETED(O) && prob(1) && prob(5))
			new /mob/living/simple_animal/hostile/mimic/copy(src, O)

/turf/simulated/snow/attack_paw(mob/user)
	return attack_hand(user)

/turf/simulated/snow/attackby(obj/item/C, mob/user)
	if (istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		user.SetNextMove(CLICK_CD_RAPID)
		if(L)
			if(R.get_amount() < 2)
				to_chat(user, "\red You don't have enough rods to do that.")
				return
			if(user.is_busy()) return
			to_chat(user, "\blue You begin to build a catwalk.")
			if(do_after(user,30,target = src))
				if(!R.use(2))
					return
				playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
				to_chat(user, "\blue You build a catwalk!")
				ChangeTurf(/turf/simulated/floor/plating/airless/catwalk)
				qdel(L)
				return

		if(!R.use(1))
			return
		to_chat(user, "\blue Constructing support lattice ...")
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
		ReplaceWithLattice()

	else if (istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(!S.use(1))
				return
			qdel(L)
			user.SetNextMove(CLICK_CD_RAPID)
			playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
			S.build(src)
			return
		else
			to_chat(user, "\red The plating is going to need some support.")

/turf/simulated/snow/ChangeTurf(path, force_lighting_update = 0)
	return ..(path, TRUE)

/turf/simulated/snow/singularity_act()
	return
