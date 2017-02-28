/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/cooldowntime = 0
	var/max_integrity = 100
	var/obj_integrity = 100
	var/break_message = "<span class='warning'>The structure has been destroyed!</span>"
	var/break_sound = 'sound/hallucinations/veryfar_noise.ogg'

/obj/structure/cult/bullet_act(obj/item/projectile/Proj)
	if((Proj.damage && Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		visible_message("<span class='danger'>[src] was hit by [Proj].</span>")
		take_damage(Proj.damage)

/obj/structure/cult/proc/take_damage(amount)
	obj_integrity -= amount / 2
	if(obj_integrity <= 0)
		playsound(src, break_sound, 50, 1)
		visible_message("[break_message]")
		qdel(src)

/obj/structure/cult/examine(mob/user)
	..()
	var/can_see_cult = iscultist(user) || isobserver(user) || isshade(user)
	if(can_see_cult)
		to_chat(user,"<span class='cult'>It is at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>")
	to_chat(user,"<span class='notice'>\The [src] is [anchored ? "":"not "]secured to the floor.</span>")
	if(can_see_cult && cooldowntime > world.time)
		to_chat(user,"<span class='cult'>The magic in [src] is too weak, it will be ready to use again in [getETA()].</span>")

/obj/structure/cult/attack_animal(mob/living/simple_animal/M)
	M.do_attack_animation(src)
	if(istype(M, /mob/living/simple_animal/construct/builder))
		if(obj_integrity < max_integrity)
			obj_integrity = min(max_integrity, obj_integrity + 5)
			playsound(src, 'sound/items/Welder.ogg', 50, 1)
			M.visible_message("<span class='danger'>[M] repairs \the <b>[src]</b>.</span>", \
				"<span class='cult'>You repair <b>[src]</b>, leaving them at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.</span>")
		else
			to_chat(M,"<span class='cult'>You cannot repair [src], as them are undamaged!</span>")
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		take_damage(M.melee_damage_upper + M.melee_damage_lower)

/obj/structure/cult/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/book/tome) && iscultist(user))
		anchored = !anchored
		to_chat(user,"<span class='notice'>You [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor.</span>")
		if(!anchored)
			icon_state = "[initial(icon_state)]_off"
		else
			icon_state = initial(icon_state)
	else
		playsound(src,'sound/weapons/smash.ogg', 50, 1)
		take_damage(I.force)
		return ..(I, user, params)

/obj/structure/cult/proc/getETA()
	var/time = (cooldowntime - world.time)/600
	var/eta = "[round(time, 1)] minutes"
	if(time <= 1)
		time = (cooldowntime - world.time)*0.1
		eta = "[round(time, 1)] seconds"
	return eta

/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	break_message = "<span class='warning'>The altar shatters, leaving only the wailing of the damned!</span>"

/obj/structure/cult/talisman/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user,"<span class='warning'>You're pretty sure you know exactly what this is used for and you can't seem to touch it.</span>")
		return
	if(!anchored)
		to_chat(user,"<span class='cult'>You need to anchor [src] to the floor with a tome first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user,"<span class='cult'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Zealot's Blindfold","Flask of Unholy Water")
	var/pickedtype
	switch(choice)
		if("Zealot's Blindfold")
			pickedtype = /obj/item/clothing/glasses/cultblind
		if("Flask of Unholy Water")
			pickedtype = /obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater
	if(src && !qdeleted(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		var/obj/item/N = new pickedtype(get_turf(src))
		to_chat(user,"<span class='cult'>You kneel before the altar and your faith is rewarded with an [N]!</span>")


/obj/structure/cult/forge
	name = "Daemon Forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"
	luminosity = 3
	light_color = "#ff0000"
	light_range = 4
	break_message = "<span class='warning'>The force breaks apart into shards with a howling scream!</span>"

/obj/structure/cult/forge/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user,"<span class='warning'>The heat radiating from [src] pushes you back.</span>")
		return
	if(!anchored)
		to_chat(user,"<span class='cult'>You need to anchor [src] to the floor with a tome first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user,"<span class='cult'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Nar-Sien Hardsuit")
	var/pickedtype = list()
	switch(choice)
		if("Shielded Robe")
			pickedtype += /obj/item/clothing/suit/cultrobes/cult_shield
			pickedtype += /obj/item/clothing/head/culthood/alt
		if("Flagellant's Robe")
			pickedtype += /obj/item/clothing/suit/cultrobes/berserker
			pickedtype += /obj/item/clothing/head/culthood/berserkerhood
		if("Nar-Sien Hardsuit")
			pickedtype += /obj/item/clothing/suit/space/cult
			pickedtype += /obj/item/clothing/head/helmet/space/cult
	if(src && !qdeleted(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			var/obj/item/D = new N(get_turf(src))
			to_chat(user,"<span class='cult'>You work the forge as dark knowledge guides your hands, creating [D]!</span>")

var/list/blacklisted_pylon_turfs = typecacheof(list(
	/turf/unsimulated,
	/turf/simulated/floor/engine/cult,
	/turf/space,
	/turf/simulated/wall))

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	luminosity = 5
	light_color = "#ff0000"
	light_range = 4
	break_sound = 'sound/effects/Glassbr2.ogg'
	break_message = "<span class='warning'>The blood-red crystal falls to the floor and shatters!</span>"
	var/heal_delay = 25
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/cult/pylon/New()
	SSobj.processing |= src
	..()

/obj/structure/cult/pylon/Destroy()
	SSobj.processing.Remove(src)
	return ..()

/obj/structure/cult/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || isshade(L))
				if(L.health != L.maxHealth)
					new /obj/effect/overlay/cult/heal(get_turf(src), "#960000")
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						H.adjustBruteLoss(-1, 0)
						H.adjustFireLoss(-1, 0)
						H.shock_stage = max(0, H.shock_stage - 1)
						H.updatehealth()
					if(isshade(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.health++
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/simulated/floor/engine/cult))
				cultturfs |= T
				continue
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			T.ChangeTurf(/turf/simulated/floor/engine/cult)
		else
			var/turf/simulated/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/overlay/cult/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/cult/tome
	name = "Archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	luminosity = 1
	break_message = "<span class='warning'>The books and tomes of the archives burn into ash as the desk shatters!</span>"

/obj/structure/cult/tome/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user,"<span class='warning'>All of these books seem to be gibberish.</span>")
		return
	if(!anchored)
		to_chat(user,"<span class='cult'>You need to anchor [src] to the floor with a tome first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user,"<span class='cult'>The magic in [src] is weak, it will be ready to use again in [getETA()].</span>")
		return
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Supply Talisman","Shuttle Curse","Veil Walker Set")
	var/list/pickedtype = list()
	switch(choice)
		if("Supply Talisman")
			pickedtype += /obj/item/weapon/paper/talisman/supply/weak
		if("Shuttle Curse")
			pickedtype += /obj/item/device/shuttle_curse
		if("Veil Walker Set")
			pickedtype += /obj/item/device/cult_shift
			pickedtype += /obj/item/device/flashlight/culttorch
	if(src && !qdeleted(src) && anchored && pickedtype.len && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			var/obj/item/D = new N(get_turf(src))
			to_chat(user,"<span class='cult'>You summon [D] from the archives!</span>")


/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/gateway/Bumped(mob/M)
	spawn(0)
		return
	return

/obj/effect/gateway/Crossed(AM as mob|obj)
	spawn(0)
		return
	return
