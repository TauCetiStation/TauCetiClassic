/mob/living/simple_animal/hostile/gorgona
	name = "Горгона"
	desc = "Не нужно ждать доброго от коровы с каменной кожей."
	icon_state = "gorgona"
	icon_dead = "gorgona_dead"
	speak = list("МУУУУ")
	speak_emote = list("мычит")
	faction = "tataliya"
	speak_chance = 10
	turns_per_move = 4
	speed = 3
	see_in_dark = 6
	maxHealth = 100
	health = 100
	melee_damage = 10
	attacktext = "бодает"
	attack_sound = list('sound/voice/cowmoos.ogg')
	var/icon/imageToCopy
	var/datum/reagents/gorgona_udder = null

/mob/living/simple_animal/hostile/gorgona/atom_init()
	gorgona_udder = new(50)
	gorgona_udder.add_reagent("milk", 50)
	gorgona_udder.my_atom = src
	. = ..()

/mob/living/simple_animal/hostile/gorgona/Destroy()
	QDEL_NULL(gorgona_udder)
	return ..()

/obj/structure/gorgona_victim
	name = ""
	desc = ""

/mob/living/simple_animal/hostile/gorgona/AttackingTarget()
	..()
	if(prob(5))
		var/mob/living/L = target
		var/obj/structure/gorgona_victim/V = new/obj/structure/gorgona_victim(L.loc)
		V.icon = L.icon
		V.icon_state = L.icon_state
		V.appearance = L.appearance
		V.layer = L.layer
		V.plane = L.plane
		V.color = list(0.33, 0.33, 0.33, 0, 0.59, 0.59, 0.59, 0, 0.11, 0.11, 0.11, 0, 0,    0,    0,    1, 0,    0,    0,    0)
		V.name = "Жертва Горгоны"
		V.desc = "Это существо не знало или забыло, то что горгоны могут превращать взглядом в камень.."
		L.death()
		qdel(L)

/mob/living/simple_animal/hostile/gorgona/attackby(obj/item/O, mob/user)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		user.visible_message("<span class='notice'>[user] ДОЕТ ГОРГОНУ. НАДЕЮСЬ ЕМУ ХОТЯ БЫ НРАВИТСЯ \the [O].</span>")
		var/obj/item/weapon/reagent_containers/glass/G = O
		var/transfered = gorgona_udder.trans_id_to(G, "milk", rand(5,10))
		if(G.reagents.total_volume >= G.volume)
			to_chat(user, "<span class='warning'>[O] заполнено молоком.</span>")
		if(!transfered)
			to_chat(user, "<span class='warning'> No milk?</span>")
	else
		..()
