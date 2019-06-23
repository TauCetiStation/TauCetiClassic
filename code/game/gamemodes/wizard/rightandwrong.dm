//In this file: Summon Magic/Summon Guns/Summon Events

/proc/rightandwrong(summon_type, mob/user) //0 = Summon Guns, 1 = Summon Magic
	var/list/gunslist
	var/list/magiclist
	if(!summon_type)
		gunslist = typecacheof(list(/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile))
	else
		magiclist = list(/obj/effect/proc_holder/spell/targeted/area_teleport/teleport, /obj/effect/proc_holder/spell/targeted/gnomecurse, /obj/effect/proc_holder/spell/targeted/barnyardcurse, /obj/effect/proc_holder/spell/targeted/lighting_shock, /obj/effect/proc_holder/spell/targeted/charge,
	/obj/effect/proc_holder/spell/aoe_turf/conjure/smoke, /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt,
	/obj/effect/proc_holder/spell/in_hand/fireball, /obj/effect/proc_holder/spell/in_hand/tesla, /obj/effect/proc_holder/spell/in_hand/arcane_barrage,
	/obj/effect/proc_holder/spell/aoe_turf/knock, /obj/effect/proc_holder/spell/targeted/mind_transfer, /obj/effect/proc_holder/spell/aoe_turf/repulse,
	/obj/effect/proc_holder/spell/targeted/spacetime_dist, /obj/effect/proc_holder/spell/targeted/summonitem, /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop,
	/obj/effect/proc_holder/spell/targeted/projectile/magic_missile, /obj/effect/proc_holder/spell/targeted/genetic/mutate, /obj/effect/proc_holder/spell/targeted/turf_teleport/blink,
	/obj/effect/proc_holder/spell/targeted/forcewall, /obj/effect/proc_holder/spell/targeted/trigger/blind, /obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, "<B>You summoned [summon_type ? "magic" : "guns"]!</B>")
		message_admins("[key_name_admin(user, 1)] summoned [summon_type ? "magic" : "guns"]!")
		log_game("[key_name(user)] summoned [summon_type ? "magic" : "guns"]!")
	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == DEAD || !H.client || (H.mind && H.mind.special_role == "Wizard")) continue
		if(!summon_type)
			var/randomizeguns = pick(gunslist)
			H.put_in_hands(new randomizeguns(H))
		else
			var/randomizemagic = pick(magiclist)
			H.AddSpell(new randomizemagic(H))
			for(var/obj/effect/proc_holder/spell/S in H.spell_list)
				if(istype(S, randomizemagic))
					S.clothes_req = 0
	if(!summon_type)
		for(var/mob/M in player_list)
			M.playsound_local(null, 'sound/magic/Summon_guns.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
	else
		for(var/mob/M in player_list)
			M.playsound_local(null, 'sound/magic/Summon_Magic.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
