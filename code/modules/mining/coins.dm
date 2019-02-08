/obj/item/weapon/coin
	icon = 'icons/obj/economy.dmi'
	name = COIN_IRON
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 0.0
	throwforce = 0.0
	w_class = ITEM_SIZE_TINY
	var/string_attached
	var/sides = 2
	var/cooldown = 0
	var/list/sideslist = list("heads","tails")
	var/coinflip
	var/cmineral = null
	var/worth = 0
	var/reagent = "iron"

/obj/item/weapon/coin/atom_init()
	. = ..()
	price = worth
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
	create_reagents(4)
	reagents.add_reagent(reagent, 4)

/obj/item/weapon/coin/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] contemplates suicide with \the [src]!</span>")
	if (!attack_self(user))
		user.visible_message("<span class='suicide'>[user] couldn't flip \the [src]!</span>")
	addtimer(CALLBACK(src, .proc/manual_suicide, user), 10)//10 = time takes for flip animation
	return MANUAL_SUICIDE

/obj/item/weapon/coin/proc/manual_suicide(mob/living/user)
	var/index = sideslist.Find(coinflip)
	if (index==2) //tails
		user.visible_message("<span class='suicide'>\the [src] lands on [coinflip]! [user] promptly falls over, dead!</span>")
		user.adjustOxyLoss(200)
		user.death(0)
	else
		user.visible_message("<span class='suicide'>\the [src] lands on [coinflip]! [user] keeps on living!</span>")

/obj/item/weapon/coin/examine(mob/user)
	..()
	if(worth)
		to_chat(user, "<span class='info'>It's worth [worth] credit\s.</span>")

/obj/item/weapon/coin/gold
	name = COIN_GOLD
	cmineral = "gold"
	reagent = "gold"
	icon_state = "coin_gold_heads"
	worth = 250
	materials = list(MAT_GOLD = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/silver
	name = COIN_SILVER
	cmineral = "silver"
	reagent = "silver"
	icon_state = "coin_silver_heads"
	worth = 100
	materials = list(MAT_SILVER = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/diamond
	name = COIN_DIAMOND
	cmineral = "diamond"
	reagent = "carbon"
	icon_state = "coin_diamond_heads"
	worth = 1000
	materials = list(MAT_DIAMOND = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/iron
	name = COIN_IRON
	cmineral = "iron"
	reagent = "iron"
	icon_state = "coin_iron_heads"
	worth = 10
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/phoron
	name = COIN_PHORON
	cmineral = "phoron"
	reagent = "phoron"
	icon_state = "coin_phoron_heads"
	worth = 400
	materials = list(MAT_PHORON = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/uranium
	name = COIN_URANIUM
	cmineral = "uranium"
	reagent = "uranium"
	icon_state = "coin_uranium_heads"
	worth = 250
	materials = list(MAT_URANIUM = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/bananium
	name = COIN_BANANIUM
	cmineral = "bananium"
	reagent = "banana"
	icon_state = "coin_bananium_heads"
	worth = 2000
	materials = list(MAT_BANANIUM = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/platinum
	name = COIN_PLATINUM
	cmineral = "platinum"
	reagent = "silver" //have no idea
	icon_state = "coin_adamantine_heads"
	worth = 1000

/obj/item/weapon/coin/mythril
	name = COIN_MYTHRIL
	cmineral = "mythril"
	reagent = "silver" //true silver
	icon_state = "coin_mythril_heads"
	worth = 3000

/obj/item/weapon/coin/twoheaded
	cmineral = "silver"
	reagent = "silver"
	icon_state = "coin_silver_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	materials = list(MAT_SILVER = MINERAL_MATERIAL_AMOUNT*0.2)
	worth = 10

/obj/item/weapon/coin/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='warning'>There already is a string attached to this coin!</span>")
			return

		if(CC.use(1))
			overlays += image('icons/obj/items.dmi',"coin_string_overlay")
			string_attached = 1
			to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
			return

		else
			to_chat(user, "<span class='warning'>You need one length of cable to attach a string to the coin!</span>")
			return

	else if(istype(W,/obj/item/weapon/wirecutters) )
		if(!string_attached)
			..()
			return

		new /obj/item/stack/cable_coil/red(user.loc, 1)
		overlays = list()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	else
		..()

/obj/item/weapon/coin/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			to_chat(user, "<span class='warning'>The coin won't flip very well with something attached!</span>" )
			return FALSE //do not flip the coin
		coinflip = pick(sideslist)
		cooldown = world.time + 15
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		var/oldloc = loc
		sleep(15)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
 							 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
							 "<span class='italics'>You hear the clattering of loose change.</span>")
	return TRUE //did the coin flip? useful for suicide_act
