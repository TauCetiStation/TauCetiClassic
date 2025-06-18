/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = TRUE
	var/list/stored_ore = list()

	resistance_flags = CAN_BE_HIT

/obj/structure/ore_box/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/ore))
		user.drop_from_inventory(W, src)
		updateUsrDialog()

	else if(istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		user.SetNextMove(CLICK_CD_INTERACT)

		var/have_ore = FALSE
		if(locate(/obj/item/weapon/ore) in S.contents)
			have_ore = TRUE

		for(var/obj/item/weapon/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
		if(have_ore)
			to_chat(user, "<span class='notice'>You empty the satchel into the box.</span>")
			playsound(src, 'sound/items/mining_satchel_unload.ogg', VOL_EFFECTS_MASTER)
		else
			to_chat(user, "<span class='warning'>There is no ore to unload here!</span>")
		updateUsrDialog()


/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/weapon/ore/O as anything in contents)
		O.forceMove(loc)

/obj/structure/ore_box/deconstruct(disassembled)
	dump_box_contents()
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/wood(loc, 4)
	..()

/obj/structure/ore_box/Entered(atom/movable/ORE)
	if(istype(ORE, /obj/item/weapon/ore))
		stored_ore[ORE.type]++

/obj/structure/ore_box/Exited(atom/movable/ORE)
	if(istype(ORE, /obj/item/weapon/ore))
		stored_ore[ORE.type]--
	if(!contents.len)
		stored_ore = list()

/obj/structure/ore_box/attack_hand(mob/user)
	var/dat = ""

	if(length(contents))
		for(var/ore_type in stored_ore)
			var/obj/item/weapon/ore/ore = ore_type
			dat += {"<span class="orebox32x32 [replacetext(replacetext("[ore_type]", "[/obj/item]/", ""), "/", "-")]"></span><span style='position: relative; top: -10px;'><span class='orange'><B>x[stored_ore[ore_type]]</B></span> [initial(ore.name)]</span><br>"}
		dat += "<br><A href='?src=\ref[src];removeall=1'>Empty box</A>"
	else
		dat += "The box is empty"

	var/datum/browser/popup = new(user, "orebox", "The contents of the ore box reveal...", 280, 400)
	popup.add_stylesheet(get_asset_datum(/datum/asset/spritesheet/orebox))
	popup.set_content(dat)
	popup.open()

/obj/structure/ore_box/examine(mob/user)
	..()

	// Borgs can now check contents too.
	if((!ishuman(user)) && (!isrobot(user)))
		return

	if(!Adjacent(user)) //Can only check the contents of ore boxes if you can physically reach them.
		return

	add_fingerprint(user)

	if(!length(contents))
		to_chat(user, "It is empty.")
		return

	to_chat(user, "It holds:")
	var/dat = ""
	for(var/ore_type in stored_ore)
		var/obj/item/weapon/ore/ore = ore_type
		dat += "<B>x[stored_ore[ore_type]]</B> [initial(ore.name)]<br>"
	to_chat(user, dat)

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["removeall"])
		empty_box()
	updateUsrDialog()

/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr)) //Only living, intelligent creatures with hands can empty ore boxes.
		to_chat(usr, "<span class='warning'>You are physically incapable of emptying the ore box.</span>")
		return

	if(usr.incapacitated())
		return

	if(!Adjacent(usr)) //You can only empty the box if you can physically reach it
		to_chat(usr, "<span class='warning'>You cannot reach the ore box.</span>")
		return

	add_fingerprint(usr)

	if(length(contents) < 1)
		to_chat(usr, "<span class='warning'>The ore box is empty!</span>")
		return

	dump_box_contents()

	playsound(src, 'sound/items/orebox_unload.ogg', VOL_EFFECTS_MASTER)
	to_chat(usr, "<span class='notice'>You empty the ore box.</span>")
