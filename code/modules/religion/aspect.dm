/datum/aspect
	var/name
	var/desc = "This aspect not used in game"
	// Used for give a god the information about aspect and desire items
	var/god_desc
	//can only be increased if you select one aspect twice and more times
	var/power = 1
	// Whether this aspect is allowed roundstart.
	var/starter = TRUE
	// Used in the radial menu when choosing a ritual
	var/icon = 'icons/hud/radial.dmi'
	var/icon_state = "radial_magic"
	var/image/aspect_image

	// List of holy turfs blessed with this aspect.
	var/list/holy_turfs
	// List of /atom/movables that this aspect is registered to.
	var/list/affecting

	// Color of aspect
	var/color

/datum/aspect/New()
	if(icon && icon_state)
		aspect_image = image(icon = src.icon, icon_state = src.icon_state)

/datum/aspect/Destroy()
	QDEL_LIST_ASSOC_VAL(holy_turfs)
	holy_turfs = null
	return ..()

// Return the amount of favour this item will give, if succesfully sacrificed.
/datum/aspect/proc/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	return 0

/datum/aspect/proc/register_holy_turf(turf/simulated/floor/F, datum/religion/R)
	RegisterSignal(F, list(COMSIG_ATOM_ENTERED), PROC_REF(holy_turf_enter))
	RegisterSignal(F, list(COMSIG_ATOM_EXITED), PROC_REF(holy_turf_exit))

/datum/aspect/proc/holy_turf_enter(datum/source, atom/movable/mover, atom/oldLoc)
	LAZYADD(affecting, mover)

/datum/aspect/proc/unregister_holy_turf(turf/simulated/floor/F, datum/religion/R)
	UnregisterSignal(F, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
	for(var/atom/movable/AM in affecting)
		holy_turf_exit(F, AM)

/datum/aspect/proc/holy_turf_exit(datum/source, atom/movable/mover, atom/newLoc)
	LAZYREMOVE(affecting, mover)

//Gives mana from: any organs, limbs, slabs of meat and blood
//Needed for: spells and rituals related to the theme of death, interaction with dead body, necromancy
/datum/aspect/death
	name = ASPECT_DEATH
	desc = "You can consider it necromancy"
	icon_state = "aspect_death"

	color = COLOR_MAROON

	god_desc = "Смертные людишки могут жертвовать для увеличения вашей силы: пакеты с кровью, мозги, внутренние и внешние органы."

/datum/aspect/death/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	if(istype(I, /obj/item/weapon/reagent_containers/blood))
		var/blood_am = 0
		if(I.reagents)
			blood_am = I.reagents.get_reagent_amount("blood")
		return blood_am

	else if(isbodypart(I))
		return 50

	else if(istype(I, /obj/item/brain))
		return 100

	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/meat))
		return 25

	return 0

//Gives mana from: scientist points
//Needed for: spells and rituals related to the theme of sci-fi, future
/datum/aspect/science
	name = ASPECT_SCIENCE
	desc = "Sci-fi items and other science"
	icon_state = "aspect_science"

	color = COLOR_VIOLET

	god_desc = "Хомосапиенс и другие инородные расы могут дарить все сорта научных вещей."

/datum/aspect/science/sacrifice(obj/item/I, mob/living/L, obj/structure/altar_of_gods/AOG)
	. = AOG.experiments.get_object_research_value(I) * 0.01
	AOG.experiments.do_research_object(I)

//Gives mana from: any food
//Needed for: spells and rituals related to the theme of food
/datum/aspect/food
	name = ASPECT_FOOD
	desc = "Can be considered it greed"
	icon_state = "aspect_food"

	color = COLOR_BROWN_ORANGE

	god_desc = "Крестьяне обязаны платить вам едой."

/datum/aspect/food/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	if(istype(I, /obj/item/weapon/reagent_containers/food) && I.reagents)
		var/favour_amount = 0
		for(var/datum/reagent/R in I.reagents.reagent_list)
			favour_amount += R.nutriment_factor * R.volume * 0.25
		return favour_amount

	return 0

//Gives mana from: guns and weapons
//Needed for: spells and rituals related to the theme of weapon and armor, their damage, buff etc
/datum/aspect/weapon
	name = ASPECT_WEAPON //with armor
	desc = "Weapons and related things, war"
	icon_state = "aspect_weapon"

	god_desc = "И пускай оружейный барон станет самым религиозным человеком."

	color = COLOR_DARK_GRAY

