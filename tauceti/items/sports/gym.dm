/obj/structure/pbag
	name = "punching bag"
	desc = "It's made by some goons"

	icon = 'tauceti/items/sports/pbag.dmi'
	icon_state = "pbag"

	density = 0
	anchored = 1

	var/health = 1000

	New()
		//color = pick("#aaffaa", "#aaaaff", "#ff3030", "#ff1010", "#ffffff")
		color = random_color()


	attack_hand(mob/user as mob)
		if(!anchored) return
		hit(user)

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if(prob(50))
					qdel(src)
					return
				else
					down()
			if(3.0)
				swing(rand(10, 50))
				return

	proc/down()
		anchored = 0
		icon_state = "pbagdown"
		playsound(src.loc, 'sound/weapons/tablehit1.ogg', 70, 1, -1)
		return

	proc/hit(mob/user as mob)
		if(health < 0)
			down()
		else
			if(HULK in user.mutations)
				health -= rand(100, 500)
			else
				health -= rand(10, 50)
			playsound(src.loc, "swing_hit", 50, 1, -1)
			swing()

		return

	proc/swing(var/time = rand(5, 20))
		icon_state = "pbaghit"
		spawn(time)
			icon_state = "pbag"

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/weapon/wrench))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
			src.anchored = !src.anchored
			user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
				"You [anchored? "secure":"undo"] the external bolts.", \
				"You hear a ratchet")
			if(anchored)
				icon_state = "pbag"
				health = 1000
			else
				icon_state = "pbagdown"
				health = 0