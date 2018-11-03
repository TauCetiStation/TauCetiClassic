///-----------------------------------------------------//
///														//
///					Table Crafting						//
///		Food that you can craft by combining pieces.	//
///														//
///-----------------------------------------------------//
//TO DO: port tablecrafting from TG

/*Egg + flour = dough
/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/flour))
		new /obj/item/weapon/reagent_containers/food/snacks/dough(src)
		to_chat(user, "<span class='notice'>You make some dough.</span>")
		qdel(W)
		qdel(src) 			NO. Use bowl and spoon*/


// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchen/rollingpin))
		new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(src)
		to_chat(user, "<span class='notice'>You flatten the dough.</span>")
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/weapon/W, mob/user)
	// Bun + meatball = borglar
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/meatball))
		new /obj/item/weapon/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "<span class='notice'>You make a burger.</span>")
		qdel(W)
		qdel(src)

	// Bun + cutlet = borglar
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/cutlet))
		new /obj/item/weapon/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "<span class='notice'>You make a burger.</span>")
		qdel(W)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/sausage))
		new /obj/item/weapon/reagent_containers/food/snacks/hotdog(src)
		to_chat(user, "<span class='notice'>You make a hotdog.</span>")
		qdel(W)
		qdel(src)































