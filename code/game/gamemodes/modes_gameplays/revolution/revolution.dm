/obj/item/weapon/revhead_converter
	name = "Suspicious item"
	desc = "Don't touch this!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pipette1"

/obj/item/weapon/revhead_converter/attack(mob/living/carbon/human/H, mob/living/user, def_zone)
	if(!H)
		return
	var/datum/mind/D = H.mind
	if(!D)
		return
	var/datum/role/rev/R = D.GetRole(REV)
	if(R)
		var/datum/role/rev_leader/leader_role = create_and_setup_role(/datum/role/rev_leader, H, setup_role = FALSE)
		R.faction.HandleRecruitedRole(leader_role)
		R.RemoveFromRole(D)
		setup_role(leader_role)
		qdel(src)
