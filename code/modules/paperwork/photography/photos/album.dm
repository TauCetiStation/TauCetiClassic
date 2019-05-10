/*
 * Photo album
 */

/obj/item/weapon/storage/photo_album
	name = "photo album"
	icon = 'icons/obj/photography.dmi'
	icon_state = "album"
	item_state = "book8"
	w_class = ITEM_SIZE_NORMAL // same as book
	can_hold = list("/obj/item/weapon/photo")
	max_storage_space = DEFAULT_BOX_STORAGE
	var/current_page = 1

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object)
	if(ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		if(!istype(over_object, /obj/screen))
			return ..()
		playsound(loc, "rustle", 50, 1, -5)
		if(!M.restrained() && !M.stat && M.back == src)
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
	return

/obj/item/weapon/storage/photo_album/attack_self(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		user.playsound_local(null, "pageturn", 50)
		user.visible_message("<span class='notice'>[user] opens up \the [src] and looks inside.</span>",
								 "<span class='notice'>You start looking into \the [src].</span>")
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/album)
		assets.send(user)
		return src.interact(user)

	..()

/obj/item/weapon/storage/photo_album/interact(mob/user)
	if(!user || (user && !user.client))
		return 0
	var/list/contained_photos = list()
	for(var/obj/item/weapon/photo/P in contents)
		if(P.img)
			contained_photos += P
	var/dat = text("<html><HEAD><TITLE>[name]</TITLE></HEAD>")
	dat += "<body>"
	dat += "<style>body{background-image:url('photoalbum.png');background-color: #F5ECDD;background-repeat:no-repeat;background-position:center top;}</style>"
	if(contained_photos.len)
		var/first_photo_num = (current_page * 2) - 1
		var/second_photo_num = current_page * 2
		if(contained_photos.len >= first_photo_num)
			dat += "<div align='center'><table width='100%'><tr><td width='50%'>"
			dat += "<table align='left' width='100%'><tr>"
			var/obj/item/weapon/photo/P_ONE = contained_photos[first_photo_num]
			user << browse_rsc(P_ONE.img, "album_photo[P_ONE.photo_id].png")
			dat += "<div align='center'><br><img src='album_photo[P_ONE.photo_id].png' width = '180'>"
			dat += "<br><br><b>[P_ONE.name]</b><br>"
			dat += "<br><br><b><A href='?src=\ref[src];takeout=\ref[P_ONE]'>Take out</a></b>"
			dat += "</div>"
			dat += "</tr></td></table>"
			dat += "<td width='50%'>"
			dat += "<table align='right' width='100%'><tr>"
			if(contained_photos.len >= second_photo_num)
				var/obj/item/weapon/photo/P_TWO = contained_photos[second_photo_num]
				user << browse_rsc(P_TWO.img, "album_photo[P_TWO.photo_id].png")
				dat += "<br><div align='center'><img src='album_photo[P_TWO.photo_id].png' width = '180'>"
				dat += "<br><br><b>[P_TWO.name]</b><br>"
				dat += "<br><br><b><A href='?src=\ref[src];takeout=\ref[P_TWO]'>Take out</a></b>"

			dat += "</div>"
			dat += "</div></tr></td></table>"
			dat += "</tr></table>"
		else
			current_page--
			usr << browse(null, "window=photoalbum_browser")
			usr.unset_machine(src)
			return
	else
		dat += "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>"
	dat += "<br><br><p align='left'>Page [current_page]   --   <A href='?src=\ref[src];close=1'>Close</a>"
	if(current_page > 1)
		dat += "   --   <A href='?src=\ref[src];prevpage=1'>Previous Page</a>"
	if(contained_photos.len && contained_photos.len > (current_page * 2) && current_page < 4)
		dat += "   --   <A href='?src=\ref[src];nextpage=1'>Next Page</a>"
	dat += "</p>"
	dat += "</body></html>"
	contained_photos = null
	winshow(user, "photoalbum", TRUE)
	user << browse(entity_ja(dat), "window=photoalbum_browser;size=600x400")

/obj/item/weapon/storage/photo_album/Topic(href, href_list)
	if(get_dist(src, usr) > 1)
		return
	usr.set_machine(src)

	if(href_list["takeout"])
		var/obj/item/weapon/photo/P = locate(href_list["takeout"])
		if(P.loc != src)
			updateDialog()
			return
		if(!iscarbon(usr))
			return
		var/mob/living/carbon/M = usr
		if(!M.r_hand)
			to_chat(M, "<span class='notice'>You take out \the [P].</span>")
			remove_from_storage(P)
			M.put_in_r_hand(P)
		else if(!M.l_hand)
			to_chat(M, "<span class='notice'>You take out \the [P].</span>")
			remove_from_storage(P)
			M.put_in_l_hand(P)
		else
			to_chat(M, "<span class='warning'>You need at least one hand to be empty.</span>")

	else if(href_list["close"])
		playsound(src.loc, "pageturn", 50, 1)
		usr << browse(null, "window=photoalbum_browser")
		usr.unset_machine(src)
		return
	else if(href_list["nextpage"])
		if(current_page < 4)
			current_page++
			playsound(src.loc, "pageturn", 50, 1)
		else
			to_chat(usr, "<span class='warning'>There is no more pages.</span>")
	else if(href_list["prevpage"])
		if(current_page > 1)
			current_page--
			playsound(src.loc, "pageturn", 50, 1)
		else
			to_chat(usr, "<span class='warning'>There is no more pages.</span>")

	src.interact(usr)
	..()
	updateDialog()
