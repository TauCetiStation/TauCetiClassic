/obj/lot_holder
	name = "Lot Holder"
	icon = 'icons/effects/32x32.dmi'
	icon_state = "blank"
	anchored = TRUE

	var/tag_description = ""

/obj/lot_holder/examine(mob/user)
	. = ..()

	to_chat(user, tag_description)

/datum/component/stall_lot
	var/list/Tag
	var/obj/item/Lot_Item
	var/cost
	var/datum/money_account/Seller
	var/obj/structure/table/reinforced/stall/Table
	var/obj/lot_holder/Holder

/datum/component/stall_lot/Initialize(obj/structure/table/reinforced/stall/tbl)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	Lot_Item = parent

	Tag = Lot_Item.price_tag
	cost = Tag["price"]
	Seller = get_account(Tag["account"])

	Table = tbl

	Holder = new(Table.loc)
	Lot_Item.forceMove(Holder)
	Holder.pixel_x = Lot_Item.pixel_x
	Holder.pixel_y = Lot_Item.pixel_y
	Holder.name = Lot_Item.name
	Holder.add_overlay(Lot_Item)
	Holder.tag_description = "Прикреплён ценник. Описание: [Tag["description"]], Цена: [Tag["price"]]$"

	RegisterSignal(Holder, list(COMSIG_PARENT_ATTACKBY), .proc/on_clicked)
	RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), .proc/on_table_destroy)

/datum/component/stall_lot/Destroy()
	Lot_Item.forceMove(Table.loc)
	qdel(Holder)
	return ..()

/datum/component/stall_lot/proc/on_clicked(datum/source, obj/item/I,  mob/living/user)
	Table.visible_message("<span class='info'>[user] прикладывает карту к столу.</span>")
	if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/Card = I
		var/datum/money_account/Buyer = get_account(Card.associated_account_number)

		if(!Buyer)
			return

		var/attempt_pin = 0
		if(Buyer.security_level > 0)
			attempt_pin = input("Введите ПИН-код", "Прилавок") as num
			if(isnull(attempt_pin))
				to_chat(user, "[bicon(Table)]<span class='warning'>Неверный ПИН-код!</span>")
				return
			Buyer = attempt_account_access(Card.associated_account_number, attempt_pin, 2)

		if(cost > 0 && Seller)
			if(Seller.suspended)
				Table.visible_message("[bicon(Table)]<span class='warning'>Подключённый аккаунт заблокирован.</span>")
				return
			if(cost <= Buyer.money)
				charge_to_account(Buyer.account_number, Buyer.owner_name, "Покупка [Lot_Item.name]", "Прилавок", -cost)
				charge_to_account(Seller.account_number, Seller.owner_name, "Прибыль за продажу [Lot_Item.name]", "Прилавок", cost)
			else
				Table.visible_message("[bicon(Table)]<span class='warning'>Недостаточно средств!</span>")
				return

		qdel(src)

/datum/component/stall_lot/proc/on_table_destroy(datum/source, obj/item/I,  mob/living/user, params)
	qdel(src)
