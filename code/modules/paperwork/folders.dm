/obj/item/weapon/folder
	name = "folder"
	desc = "A folder."
	icon = 'icons/obj/bureaucracy.dmi'
	hitsound = list('sound/items/misc/folder-slap.ogg')
	icon_state = "folder_grey"
	w_class = SIZE_TINY

/obj/item/weapon/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/weapon/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/weapon/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/weapon/folder/white
	desc = "A white folder."
	icon_state = "folder_white"

/obj/item/weapon/folder/purple
	desc = "A purple folder."
	icon_state = "folder_purple"

/obj/item/weapon/folder/green
	desc = "A green folder."
	icon_state = "folder_green"

/obj/item/weapon/folder/pink
	desc = "A pink folder."
	icon_state = "folder_pink"

/obj/item/weapon/folder/brown
	desc = "A brown folder."
	icon_state = "folder_brown"

/obj/item/weapon/folder/update_icon()
	cut_overlays()
	if(contents.len)
		add_overlay("folder_paper")
	return

/obj/item/weapon/folder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/weapon/paper_bundle))
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You put the [I] into \the [src].</span>")
		update_icon()

	else if(istype(I, /obj/item/weapon/pen))
		var/n_name = sanitize(input(usr, "What would you like to label the folder?", "Folder Labelling", null) as text, MAX_NAME_LEN)
		if((loc == usr && usr.stat == CONSCIOUS))
			name = "folder[(n_name ? text("- '[n_name]'") : null)]"

	else
		return ..()

/obj/item/weapon/folder/attack_self(mob/user)
	var/dat = ""

	for(var/obj/item/weapon/paper/P in src)
		dat += "<A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[sanitize(P.name)]</A><BR>"
	for(var/obj/item/weapon/photo/Ph in src)
		dat += "<A href='?src=\ref[src];remove=\ref[Ph]'>Remove</A> - <A href='?src=\ref[src];look=\ref[Ph]'>[sanitize(Ph.name)]</A><BR>"
	for(var/obj/item/weapon/paper_bundle/Pb in src)
		dat += "<A href='?src=\ref[src];remove=\ref[Pb]'>Remove</A> - <A href='?src=\ref[src];browse=\ref[Pb]'>[sanitize(Pb.name)]</A><BR>"

	var/datum/browser/popup = new(user, "folder", "[name]", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

	add_fingerprint(usr)
	return

/obj/item/weapon/folder/Topic(href, href_list)
	..()
	if(usr.incapacitated())
		return

	if(usr.contents.Find(src))

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(P && P.loc == src)
				P.loc = usr.loc
				usr.put_in_hands(P)

		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if(P)
				P.show_content(usr)
		if(href_list["look"])
			var/obj/item/weapon/photo/P = locate(href_list["look"])
			if(P)
				P.show(usr)
		if(href_list["browse"])
			var/obj/item/weapon/paper_bundle/P = locate(href_list["browse"])
			if(P)
				P.attack_self(usr)
				onclose(usr, "[P.name]")

		//Update everything
		attack_self(usr)
		update_icon()
	return

/obj/item/folder_holder
	name = "folder holder"
	desc = "Папка всех папок."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "folder_holder"
	var/icon/foldersoverlay

/obj/item/folder_holder/atom_init(mapload)
	. = ..()
	if(mapload)
		var/atom/A = get_turf(src)
		for(var/obj/item/weapon/folder in A.contents)
			folder.forceMove(src)
		update_icon()

/obj/item/folder_holder/update_icon()
	cut_overlay(foldersoverlay)
	foldersoverlay = icon('icons/effects/32x32.dmi', "blank")
	var/foldernumber = 0
	for(var/obj/item/weapon/folder in contents)
		var/icon/foldericon = icon('icons/obj/bureaucracy.dmi', "folder_holder_[folder.icon_state]")
		if(folder.contents.len)
			foldericon.Blend(icon('icons/obj/bureaucracy.dmi', "folder_holder_folder_paper"), ICON_OVERLAY, 1, 1)
		foldersoverlay.Blend(foldericon, ICON_OVERLAY, foldernumber * 4 + 1, 1)
		foldernumber++
	icon_state = "folder_holder_[foldernumber]"
	add_overlay(foldersoverlay)

/obj/item/folder_holder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/folder) && contents.len < 5)
		user.drop_from_inventory(I, src)
		to_chat(user, "<span class='notice'>You put the [I] into \the [src].</span>")
		update_icon()
	else
		return ..()

/obj/item/folder_holder/attack_hand(mob/user)
	if(contents.len)
		var/list/folders = list()
		for(var/obj/item/weapon/folder in contents)
			folders[folder] = image(icon = folder.icon, icon_state = folder.icon_state)

		var/obj/item/weapon/folder/selection = show_radial_menu(user, src, folders, require_near = TRUE, tooltips = TRUE)

		if(selection)
			if(ishuman(user))
				user.put_in_hands(selection)
			else
				selection.forceMove(get_turf(src))
			update_icon()
	else
		..()
