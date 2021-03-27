/obj/item/weapon/storage/visuals
	var/list/item_overlays = list()

	var/def_icon_state = "icon"
	var/opened = FALSE
	// Whether this storage can only be viewed/put items in when opened.
	var/require_opened = FALSE

/obj/item/weapon/storage/visuals/proc/gen_item_overlay(obj/item/I)
	var/image/IO = image(I.icon, I.icon_state)
	var/matrix/M = matrix()
	M.Scale(0.7)
	// IO.appearance = I
	IO.transform = M
	IO.pixel_x = rand(-5, 5)
	IO.pixel_y = rand(-5, 5)
	IO.loc = src
	return IO

/obj/item/weapon/storage/visuals/proc/add_item(obj/item/I)
	item_overlays[I] = gen_item_overlay(I)
	if(opened)
		add_overlay(item_overlays[I])

/obj/item/weapon/storage/visuals/proc/remove_item(obj/item/I)
	if(opened)
		cut_overlay(item_overlays[I])
	qdel(item_overlays[I])
	item_overlays -= I

/obj/item/weapon/storage/visuals/open(mob/user)
	if(require_opened && !opened)
		to_chat(user, "<span class='notice'>You can't view [src]'s inventory without opening it up!</span>")
		return FALSE
	return ..()

/obj/item/weapon/storage/visuals/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(require_opened && !opened)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>You can't put items into [src] without opening it up!</span>")
		return FALSE
	return ..()

/obj/item/weapon/storage/visuals/equipped(mob/user, slot)
	..()
	update_overlays()

/obj/item/weapon/storage/visuals/dropped(mob/user, slot)
	..()
	update_overlays()

/obj/item/weapon/storage/visuals/handle_item_insertion(obj/item/I, prevent_warning = FALSE, NoUpdate = FALSE)
	. = ..()
	if(.)
		add_item(I)

/obj/item/weapon/storage/visuals/remove_from_storage(obj/item/I, atom/new_location, NoUpdate = FALSE)
	. = ..()
	if(.)
		remove_item(I)

/obj/item/weapon/storage/visuals/proc/update_overlays()
	if(opened)
		cut_overlays()
		icon_state = "[def_icon_state]_open"
		for(var/obj/item/I in contents)
			var/image/IO = item_overlays[I]
			IO.plane = plane
			IO.layer = layer + 0.05
			add_overlay(IO)
	else
		cut_overlays()
		icon_state = "[def_icon_state]_closed"

/obj/item/weapon/storage/visuals/attack_self(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	opened = !opened
	if(!opened)
		close_all()
	update_overlays()



/obj/item/weapon/storage/visuals/surgery
	name = "surgeon tray"
	desc = "This is a surgical tray made of stainless steel, the label on the lid reads: Made by Vey Med Corp. 2189 year."

	def_icon_state = "case-surgery"
	icon_state = "case-surgery_closed"
	item_state = "case-surgery"

	use_sound = 'sound/items/surgery_tray_use.ogg'

	flags = CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_LARGE

	max_storage_space = 18
	max_w_class = ITEM_SIZE_NORMAL
	can_hold = list(
		/obj/item/weapon/retractor,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/cautery,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
		/obj/item/weapon/bonesetter
		)
	require_opened = TRUE



/obj/item/weapon/storage/visuals/surgery/full

/obj/item/weapon/storage/visuals/surgery/full/atom_init()
	. = ..()
	var/static/list/types_to_insert = list(
		/obj/item/weapon/scalpel,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/retractor,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/cautery,
		/obj/item/weapon/bonesetter,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein
	)

	for(var/item_type in types_to_insert)
		var/obj/item/I = new item_type(src)
		handle_item_insertion(I, TRUE, TRUE)
