/obj/item/weapon/storage/bag/trash/miners
	name = "industrial trash bag"
	desc = "Instead of usual trash bag, this one comes with self-compressing mechanism, which allows it to hold a huge amount of trash inside. It has a smart vacuum pull system which takes in only trash. Very expensive for a trash bag!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag"
	item_state = "trashbag"
	color = "red"

	w_class = 4
	max_w_class = 4
	storage_slots = 15
	max_combined_w_class = 60
	can_hold = list("/obj/item/weapon/scrap_lump")
	cant_hold = list()

/obj/item/weapon/paper/crumpled/bloody/dickbutt
	info = "<p><img src=paper_dickbutt.png></p>"
	layer = 2.9

/obj/item/weapon/paper/crumpled/bloody/dickbutt/examine(mob/user)
	..()
	user << browse_rsc(file("icons/dickbutt.png"), "paper_dickbutt.png")
