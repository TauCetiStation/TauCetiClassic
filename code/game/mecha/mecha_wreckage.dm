///////////////////////////////////
////////  Mecha wreckage   ////////
///////////////////////////////////


/obj/effect/decal/mecha_wreckage
	name = "Exosuit wreckage"
	desc = "Remains of some unfortunate mecha. Completely unrepairable."
	icon = 'icons/mecha/mecha.dmi'
	density = 1
	anchored = 0
	opacity = 0
	var/list/salvage  = list(
		"welder" = list(
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)
	var/salvage_num = 15

/obj/effect/decal/mecha_wreckage/ex_act(severity)
	if(severity == 1)
		qdel(src)
	return

/obj/effect/decal/mecha_wreckage/bullet_act(obj/item/projectile/Proj)
	return

/obj/effect/decal/mecha_wreckage/attackby(obj/item/weapon/W, mob/user)
	var/salvage_with = ""
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.use(3,user))
			salvage_with = "welder"
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
	if(iswirecutter(W))
		salvage_with = "wirecutter"
	if(iscrowbar(W))
		salvage_with = "crowbar"
	if(!salvage_with)
		..()
		return
	if(salvage_num <= 0)
		to_chat(user, "You don't see anything that can be salvaged anymore.")
		return
	var/salvaged = detach_part(salvage_with)
	if(salvaged)
		user.visible_message("[user] salvages [salvaged] from [src]", "You salvaged [salvaged] from [src]")
	else
		to_chat(user, "You failed to salvage anything valuable from [src].")


/obj/effect/decal/mecha_wreckage/proc/detach_part(var/where)
	var/obj/to_salvage = pick(salvage[where])
	if(to_salvage)
		var/obj/salvaged = new to_salvage(get_turf(src))
		salvage[where] -= to_salvage
		salvage[where] += /obj/item/stack/rods
		if(!prob(reliability))
			salvaged.make_old()

		salvage_num--
		return salvaged
	return 0

/obj/effect/decal/mecha_wreckage/gygax
	name = "Gygax wreckage"
	icon_state = "gygax-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/gygax_torso,
			/obj/item/mecha_parts/part/gygax_left_arm,
			/obj/item/mecha_parts/part/gygax_right_arm,
			/obj/item/mecha_parts/part/gygax_left_leg,
			/obj/item/mecha_parts/part/gygax_right_leg,
			/obj/item/mecha_parts/part/gygax_head,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/gygax/targeting,
			/obj/item/weapon/circuitboard/mecha/gygax/peripherals,
			/obj/item/weapon/circuitboard/mecha/gygax/main,
			/obj/item/weapon/stock_parts/scanning_module/adv,
			/obj/item/weapon/stock_parts/capacitor/adv,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/gygax,
			/obj/item/mecha_parts/part/gygax_armour,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/effect/decal/mecha_wreckage/gygax/dark
	name = "Dark Gygax wreckage"
	icon_state = "darkgygax-broken"

/obj/effect/decal/mecha_wreckage/gygax/ultra
	name = "Gygax Ultra wreckage"
	icon_state = "ultra-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/ultra_torso,
			/obj/item/mecha_parts/part/ultra_left_arm,
			/obj/item/mecha_parts/part/ultra_right_arm,
			/obj/item/mecha_parts/part/ultra_left_leg,
			/obj/item/mecha_parts/part/ultra_right_leg,
			/obj/item/mecha_parts/part/ultra_head,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/ultra/targeting,
			/obj/item/weapon/circuitboard/mecha/ultra/peripherals,
			/obj/item/weapon/circuitboard/mecha/ultra/main,
			/obj/item/weapon/stock_parts/capacitor/super,
			/obj/item/weapon/stock_parts/scanning_module/phasic,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/ultra,
			/obj/item/mecha_parts/part/ultra_armour,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/effect/decal/mecha_wreckage/marauder
	name = "Marauder wreckage"
	icon_state = "marauder-broken"

/obj/effect/decal/mecha_wreckage/mauler
	name = "Mauler Wreckage"
	icon_state = "mauler-broken"
	desc = "The syndicate won't be very happy about this..."

/obj/effect/decal/mecha_wreckage/seraph
	name = "Seraph wreckage"
	icon_state = "seraph-broken"

