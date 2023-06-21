////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	w_class = SIZE_MINUSCULE
	volume = 5

/obj/item/weapon/reagent_containers/dropper/afterattack(atom/target, mob/user, proximity, params)
	. = ..()

////////////////////////////////////////////////////////////////////////////////
/// Pipette
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/dropper/precision
	name = "pipette"
	desc = "A high precision pippette. Holds 1 unit."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pipette"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
	volume = 1
