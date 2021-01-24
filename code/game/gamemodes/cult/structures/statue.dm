/obj/structure/cult/statue
	name = "statue"
	icon_state = "shell" // can be shell_glow
	var/health = 1000

/obj/structure/cult/statue/Destroy()
	playsound(src, 'sound/effects/ghost2.ogg', VOL_EFFECTS_MASTER)

	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(10)
	reagents.add_reagent("blood", 10)
	S.set_up(reagents, 20, 0, get_turf(src))
	S.attach(get_turf(src))
	S.color = "#5f0344"
	S.start()

	return ..()

/obj/structure/cult/statue/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	playsound(src, 'sound/effects/digging.ogg', VOL_EFFECTS_MASTER)
	healthcheck()

/obj/structure/cult/statue/attackby(obj/item/weapon/W, mob/user)
	..()
	if(length(W.hitsound))
		playsound(src, pick(W.hitsound), VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/effects/digging.ogg', VOL_EFFECTS_MASTER)
	health -= W.force
	healthcheck()

/obj/structure/cult/statue/attack_hand(mob/living/carbon/human/user)
	user.SetNextMove(CLICK_CD_MELEE)
	user.visible_message("<span class='userdanger'>[user] kicks [src] unsuccessfully.</span>", "<span class='userdanger'>You feel pain of hitting [src] hard with your fist.</span>")
	var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
	BP.take_damage(3, 0, 0, "stone")
	playsound(src, 'sound/effects/digging.ogg', VOL_EFFECTS_MASTER)

/obj/structure/cult/statue/attack_animal(mob/living/simple_animal/user)
	. = ..()
	health -= user.melee_damage

/obj/structure/cult/statue/attack_paw(mob/living/user)
	return attack_hand(user)

/obj/structure/cult/statue/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/structure/cult/statue/capture
	name = "statue of gargoyle"
	icon_state = "gargoyle_glow"

	health = 100
	var/obj/effect/rune/capture_rune

/obj/structure/cult/statue/capture/atom_init(mapload, obj/effect/rune/R)
	. = ..()
	capture_rune = R

/obj/structure/cult/statue/capture/Destroy()
	if(!QDELETED(capture_rune))
		qdel(capture_rune)
	return ..()

/obj/structure/cult/statue/jew
	name = "statue of jew"
	icon_state = "jew" // cant be jew_glow

/obj/structure/cult/statue/gargoyle
	name = "statue of gargoyle"
	icon_state = "gargoyle" // can be gargoyle_glow
