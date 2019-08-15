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

/obj/structure/closet/coffin/attackby(obj/item/weapon/W, mob/user)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = W
			MouseDrop_T(G.affecting, user)      //act like they were dragged onto the closet
		if(istype(W,/obj/item/tk_grab))
			return 0
		if(iscrowbar(W))
			new /obj/item/stack/sheet/wood(loc, 5)
			visible_message("<span class='notice'>\The [src] has been disassembled apart by [user] with \the [W].</span>",
							"You hear splitting wood.")
			qdel(src)
			return
		if(!W.canremove || W.flags & NODROP || isrobot(user))
			return
		usr.drop_item()
		if(W)
			W.forceMove(src.loc)

	else if(istype(W, /obj/item/weapon/packageWrap) || istype(W, /obj/item/weapon/extraction_pack))
		return

	else if(isscrewdriver(W))
		user.SetNextMove(CLICK_CD_INTERACT)
		src.welded = !src.welded
		visible_message("<span class='warning'>[src] has been [welded?"screwed":"unscrewed"] by [user].</span>",
						"You hear screwing.")
	else
		attack_hand(user)