/obj/effect/decal/mecha_wreckage/ripley
	name = "Ripley wreckage"
	icon_state = "ripley-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/ripley_torso,
			/obj/item/mecha_parts/part/ripley_left_arm,
			/obj/item/mecha_parts/part/ripley_right_arm,
			/obj/item/mecha_parts/part/ripley_left_leg,
			/obj/item/mecha_parts/part/ripley_right_leg,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
			/obj/item/weapon/circuitboard/mecha/ripley/main,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/ripley,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/effect/decal/mecha_wreckage/ripley/firefighter
	name = "Firefighter wreckage"
	icon_state = "firefighter-broken"

/obj/effect/decal/mecha_wreckage/ripley/firefighter/atom_init()
	. = ..()
	salvage["crowbar"] += /obj/item/clothing/suit/fire
	salvage["crowbar"] += /obj/item/mecha_parts/chassis/firefighter
	salvage["crowbar"] -= /obj/item/mecha_parts/chassis/ripley

/obj/effect/decal/mecha_wreckage/ripley/deathripley
	name = "Death-Ripley wreckage"
	icon_state = "deathripley-broken"

/obj/effect/decal/mecha_wreckage/honker
	name = "Honker wreckage"
	icon_state = "honker-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/honker_torso,
			/obj/item/mecha_parts/part/honker_left_arm,
			/obj/item/mecha_parts/part/honker_right_arm,
			/obj/item/mecha_parts/part/honker_left_leg,
			/obj/item/mecha_parts/part/honker_right_leg,
			/obj/item/mecha_parts/part/honker_head,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/honker/main,
			/obj/item/weapon/circuitboard/mecha/honker/peripherals,
			/obj/item/weapon/circuitboard/mecha/honker/targeting,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/honker,
			/obj/item/clothing/mask/gas/clown_hat,
			/obj/item/clothing/shoes/clown_shoes,
			/obj/item/weapon/bikehorn,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/effect/decal/mecha_wreckage/durand
	name = "Durand wreckage"
	icon_state = "durand-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/durand_torso,
			/obj/item/mecha_parts/part/durand_left_arm,
			/obj/item/mecha_parts/part/durand_right_arm,
			/obj/item/mecha_parts/part/durand_left_leg,
			/obj/item/mecha_parts/part/durand_right_leg,
			/obj/item/mecha_parts/part/durand_head,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/durand/targeting,
			/obj/item/weapon/circuitboard/mecha/durand/peripherals,
			/obj/item/weapon/circuitboard/mecha/durand/main,
			/obj/item/weapon/stock_parts/capacitor/adv,
			/obj/item/weapon/stock_parts/scanning_module/adv,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/durand,
			/obj/item/mecha_parts/part/durand_armour,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/effect/decal/mecha_wreckage/durand/vindicator
	name = "Vindicator wreckage"
	icon_state = "vindicator-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/vindicator_torso,
			/obj/item/mecha_parts/part/vindicator_left_arm,
			/obj/item/mecha_parts/part/vindicator_right_arm,
			/obj/item/mecha_parts/part/vindicator_left_leg,
			/obj/item/mecha_parts/part/vindicator_right_leg,
			/obj/item/mecha_parts/part/vindicator_head,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/vindicator/targeting,
			/obj/item/weapon/circuitboard/mecha/vindicator/peripherals,
			/obj/item/weapon/circuitboard/mecha/vindicator/main,
			/obj/item/weapon/stock_parts/capacitor/super,
			/obj/item/weapon/stock_parts/scanning_module/phasic,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/vindicator,
			/obj/item/mecha_parts/part/vindicator_armour,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/effect/decal/mecha_wreckage/phazon
	name = "Phazon wreckage"
	icon_state = "phazon-broken"


/obj/effect/decal/mecha_wreckage/odysseus
	name = "Odysseus wreckage"
	icon_state = "odysseus-broken"
	salvage = list(
		"welder" = list(
			/obj/item/mecha_parts/part/odysseus_torso,
			/obj/item/mecha_parts/part/odysseus_head,
			/obj/item/mecha_parts/part/odysseus_left_arm,
			/obj/item/mecha_parts/part/odysseus_right_arm,
			/obj/item/mecha_parts/part/odysseus_left_leg,
			/obj/item/mecha_parts/part/odysseus_right_leg,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/circuitboard/mecha/odysseus/peripherals,
			/obj/item/weapon/circuitboard/mecha/odysseus/main,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/mecha_parts/chassis/odysseus,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)
