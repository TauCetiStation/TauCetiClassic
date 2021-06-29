
//what people wear unrevealed

/datum/outfit/mafia
	name = "Mafia Game Outfit"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/black

//town

/datum/outfit/mafia/assistant
	name = "Mafia Assistant"

	uniform = /obj/item/clothing/under/color/grey

/datum/outfit/mafia/detective
	name = "Mafia Detective"

	uniform = /obj/item/clothing/under/det
	shoes = /obj/item/clothing/shoes/brown
	suit = /obj/item/clothing/suit/storage/det_suit
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/det_hat
	mask = /obj/item/clothing/mask/cigarette

/datum/outfit/mafia/psychologist
	name = "Mafia Psychologist"

	uniform = /obj/item/clothing/under/rank/psych/turtleneck
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/mafia/chaplain
	name = "Mafia Chaplain"

	suit = /obj/item/clothing/suit/hooded/skhima
	uniform = /obj/item/clothing/under/rank/chaplain

/datum/outfit/mafia/md
	name = "Mafia Medical Doctor"

	uniform = /obj/item/clothing/under/rank/medical
	shoes = /obj/item/clothing/shoes/white
	suit =  /obj/item/clothing/suit/storage/labcoat

/datum/outfit/mafia/security
	name = "Mafia Security Officer"

	uniform = /obj/item/clothing/under/rank/security
	head = /obj/item/clothing/head/helmet
	suit = /obj/item/clothing/suit/storage/flak
	shoes = /obj/item/clothing/shoes

/datum/outfit/mafia/lawyer
	name = "Mafia Lawyer"

	uniform = /obj/item/clothing/under/lawyer/bluesuit
	suit = /obj/item/clothing/suit/storage/lawyer/bluejacket
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/mafia/hop
	name = "Mafia Head of Personnel"

	uniform = /obj/item/clothing/under/rank/head_of_personnel
	shoes = /obj/item/clothing/shoes/brown
	glasses = /obj/item/clothing/glasses/sunglasses

/datum/outfit/mafia/hos
	name = "Mafia Head of Security"

	uniform = /obj/item/clothing/under/rank/head_of_security
	shoes = /obj/item/clothing/shoes/boots
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /obj/item/clothing/gloves/black
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud

/datum/outfit/mafia/warden
	name = "Mafia Warden"

	uniform = /obj/item/clothing/under/rank/warden
	shoes = /obj/item/clothing/shoes
	suit = /obj/item/clothing/suit/storage/flak/warden
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/beret/sec/warden
	glasses = /obj/item/clothing/glasses/sunglasses/hud/sechud

//mafia

/datum/outfit/mafia/changeling
	name = "Mafia Changeling"

	head = /obj/item/clothing/head/helmet/changeling
	suit = /obj/item/clothing/suit/armor/changeling

//solo

/datum/outfit/mafia/fugitive
	name = "Mafia Fugitive"

	uniform = /obj/item/clothing/under/color/orange
	shoes = /obj/item/clothing/shoes/orange

/datum/outfit/mafia/obsessed
	name = "Mafia Obsessed"
	uniform = /obj/item/clothing/under/overalls
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	mask = /obj/item/clothing/mask/surgical
	suit = /obj/item/clothing/suit/apron

/datum/outfit/mafia/obsessed/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_blood(H)//Oh yes, there will be blood...
	H.regenerate_icons()

/datum/outfit/mafia/clown
	name = "Mafia Clown"

	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat

/datum/outfit/mafia/traitor
	name = "Mafia Traitor"

	head = /obj/item/clothing/head/fedora
	glasses = /obj/item/clothing/glasses/sunglasses/big
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	uniform = /obj/item/clothing/under/suit_jacket/reinforced
	shoes = /obj/item/clothing/shoes/laceup

/datum/outfit/mafia/nightmare
	name = "Mafia Nightmare"

	uniform = null
	shoes = null
