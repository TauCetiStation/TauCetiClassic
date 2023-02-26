#define FEEDER_FULL 8
#define FEEDER_HALF 5
#define FEEDER_ALMOST_EMPTY 3
#define FEEDER_EMPTY 0

ADD_TO_GLOBAL_LIST(/obj/structure/chicken_feeder, chicken_feeder_list)

/obj/structure/chicken_feeder
	name = "Chicken Feeder"
	desc = "Co-co-co"
	icon = 'icons/obj/feeder.dmi'
	icon_state = "empty"
	density = FALSE
	anchored = TRUE
	var/food = 0
	var/maxFood = 10

var/global/list/chicken_feeder_list = list()

/obj/structure/chicken_feeder/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/wheat))
		if(food != maxFood)
			qdel(O)
			food += 1
			update_icon()
		else
			to_chat(user, "<span class='notice'>Already full</span>")
	if(iswrenching(O))
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(!user.is_busy() && do_after(user, 4 SECONDS, target = src))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else
		..()

/obj/structure/chicken_feeder/proc/feed(mob/living/simple_animal/chicken/C)
	food -= 1
	if(food < 0) // i dont know how
		food = 0
	C.eggsleft += rand(1, 4)
	update_icon()



/obj/structure/chicken_feeder/update_icon()
	if(food >= FEEDER_FULL)
		icon_state = "full"
		return
	if(food >= FEEDER_HALF)
		icon_state = "half"
		return
	if(food >= FEEDER_ALMOST_EMPTY)
		icon_state = "almost empty"
		return
	if(food == FEEDER_EMPTY)
		icon_state = "empty"
		return

#undef FEEDER_FULL
#undef FEEDER_HALF
#undef FEEDER_ALMOST_EMPTY
#undef FEEDER_EMPTY
