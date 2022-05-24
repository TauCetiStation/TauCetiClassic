/obj/item/lootbox
	name = "Волшебный сундучок"
	desc = "Открыв его, вы получаете один из множества полезных призов!"
	icon = 'icons/obj/homm.dmi'
	icon_state = "lootbox"
	w_class = SIZE_TINY
	var/isbusy = 0

/obj/item/lootbox/attack_self(mob/user)
	if(!isbusy) // cant open the box if we are already opening it
		isbusy = TRUE
		playsound(src, 'sound/effects/lootbox.ogg', 200)
		user.visible_message("<span class='notice'>[user] пытается открыть [src]!</span>")
		if(do_after(user, 30, target = src)) // progress bar
			// chance you get something good goes up if we have a clover
			var/outcome_modifier = 0
			if(ishuman(user))
				var/mob/living/carbon/human/HU = user
				for(var/obj/item/clover/lucky/CL in HU.contents)
					outcome_modifier = 4 + outcome_modifier/2 // first clover is 4, second is 6, third is 7... and so on
			if(prob(40+(outcome_modifier*11))) // 40% (or 84% if u have a clover)
			// GOOD STUFF
				//клевер
				if(prob(1+(outcome_modifier/4))) //1% or 2%
					var/obj/item/clover/C = new /obj/item/clover (get_turf(user))
					new /obj/effect/effect/luck(get_turf(user))
					user.put_in_hands(C)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [C.name]!</span>")

				//мазь от проклятия Бехолдера
				else if(prob(2+(outcome_modifier/2))) //2% or 4%
					var/obj/item/uncurs_ointment/O = new /obj/item/uncurs_ointment(get_turf(user))
					new /obj/effect/effect/luck(get_turf(user))
					user.put_in_hands(O)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [O.name]!</span>")

				//лошадь
				else if(prob(2+(outcome_modifier/2))) //2% or 4%
					var/obj/vehicle/space/spacebike/horse/H = new /obj/vehicle/space/spacebike/horse(get_turf(user))
					new /obj/effect/effect/luck(get_turf(user))
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [H.name]!</span>")
				//золотая монета
				else if(prob(6+(outcome_modifier*2))) //6% or 14%
					var/obj/item/stack/money/gold/GO = new /obj/item/stack/money/gold (get_turf(user))
					new /obj/effect/effect/luck(get_turf(user))
					user.put_in_hands(GO)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [GO.name]!</span>")
				//серебрянная монета
				else if(prob(15+(outcome_modifier))) //15% or 19%
					var/obj/item/stack/money/silver/SI = new /obj/item/stack/money/silver (get_turf(user))
					playsound(src, 'sound/effects/chest.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
					user.put_in_hands(SI)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [SI.name]!</span>")
				//оружие или броня
				else if(prob(20+(outcome_modifier*3))) //20% or 32%
					var/obj/item/I = new /obj/item
					switch(rand(1, 100))
						if(1 to 7)
							I = new /obj/item/clothing/suit/armor/crusader(get_turf(user))
						if(8 to 16)
							I = new /obj/item/clothing/head/helmet/crusader(get_turf(user))
						if(17 to 25)
							I = new /obj/item/clothing/gloves/combat(get_turf(user))
						if(26 to 32)
							I = new /obj/item/weapon/claymore/religion(get_turf(user))
						if(33 to 40)
							I = new /obj/item/weapon/claymore(get_turf(user))
						if(41 to 56)
							I = new /obj/item/weapon/spear(get_turf(user))
						if(56 to 62)
							I = new /obj/item/weapon/crossbow(get_turf(user))
						if(63 to 71)
							I = new /obj/item/weapon/hatchet(get_turf(user))
						if(72 to 74)
							I = new /obj/item/weapon/katana(get_turf(user))
						if(75 to 80)
							I = new /obj/item/clothing/suit/armor/milita(get_turf(user))
						if(81 to 88)
							I = new /obj/item/weapon/shield/buckler(get_turf(user))
						if(89 to 100)
							I = new /obj/item/weapon/arrow/harpoon(get_turf(user))
							new /obj/item/weapon/arrow/harpoon(get_turf(user))
							new /obj/item/weapon/arrow/harpoon(get_turf(user))
							new /obj/item/weapon/arrow/harpoon(get_turf(user))
							new /obj/item/weapon/arrow/harpoon(get_turf(user))
					playsound(src, 'sound/effects/chest.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
					user.put_in_hands(I)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [I.name]!</span>")
				//бронзовая монета
				else if(prob(20)) //20%
					var/obj/item/stack/money/bronz/BR = new /obj/item/stack/money/bronz (get_turf(user))
					playsound(src, 'sound/effects/chest.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
					user.put_in_hands(BR)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [BR.name]!</span>")
				//серебрянная руда
				else if(prob(30)) //30%
					var/obj/item/weapon/ore/silver/SIL = new /obj/item/weapon/ore/silver (get_turf(user))
					playsound(src, 'sound/effects/chest.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
					user.put_in_hands(SIL)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [SIL.name]!</span>")
				//железная руда
				else //
					var/obj/item/weapon/ore/iron/IR = new /obj/item/weapon/ore/iron (get_turf(user))
					playsound(src, 'sound/effects/chest.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
					user.put_in_hands(IR)
					user.visible_message("<span class='notice'>[user] открывает [src], а там... [IR.name]!</span>")
			else
			// Bad stuff
				user.visible_message("<span class='notice'>[user] - лох!</span>")
				playsound(src, 'sound/effects/chest.ogg', VOL_EFFECTS_MASTER, vary = FALSE) // Найти бы страшный звук
			qdel(src)
		else
			isbusy = FALSE
		..()


/obj/effect/effect/luck
	name = "Удача!"
	icon = 'icons/obj/homm64.dmi'
	icon_state = "luck"
	anchored = TRUE
	density = FALSE
	layer = 5
	animate_movement = FALSE

/obj/effect/effect/luck/atom_init()
	. = ..()
	playsound(get_turf(src), 'sound/effects/goodluck.ogg', VOL_EFFECTS_MASTER)
	addtimer(CALLBACK(src, .proc/anim_end), 2 SECONDS)

/obj/effect/effect/luck/proc/anim_end()
	qdel(src)