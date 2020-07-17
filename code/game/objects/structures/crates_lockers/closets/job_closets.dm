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

/obj/structure/closet/gmcloset/PopulateContents()
	new /obj/item/clothing/head/hairflower(src)
	new /obj/item/clothing/under/dress/dress_saloon(src)
	for (var/i in 1 to 2)
		new /obj/item/clothing/head/that(src)
		new /obj/item/clothing/under/sl_suit(src)
		new /obj/item/clothing/under/rank/bartender(src)
		new /obj/item/clothing/suit/wcoat(src)
		new /obj/item/clothing/shoes/black(src)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/PopulateContents()
	new /obj/item/clothing/under/rank/janitor(src)
	new /obj/item/weapon/cartridge/janitor(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/head/soft/janitor(src)
	new /obj/item/device/flashlight(src)
	for (var/i in 1 to 4)
		new /obj/item/weapon/caution(src)
	new /obj/item/device/lightreplacer(src)
	new /obj/item/weapon/storage/bag/trash(src)
	new /obj/item/clothing/shoes/boots/galoshes(src)
	new /obj/item/weapon/storage/pouch/small_generic(src) // Because I feel like poor janitor gets it bad.

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/PopulateContents()
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

/obj/structure/closet/theatrecloset/PopulateContents()
	switch (rand(1, 21))
		if (1)
			new /obj/item/clothing/suit/chickensuit(src)
			new /obj/item/clothing/head/chicken(src)
			new /obj/item/weapon/reagent_containers/food/snacks/egg(src)
		if (2)
			new /obj/item/clothing/under/gladiator(src)
			new /obj/item/clothing/head/helmet/gladiator(src)
		if (3)
			new /obj/item/clothing/mask/gas/sexymime(src)
			new /obj/item/clothing/under/sexymime(src)
		if (4)
			new /obj/item/clothing/under/gimmick/rank/captain/suit(src)
			new /obj/item/clothing/head/flatcap(src)
			new /obj/item/clothing/mask/cigarette/cigar/havana(src)
			new /obj/item/clothing/shoes/boots(src)
		if (5)
			new /obj/item/clothing/under/schoolgirl(src)
			new /obj/item/clothing/head/kitty(src)
		if (6)
			new /obj/item/clothing/under/blackskirt(src)
			var/choice = pick(/obj/item/clothing/head/chep, /obj/item/clothing/head/rabbitears)
			new choice(src)
			new /obj/item/clothing/glasses/sunglasses/blindfold(src)
		if (7)
			new /obj/item/clothing/suit/wcoat(src)
			new /obj/item/clothing/under/suit_jacket(src)
			new /obj/item/clothing/head/that(src)
		if (8)
			new /obj/item/clothing/gloves/white(src)
			new /obj/item/clothing/shoes/white(src)
			new /obj/item/clothing/under/scratch(src)
			if (prob(30))
				new /obj/item/clothing/head/cueball(src)
		if (9)
			new /obj/item/clothing/under/kilt(src)
			new /obj/item/clothing/head/beret/red(src)
		if (10)
			new /obj/item/clothing/suit/wcoat(src)
			new /obj/item/clothing/glasses/monocle(src)
			var/choice = pick( /obj/item/clothing/head/bowler, /obj/item/clothing/head/that)
			new choice(src)
			new /obj/item/clothing/shoes/black(src)
			new /obj/item/weapon/cane(src)
			new /obj/item/clothing/under/sl_suit(src)
			new /obj/item/clothing/mask/fakemoustache(src)
		if (11)
			new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(src)
			new /obj/item/clothing/head/plaguedoctorhat(src)
			new /obj/item/clothing/mask/gas/plaguedoctor(src)
		if( 12)
			new /obj/item/clothing/under/owl(src)
			new /obj/item/clothing/mask/gas/owl_mask(src)
		if (13)
			new /obj/item/clothing/under/waiter(src)
			var/choice = pick( /obj/item/clothing/head/kitty, /obj/item/clothing/head/rabbitears)
			new choice(src)
			new /obj/item/clothing/suit/apron(src)
		if (14)
			new /obj/item/clothing/under/pirate(src)
			new /obj/item/clothing/suit/pirate(src)
			var/choice = pick( /obj/item/clothing/head/pirate , /obj/item/clothing/head/bandana )
			new choice(src)
			new /obj/item/clothing/glasses/eyepatch(src)
		if (15)
			new /obj/item/clothing/under/soviet(src)
			new /obj/item/clothing/head/ushanka(src)
		if (16)
			new /obj/item/clothing/suit/imperium_monk(src)
			if (prob(25))
				new /obj/item/clothing/mask/gas/cyborg(src)
		if (17)
			new /obj/item/clothing/suit/holidaypriest(src)
		if (18)
			new /obj/item/clothing/shoes/sandal/marisa(src)
			for (var/i in 1 to 2)
				new /obj/item/clothing/head/wizard/marisa/fake(src)
		if (19)
			new /obj/item/clothing/under/sundress(src)
			new /obj/item/clothing/head/witchwig(src)
			new /obj/item/weapon/staff/broom(src)
		if (20)
			new /obj/item/clothing/shoes/sandal(src)
			new /obj/item/clothing/suit/wizrobe/fake(src)
			new /obj/item/clothing/head/wizard/fake(src)
			new /obj/item/weapon/staff/(src)
		if (21)
			new /obj/item/clothing/mask/gas/sexyclown(src)
			new /obj/item/clothing/under/sexyclown(src)
