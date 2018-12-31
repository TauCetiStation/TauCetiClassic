///-----------------------------------------------------//
///														//
///						Sandwich						//
///														//
///-----------------------------------------------------//

#define MIN_SANDWICH_LIMIT 4
#define SANDWICH_GROWTH_BY_SLICE 4
#define MAX_SANDWICH_LIMIT 124 // 30 breadslices + 4 base size

/obj/item/weapon/reagent_containers/food/snacks/breadslice/attackby(obj/item/W, mob/user)

	if(istype(W,/obj/item/weapon/shard) || istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		var/obj/item/weapon/reagent_containers/food/snacks/csandwich/S = new(get_turf(src))
		S.attackby(W,user)
		qdel(src)
	..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich
	name = "sandwich"
	desc = "The best thing since sliced bread."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	bitesize = 2

	var/list/ingredients = list()

/obj/item/weapon/reagent_containers/food/snacks/csandwich/attackby(obj/item/W, mob/user)

	var/sandwich_limit = MIN_SANDWICH_LIMIT
	for(var/obj/item/O in ingredients)
		if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/breadslice))
			sandwich_limit += SANDWICH_GROWTH_BY_SLICE
	sandwich_limit = min(sandwich_limit, MAX_SANDWICH_LIMIT)

	if(src.contents.len > sandwich_limit)
		to_chat(user, "<span class='red'>If you put anything else on \the [src] it's going to collapse.</span>")
		return
	else if(istype(W,/obj/item/weapon/shard))
		to_chat(user, "<span class='notice'>You hide [W] in \the [src].</span>")
		user.drop_item()
		W.loc = src
		update()
		return
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks))
		to_chat(user, "<span class='notice'>You layer [W] over \the [src].</span>")
		var/obj/item/weapon/reagent_containers/F = W
		F.reagents.trans_to(src, F.reagents.total_volume)
		user.drop_item()
		W.loc = src
		ingredients += W
		update()
		return
	..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich/proc/update()
	var/fullname = "" // We need to build this from the contents of the var.
	var/i = 0

	overlays.Cut()

	for(var/obj/item/weapon/reagent_containers/food/snacks/O in ingredients)
		i++
		if(i == 1)
			fullname += "[O.name]"
		else if(i == ingredients.len)
			fullname += " and [O.name]"
		else
			fullname += ", [O.name]"

		var/image/I = new(src.icon, "sandwich_filling")
		I.color = O.filling_color
		I.pixel_x = pick(list(-1,0,1))
		I.pixel_y = (i*2)+1
		overlays += I

	var/image/T = new(src.icon, "sandwich_top")
	T.pixel_x = pick(list(-1,0,1))
	T.pixel_y = (ingredients.len * 2)+1
	overlays += T

	name = lowertext("[fullname] sandwich")
	if(length(name) > 80) name = "[pick(list("absurd","colossal","enormous","ridiculous"))] sandwich"
	w_class = ceil(Clamp((ingredients.len/2),1,3))

/obj/item/weapon/reagent_containers/food/snacks/csandwich/Destroy()
	for(var/obj/item/O in ingredients)
		qdel(O)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/csandwich/examine(mob/user)
	..()
	var/obj/item/O = pick(contents)
	to_chat(user, "<span class='notice'>You think you can see [O.name] in there.</span>")

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

#undef MIN_SANDWICH_LIMIT
#undef SANDWICH_GROWTH_BY_SLICE
#undef MAX_SANDWICH_LIMIT
