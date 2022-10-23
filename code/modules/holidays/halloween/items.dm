		////////////////
		//Spooky Items//
		////////////////

/obj/item/weapon/bikehorn/spidertoy
	name = "little spider"
	desc = "An 'adorable' plastic toy that resembles a spider. Scare the medbay nurses with this."
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "fakespider"
	item_state = "fakespider"
	attack_verb = list("bitten", "hissed", "webbed")

/obj/item/weapon/bikehorn/spidertoy/attack(mob/target, mob/user, def_zone)
	playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MISC)
	return
	// so it doesnt make a bikehorn noise

/obj/item/weapon/bikehorn/spidertoy/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 8
		playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MISC)
		src.add_fingerprint(user)
	return

/obj/effect/spider/stickyweb/nonstick
	name = "fake webbing"
	desc = "Convincing enough for someone's front yard, at least."

/obj/effect/spider/stickyweb/nonstick/CanPass(atom/movable/mover, turf/target)
	return TRUE

/obj/item/weapon/storage/box/trick_o_treat
	name = "trick-o-treat bag"
	desc = "A pumpkin shaped bag that holds all sorts of goodies!"
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "trickortreat"
	item_state = "trickortreat"
	foldable = null

/obj/item/weapon/storage/box/trick_o_treat/atom_init()
	. = ..()
	for(var/whatsinthebag in 1 to 7)
		var/inbag = pick(/obj/item/weapon/reagent_containers/food/snacks/candy/caramel,
		/obj/item/weapon/reagent_containers/food/snacks/sugarcookie,
		/obj/item/weapon/reagent_containers/food/snacks/candy_corn,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
		new inbag(src)

		///////////////////
		//Spooky Clothing//
		///////////////////

/obj/item/clothing/head/helmet/skull
	name = "skull helmet"
	desc = "An intimidating tribal helmet, it doesn't look very comfortable."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 25, bullet = 25, laser = 25, energy = 10, bomb = 10, bio = 5, rad = 20, fire = 40, acid = 20)
	icon_state = "skull"

/obj/item/clothing/head/lobsterhat
	name = "foam lobster head"
	desc = "When everything's going to crab, protecting your head is the best choice."
	icon_state = "lobster_hat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR|HEADCOVERSMOUTH

/obj/item/clothing/suit/dracula
	name = "dracula coat"
	desc = "Looks like this belongs in a very old movie set"
	icon_state = "draculacoat"

/obj/item/clothing/suit/gothcoat
	name = "gothic coat"
	desc = "Perfect for those who want stalk in a corner of a bar."
	icon_state = "gothcoat"

/obj/item/clothing/under/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient era known as the victorian era"
	icon_state = "draculass"
	item_state = "draculass"
	item_color = "draculass"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	item_state = "lobster"
	item_color = "lobster"

/obj/item/clothing/under/skeleton
	name = "skeleton jumpsuit"
	desc = "A black jumpsuit with a white bone pattern printed on it. Spooky!"
	icon_state = "skeleton"
	item_state = "skeleton"
	item_color = "skeleton"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/under/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	item_state = "mummy"
	item_color = "mummy"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/under/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	item_state = "scarecrow"
	item_color = "scarecrow"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/head/scarecrow_hat
	name = "scarecrow hat"
	desc = "A simple straw hat."
	icon_state = "scarecrow_hat"

/obj/item/clothing/head/pharoah
	name = "pharoah hat"
	desc = "Walk like an Egyptian."
	icon_state = "pharoah_hat"

/obj/item/clothing/suit/ghost_sheet
	name = "ghost sheet"
	desc = "The hands float by themselves, so it's extra spooky."
	icon_state = "ghost_sheet"
	item_state = "ghost_sheet"

		/////////////////
		//Spooky Vender//
		/////////////////

/obj/machinery/vending/spooky
	name = "SpookyVend"
	desc = "Boo! Things are about to get scarier than ever!"
	icon = 'code/modules/halloween/halloween.dmi'
	icon_state = "SpookyVend"
	product_slogans = "SpookyVend: Get Spooked Today"
	products = list(/obj/item/weapon/bikehorn/spidertoy = 4,
					/obj/item/weapon/storage/box/trick_o_treat = 50,
					/obj/item/clothing/head/helmet/skull = 4,
					/obj/item/clothing/under/skeleton = 4,
					/obj/item/clothing/head/pharoah = 4,
					/obj/item/clothing/under/mummy = 4,
					/obj/item/clothing/head/scarecrow_hat = 4,
					/obj/item/clothing/under/scarecrow = 4,
					/obj/item/clothing/head/lobsterhat = 3,
					/obj/item/clothing/under/lobster = 4,
					/obj/item/clothing/suit/dracula = 4,
					/obj/item/clothing/under/draculass = 4,
					/obj/item/clothing/suit/gothcoat = 4,
					/obj/item/clothing/head/pumpkinhead = 4,
					/obj/item/clothing/suit/ghost_sheet = 5,)
	prices = list(/obj/item/weapon/bikehorn/spidertoy = 5,
					/obj/item/weapon/storage/box/trick_o_treat = 50,
					/obj/item/clothing/head/helmet/skull = 10,
					/obj/item/clothing/under/skeleton = 10,
					/obj/item/clothing/head/pharoah = 10,
					/obj/item/clothing/under/mummy = 10,
					/obj/item/clothing/head/scarecrow_hat = 10,
					/obj/item/clothing/under/scarecrow = 10,
					/obj/item/clothing/head/lobsterhat = 10,
					/obj/item/clothing/under/lobster = 10,
					/obj/item/clothing/suit/dracula = 10,
					/obj/item/clothing/under/draculass = 10,
					/obj/item/clothing/suit/gothcoat = 10,
					/obj/item/clothing/head/pumpkinhead = 10,
					/obj/item/clothing/suit/ghost_sheet = 10,)
