/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

/obj/structure/closet/coffin/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/obj/structure/closet/coffin/tools_interact(obj/item/weapon/W, mob/user)
	if(opened && iscrowbar(W))
		new /obj/item/stack/sheet/wood(loc, 5)
		visible_message("<span class='notice'>\The [src] has been disassembled apart by [user] with \the [W].</span>",
						"<span class='notice'>You hear splitting wood.</span>")
		qdel(src)
		return TRUE

	else if(!opened && isscrewdriver(W))
		user.SetNextMove(CLICK_CD_INTERACT)
		src.welded = !src.welded
		visible_message("<span class='warning'>[src] has been [welded?"screwed":"unscrewed"] by [user].</span>",
						"<span class='warning'>You hear screwing.</span>")
		return TRUE
