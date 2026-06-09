/obj/item/weapon/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	w_class = SIZE_TINY
	var/datum/geosample/geologic_data
	var/oretag
	var/points = 0
	var/refined_type = null //What this ore defaults to being refined into

	var/smelt_progress = 0
	var/smelt_max = 5

/obj/item/weapon/ore/Crossed(atom/movable/M)
	if(isliving(M))
		var/mob/living/L = M
		if (L.stat == CONSCIOUS && !L.restrained())
			L.pickup_ore()

/obj/item/weapon/ore/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/datum/gas_mixture/env = loc.return_air()
	if(!env)
		return

	var/list/found_recipes = list()
	checking_recipes:
		for(var/datum/smelting_recipe/recipe in global.smelting_recipes)
			if(exposed_temperature < recipe.temp)
				continue

			if(recipe.input != oretag)
				continue

			for(var/inputgas in recipe.inputgasses)
				if(!env.get_gas(inputgas) || (env.get_gas(inputgas) < 0.1))
					continue checking_recipes

			found_recipes += recipe

	if(!found_recipes.len)
		return

	smelt_progress++

	if(smelt_progress >= smelt_max)
		var/datum/smelting_recipe/recipe = pick(found_recipes)

		for(var/gas in recipe.inputgasses)
			env.adjust_gas(gas, -0.1)

		for(var/gas in recipe.outputgasses)
			env.adjust_gas(gas, 0.1)

		if(recipe.output)
			var/outputtype = recipe.output
			new outputtype(loc)

		qdel(src)
		return


/obj/item/weapon/ore/uranium
	name = "pitchblende"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	oretag = "uranium"
	points = 20
	refined_type = /obj/item/stack/sheet/mineral/uranium

/obj/item/weapon/ore/iron
	name = "hematite"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	oretag = "hematite"
	points = 1
	refined_type = /obj/item/stack/sheet/mineral/iron

/obj/item/weapon/ore/coal
	name = "carbonaceous rock"
	icon_state = "Coal ore"
	origin_tech = "materials=1"
	oretag = "coal"
	points = 1
	refined_type = /obj/item/stack/sheet/mineral/plastic

/obj/item/weapon/ore/glass
	name = "impure silicates"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	oretag = "sand"
	points = 1
	refined_type = /obj/item/stack/sheet/glass

/obj/item/weapon/ore/glass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/cloth))
		if(!I.use_tool(src, user, 20, 1))
			return
		new /obj/item/stack/sheet/sandbag(loc, 1, TRUE)
		qdel(src)
	else
		return ..()

/obj/item/weapon/ore/phoron
	name = "phoron crystals"
	icon_state = "Phoron ore"
	origin_tech = "materials=2"
	oretag = "phoron"

/obj/item/weapon/ore/silver
	name = "native silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	oretag = "silver"
	points = 10
	refined_type = /obj/item/stack/sheet/mineral/silver

/obj/item/weapon/ore/gold
	name = "native gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	oretag = "gold"
	points = 20
	refined_type = /obj/item/stack/sheet/mineral/gold

/obj/item/weapon/ore/diamond
	name = "diamonds"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	oretag = "diamond"

/obj/item/weapon/ore/osmium
	name = "raw platinum"
	icon_state = "Platinum ore"
	oretag = "platinum"
	origin_tech = "materials=4"
	points = 40
	refined_type = /obj/item/stack/sheet/mineral/platinum

/obj/item/weapon/ore/hydrogen
	name = "raw hydrogen"
	icon_state = "Phazon"
	oretag = "hydrogen"
	points = 10
	refined_type = /obj/item/stack/sheet/mineral/tritium

/obj/item/weapon/ore/clown
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	oretag = "bananium"

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless."
	icon_state = "slag"
	oretag = "slag"

/obj/item/weapon/ore/atom_init()
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
	if(is_mining_level(z))
		SSStatistics.score.oremined++ //When ore spawns, increment score.  Only include ore spawned on mining asteroid.

/obj/item/weapon/ore/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = I
		C.sample_item(src, user)
	else
		return ..()

/obj/item/weapon/ore/use(used, transfer = FALSE)
	if(used == 1)
		qdel(src)
		return TRUE
	return FALSE
