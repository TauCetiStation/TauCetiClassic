
/obj/item/weapon/implant/maelstrom
	icon_state = "implant_blood"
	icon = 'icons/obj/items.dmi'
	item_action_types = list(/datum/action/item_action/implant/maelstrom)

/obj/item/weapon/implant/maelstrom/atom_init()
	. = ..()
	AddElement(/datum/element/maelstrom)

/datum/action/item_action/implant/maelstrom
	name = "Maelstrom Implant"

/obj/item/weapon/implantcase/maelstrom
	name = "Glass Case- 'Maelstrom'"
	desc = "A case containing an illegal implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/maelstrom/atom_init()
	imp = new /obj/item/weapon/implant/maelstrom(src)
	. = ..()

/obj/item/weapon/implanter/maelstrom/atom_init()
	imp = new /obj/item/weapon/implant/maelstrom(src)
	. = ..()
	update()
