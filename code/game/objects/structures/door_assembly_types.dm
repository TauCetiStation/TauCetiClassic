/obj/structure/door_assembly/door_assembly_com
	name         = "command airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/command.dmi'
	glass_type   = /obj/machinery/door/airlock/command/glass
	airlock_type = /obj/machinery/door/airlock/command

/obj/structure/door_assembly/door_assembly_sec
	name         = "security airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/security.dmi'
	glass_type   = /obj/machinery/door/airlock/security/glass
	airlock_type = /obj/machinery/door/airlock/security

/obj/structure/door_assembly/door_assembly_eng
	name         = "engineering airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/engineering.dmi'
	glass_type   = /obj/machinery/door/airlock/engineering/glass
	airlock_type = /obj/machinery/door/airlock/engineering

/obj/structure/door_assembly/door_assembly_min
	name         = "mining airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/mining.dmi'
	glass_type   = /obj/machinery/door/airlock/mining/glass
	airlock_type = /obj/machinery/door/airlock/mining

/obj/structure/door_assembly/door_assembly_atmo
	name         = "atmos airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/atmos.dmi'
	glass_type   = /obj/machinery/door/airlock/atmos/glass
	airlock_type = /obj/machinery/door/airlock/atmos

/obj/structure/door_assembly/door_assembly_research
	name         = "research airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/research.dmi'
	glass_type   = /obj/machinery/door/airlock/research/glass
	airlock_type = /obj/machinery/door/airlock/research

/obj/structure/door_assembly/door_assembly_science
	name         = "science airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/science.dmi'
	glass_type   = /obj/machinery/door/airlock/science/glass
	airlock_type = /obj/machinery/door/airlock/science

/obj/structure/door_assembly/door_assembly_med
	name         = "medical airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/medical.dmi'
	glass_type   = /obj/machinery/door/airlock/medical/glass
	airlock_type = /obj/machinery/door/airlock/medical

/obj/structure/door_assembly/door_assembly_viro
	name         = "virology airlock assembly"
	icon         = 'icons/obj/doors/airlocks/station/virology.dmi'
	glass_type   = /obj/machinery/door/airlock/virology/glass
	airlock_type = /obj/machinery/door/airlock/virology

/obj/structure/door_assembly/door_assembly_mai
	name             = "maintenance airlock assembly"
	icon             = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	airlock_type     = /obj/machinery/door/airlock/maintenance

/obj/structure/door_assembly/door_assembly_ext
	name             = "external airlock assembly"
	icon             = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file    = 'icons/obj/doors/airlocks/external/overlays.dmi'
	airlock_type     = /obj/machinery/door/airlock/external
	can_insert_glass = FALSE

/obj/structure/door_assembly/door_assembly_fre
	name             = "freezer airlock assembly"
	icon             = 'icons/obj/doors/airlocks/station/freezer.dmi'
	airlock_type     = /obj/machinery/door/airlock/freezer
	can_insert_glass = FALSE

/obj/structure/door_assembly/door_assembly_hatch
	name             = "hatch airlock assembly"
	icon             = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file    = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	airlock_type     = /obj/machinery/door/airlock/hatch
	can_insert_glass = FALSE

/obj/structure/door_assembly/door_assembly_vault
	name             = "vault door assembly"
	icon             = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file    = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	can_insert_glass = FALSE

/obj/structure/door_assembly/door_assembly_mhatch
	name             = "maintenance hatch airlock assembly"
	icon             = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file    = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	airlock_type     = /obj/machinery/door/airlock/maintenance_hatch
	can_insert_glass = FALSE

/obj/structure/door_assembly/door_assembly_highsecurity
	name             = "highsecurity airlock assembly"
	icon             = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file    = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	airlock_type     = /obj/machinery/door/airlock/highsecurity
	can_insert_glass = FALSE

/obj/structure/door_assembly/multi_tile
	name          = "multi tile airlock assembly"
	icon          = 'icons/obj/doors/airlocks/multi_tile/multi_tile.dmi'
	overlays_file = 'icons/obj/doors/airlocks/multi_tile/overlays.dmi'
	airlock_type  = /obj/machinery/door/airlock/multi_tile/glass

	glass_material   = "glass"
	glass_only       = TRUE
	can_insert_glass = FALSE

/obj/structure/door_assembly/door_assembly_neutral
	name             = "neutral airlock assembly"
	icon             = 'icons/obj/doors/airlocks/station/neutral.dmi'
	airlock_type     = /obj/machinery/door/airlock/neutral
	can_insert_glass = FALSE