/obj/item/weapon/storage/hidden_cache
	storage_slots = 1
	max_w_class = SIZE_SMALL

	var/particles/interaction_particle
	var/interaction_time = 1 SECONDS

/obj/item/weapon/storage/hidden_cache/try_open(mob/user, check_only = FALSE)
	if(!user)
		return FALSE

	if(!user.in_interaction_vicinity(src))
		return FALSE

	if(user.is_busy())
		return FALSE

	user.visible_message("<span class='danger'>[user] возится с [CASE(loc, ABLATIVE_CASE)]...</span>")

	if(length(use_sound))
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, FALSE, null, -5)

	var/obj/effect/abstract/particle_holder/Holder
	if(interaction_particle)
		Holder = new /obj/effect/abstract/particle_holder(loc, interaction_particle, PARTICLE_FADEOUT)

	if(!do_after(user, interaction_time, target = loc))
		Holder.delete_particle()
		return

	QDEL_NULL(Holder)

	open(user)
	return TRUE

/obj/item/weapon/storage/hidden_cache/toilet
	name = "бачок унитаза"
	cases = list("бачок унитаза", "бачка унитаза", "бачку унитаза", "бачок унитаза", "бачком унитаза", "бачке унитаза")
	interaction_particle = /particles/tool/digging/watersplash
	interaction_time = 0.5 SECOND

/obj/item/weapon/storage/hidden_cache/toilet/atom_init()
	. = ..()

	use_sound = SOUNDIN_WATER_DEEP

/obj/item/weapon/storage/hidden_cache/toilet/try_open(mob/user, check_only = FALSE)
	var/obj/structure/toilet/toilet = loc
	if(!toilet.cistern_open)
		return FALSE

	return ..()

/obj/item/weapon/storage/hidden_cache/flowerpot
	name = "горшок"
	cases = list("горшок", "горшка", "горшку", "горшок", "горшком", "горшке")
	interaction_particle = /particles/tool/digging/flowerpot
	interaction_time = 3 SECONDS
	max_w_class = SIZE_TINY

/obj/item/weapon/storage/hidden_cache/flowerpot/atom_init()
	. = ..()

	use_sound = SOUNDIN_RAKE

/obj/item/weapon/storage/hidden_cache/vending
	name = "отсек выдачи"
	cases = list("отсек выдачи", "отсека выдачи", "отсеку выдачи", "отсек выдачи", "отсеком выдачи", "отсеке выдачи")
	use_sound = list('sound/items/surgery_tray_use.ogg')
	max_w_class = SIZE_SMALL

/obj/item/weapon/storage/hidden_cache/mirror
	name = "место за зеркалом"
	cases = list("место за зеркалом", "места за зеркалом", "месту за зеркалом", "место за зеркалом", "местом за зеркалом", "месте за зеркалом")
	use_sound = list('sound/items/Crowbar.ogg')
	max_w_class = SIZE_MINUSCULE

/obj/item/weapon/storage/hidden_cache/pillow
	name = "подушка"
	cases = list("подушка", "подушки", "подушке", "подушку", "подушкой", "подушке")
	max_w_class = SIZE_TINY

/obj/item/weapon/storage/hidden_cache/fancytable
	name = "место под скатертью"
	cases = list("место под скатертью", "места под скатертью", "месту под скатертью", "место под скатертью", "местом под скатертью", "месте под скатертью")
	max_w_class = SIZE_SMALL
