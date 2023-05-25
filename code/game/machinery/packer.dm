/obj/machinery/packer
	name = "packer"
	desc = "Упаковывает предметы в деревянный ящик."
	icon_state = "packer"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/storage_wood = 0
	var/storage_capacity = 50
	var/state_empty = TRUE

	var/to_pack = 15

	var/icon/load_overlay
	var/icon/cut_icon

/obj/machinery/packer/atom_init()
	. = ..()

	cut_icon = icon('icons/obj/storage.dmi', "wooden_box_open_itemmask")
	load_overlay = icon('icons/effects/32x32.dmi', "blank")

/obj/machinery/packer/examine(mob/user)
	. = ..()
	to_chat(user, "Загружено досок: [storage_wood]шт.")

/obj/machinery/packer/proc/check_can_load(obj/item/I)
	if(I.flags_2 & CANT_BE_INSERTED)
		return FALSE
	if(I.anchored)
		return FALSE
	if(I.w_class >= SIZE_NORMAL)
		return FALSE
	return TRUE

/obj/machinery/packer/attackby(obj/item/I, mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(istype(I, /obj/item/stack/sheet/wood))
		var/loaded = load_wood(I)
		if(loaded)
			to_chat(user, "Загружено [loaded]шт. досок.")
	else if(istype(I, /obj/item/weapon/storage)) // fastload from userstorage
		if(istype(I, /obj/item/weapon/storage/lockbox))
			var/obj/item/weapon/storage/lockbox/L = I
			if(L.locked)
				to_chat(user, "<span class='notice'>[L] заперт.</span>")
				return
		var/obj/item/weapon/storage/S = I

		for(var/obj/Item in S.contents)
			S.remove_from_storage(Item, src.loc)
			load_item(Item)
	else
		load_item(I, user)

/obj/machinery/packer/Bumped(atom/movable/AM)
	if(stat & (BROKEN|NOPOWER))
		return
	if(isliving(AM))
		return
	if(istype(AM, /obj/item/stack/sheet/wood))
		load_wood(AM)
	else if(istype(AM, /obj/item))
		load_item(AM)
	else
		AM.forceMove(loc)

/obj/machinery/packer/proc/load_wood(obj/item/stack/sheet/wood/Wood)
	if(Wood.is_cyborg())
		return

	var/can_put = storage_capacity - storage_wood
	var/loaded = 0
	if(!can_put)
		return

	if(Wood.amount > can_put)
		storage_wood += can_put
		loaded = Wood.amount - can_put
		Wood.set_amount(loaded)
	else
		loaded = Wood.amount
		storage_wood += loaded
		qdel(Wood)

	if(state_empty && storage_wood >= 2)
		flick("packer_loading", src)
		icon_state = "packer_loaded"
		state_empty = FALSE

	return loaded

/obj/machinery/packer/proc/load_item(obj/item/Item, mob/user = null)
	if(state_empty)
		if(user)
			to_chat(user, "Требуются доски для ящика.")
		return
	if(check_can_load(Item))
		if(user)
			user.drop_from_inventory(Item, src)
			to_chat(user, "[Item.name] положен внутрь.")
		else
			Item.forceMove(src)

		cut_overlay(load_overlay)
		load_overlay.Blend(new/icon(Item.icon, Item.icon_state), ICON_OVERLAY, rand(-10, 10), rand(-5, 5))
		load_overlay.Blend(cut_icon, ICON_ADD, 1, 1)
		add_overlay(load_overlay)

		if(contents.len >= to_pack)
			pack()

/obj/machinery/packer/proc/pack()

	storage_wood -= 2

	flick("packer_packing", src)

	cut_overlay(load_overlay)
	load_overlay = icon('icons/effects/32x32.dmi', "blank")
	add_overlay(load_overlay)

	if(storage_wood >= 2)
		icon_state = "packer_loaded"
	else
		icon_state = "packer"
		state_empty = TRUE

	var/obj/item/weapon/wooden_box/box = new(src, contents)
	addtimer(CALLBACK(box, /atom/movable.proc/forceMove, loc), 8)

/obj/machinery/packer/attack_hand(mob/living/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(state_empty)
		to_chat(user, "Требуются доски для ящика.")
		return

	if(!contents.len)
		to_chat(user, "Нечего упаковывать.")
		return

	to_chat(user, "Упаковка запущена.")
	pack()


/obj/item/weapon/wooden_box
	name = "A wooden box"
	desc = "Деревянная коробка."
	icon = 'icons/obj/storage.dmi'
	icon_state = "wooden_box"
	w_class = SIZE_NORMAL

	var/icon/Picture
	var/list/startswith

/obj/item/weapon/wooden_box/examine(mob/user)
	. = ..()

	var/contents_message = "пуст."
	if(1 <= contents.len && contents.len < 5)
		contents_message = "почти пуст."
	else if(5 <= contents.len && contents.len < 10)
		contents_message = "наполовину полон."
	else if(10 <= contents.len && contents.len <= 15)
		contents_message = "полон."
	to_chat(user, "Ящик на вид [contents_message]")

/obj/item/weapon/wooden_box/atom_init(mapload, items_to_store)
	. = ..()
	if(!items_to_store)
		items_to_store = list()
	if(startswith)
		items_to_store += startswith

	for(var/Thing in items_to_store)
		if(isobj(Thing))
			var/obj/Item = Thing
			Item.forceMove(src)
		else
			new Thing(src)

	var/obj/item/Item_for_picture = pick(contents)
	name += " of [Item_for_picture.name]"
	if(Item_for_picture)
		var/icon/cut_icon = icon(icon, "wooden_box_itemmask")
		Picture = icon(icon = Item_for_picture.icon, icon_state = Item_for_picture.icon_state)
		Picture.Turn(90)
		Picture.Scale(32, 24)
		Picture.Shift(1, 8)
		Picture.Blend(cut_icon, ICON_ADD, 1, 1)
		add_overlay(Picture)


/obj/item/weapon/wooden_box/Destroy()
	cut_overlays()
	qdel(Picture)
	var/turf/T = get_turf(src)
	for(var/atom/movable/M in contents)
		M.forceMove(T)
		M.pixel_x = rand(-5, 5)
		M.pixel_y = rand(-5, 5)
	new /obj/item/stack/sheet/wood(T, 2)
	..()

/obj/item/weapon/wooden_box/attack_self(mob/user)
	to_chat(user, "<span class='notice'>Нужна монтировка чтобы вскрыть!</span>")
	return

/obj/item/weapon/wooden_box/attackby(obj/item/weapon/W, mob/user)
	if(isprying(W))
		user.visible_message("<span class='notice'>[user] вскрывает [src].</span>", \
							 "<span class='notice'>Вы вскрываете [src].</span>", \
							 "<span class='notice'>Слышно треск дерева.</span>")
		qdel(src)
	else
		return attack_self(user)

/obj/item/weapon/wooden_box/potato
	name = "A wooden box"
	desc = "Коробка полная картошки на чёрный день."
	startswith = list(
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,
	/obj/item/weapon/reagent_containers/food/snacks/grown/potato,)

/obj/item/weapon/wooden_box/beer
	name = "A wooden box"
	desc = "Коробка с пивом, необычный формат хранения."
	startswith = list(
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,
	/obj/item/weapon/reagent_containers/food/drinks/bottle/beer,)

/obj/item/weapon/wooden_box/banana
	name = "A wooden box"
	desc = "Бонанза - съешь банан, спаси мир!"
	startswith = list(
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
	/obj/item/weapon/reagent_containers/food/snacks/grown/banana,)

/obj/item/wooden_box_pack_placeholder
	name = "A wooden box"
	desc = "Деревянная коробка."
	icon = 'icons/obj/storage.dmi'
	icon_state = "wooden_box_open"

/obj/item/wooden_box_pack_placeholder/atom_init()
	. = ..()
	var/list/to_pack = list()
	for(var/obj/item/I in loc)
		if(I.flags_2 & CANT_BE_INSERTED)
			continue
		if(I.anchored)
			continue
		if(I.w_class >= SIZE_NORMAL)
			continue

		to_pack += I
		if(to_pack.len >= 15)
			break

	if(to_pack.len)
		new /obj/item/weapon/wooden_box(loc, to_pack)
	else
		new /obj/item/stack/sheet/wood(loc, 2)
	qdel(src)

/obj/item/box_pack_placeholder
	name = "A box"
	desc = "Коробка."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box"

/obj/item/box_pack_placeholder/atom_init()
	. = ..()
	var/obj/item/weapon/storage/box/Box = new /obj/item/weapon/storage/box(loc)
	for(var/obj/item/I in loc)
		if(I.flags_2 & CANT_BE_INSERTED)
			continue
		if(I.anchored)
			continue
		if(I.w_class >= SIZE_NORMAL)
			continue
		if(!Box.can_be_inserted(I, TRUE))
			break

		I.forceMove(Box)

	qdel(src)
