/* Closets for specific jobs
 * Contains:
 *		Bartender
 *		Janitor
 *		Lawyer
 */

/*
 * Bartender
 */
/obj/structure/closet/gmcloset
	name = "formal closet"
	desc = "It's a storage unit for formal clothing."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/gmcloset/New()
	..()
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/hairflower(src)
	new /obj/item/clothing/under/sl_suit(src)
	new /obj/item/clothing/under/sl_suit(src)
	new /obj/item/clothing/under/rank/bartender(src)
	new /obj/item/clothing/under/rank/bartender(src)
	new /obj/item/clothing/under/dress/dress_saloon(src)
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/New()
	..()
	new /obj/item/clothing/under/rank/janitor(src)
	new /obj/item/weapon/cartridge/janitor(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/head/soft/janitor(src)
	new /obj/item/device/flashlight(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/device/lightreplacer(src)
	new /obj/item/weapon/storage/bag/trash(src)
	new /obj/item/clothing/shoes/galoshes(src)

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/New()
	..()
	new /obj/item/clothing/under/lawyer/female(src)
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/bluesuit(src)
	new /obj/item/clothing/suit/storage/lawyer/bluejacket(src)
	new /obj/item/clothing/under/lawyer/purpsuit(src)
	new /obj/item/clothing/suit/storage/lawyer/purpjacket(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)

/obj/structure/closet/theatrecloset
	name = "Theatre Closet"
	desc = "This closet contains basic set of costumes required to preform stage acts and honk outside."
	icon_state = "cabinet_closed"
	icon_closed = "cabinet_closed"
	icon_opened = "cabinet_open"

/obj/structure/closet/theatrecloset/New()
	..()

	switch (rand(1, 21))
		if (1)
			new /obj/item/clothing/suit/chickensuit(src.loc)
			new /obj/item/clothing/head/chicken(src.loc)
			new /obj/item/weapon/reagent_containers/food/snacks/egg(src.loc)
		if (2)
			new /obj/item/clothing/under/gladiator(src.loc)
			new /obj/item/clothing/head/helmet/gladiator(src.loc)
		if (3)
			new /obj/item/clothing/mask/gas/sexymime(src.loc)
			new /obj/item/clothing/under/sexymime(src.loc)
		if (4)
			new /obj/item/clothing/under/gimmick/rank/captain/suit(src.loc)
			new /obj/item/clothing/head/flatcap(src.loc)
			new /obj/item/clothing/mask/cigarette/cigar/havana(src.loc)
			new /obj/item/clothing/shoes/jackboots(src.loc)
		if (5)
			new /obj/item/clothing/under/schoolgirl(src.loc)
			new /obj/item/clothing/head/kitty(src.loc)
		if (6)
			new /obj/item/clothing/under/blackskirt(src.loc)
			var/CHOICE = pick( /obj/item/clothing/head/beret , /obj/item/clothing/head/rabbitears )
			new CHOICE(src.loc)
			new /obj/item/clothing/glasses/sunglasses/blindfold(src.loc)
		if (7)
			new /obj/item/clothing/suit/wcoat(src.loc)
			new /obj/item/clothing/under/suit_jacket(src.loc)
			new /obj/item/clothing/head/that(src.loc)
		if (8)
			new /obj/item/clothing/gloves/white(src.loc)
			new /obj/item/clothing/shoes/white(src.loc)
			new /obj/item/clothing/under/scratch(src.loc)
			if (prob(30))
				new /obj/item/clothing/head/cueball(src.loc)
		if (9)
			new /obj/item/clothing/under/kilt(src.loc)
			new /obj/item/clothing/head/beret(src.loc)
		if (10)
			new /obj/item/clothing/suit/wcoat(src.loc)
			new /obj/item/clothing/glasses/monocle(src.loc)
			var/CHOICE= pick( /obj/item/clothing/head/bowler, /obj/item/clothing/head/that)
			new CHOICE(src.loc)
			new /obj/item/clothing/shoes/black(src.loc)
			new /obj/item/weapon/cane(src.loc)
			new /obj/item/clothing/under/sl_suit(src.loc)
			new /obj/item/clothing/mask/fakemoustache(src.loc)
		if (11)
			new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src.loc)
			new /obj/item/clothing/head/plaguedoctorhat(src.loc)
			new /obj/item/clothing/mask/gas/plaguedoctor(src.loc)
		if( 12)
			new /obj/item/clothing/under/owl(src.loc)
			new /obj/item/clothing/mask/gas/owl_mask(src.loc)
		if (13)
			new /obj/item/clothing/under/waiter(src.loc)
			var/CHOICE= pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
			new CHOICE(src.loc)
			new /obj/item/clothing/suit/apron(src.loc)
		if (14)
			new /obj/item/clothing/under/pirate(src.loc)
			new /obj/item/clothing/suit/pirate(src.loc)
			var/CHOICE = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/head/bandana )
			new CHOICE(src.loc)
			new /obj/item/clothing/glasses/eyepatch(src.loc)
		if (15)
			new /obj/item/clothing/under/soviet(src.loc)
			new /obj/item/clothing/head/ushanka(src.loc)
		if (16)
			new /obj/item/clothing/suit/imperium_monk(src.loc)
			if (prob(25))
				new /obj/item/clothing/mask/gas/cyborg(src.loc)
		if (17)
			new /obj/item/clothing/suit/holidaypriest(src.loc)
		if (18)
			new /obj/item/clothing/shoes/sandal/marisa(src.loc)
			new /obj/item/clothing/head/wizard/marisa/fake(src.loc)
			new/obj/item/clothing/suit/wizrobe/marisa/fake(src.loc)
		if (19)
			new /obj/item/clothing/under/sundress(src.loc)
			new /obj/item/clothing/head/witchwig(src.loc)
			new /obj/item/weapon/staff/broom(src.loc)
		if (20)
			new /obj/item/clothing/shoes/sandal(src.loc)
			new /obj/item/clothing/suit/wizrobe/fake(src.loc)
			new /obj/item/clothing/head/wizard/fake(src.loc)
			new /obj/item/weapon/staff/(src.loc)
		if (21)
			new /obj/item/clothing/mask/gas/sexyclown(src.loc)
			new /obj/item/clothing/under/sexyclown(src.loc)
