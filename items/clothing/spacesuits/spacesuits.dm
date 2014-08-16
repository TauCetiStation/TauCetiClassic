//Модкит для переделки кошачьего инжескафа обратно в людской
/*/obj/item/device/modkit/tajaran_to_human
	name = "human engineering hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Human."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/tajara
	from_suit = /obj/item/clothing/suit/space/rig/tajara
	to_helmet = /obj/item/clothing/suit/space/rig
	to_suit = /obj/item/clothing/suit/space/rig */

// Атмос-риг для кошаков
/obj/item/clothing/head/helmet/space/rig/tajara/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has improved thermal protection and minor radiation shielding. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig0-atmos"
	item_state = "atmos-helm"
	item_color = "atmos"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list("Tajaran")

/obj/item/clothing/suit/space/rig/tajara/atmos
	name = "atmos hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig-atmos"
	item_state = "rig-atmos"
	item_color = "rig-atmos"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 50)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list("Tajaran")

/obj/item/device/modkit/atmos_tajaran
	name = "tajara atmospherics hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajara."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/atmos
	from_suit = /obj/item/clothing/suit/space/rig/atmos
	to_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/atmos
	to_suit = /obj/item/clothing/suit/space/rig/tajara/atmos

/obj/item/device/modkit/atmos_tajaran_to_human
	name = "human atmospherics hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Human."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/atmos
	from_suit = /obj/item/clothing/suit/space/rig/tajara/atmos
	to_helmet = /obj/item/clothing/head/helmet/space/rig/atmos
	to_suit = /obj/item/clothing/suit/space/rig/atmos

//Медриг для кошаков
/obj/item/clothing/head/helmet/space/rig/tajara/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has minor radiation shielding. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	item_color = "medical"
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 50)
	species_restricted = list("Tajaran")

/obj/item/clothing/suit/space/rig/tajara/medical
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has minor radiation shielding. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig-medical"
	item_state = "rig-med"
	item_color = "rig-medical"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 50)
	species_restricted = list("Tajaran")

/obj/item/device/modkit/med_tajaran
	name = "tajara medical hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajara."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/medical
	from_suit = /obj/item/clothing/suit/space/rig/medical
	to_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/medical
	to_suit = /obj/item/clothing/suit/space/rig/tajara/medical

/obj/item/device/modkit/med_tajaran_to_human
	name = "human medical hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Human."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/medical
	from_suit = /obj/item/clothing/suit/space/rig/tajara/medical
	to_helmet = /obj/item/clothing/head/helmet/space/rig/medical
	to_suit = /obj/item/clothing/suit/space/rig/medical

//Щитсекриг для котов
/obj/item/clothing/head/helmet/space/rig/tajara/sec
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has an additional layer of armor. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig0-sec"
	item_state = "sec-helm"
	item_color = "sec"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	siemens_coefficient = 0.7
	species_restricted = list("Tajaran")

/obj/item/clothing/suit/space/rig/tajara/sec
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig-sec"
	item_state = "rig-sec"
	item_color = "rig-sec"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)
	siemens_coefficient = 0.7
	species_restricted = list("Tajaran")

/obj/item/device/modkit/sec_tajaran
	name = "tajara security hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajara."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/security
	from_suit = /obj/item/clothing/suit/space/rig/security
	to_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/sec
	to_suit = /obj/item/clothing/suit/space/rig/tajara/sec

/obj/item/device/modkit/sec_tajaran_to_human
	name = "human security hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Human."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/sec
	from_suit = /obj/item/clothing/suit/space/rig/tajara/sec
	to_helmet = /obj/item/clothing/head/helmet/space/rig/security
	to_suit = /obj/item/clothing/suit/space/rig/security

//Шахтёрный риг для котов
/obj/item/clothing/head/helmet/space/rig/tajara/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has reinforced plating. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig0-mining"
	item_state = "mining-helm"
	item_color = "mining"
	armor = list(melee = 50, bullet = 5, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 20)
	species_restricted = list("Tajaran")

/obj/item/clothing/suit/space/rig/tajara/mining
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating. This one doesn't look like it was made for humans."
	icon = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	tc_custom = 'tauceti/items/clothing/spacesuits/tajaran.dmi'
	icon_state = "rig-mining"
	item_state = "rig-mining"
	item_color = "rig-mining"
	armor = list(melee = 50, bullet = 5, laser = 20,energy = 5, bomb = 55, bio = 100, rad = 20)
	species_restricted = list("Tajaran")

/obj/item/device/modkit/mining_tajaran
	name = "tajara mining hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajara."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/mining
	from_suit = /obj/item/clothing/suit/space/rig/mining
	to_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/mining
	to_suit = /obj/item/clothing/suit/space/rig/tajara/mining

/obj/item/device/modkit/mining_tajaran_to_human
	name = "human mining hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Human."
	from_helmet = /obj/item/clothing/head/helmet/space/rig/tajara/mining
	from_suit = /obj/item/clothing/suit/space/rig/tajara/mining
	to_helmet = /obj/item/clothing/head/helmet/space/rig/mining
	to_suit = /obj/item/clothing/suit/space/rig/mining
