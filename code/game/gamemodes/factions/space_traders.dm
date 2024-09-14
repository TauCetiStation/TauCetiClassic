/obj/effect/landmark/space_traders/product
	name = "Space Traders Product"
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"

/obj/effect/landmark/space_traders/dealer
	name = "Space Trader Dealer"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Quartermaster"

/obj/effect/landmark/space_traders/guard
	name = "Space Trader Guard"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Blueshield Officer"

/obj/effect/landmark/space_traders/porter
	name = "Space Trader Porter"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Trader Porter"

/datum/faction/space_traders
	name = F_SPACE_TRADERS
	ID = F_SPACE_TRADERS

	logo_state = "space_traders"
	max_roles = 3
	roletype = /datum/role/space_trader

/datum/faction/space_traders/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/make_money/faction/traders)
	return TRUE
