
/*
 * Backpack
 */

/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_state = "backpack"
	w_class = 4.0
	slot_flags = SLOT_BACK	//ERROOOOO
	max_w_class = 3
	max_combined_w_class = 21

/obj/item/weapon/storage/backpack/attackby(obj/item/weapon/W, mob/user)
	if (src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	..()

/obj/item/weapon/storage/backpack/equipped(mob/user, slot)
	if (slot == slot_back && src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	..(user, slot)

/*
/obj/item/weapon/storage/backpack/dropped(mob/user)
	if (loc == user && src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	..(user)
*/

/*
 * Backpack Types
 */

/obj/item/weapon/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	icon_state = "holdingpack"
	max_w_class = 4
	max_combined_w_class = 28

/obj/item/weapon/storage/backpack/holding/New()
	..()
	return

/obj/item/weapon/storage/backpack/holding/attackby(obj/item/weapon/W, mob/user)
	if(crit_fail)
		to_chat(user, "<spam class='red'>The Bluespace generator isn't working.</span>")
		return
	if(istype(W, /obj/item/weapon/storage/backpack/holding) && !W.crit_fail)
		to_chat(user, "<spam class='red'>The Bluespace interfaces of the two devices conflict and malfunction.</span>")
		qdel(W)
		return
	..()

/obj/item/weapon/storage/backpack/holding/proc/failcheck(mob/user)
	if (prob(src.reliability))
		return 1 //No failure
	if (prob(src.reliability))
		to_chat(user, "<spam class='red'>The Bluespace portal resists your attempt to add another item.</span>")//light failure
	else
		to_chat(user, "<spam class='red'>The Bluespace generator malfunctions!</span>")
		for (var/obj/O in src.contents) //it broke, delete what was in it
			qdel(O)
		crit_fail = 1
		icon_state = "brokenpack"

/obj/item/weapon/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))
	return

/obj/item/weapon/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4.0
	storage_slots = 20
	max_w_class = 3
	max_combined_w_class = 400 // can store a ton of shit!

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/weapon/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for Nanotrasen officers."
	icon_state = "captainpack"
	item_state = "captainpack"

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"

/*
 * Satchel Types
 */

/obj/item/weapon/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"

/obj/item/weapon/storage/backpack/satchel/withwallet
	New()
		..()
		new /obj/item/weapon/storage/wallet/random( src )

/obj/item/weapon/storage/backpack/satchel_norm
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"

/obj/item/weapon/storage/backpack/satchel_eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"
	item_state = "engiepack"

/obj/item/weapon/storage/backpack/satchel_med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"
	item_state = "medicalpack"

/obj/item/weapon/storage/backpack/satchel_vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/weapon/storage/backpack/satchel_chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/weapon/storage/backpack/satchel_gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/weapon/storage/backpack/satchel_tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"

/obj/item/weapon/storage/backpack/satchel_sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"
	item_state = "securitypack"

/obj/item/weapon/storage/backpack/satchel_hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"

/obj/item/weapon/storage/backpack/satchel_cap
	name = "captain's satchel"
	desc = "An exclusive satchel for Nanotrasen officers."
	icon_state = "satchel-cap"
	item_state = "captainpack"

//ERT backpacks.
/obj/item/weapon/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Nanotrasen Emergency Response Team."
	icon_state = "ert_commander"
	item_state = "backpack"

//Commander
/obj/item/weapon/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Nanotrasen Emergency Response Team."

//Security
/obj/item/weapon/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/weapon/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/weapon/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Nanotrasen Emergency Response Team."
	icon_state = "ert_medical"

/obj/item/weapon/storage/backpack/kitbag
	name = "kitbag"
	icon_state = "kitbag"

/obj/item/weapon/storage/backpack/medbag
	name = "medbag"
	icon_state = "medbag"

/obj/item/weapon/storage/backpack/alt
	icon_state = "backpack-alt"
	item_state = "backpack"

/obj/item/weapon/storage/backpack/backpack_vir
	name = "virologist backpack"
	desc = "A sterile backpack with virologist colours."
	icon_state = "backpack-vir"
	item_state = "backpack-vir"

/obj/item/weapon/storage/backpack/backpack_chem
	name = "chemist backpack"
	desc = "A sterile backpack with chemist colours."
	icon_state = "backpack-chem"
	item_state = "backpack-chem"

/obj/item/weapon/storage/backpack/backpack_gen
	name = "geneticist backpack"
	desc = "A sterile backpack with geneticist colours."
	icon_state = "backpack-gen"
	item_state = "backpack-gen"

/obj/item/weapon/storage/backpack/backpack_tox
	name = "scientist backpack"
	desc = "Useful for holding research materials."
	icon_state = "backpack-tox"
	item_state = "backpack-tox"

/obj/item/weapon/storage/backpack/backpack_hyd
	name = "hydroponics backpack"
	desc = "A green backpack for plant related work."
	icon_state = "backpack-hyd"
	item_state = "backpack-hyd"

/obj/item/weapon/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = "A silent backpack made for those silent workers. Silence Co."
	icon_state = "mimepack"
	item_state = "mimepack"