/datum/aspect/weapon/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	if(istype(I,/obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/G = I
		var/cost = 0
		for(var/obj/item/ammo_casing/A in G.ammo_type)
			var/obj/item/projectile/P = initial(A.projectile_type)
			cost += initial(P.damage) * 15
		return cost

	if(istype(I,/obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/W = I

		var/cost = 0
		var/obj/item/ammo_box/magazine/M = initial(W.initial_mag)
		var/obj/item/ammo_casing/C = initial(M.ammo_type)
		cost = W.magazine.stored_ammo.len * C.BB.damage
		return cost

	if(istype(I, /obj/item/weapon) && !istype(I,/obj/item/weapon/melee/cultblade))
		var/datum/component/twohanded/T = I.GetComponent(/datum/component/twohanded)
		if(T)
			return T.force_wielded * sqrt(T.force_wielded)
		return I.force * sqrt(I.force)
	return 0

//Gives mana from: minerals, sheet, steel, money etc
//Needed for: spells and rituals related to the theme of materials, his shell, manipulation of the molecular composition of the resource
/datum/aspect/resources
	name = ASPECT_RESOURCES
	desc = "Manipulated on minerals, metallic, glass and others"
	icon_state = "ascept_resources"

	color = COLOR_DARK_BROWN

	god_desc = "Рабочие могут приносить разные ресурсы на вашу милость."

/datum/aspect/resources/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/material = I
		return material.amount * 5
	return 0

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of spawn animal, creatures
/datum/aspect/conjure
	name = ASPECT_SPAWN
	desc = "Create any bio-materials"
	icon_state = "aspect_spawn"

	color = COLOR_PURPLE_GRAY

//Gives mana from: any heal near the altar
//Needed for: spells and rituals related to the theme of heal, buff
/datum/aspect/rescue
	name = ASPECT_RESCUE
	desc = "Any heal, buff"
	icon_state = "aspect_rescue"

	color = COLOR_LIME

//Gives mana from: ghosts staying near the altar
//Needed for: spells and rituals related to the theme of ghosts
/datum/aspect/mystic
	name = ASPECT_MYSTIC
	desc = "Any interaction with ghosts"
	icon_state = "aspect_mystic"

	color = COLOR_NAVY_BLUE

//Gives mana from: sacrificed charge, tech parts
//Needed for: spells and rituals related to the theme of electrical equipment, electrical energy
/datum/aspect/technology
	name = ASPECT_TECH
	desc = "Accepts electrical energy and tech parts, also manipulates any electrical equipment"
	icon_state = "aspect_tech"

	color = COLOR_CYAN

	god_desc = "Принимаются электрическая энергия и качественные технические детали."

/datum/aspect/technology/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/C = I
		return C.charge * 0.01

	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/part = I
		return 25 * part.rating

	else if(istype(I, /obj/item/weapon/circuitboard))
		return 30

	else if(isassembly(I))
		return 10 * I.w_class

	return 0

//Gives mana from: does not affect mana accumulation
//Needed for: spells and rituals related to the theme of random, eg random heal
/datum/aspect/chaos
	name = ASPECT_CHAOS
	desc = "The meaning of the aspect is that its rituals and spells are random"
	icon_state = "aspect_chaos"

	color = COLOR_ORANGE

//Gives mana from: fools, how clowns
//Needed for: spells and rituals related to the theme of clown equipments, items
/datum/aspect/wacky
	name = ASPECT_WACKY
	desc = "Clownism"
	icon_state = "aspect_wacky"

	color = COLOR_OLIVE

	god_desc = "Вашей Семье срочно нужно очень много БАНАНОВ и БАНАНИУМА!!!"

/datum/aspect/wacky/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	if(istype(I, /obj/item/weapon/bananapeel/honk))
		return 40
	if(istype(I, /obj/item/weapon/bananapeel))
		return 30
	if(istype(I, /obj/item/stack/sheet/mineral/clown))
		var/obj/item/stack/sheet/mineral/clown/banan = I
		return banan.amount * 60
	if(istype(I, /obj/item/weapon/ore/clown))
		return 50
	return FALSE

/datum/aspect/wacky/holy_turf_enter(datum/source, atom/movable/mover, atom/oldLoc)
	..()
	RegisterSignal(mover, list(COMSIG_MOB_SLIP), PROC_REF(on_slip))

/datum/aspect/wacky/proc/on_slip(datum/source, weaken_duration, obj/slipped_on, lube)
	var/mob/M = source
	var/turf/simulated/floor/F = M.loc
	if(!istype(F))
		return

	// It ain't no fun if they don't suffer!
	if(M.stat != CONSCIOUS || !M.client)
		return

	F.holy.religion.adjust_favor(weaken_duration * power * 0.5)

/datum/aspect/wacky/holy_turf_exit(datum/source, atom/movable/mover, atom/newLoc)
	..()
	UnregisterSignal(mover, list(COMSIG_MOB_SLIP))

// Children of this type somehow integrate with light on tiles.
/datum/aspect/lightbending
	var/list/favor_for_turf

/datum/aspect/lightbending/register_holy_turf(turf/simulated/floor/F, datum/religion/R)
	..()
	RegisterSignal(F.lighting_object, list(COMSIG_LIGHT_UPDATE_OBJECT), PROC_REF(recalc_favor_gain))
	recalc_favor_gain(F.lighting_object, F)

/datum/aspect/lightbending/unregister_holy_turf(turf/simulated/floor/F, datum/religion/R)
	..()
	UnregisterSignal(F.lighting_object, list(COMSIG_LIGHT_UPDATE_OBJECT))
	if(favor_for_turf)
		R.passive_favor_gain -= favor_for_turf[F]
		favor_for_turf -= F
	UNSETEMPTY(favor_for_turf)

/datum/aspect/lightbending/proc/get_light_gain(turf/simulated/floor/F)
	return 0.0

/datum/aspect/lightbending/proc/recalc_favor_gain(datum/source, turf/myturf)
	var/turf/simulated/floor/F = myturf
	if(!istype(F))
		return

	var/prev_gain = 0.0
	if(favor_for_turf)
		prev_gain = favor_for_turf[F]
	var/favor_gain = get_light_gain(F)

	if(favor_gain != 0.0)
		START_PROCESSING(SSreligion, F.holy.religion)
		LAZYSET(favor_for_turf, F, favor_gain)
		F.holy.religion.passive_favor_gain += favor_gain - prev_gain
	else
		favor_for_turf -= F
		UNSETEMPTY(favor_for_turf)

//Gives mana from: darkness on holy turfs
//Needed for: spells and rituals related to the theme of dark, eviv, obcurse
/datum/aspect/lightbending/darkness
	name = ASPECT_OBSCURE
	desc = "Dark, darkness, obcurse, evil"
	icon_state = "aspect_obscure"

	color = COLOR_DARK_GUNMETAL

	god_desc = "Вам нужная тьма на святой земле."

/datum/aspect/lightbending/darkness/get_light_gain(turf/simulated/floor/F)
	return (0.6 - F.get_lumcount()) * 0.05 * (1.4 * sqrt(power) + (power / 4)) //https://www.desmos.com/calculator/nwle5biewp

//Gives mana from: light levels on holy turfs
//Needed for: spells and rituals related to the theme of receiving light
/datum/aspect/lightbending/light
	name = ASPECT_LIGHT
	desc = "Light interaction"
	icon_state = "aspect_light"

	color = COLOR_AMBER

	god_desc = "Вам нужен свет на святой земле."

/datum/aspect/lightbending/light/get_light_gain(turf/simulated/floor/F)
	return (F.get_lumcount() - 0.4) * 0.03 * (1.4 * sqrt(power) + (power / 4)) //https://www.desmos.com/calculator/nwle5biewp

//Gives mana for economical cost of an item.
//Needed for: anything economy related
/datum/aspect/greed
	name = ASPECT_GREED
	desc = "Greed"
	icon_state = "aspect_greed"

	color = COLOR_BOTTLE_GREEN

	god_desc = "Не всё то золото, что блестит, иногда купюры могут этому следовать. Вам нужно богатств."

/datum/aspect/greed/sacrifice(obj/item/I, mob/living/L, obj/AOG)
	return I.get_price() * 0.05
