/obj/effect/spawner/parkflora
	name = "park flora"
	icon = 'icons/hud/screen1.dmi'
	icon_state = "x"

	var/static/list/subplants = list(
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita = 5,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap = 2,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 7,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle = 10,
		/obj/item/weapon/reagent_containers/food/snacks/grown/mtear = 20,
		/obj/item/weapon/reagent_containers/food/snacks/grown/harebell = 25,
		/obj/item/weapon/reagent_containers/food/snacks/grown/shand = 20,
	)

/obj/effect/spawner/parkflora/atom_init()
	..()

	spawn_flora()

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/parkflora/proc/spawn_flora()
	var/list/possible_turfs = list()
	for(var/turf_dir in alldirs)
		var/turf/T = get_step(src, turf_dir)
		if(T.is_grass_floor())
			possible_turfs[T] = turf_dir

	if(!possible_turfs.len)
		return

	for(var/i in 1 to rand(1, 2))
		var/turf/T = pick(possible_turfs)
		var/turf_dir = possible_turfs[T]

		var/itemtype = pickweight(subplants)
		var/obj/item/item = new itemtype(T)

		var/offsetX = X_OFFSET(8, turf_dir)
		var/offsetY = Y_OFFSET(8, turf_dir)

		item.pixel_x = rand(-4, 4) + offsetX
		item.pixel_y = rand(-4, 4) + offsetY
