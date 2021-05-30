/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
//Might want to move this into several files later but for now it works here
/obj/item/borg/stun
	name = "electrified arm"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/borg/stun/attack(mob/living/M, mob/living/silicon/robot/user)
	M.log_combat(user, "stunned with [name]")
	playsound(src, 'sound/machines/defib_zap.ogg', VOL_EFFECTS_MASTER)

	user.cell.charge -= 30

	M.Weaken(5)
	if (M.stuttering < 5)
		M.stuttering = 5
	M.Stun(5)


	M.visible_message("<span class='warning'><B>[user] has prodded [M] with an electrically-charged arm!</B></span>", blind_message = "<span class='warning'>You hear someone fall</span>")

/obj/item/borg/overdrive
	name = "overdrive"
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	var/sight_mode = null


/obj/item/borg/sight/xray
	name = "x-ray Vision"
	sight_mode = BORGXRAY


/obj/item/borg/sight/thermal
	name = "thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"
	icon = 'icons/obj/clothing/glasses.dmi'


/obj/item/borg/sight/meson
	name = "meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"
	icon = 'icons/obj/clothing/glasses.dmi'

/obj/item/borg/sight/night
	name = "night vision"
	sight_mode = BORGNIGHT
	icon_state = "night"
	icon = 'icons/obj/clothing/glasses.dmi'
