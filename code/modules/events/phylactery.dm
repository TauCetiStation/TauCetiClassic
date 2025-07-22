
/obj/item/weapon/phylactery
	name = "Phylactery E.G.G."
	desc = "Высокотехнологичное устройство, поддерживающее жизнь связанного с ним существа. Выглядит, как яйцо. Сзади надпись - НЕ БРОСАТЬ."
	icon = 'icons/holidays/event.dmi'
	icon_state = "phylactery"
	item_state = "egg-mime"
	w_class = SIZE_NORMAL
	var/mob/living/carbon/human/egg_master
	var/egg_health = 100

/obj/item/weapon/phylactery/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/phylactery/process()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/env = T.return_air()
	if(env && (env.temperature < 200 || env.temperature > 375))
		if(prob(30))
			visible_message("<span class='danger'>Филактерия недовольно пищит! На экране мигает значек температуры.</span>")
		egg_health -= 5
		update_egg_health()

/obj/item/weapon/phylactery/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	visible_message("<span class='danger'>Филактерия получает сильный урон!</span>")
	egg_health -= 50
	update_egg_health()

/obj/item/weapon/phylactery/attackby(obj/item/O, mob/user)
	if (!O || !user) return
	if(O.force && O.force >= 5)
		visible_message("<span class='danger'>[user] attacks [src] with [O].</span>")
		egg_health -= 10
		update_egg_health()
		user.SetNextMove(CLICK_CD_MELEE)
	return ..()

/obj/item/weapon/phylactery/proc/update_egg_health()
	update_icon()
	if(egg_health <= 0)
		egg_break()

/obj/item/weapon/phylactery/update_icon()
	if(egg_health > 70)
		icon_state = "phylactery"
	else if(egg_health > 35)
		icon_state = "phylactery_damaged"
	else
		icon_state = "phylactery_badlydamaged"

/obj/item/weapon/phylactery/proc/egg_break()
	new /obj/effect/decal/remains/robot(loc)
	playsound(src, 'sound/effects/ghost.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
	if(egg_master)
		visible_message("<span class='danger'>Филактерия [egg_master.real_name] разбивается вдребезги!</span>")
		to_chat(egg_master, "<span class='danger'>Вы чувствуете, словно вас разрывает изнутри!</span>")
		egg_master.phylactery_egg = null
		egg_master.gib() //rip
		egg_master = null
	qdel(src)

/obj/item/weapon/phylactery/proc/egg_link(mob/living/carbon/human/H)
	if(ishuman(H))
		egg_master = H
		H.phylactery_egg = src
		// immune to damage
		H.mob_brute_mod.ModMultiplicative(0, src)
		H.mob_burn_mod.ModMultiplicative(0, src)
		H.mob_oxy_mod.ModMultiplicative(0, src)
		H.mob_tox_mod.ModMultiplicative(0, src)
		H.mob_clone_mod.ModMultiplicative(0, src)
		name = "Phylactery E.G.G. - [H.real_name]"
		to_chat(egg_master, "<span class='userdanger'><B>Внимание:</B> Активирована система Филактерия Я.Й.Ц.О.</span>")
		to_chat(egg_master, "<span class='notice'>Пока яйцо в порядке, вы неуязвимы. Но как только оно разобьется, вы сразу умрете. Будьте с ним осторожны! Оно довольно хрупкое. Ломается при особо низких температурах!</span>")

/obj/item/weapon/phylactery/Destroy()
	. = ..()
	if(egg_master)
		to_chat(egg_master, "<span class='danger'>Вы чувствуете, словно вас разрывает изнутри!</span>")
		egg_master.phylactery_egg = null
		egg_master.gib()
		egg_master = null
