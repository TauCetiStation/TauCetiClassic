/mob/living/silicon/robot/drone/syndi
    real_name = "syndicate drone"
    maxHealth = 25
    health = 25
    //emagged = 1
    scrambledcodes = 1
    modtype = "Syndicate"
    faction = "syndicate"
    req_access = list(access_syndicate)
    holder_type = /obj/item/weapon/holder/drone/syndi

    var/points = 10 //internal uplink points for upgrade purchase
    var/mob/living/carbon/human/operator = null //Mob controlling the drone

/mob/living/silicon/robot/drone/syndi/atom_init()
	. = ..()
	set_ai_link(null)
	radio = new /obj/item/device/radio/borg/syndicate(src)
	//module = new /obj/item/weapon/robot_module/___(src)
	laws = new /datum/ai_laws/syndicate_override()

/mob/living/silicon/robot/drone/syndi/init(laws_type, ai_link, datum/religion/R)
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	laws = new laws_type(R)

/mob/living/silicon/robot/drone/syndi/updatename()
	var/N = rand(100,999)
	real_name = "syndicate drone ([N])"
	name = "maintenance drone ([N])"