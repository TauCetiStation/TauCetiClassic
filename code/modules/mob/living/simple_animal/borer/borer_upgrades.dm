#define COST_INNATE 0

/obj/effect/proc_holder/borer
    panel = "Borer"
    name = ""
    desc = null

    var/cost = COST_INNATE

    // list of paths that need to be bought before this
    var/list/requires_t = list()
    var/mob/living/simple_animal/borer/holder

/obj/effect/proc_holder/borer/proc/on_gain(mob/user)
    holder = user
    return

/obj/effect/proc_holder/borer/proc/on_lose(mob/user)
    return

/obj/effect/proc_holder/borer/proc/can_use(mob/user)
    return FALSE

/obj/effect/proc_holder/borer/proc/can_activate(mob/user)
    return can_use(user)

/obj/effect/proc_holder/borer/proc/activate()
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
 
/obj/effect/proc_holder/borer/active/can_use(mob/user)
    return TRUE

/obj/effect/proc_holder/borer/active/get_stat_entry()
    var/cooldown_str = cooldown ? "([round(get_recharge() / 10)]/[cooldown / 10]) " : null
    var/chemical_str = chemicals ? "([chemicals] c.)" : null
    return "[cooldown_str][chemical_str]"

/obj/effect/proc_holder/borer/active/proc/get_recharge()
    return clamp(world.time - last_used, 0, cooldown)

/obj/effect/proc_holder/borer/active/can_activate(mob/user)
    var/mob/living/simple_animal/borer/B = user.has_brain_worms()
    if(!B || B != holder)
        return FALSE
    if(get_recharge() < cooldown)
        to_chat(user, "[src] is not ready yet! Wait [(cooldown - get_recharge()) / 10] seconds.")
        return FALSE
    if(!B.hasChemicals(chemicals))
        to_chat(user, "You don't have enough chemicals to use [src]. You need [chemicals - B.chemicals] units more.")
        return FALSE
    return can_use(user)

/obj/effect/proc_holder/borer/active/proc/put_on_cd()
    last_used = world.time

/obj/effect/proc_holder/borer/active/proc/use_chemicals()
    return holder.useChemicals(chemicals)

/obj/effect/proc_holder/borer/active/proc/cd_and_chemicals()
    if(use_chemicals())
        put_on_cd()
        return TRUE
    return FALSE

/obj/effect/proc_holder/borer/active/activate(mob/user)
    return cd_and_chemicals()

/obj/effect/proc_holder/borer/active/noncontrol/can_use(mob/user)
    return holder.host && user == holder

/obj/effect/proc_holder/borer/active/control/can_use(mob/user)
    return holder.controlling && user.has_brain_worms() == holder

/obj/effect/proc_holder/borer/active/hostless/can_use(mob/user)
    return !holder.host && user == holder
