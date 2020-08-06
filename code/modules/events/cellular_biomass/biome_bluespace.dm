/obj/effect/cellular_biomass_controller/bluespace
	living_grow_chance = 10 //more then average enemies amount
	core_grow_chance = 4
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
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'

/obj/structure/cellular_biomass/grass/bluespace
	health = 100
	name = "Glitch"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'

/obj/structure/cellular_biomass/lair/bluespace
	health = 100
	name = "Glitch"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'

/obj/structure/cellular_biomass/core/bluespace
	name = "Glitch"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'
	light_color = "#00ffff"

/obj/effect/decal/cleanable/cellular/bluespace
	name = "Glitch"
	desc = "Absolutely ma+(AUSC++)AS)ICJQWDP"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'
	icon_state = "decal_1"
	random_icon_states = list("decal_1", "decal_2", "decal_3", "decal_4", "decal_5")

/obj/structure/cellular_biomass/wall/bluespace/atom_init()
	. = ..()
	icon_state = "bluewall_1"
	desc = get_bluespace_scramble()

/obj/structure/cellular_biomass/grass/bluespace/atom_init()
	. = ..()
	icon_state = "bluegrass_1"
	desc = get_bluespace_scramble()

/obj/structure/cellular_biomass/core/bluespace/atom_init()
	. = ..()
	icon_state = "light_1"
	desc = get_bluespace_scramble()

/obj/structure/cellular_biomass/lair/bluespace/atom_init()
	var/type = pick(subtypesof(/mob/living/simple_animal/hostile/cellular/bluespace))
	new type(loc)
	..()
	return INITIALIZE_HINT_QDEL // glitches are self-replicating, no need for lair

/obj/effect/decal/cleanable/bluespace
	name = "Glitch"
	desc = "(W#_F(AWI_+AIGgggg"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("decal_1", "decal_2", "decal_3", "decal_4", "decal_5")

/mob/living/simple_animal/hostile/cellular/bluespace
	name = "Moving Glitch"
	desc = "It's impossible to deEF*E((F((F(CVP"
	icon = 'icons/obj/structures/cellular_biomass/bluespace_cellular.dmi'
	speak_emote = list("buzzing")
	attacktext = "discharg"
	attack_sound = list('sound/weapons/blaster.ogg')
	faction = "bluespace"
	health = 32
	maxHealth = 32
	melee_damage = 8
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
	if(health>2)
		visible_message("<b>[src]</b> duplicates!")
		var/mob/living/simple_animal/newglitch = new /mob/living/simple_animal/hostile/cellular/bluespace/meelee(src.loc)
		health = health / 2
		newglitch.health = health
	return

/mob/living/simple_animal/hostile/cellular/bluespace/ranged/attackby(obj/item/weapon/W, mob/user)
	if(health > 2)
		visible_message("<b>[src]</b> duplicates!")
		var/mob/living/simple_animal/newglitch = new /mob/living/simple_animal/hostile/cellular/bluespace/ranged(src.loc)
		health = health / 2
		newglitch.health = health
	return
