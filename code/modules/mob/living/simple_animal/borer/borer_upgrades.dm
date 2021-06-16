#define COST_INITIAL 0

/obj/effect/proc_holder/borer
    panel = "Borer"
    desc = ""

    var/cost = COST_INITIAL

/obj/effect/proc_holder/borer/proc/on_gain(mob/user)
    return

/obj/effect/proc_holder/borer/proc/on_lose(mob/user)
    return

/obj/effect/proc_holder/borer/proc/can_use(mob/user)
    return FALSE

/obj/effect/proc_holder/borer/proc/can_activate(mob/user)
    return can_use(user)

/obj/effect/proc_holder/borer/proc/activate(mob/user)
    return 

/obj/effect/proc_holder/borer/proc/get_stat_entry()
    return null

/obj/effect/proc_holder/borer/Click()
    if(!can_activate(usr))
        return
    activate()

/obj/effect/proc_holder/borer/active
    var/cooldown = 0
    var/last_used = 0
    var/chemicals = 0

/obj/effect/proc_holder/borer/active/get_stat_entry()
    var/cooldown_str = cooldown ? "([get_recharge() / 10]/[cooldown]) " : null
    var/chemical_str = chemicals ? "([chemicals] c.)" : null
    return "[cooldown_str][chemical_str]"

/obj/effect/proc_holder/borer/active/proc/get_recharge()
    return clamp(world.time - last_used, 0, cooldown)

/obj/effect/proc_holder/borer/active/can_activate(mob/user)
    var/mob/living/simple_animal/borer/B = user?.get_borer()
    if(!B)
        return FALSE
    return can_use(user) && get_recharge() >= cooldown && B.hasChemicals(chemicals)

/obj/effect/proc_holder/borer/active/activate(mob/user)
    last_used = world.time
    var/mob/living/simple_animal/borer/B = user?.get_borer()
    if(!B)
        return
    B.adjustChemicals(-chemicals)


/obj/effect/proc_holder/borer/active/noncontrol/can_use(mob/user)
    return user && user == user.get_borer()

/obj/effect/proc_holder/borer/active/control/can_use(mob/user)
    return user && user != user.get_borer()
