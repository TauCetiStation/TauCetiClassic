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

//MEAT//
//raw cutlet + knife = bacon
/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(istype(W,/obj/item/weapon/kitchenknife))
		var/obj/item/weapon/reagent_containers/food/snacks/raw_bacon/F = new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a bacon.</span>")
		return

//BURGERS//
// Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/burger/attackby(obj/item/weapon/reagent_containers/food/snacks/cheesewedge/W, mob/user)
	if(istype(W) && src == /obj/item/weapon/reagent_containers/food/snacks/burger)
		new /obj/item/weapon/reagent_containers/food/snacks/burger/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(W)
		qdel(src)
		return
	else
		..()

// Human Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/burger/human/attackby(obj/item/weapon/reagent_containers/food/snacks/cheesewedge/W, mob/user)
	if(istype(W))
		new /obj/item/weapon/reagent_containers/food/snacks/burger/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(W)
		qdel(src)
		return
	else
		..()

//VEGETABLES//

// potato + knife = cleaned potato
// potato + cable coil = potato cell
/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(istype(W, /obj/item/weapon/kitchenknife))
		var/obj/item/weapon/reagent_containers/food/snacks/cleanedpotato/P = new /obj/item/weapon/reagent_containers/food/snacks/cleanedpotato(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(P)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You clean the potato.</span>")
		return
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(C.use(5))
			to_chat(user, "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>")
			var/obj/item/weapon/stock_parts/cell/potato/pocell = new /obj/item/weapon/stock_parts/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			qdel(src)
			return

// cleaned potato + knife = raw sticks
/obj/item/weapon/reagent_containers/food/snacks/cleanedpotato/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		var/obj/item/weapon/reagent_containers/food/snacks/rawsticks/P = new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(P)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You cut the potato.</span>")
	else
		..()

//DOUGH//
// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/weapon/W, mob/user)
	.=..()
	if(istype(W,/obj/item/weapon/kitchen/rollingpin))
		var/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/F = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You flatten the dough.</span>")

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/weapon/W, mob/user)
	.=..()
// Bun + cutlet = borglar or human burger
	if(W == /obj/item/weapon/reagent_containers/food/snacks/cutlet)
		var/obj/item/weapon/reagent_containers/food/snacks/burger/F = new /obj/item/weapon/reagent_containers/food/snacks/burger(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a burger.</span>")
		qdel(W)
		return
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/cutlet/human))
		var/obj/item/weapon/reagent_containers/food/snacks/burger/human/F = new /obj/item/weapon/reagent_containers/food/snacks/burger/human(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a strange looking burger.</span>")
		qdel(W)
		return


// Bun + sausage = hotdog
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/sausage))
		var/obj/item/weapon/reagent_containers/food/snacks/hotdog/F = new /obj/item/weapon/reagent_containers/food/snacks/hotdog(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a hotdog.</span>")
		qdel(W)

//PASTA CRAFTING
/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettiboiled/attackby(obj/item/weapon/W, mob/user)
	.=..()
// Boiled Spagetti + Meatball = spaghetti & meatball
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/meatball))
		var/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettionemeatball/F = new /obj/item/weapon/reagent_containers/food/snacks/pasta/spagettionemeatball(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a [F].</span>")
		qdel(W)
		return
// Boiled Spagetti + tomato = tomato spaghetti
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/tomato))
		var/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettitomato/F = new /obj/item/weapon/reagent_containers/food/snacks/pasta/spagettitomato(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a [F].</span>")
		qdel(W)
		return


/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettionemeatball/attackby(obj/item/weapon/W, mob/user)
	.=..()
// spaghetti & meatball + Meatball = spaghetti & meatballs
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/meatball))
		var/obj/item/weapon/reagent_containers/food/snacks/pasta/spagetticouplemeatballs/F = new /obj/item/weapon/reagent_containers/food/snacks/pasta/spagetticouplemeatballs(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a [F].</span>")
		qdel(W)
		return

/obj/item/weapon/reagent_containers/food/snacks/pasta/spagetticouplemeatballs/attackby(obj/item/weapon/W, mob/user)
	.=..()
// spaghetti & meatballs + Meatball = spesslaw
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/meatball))
		var/obj/item/weapon/reagent_containers/food/snacks/pasta/spagettispesslaw/F = new /obj/item/weapon/reagent_containers/food/snacks/pasta/spagettispesslaw(src)
		if(user.l_hand == src || user.r_hand == src)
			qdel(src)
			user.put_in_hands(F)
		else
			qdel(src)
		to_chat(user, "<span class='notice'>You make a [F].</span>")
		qdel(W)
		return












