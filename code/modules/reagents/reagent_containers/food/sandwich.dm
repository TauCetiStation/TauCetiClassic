#define MIN_SANDWICH_LIMIT 4
#define SANDWICH_GROWTH_BY_SLICE 4
#define MAX_RENDERED_SANDWICH_LIMIT 1000
#define MAX_SANDWICH_LIMIT 10000

/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/shard) || istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/csandwich/S = new(get_turf(src))
		S.attackby(I, user)
		qdel(src)
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

	var/image/top_overlay

	var/sandwich_limit = SANDWICH_GROWTH_BY_SLICE

	var/gasp_cd = 0

/obj/item/weapon/reagent_containers/food/snacks/csandwich/attackby(obj/item/I, mob/user, params)
	if(contents.len > sandwich_limit)
		to_chat(user, "<span class='red'>If you put anything else on \the [src] it's going to collapse.</span>")
		return

	if(istype(I, /obj/item/weapon/shard))
		to_chat(user, "<span class='notice'>You hide [I] in \the [src].</span>")
		user.drop_from_inventory(I, src)
		add_ingredient()
		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/breadslice))
			sandwich_limit = min(sandwich_limit + SANDWICH_GROWTH_BY_SLICE, MAX_SANDWICH_LIMIT)

		to_chat(user, "<span class='notice'>You layer [I] over \the [src].</span>")
		var/obj/item/weapon/reagent_containers/F = I
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.drop_from_inventory(F, src)
		add_ingredient()
		add_filling_overlay(F)
		return

	return ..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich/proc/add_ingredient()
	if(contents.len > 5)
		name = ""
		if(contents.len > 100)
			name += "very "

		name += "[pick(list("absurd", "colossal", "enormous", "ridiculous"))] sandwich"

		if(prob(30))
			var/obj/item/O1 = pick(contents)
			name += " with \a [O1.name]"
			if(prob(10))
				var/obj/item/O2 = pick(contents)
				name += " and \a [O2.name]"

	else
		name = ""
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/O in contents)
			i++
			if(i == 1)
				name += "[O.name]"
			else if(i == contents.len)
				name += " and [O.name]"
			else
				name += ", [O.name]"

	w_class = clamp(contents.len, SIZE_TINY, SIZE_GARGANTUAN)

	if(contents.len >= MAX_SANDWICH_LIMIT)
		name = "finished sandwich"
		desc = "The best thing since sliced bread. This work is done. Complete. Nothing left to do with it."

/obj/item/weapon/reagent_containers/food/snacks/csandwich/proc/add_filling_overlay(obj/item/weapon/reagent_containers/food/snacks/filling)
	if(contents.len >= MAX_RENDERED_SANDWICH_LIMIT)
		return

	cut_overlay(top_overlay)
	QDEL_NULL(top_overlay)

	var/image/filling_overlay = new(icon, "sandwich_filling")
	filling_overlay.color = filling.filling_color
	filling_overlay.pixel_x = pick(list(-1, 0, 1))
	filling_overlay.pixel_y = (contents.len * 2) + 1
	add_overlay(filling_overlay)

	top_overlay = new(icon, "sandwich_top")
	top_overlay.pixel_x = pick(list(-1, 0, 1))
	top_overlay.pixel_y = (contents.len * 2) + 1
	add_overlay(top_overlay)

/obj/item/weapon/reagent_containers/food/snacks/csandwich/Destroy()
	for(var/obj/item/O in contents)
		qdel(O)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich/examine(mob/user)
	..()

	if(contents.len == 0)
		return

	if(contents.len < MAX_SANDWICH_LIMIT)
		to_chat(user, "It's like... About [contents.len] layers high!")

	var/obj/item/O = pick(contents)
	to_chat(user, "<span class='notice'>You think you can see [O.name] in there.</span>")

	if(contents.len >= MAX_SANDWICH_LIMIT)
		to_chat(user, "<span class='notice'>IT IS COMPLETE, you think to yourself, as you gaze upon [src].</span>")
		if(gasp_cd < world.time && prob(50))
			gasp_cd = world.time + 0.5 SECONDS
			user.emote("gasp")
			user.visible_message("<span class='notice'>Completely stricken by awe... [user] starts to lose their breath!</span>", "<span class='notice'>IT IS COMPLETE, you think, as you gasp for air.</span>")

/obj/item/weapon/reagent_containers/food/snacks/csandwich/attack(mob/M, mob/user, def_zone)
	if(!CanEat(user, M, src, "eat"))
		return
	var/obj/item/weapon/shard/shard = locate() in contents

	if(isliving(M) && shard && M == user) //This needs a check for feeding the food to other people, but that could be abusable.
		var/mob/living/L = M
		to_chat(L, "<span class='red'>You lacerate your mouth on a [shard.name] in the sandwich!</span>")
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
			if(!BP) //Impossible, but...
				H.adjustBruteLoss(5)
			else
				BP.take_damage(5, null, shard.damage_flags(), "[shard.name]")
		else
			L.adjustBruteLoss(5) //TODO: Target head if human.
	..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich/proc/complete()
	set waitfor = 0

	var/list/pos_filler = subtypesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/breadslice)
	var/list/pos_slices = typesof(/obj/item/weapon/reagent_containers/food/snacks/breadslice)

	while(contents.len < MAX_SANDWICH_LIMIT)
		sleep(0)

		for(var/i in 1 to SANDWICH_GROWTH_BY_SLICE - 1)
			if(contents.len >= MAX_SANDWICH_LIMIT)
				break

			var/fill_type = pick(pos_filler)
			var/obj/item/weapon/reagent_containers/food/snacks/S = new fill_type(src)
			add_ingredient()
			add_filling_overlay(S)

		if(contents.len >= MAX_SANDWICH_LIMIT)
			break

		var/slice_type = pick(pos_slices)
		var/obj/item/weapon/reagent_containers/food/snacks/breadslice/B = new slice_type(src)
		sandwich_limit = min(sandwich_limit + SANDWICH_GROWTH_BY_SLICE, MAX_SANDWICH_LIMIT)
		add_ingredient()
		add_filling_overlay(B)

#undef MIN_SANDWICH_LIMIT
#undef SANDWICH_GROWTH_BY_SLICE
#undef MAX_SANDWICH_LIMIT
