/obj/item/device/occult_scanner
	name = "occult scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "occult_scan"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/scanned_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm

/obj/item/device/occult_scanner/attack_self(mob/user)
	if(!istype(scanned_type, /obj/item/weapon/reagent_containers/food/snacks/ectoplasm))
		scanned_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm
		to_chat(user, "<span class='notice'>You reset the scanned object of the scanner.</span>")

/obj/item/device/occult_scanner/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(user && user.client && H.stat == DEAD)
		user.visible_message("<span class='notice'>[user] scans [H], the air around them humming gently.</span>",
			                 "<span class='notice'>[H] was [pick("possessed", "devoured", "destroyed", "murdered", "captured")] by [pick("Cthulhu", "Mi-Go", "Elder God", "dark spirit", "Outsider", "unknown alien creature")]</span>")
