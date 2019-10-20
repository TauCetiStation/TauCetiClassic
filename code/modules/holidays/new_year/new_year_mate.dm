//////////////////////////////////////////////
////////////////NewYearMate!//////////////////
//////////////////////////////////////////////

/obj/machinery/vending/newyearmate
	name = "NewYearMate"
	desc = "A vending machine for new year clothing and decorations!"
	icon = 'code/modules/holidays/new_year/new_year_mate.dmi'
	icon_state = "NYM"
	vend_delay = 10
	vend_reply = "Thank you for using the NewYearMate!"
	products = list(/obj/item/clothing/head/santa = 50, /obj/item/clothing/head/santahat = 10, /obj/item/clothing/suit/santa = 10, /obj/item/clothing/head/ushanka = 30, /obj/item/clothing/under/sexy_santa = 10, /obj/item/weapon/present = 50,
	/obj/item/decoration/garland = 30, /obj/item/decoration/tinsel = 30, /obj/item/decoration/snowflake = 10, /obj/item/decoration/snowman = 10, /obj/item/snowball = 500, /obj/item/clothing/suit/wintercoat = 40, /obj/item/clothing/shoes/winterboots = 40)

	contraband = list(/obj/item/clothing/suit/wintercoat/captain = 10, /obj/item/snowball = 100)

	premium = list(/obj/item/clothing/suit/wintercoat/captain = 3)

	prices = list(/obj/item/clothing/head/santa = 50, /obj/item/clothing/head/santahat = 200, /obj/item/clothing/suit/santa = 400, /obj/item/clothing/head/ushanka = 50, /obj/item/clothing/under/sexy_santa = 500, /obj/item/weapon/present = 500,
	/obj/item/decoration/garland = 20, /obj/item/decoration/tinsel = 20, /obj/item/decoration/snowflake = 50, /obj/item/decoration/snowman = 300, /obj/item/snowball = 20, /obj/item/clothing/suit/wintercoat = 100, /obj/item/clothing/shoes/winterboots = 100)
