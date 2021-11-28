/mob/living/silicon/robot/drone/syndi
    real_name = "syndicate drone"
    maxHealth = 25
    health = 25
    scrambledcodes = 1
    modtype = "Syndicate"
    faction = "syndicate"
    req_access = list(access_syndicate)
    holder_type = /obj/item/weapon/holder/drone/syndi
    eyes_overlay = "eyes-syndibot"

    var/obj/item/device/drone_uplink/uplink = null
    var/mob/living/carbon/human/operator = null //Mob controlling the drone
    var/datum/mind/operator_mind = null
    var/operator_health_last = null
    var/cooldown = 0

/mob/living/silicon/robot/drone/syndi/atom_init()
	. = ..()
	set_ai_link(null)
	radio = new /obj/item/device/radio/borg/syndicate(src)
	module = new /obj/item/weapon/robot_module/syndidrone(src)
	laws = new /datum/ai_laws/syndicate_override()
	uplink = new /obj/item/device/drone_uplink()

    flavor_text = "It's a tiny little repair drone. The casing is stamped with a Cybersun Ind. and the subscript: 'Cybersun Industries: I will definitely fix it tomorrow!'"

/mob/living/silicon/robot/drone/syndi/Destroy()
    loose_control()
    . = ..()

/mob/living/silicon/robot/drone/syndi/init(laws_type, ai_link, datum/religion/R)
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	laws = new laws_type(R)

/mob/living/silicon/robot/drone/syndi/Life()
    . = ..()
    if(!operator)
        return
    if((operator.stat != CONSCIOUS) || (operator.key != "@[key]"))
        loose_control()
        return
    if(operator.health < operator_health_last)
        to_chat(src, "<span class='warning'>You're getting damage! Secure yourself as soon as possible!</span>")
    if(cooldown)
        cooldown--
    else
        for(var/mob/living/M in range(1, operator))
            if(M != operator)
                to_chat(src, "<span class='notice'>You feel something moving around you.</span>")
                cooldown = 3//in seconds
                break
    operator_health_last = operator.health

/mob/living/silicon/robot/drone/syndi/updatename()
	var/N = rand(100,999)
	real_name = "syndicate drone ([N])"
	name = "suspicious drone ([N])"

/mob/living/silicon/robot/drone/syndi/pick_module()
    uplink.interact(src)

/mob/living/silicon/robot/drone/syndi/proc/control(mob/living/carbon/human/M)
    if(!laws.zeroth)
        set_zeroth_law("Only [M.real_name] and people he designates as being such are Syndicate Agents.")
    operator = M
    operator_mind = M.mind
    operator_health_last = M.health
    cooldown = 5//in seconds
    key = M.key
    M.key = "@[key]"
    to_chat(src, "You're now controlling the [src.name].")

/mob/living/silicon/robot/drone/syndi/proc/loose_control()
    if(!operator)
        return
    if(operator.key == "@[key]")
        operator.key = key
    else
        if(operator_mind && operator_mind.current && operator_mind.key == key)
            operator_mind.current.key = key
        else
            ghostize(FALSE)
    key = null
    to_chat(operator, "You've lost control of the [src.name].")
    operator = null
    operator_mind = null


//========Verbs========
/mob/living/silicon/robot/drone/syndi/verb/stop_control()
    set name = "Stop controling"
    set desc = "Toggles RC off."
    set category = "Drone"

    loose_control()