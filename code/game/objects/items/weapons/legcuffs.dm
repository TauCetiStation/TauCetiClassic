#define LEGCUFF_BREAKTIME_DEFAULT         30 SECONDS
//easy to apply, easy to break out of
#define LEGCUFF_BREAKTIME_BOLA            3.5 SECONDS
#define LEGCUFF_BREAKTIME_REINFORCED_BOLA 7.5 SECONDS

/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = CONDUCT
	throwforce = 0
	w_class = SIZE_SMALL
	origin_tech = "materials=1"
	var/breakouttime = LEGCUFF_BREAKTIME_DEFAULT

/obj/item/weapon/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0

/obj/item/weapon/legcuffs/beartrap/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] is putting the [src.name] on \his head! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS)

/obj/item/weapon/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && user.stat == CONSCIOUS && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		to_chat(user, "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"].</span>")

/obj/item/weapon/legcuffs/beartrap/Crossed(atom/movable/AM)
	. = ..()
	if(armed)
		if(ishuman(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/H = AM
				if(H.m_intent == "run" && !H.buckled && H.equip_to_slot_if_possible(src, SLOT_LEGCUFFED, disable_warning = TRUE))
					armed = 0
					H.visible_message("<span class='danger'>[H] steps on \the [src].</span>",
					                  "<span class='danger'>You step on \the [src]!</span>",
									  "<span class='warning'>You hear the operation of some mechanism.</span>")
					//Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
					feedback_add_details("handcuffs","B")
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !isconstruct(AM) && !isshade(AM) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20

		icon_state = "beartrap[armed]"

/obj/item/weapon/legcuffs/beartrap/armed
	icon_state = "beartrap1"
	armed = TRUE

/obj/item/weapon/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	breakouttime = LEGCUFF_BREAKTIME_BOLA
	origin_tech = "engineering=3;combat=1"
	throw_speed = 4
	var/weaken = 0.8

/obj/item/weapon/legcuffs/bola/after_throw(datum/callback/callback)
	..()
	playsound(src,'sound/weapons/bolathrow.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..()) //if it gets caught or the target can't be cuffed
		return
	if(!isliving(hit_atom))
		return
	var/mob/living/L = hit_atom
	if(!iscarbon(L))
		L.Weaken(weaken)
		qdel(src)
		return
	var/mob/living/carbon/C = L
	if(C.equip_to_slot_if_possible(src, SLOT_LEGCUFFED, disable_warning = TRUE))
		C.visible_message("<span class='danger'>\The [src] ensnares [C]!</span>",
		                "<span class='userdanger'>\The [src] ensnares you!</span>",
						"<span class='notice'>You hear something flying at a very fast speed.</span>")
		feedback_add_details("handcuffs","B")
		C.Weaken(weaken)

//traitor variant
/obj/item/weapon/legcuffs/bola/tactical
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	breakouttime = LEGCUFF_BREAKTIME_REINFORCED_BOLA
	origin_tech = "engineering=4;combat=3"
	weaken = 2
	throw_range = 5
	throw_speed = 5

#undef LEGCUFF_BREAKTIME_DEFAULT
#undef LEGCUFF_BREAKTIME_BOLA
#undef LEGCUFF_BREAKTIME_REINFORCED_BOLA
