// fake implants that can mimic real hud

/obj/item/weapon/implant/fake
	name = "organic implant"
	cases = list("органический имплант", "органического импланта", "органическому импланту", "органический имплант", "органическим имплантом", "органическом импланте")
	desc = "Мы не знаем, что это такое."

/obj/item/weapon/implant/fake/eject()
	. = ..()
	if(!QDELING(src))
		qdel(src)

/obj/item/weapon/implant/fake/mindshield
	hud_id = IMPMINDS_HUD
	hud_icon_state = "hud_imp_mindshield"

/obj/item/weapon/implant/fake/loyalty
	hud_id = IMPLOYAL_HUD
	hud_icon_state = "hud_imp_loyal"

/obj/item/weapon/implant/fake/tracking
	hud_id = IMPTRACK_HUD
	hud_icon_state = "hud_imp_tracking"

/obj/item/weapon/implant/fake/chem
	hud_id = IMPCHEM_HUD
	hud_icon_state = "hud_imp_chem"

/obj/item/weapon/implant/fake/obedience
	hud_id = IMPOBED_HUD
	hud_icon_state = "hud_imp_obedience"
