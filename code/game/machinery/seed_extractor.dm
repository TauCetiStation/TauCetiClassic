/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/max_seeds = 1000
	var/seed_multiplier = 1

/obj/machinery/seed_extractor/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/seed_extractor(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		max_seeds = 1000 * B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		seed_multiplier = M.rating


/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user)

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	default_deconstruction_crowbar(O)

	if(istype(O, /obj/item/organ/external))
		var/obj/item/organ/external/IO = O
		if(IO.species.name == DIONA)
			to_chat(user, "<span class='notice'>You extract some seeds from the [IO.name].</span>")
			var/t_amount = 0
			var/t_max = rand(1,4)
			for(var/I in t_amount to t_max)
				new /obj/item/seeds/replicapod(loc)
			qdel(IO)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
		user.drop_item()
		to_chat(user, "<span class='notice'>You extract some seeds from the [F.name].</span>")
		var/seed = text2path(F.seed)
		var/t_amount = 0
		var/t_max = rand(1,4)
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new seed(loc)
			t_prod.species = F.species
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			t_amount++
		qdel(O)

	else if(istype(O, /obj/item/weapon/grown))
		var/obj/item/weapon/grown/F = O
		user.drop_item()
		to_chat(user, "<span class='notice'>You extract some seeds from the [F.name].</span>")
		var/seed = text2path(F.seed)
		var/t_amount = 0
		var/t_max = rand(1,4)
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new seed(loc)
			t_prod.species = F.species
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			t_amount++
		qdel(O)

	else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		if(!S.use(1))
			return
		to_chat(user, "<span class='notice'>You extract some seeds from the [S.name].</span>")
		new /obj/item/seeds/grassseed(loc)

	return
