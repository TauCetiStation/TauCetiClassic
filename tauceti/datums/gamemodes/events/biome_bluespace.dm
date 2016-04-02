/obj/effect/cellular_biomass_controller/bluespace
	living_grow_chance = 8 //more then average enemies amount
	walls_type =     /obj/structure/cellular_biomass/wall/bluespace
	insides_type =   /obj/structure/cellular_biomass/grass/bluespace
	living_type =     /obj/structure/cellular_biomass/lair/bluespace
	landmarks_type = /obj/effect/decal/cleanable/cellular/bluespace
	cores_type =     /obj/structure/cellular_biomass/core/bluespace

/obj/structure/cellular_biomass/proc/get_bluespace_scramble()
	var/text = pick("You cant' d", "This is abso", "The only way to s")
	var/glitch = pick("2-803hff0icE", "2w34gua=w0-FFOF", "x0c90dd0odoi", "(W#_F(AWI_+AIGgggg")
	return "[text][glitch]"


/obj/structure/cellular_biomass/wall/bluespace
	health = 100
	name = "Glitch"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'

/obj/structure/cellular_biomass/grass/bluespace
	health = 100
	name = "Glitch"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'

/obj/structure/cellular_biomass/lair/bluespace
	health = 100
	name = "Glitch"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'

/obj/structure/cellular_biomass/core/bluespace
	name = "Glitch"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	luminosity = 4
	light_color = "#00FFFF"

/obj/effect/decal/cleanable/cellular/bluespace
	name = "Glitch"
	desc = "Absolutely ma+(AUSC++)AS)ICJQWDP"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	icon_state = "decal_1"
	random_icon_states = list("decal_1", "decal_2", "decal_3", "decal_4", "decal_5")

/obj/effect/cellular_biomass_controller/bluespace/alive()
	if(!growth_queue)
		return 0
	if(!growth_queue.len
		return 0
	return 1

/obj/structure/cellular_biomass/wall/bluespace/New()
	icon_state = "bluewall_1"
	desc = get_bluespace_scramble()

/obj/structure/cellular_biomass/grass/bluespace/New()
	icon_state = "bluegrass_1"
	desc = get_bluespace_scramble()

/obj/structure/cellular_biomass/core/bluespace/New()
	icon_state = "light_1"
	set_light(luminosity)
	desc = get_bluespace_scramble()

/obj/structure/cellular_biomass/lair/bluespace/New()
	var/type = pick(subtypesof(/mob/living/simple_animal/hostile/cellular/bluespace/))
	new type(src.loc)
	qdel(src) //glitches are self-replicating, no need for lair

/obj/effect/decal/cleanable/bluespace
	name = "Glitch"
	desc = "(W#_F(AWI_+AIGgggg"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("decal_1", "decal_2", "decal_3", "decal_4", "decal_5")

/mob/living/simple_animal/hostile/cellular/bluespace/
	name = "Moving Glitch"
	desc = "It's impossible to deEF*E((F((F(CVP"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	speak_emote = list("buzzing")
	attacktext = "discarges"
	attack_sound = 'sound/weapons/blaster.ogg'
	faction = "bluespace"
	health = 25
	maxHealth = 25
	melee_damage_lower = 1
	melee_damage_upper = 15
	speed = 1

/mob/living/simple_animal/hostile/cellular/bluespace/meelee
	icon_state = "bluemob_1"
	icon_living = "bluemob_1"
	icon_dead = "bluemob_1"

/mob/living/simple_animal/hostile/cellular/bluespace/ranged
	icon_state = "bluemob_2"
	icon_living = "bluemob_2"
	icon_dead = "bluemob_2"

/mob/living/simple_animal/hostile/cellular/bluespace/death()
	..()
	visible_message("<b>[src]</b> vanishes!")
	qdel(src)
	return

/mob/living/simple_animal/hostile/cellular/bluespace/meelee/bullet_act()
	visible_message("<b>[src]</b> duplicates!")
	new /mob/living/simple_animal/hostile/cellular/bluespace/meelee(src.loc)
	return

/mob/living/simple_animal/hostile/cellular/bluespace/ranged/attackby(obj/item/weapon/W as obj, mob/user as mob)
	visible_message("<b>[src]</b> duplicates!")
	new /mob/living/simple_animal/hostile/cellular/bluespace/ranged(src.loc)
	return

