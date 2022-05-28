/obj/structure/closet/crate/miningcar/grecka
	icon_state = "grecka"
	icon_opened = "greckaopen"
	icon_closed = "grecka"
	name = "Великий Артефакт Древних"
	desc = "Спасибо Древним за великое наследие."

/obj/structure/closet/crate/miningcar/grecka/open()
	..()
	new/obj/item/weapon/reagent_containers/food/snacks/grown/grecka(loc)



/obj/item/shakal_skull
	name = "Проклятый Череп Шакала"
	desc = "Не трогай его"
	icon = 'icons/obj/items.dmi'
	icon_state = "skull_shakal"
	item_state = ""

/obj/item/shakal_skull/pickup(mob/user)
	..()
	playsound(user, 'sound/Event/cursed.ogg', VOL_EFFECTS_MASTER)
	user.add_filter("ШАКАЛ",1,angular_blur_filter(1,1,7))

/obj/item/clover
	name = "Трехлистный клевер"
	desc = "Красивое, но совершенно бесполезное растение"
	icon = 'icons/obj/Events/lootbox.dmi'
	icon_state = "clover"
	w_class = SIZE_TINY

/obj/item/clover/lucky
	name = "Четырехлистный клевер удачи"
	desc = "Увеличивает удачу носителя"
	icon_state = "clover4"

/obj/item/weapon/shield/magical_shit
	name = "Зеркальный щит"
	desc = "Отражает снаряды. Попробуй превратить злобоглаза в курицу."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "magical_shit"
	force = 5.0
	throw_speed = 1
	throw_range = 2
	attack_verb = list("shoved", "bashed")
	block_chance = 40
	w_class = SIZE_NORMAL

//100 percent chance to block ANY projectile.
/obj/item/weapon/shield/magical_shit/IsReflect(def_zone, hol_dir, hit_dir)
	if(prob(100) && is_the_opposite_dir(hol_dir, hit_dir))
		return TRUE
	return FALSE


/obj/item/weapon/reagent_containers/glass/replenishing/vodka
	name = "Бездонная склянка не-Ртути"
	desc = "Че реально вечная?"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "unlim"
	item_state = "unlim"
	spawning_id = "vodka"
	flags = OPENCONTAINER

/obj/item/weapon/reagent_containers/glass/replenishing/vodka/update_icon()
	cut_overlays()
	if (!is_open_container())
		var/image/lid = image(icon, src, "lid_unlim")
		add_overlay(lid)

/obj/item/weapon/reagent_containers/glass/replenishing/vodka/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	spawning_id = "vodka"
