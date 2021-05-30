
/datum/reagent/coolant
	name = "Coolant"
	id = "coolant"
	description = "Industrial cooling substance."
	reagent_state = LIQUID
	color = "#c8a5dc" // rgb: 200, 165, 220

/datum/chemical_reaction/coolant
	name = "Coolant"
	id = "coolant"
	result = "coolant"
	required_reagents = list("tungsten" = 1, "oxygen" = 1, "water" = 1)
	result_amount = 3

/obj/structure/reagent_dispensers/coolanttank
	name = "coolant tank"
	desc = "A tank of industrial coolant."
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "coolanttank"
	amount_per_transfer_from_this = 10

/obj/structure/reagent_dispensers/coolanttank/atom_init()
	. = ..()
	reagents.add_reagent("coolant",1000)

/obj/structure/reagent_dispensers/coolanttank/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			explode()

/obj/structure/reagent_dispensers/coolanttank/blob_act()
	explode()

/obj/structure/reagent_dispensers/coolanttank/ex_act()
	explode()

/obj/structure/reagent_dispensers/coolanttank/explode()
	var/datum/effect/effect/system/smoke_spread/S = new /datum/effect/effect/system/smoke_spread
	//S.attach(src)
	S.set_up(5, 0, src.loc)
	S.start()
	playsound(src, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)

	var/datum/gas_mixture/env = src.loc.return_air()
	if(env)
		if (reagents.total_volume > 750)
			env.temperature = 0
		else if (reagents.total_volume > 500)
			env.temperature -= 100
		else
			env.temperature -= 50

	QDEL_IN(src, 10)
