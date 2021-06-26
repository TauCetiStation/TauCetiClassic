// HUMAN

#define isabductor(A) (istype(A, /mob/living/carbon/human/abductor))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

// CARBON
#define isxenoqueen(A) (istype(A, /mob/living/carbon/xenomorph/humanoid/queen))

#define isxenodrone(A) (istype(A, /mob/living/carbon/xenomorph/humanoid/drone))

#define isxenosentinel(A) (istype(A, /mob/living/carbon/xenomorph/humanoid/sentinel))

#define isxenohunter(A) (istype(A, /mob/living/carbon/xenomorph/humanoid/hunter))

#define isxenoadult(A) (istype(A, /mob/living/carbon/xenomorph/humanoid))

#define isxenolarva(A) (istype(A, /mob/living/carbon/xenomorph/larva))

#define isfacehugger(A) (istype(A, /mob/living/carbon/xenomorph/facehugger))

#define isxeno(A) (istype(A, /mob/living/carbon/xenomorph))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

#define isslimeadult(A) (istype(A, /mob/living/carbon/slime/adult))

#define isslime(A) (istype(A, /mob/living/carbon/slime))

#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isIAN(A) (istype(A, /mob/living/carbon/ian))

#define iscarbon(A) (istype(A, /mob/living/carbon))

// SILICON

#define isdrone(A) (istype(A, /mob/living/silicon/robot/drone))

#define isrobot(A) (istype(A, /mob/living/silicon/robot))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

#define issilicon(A) (istype(A, /mob/living/silicon))

// LIVING

#define iscorgi(A) (istype(A, /mob/living/simple_animal/corgi))

#define iscrab(A) (istype(A, /mob/living/simple_animal/crab))

#define iscat(A) (istype(A, /mob/living/simple_animal/cat))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define isclown(A) (istype(A, mob/living/simple_animal/hostile/retaliate/clown))

#define isbear(A) (istype(A, /mob/living/simple_animal/hostile/bear))

#define iscarp(A) (istype(A, /mob/living/simple_animal/hostile/carp))

#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isliving(A) (istype(A, /mob/living))

#define isessence(A) (istype(A, /mob/living/parasite/essence))

#define isgod(A) (istype(A, /mob/living/simple_animal/shade/god))

// MOB

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

// ELSE

#define isbodypart(A) (istype(A, /obj/item/organ/external))

#define isbot(A) (istype(A, /obj/machinery/bot))

#define ismachinery(A) (istype(A, /obj/machinery))

// GOONCHAT PORT

#define isatom(A) istype(A, /atom)

#define isclient(A) istype(A, /client)


// ASSEMBLY HELPERS

#define isassembly(O) (istype(O, /obj/item/device/assembly))

#define isigniter(O) (istype(O, /obj/item/device/assembly/igniter))

#define isinfared(O) (istype(O, /obj/item/device/assembly/infra))

#define isprox(O) (istype(O, /obj/item/device/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/device/assembly/signaler))

#define istimer(O) (istype(O, /obj/item/device/assembly/timer))

// TOOLS HELPERS

#define iswrench(A) istype(A, /obj/item/weapon/wrench)

#define iswelder(A) istype(A, /obj/item/weapon/weldingtool)

#define iswirecutter(A) istype(A, /obj/item/weapon/wirecutters)

#define isscrewdriver(A) istype(A, /obj/item/weapon/screwdriver)

#define iscrowbar(A) istype(A, /obj/item/weapon/crowbar)

#define ismultitool(A) istype(A, /obj/item/device/multitool)

#define iscoil(A) istype(A, /obj/item/stack/cable_coil)

// OBJECTS

#define isitem(A) (istype(A, /obj/item))

// ROLES / ANTAG

#define isfaction(A) (istype(A, /datum/faction))

#define isrole(type, H) (H?.mind ? H.mind.GetRole(type) : FALSE)

#define isanyantag(H) (H?.mind && H.mind.antag_roles.len)

#define isabductorsci(H) (H?.mind ? H.mind.GetRole(ABDUCTOR_SCI) : FALSE)

#define isabductoragent(H) (H?.mind ? H.mind.GetRole(ABDUCTOR_AGENT) : FALSE)

#define isshadowling(H) (H?.mind ? H.mind.GetRole(SHADOW) : FALSE)

#define isshadowthrall(H) (H?.mind ? H.mind.GetRole(SHADOW_THRALL) : FALSE)

#define iscultist(mob) (mob && global.cult_religion?.is_member(mob))

#define isvoxraider(H) (H?.mind ? H.mind.GetRole(VOXRAIDER) : FALSE)

#define ischangeling(H) (H?.mind ? H.mind.GetRoleByType(/datum/role/changeling) : FALSE)

#define isanyrev(H) (isrevnothead(H) || isrevhead(H))

#define isrev(H) (H?.mind ? H.mind.GetRole(REV) : FALSE)

#define isrevhead(H) (H?.mind ? H.mind.GetRole(HEADREV) : FALSE)

#define istraitor(H) (H?.mind ? H.mind.GetRole(TRAITOR) : FALSE)

#define iselitesyndie(H) (H?.mind ? H.mind.GetRole(SYNDIESQUADIE) : FALSE)

#define ismalf(H) (H?.mind ? H.mind.GetRole(MALF) : FALSE)

#define isnukeop(H) (H?.mind ? H.mind.GetRole(NUKE_OP) : FALSE)

#define iswizard(H) (H?.mind ? H.mind.GetRole(WIZARD) : FALSE)

#define isdeathsquad(H) (H?.mind ? H.mind.GetRole(DEATHSQUADIE) : FALSE)

#define isninja(H) (H?.mind ? H.mind.GetRole(NINJA) : FALSE)

#define isERT(H) (H?.mind ? H.mind.GetRole(RESPONDER) : FALSE)

#define isrolezombie(H) (H?.mind ? H.mind.GetRole(ZOMBIE) : FALSE)

#define isalien(H) (H?.mind ? H.mind.GetRole(XENOMORPH) : FALSE)

// BLOB

#define isblob(A) istype(A, /obj/effect/blob)

#define isblobnormal(A) istype(A, /obj/effect/blob/normal)

#define isblobcore(A) istype(A, /obj/effect/blob/core)

#define isblobnode(A) istype(A, /obj/effect/blob/node)

#define isblobfactory(A) istype(A, /obj/effect/blob/factory)

#define isblobshield(A) istype(A, /obj/effect/blob/shield)

#define isblobresource(A) istype(A, /obj/effect/blob/resource)
