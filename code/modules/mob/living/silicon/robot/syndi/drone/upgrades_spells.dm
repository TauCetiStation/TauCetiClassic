#define POWER_USAGE_MULTIPLIER 100
#define BURN_DAMAGE_CAP 5

/obj/effect/proc_holder/spell/no_target/syndi_drone
    panel = "Drone upgrades"
    desc = ""
    action_icon_state = "drone"
    clothes_req = FALSE

/obj/effect/proc_holder/spell/no_target/syndi_drone/boost
    name = "Maneuverability boost"
    charge_max = 600
    var/duration = 50

/obj/effect/proc_holder/spell/no_target/syndi_drone/boost/cast(list/targets, mob/user)
    if(!istype(user, /mob/living/silicon/robot/drone))
        return

    var/mob/living/silicon/robot/drone/D = user
    var/datum/robot_component/actuator/A = D.get_component("actuator")
    D.speed -= 2
    D.lying = TRUE //for the ability to pass through other mobs
    A.active_usage *= POWER_USAGE_MULTIPLIER
    var/old_overlay = D.eyes_overlay //If you want to add overlays to another effect, you will need to implement some kind of overlays stack.
    D.eyes_overlay = "eyes-syndibot" //Otherwise, they will conflict and cause unexpected overlay changes.
    D.update_icon()
    D.apply_damage(rand(0, BURN_DAMAGE_CAP), BURN)
    var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
    spark_system.set_up(5, 0, D.loc)
    spark_system.start()
    sleep(duration)
    D.apply_damage(rand(0, BURN_DAMAGE_CAP), BURN)
    spark_system.set_up(5, 0, D.loc)
    spark_system.start()
    D.eyes_overlay = old_overlay
    D.update_icon()
    A.active_usage /= POWER_USAGE_MULTIPLIER
    D.speed += 2
    D.lying = FALSE

/obj/effect/proc_holder/spell/no_target/syndi_drone/smoke
    name = "Deploy smokescreen"
    charge_type = "charges"
    charge_max = 3

/obj/effect/proc_holder/spell/no_target/syndi_drone/smoke/cast(list/targets, mob/user)
    var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
    smoke.set_up(10, 0, get_turf(user))
    playsound(user, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
    smoke.start()

#undef POWER_USAGE_MULTIPLIER
#undef BURN_DAMAGE_CAP