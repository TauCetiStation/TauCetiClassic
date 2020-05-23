/*
	Dear ninja gloves

	This isn't because I like you
	this is because your father is a bastard

	...
	I guess you're a little cool.
	 -Sayu
*/

/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	var/draining = FALSE
	var/candrain = FALSE
	var/mindrain = 200
	var/maxdrain = 400
	species_restricted = null

var/global/list/drain_atoms = list(
	/mob/living/silicon/robot,
	/obj/machinery/power/apc,
	/obj/structure/cable,
	/obj/machinery/power/smes,
	/obj/mecha,
	/obj/machinery/computer/rdconsole
)

/*
	This runs the gamut of what ninja gloves can do
	The other option would be a dedicated ninja touch bullshit proc on everything
	which would probably more efficient, but ninjas are pretty rare.
	This was mostly introduced to keep ninja code from contaminating other code;
	with this in place it would be easier to untangle the rest of it.

	For the drain proc, see events/ninja.dm
*/
/obj/item/clothing/gloves/space_ninja/Touch(mob/living/carbon/human/attacker, atom/A, proximity)
	if(!candrain || draining || isturf(A) || !proximity)
		return FALSE

	var/mob/living/carbon/human/H = attacker

	if(!istype(H))
		return FALSE // what

	var/obj/item/clothing/suit/space/space_ninja/suit = H.wear_suit

	if(!istype(suit))
		return FALSE

	// Move an AI into and out of things
	if(isAI(A))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("AICORE", "NINJASUIT", A, H)
			return TRUE
		else
			to_chat(H, "<span class='warning'><b>ERROR</b>:</span> Remote access channel disabled.")
			return FALSE

	if(istype(A, /obj/structure/AIcore/deactivated))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("INACTIVE", "NINJASUIT", A, H)
			return TRUE
		else
			to_chat(H, "<span class='warning'><b>ERROR</b>:</span> Remote access channel disabled.")
			return FALSE

	if(istype(A, /obj/machinery/computer/aifixer))
		if(suit.s_control)
			A.add_fingerprint(H)
			suit.transfer_ai("AIFIXER", "NINJASUIT", A, H)
			return TRUE
		else
			to_chat(H, "<span class='warning'><b>ERROR</b>:</span> Remote access channel disabled.")
			return FALSE

	if (is_type_in_list(A, global.drain_atoms))
		A.add_fingerprint(H)
		drain(A, suit)
		return TRUE

	if(istype(A, /obj/structure/grille))
		var/obj/structure/cable/C = locate() in A.loc
		if(C)
			drain(C, suit)
		return TRUE

	if(istype(A, /obj/machinery/r_n_d/server))
		A.add_fingerprint(H)
		var/obj/machinery/r_n_d/server/S = A

		if(S.disabled)
			return TRUE
		if(S.shocked)
			S.shock(H, 50)
			return TRUE

		drain(A, suit)
		return TRUE

	return FALSE
