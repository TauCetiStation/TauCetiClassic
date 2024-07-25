// This file is used to test the entire build
// To use istype-defines from this file for tests, wrap your istype in brackets
// Example: isabductor(A) (istype(A, /mob/living/carbon/human/abductor))
// Bad example: isabductor(A) istype(A, /mob/living/carbon/human/abductor)

// META

#define isweakref(D) (istype(D, /datum/weakref))

// TURFS

#define isenvironmentturf(A) (istype(A, /turf/environment))

#define isspaceturf(A) (istype(A, /turf/environment/space))

#define isiceturf(A) (istype(A, /turf/environment/snow/ice))

#define isfloorturf(A) (istype(A, /turf/simulated/floor))

#define isplatingturf(A) (istype(A, /turf/simulated/floor/plating))

#define iswallturf(A) (istype(A, /turf/simulated/wall))

#define iswaterturf(A) (istype(A, /turf/simulated/floor/beach/water) || istype(A, /turf/unsimulated/beach/water) || istype(A, /turf/unsimulated/jungle/water))

// HUMAN

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define isskeleton(A) (A.get_species() in list(SKELETON, SKELETON_UNATHI, SKELETON_TAJARAN, SKELETON_SKRELL, SKELETON_VOX))

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

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define isconstruct(A) istype(A, /mob/living/simple_animal/construct)

#define isgod(A) (istype(A, /mob/living/simple_animal/shade/god))

#define isreplicator(A) (istype(A, /mob/living/simple_animal/hostile/replicator))

// MOB

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

#define isautosay(A) (istype(A, /mob/autosay))

#define isMMI(A) (istype(A, /obj/item/device/mmi))

// ELSE

#define isbodypart(A) (istype(A, /obj/item/organ/external))

#define isbot(A) (istype(A, /obj/machinery/bot))

#define ismachinery(A) (istype(A, /obj/machinery))

#define istagger(A) (istype(A, /obj/item/device/tagger))

#define isdiagnostichud(A) (istype(A, /obj/item/clothing/glasses/hud/diagnostic))

// GOONCHAT PORT

#define isatom(A) (istype(A, /atom))

#define isclient(A) (istype(A, /client))


// ASSEMBLY HELPERS

#define isassembly(O) (istype(O, /obj/item/device/assembly))

#define isigniter(O) (istype(O, /obj/item/device/assembly/igniter))

#define isinfared(O) (istype(O, /obj/item/device/assembly/infra))

#define isprox(O) (istype(O, /obj/item/device/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/device/assembly/signaler))

#define istimer(O) (istype(O, /obj/item/device/assembly/timer))

// TOOLS HELPERS

#define iswrenching(I) 	I.get_quality(QUALITY_WRENCHING)

#define iswelding(I) 	I.get_quality(QUALITY_WELDING)

#define iscutter(I) 	I.get_quality(QUALITY_CUTTING)

#define isscrewing(I) 	I.get_quality(QUALITY_SCREWING)

#define isprying(I)		I.get_quality(QUALITY_PRYING)

#define ispulsing(I) 	I.get_quality(QUALITY_PULSING)

#define issignaling(I)  I.get_quality(QUALITY_SIGNALLING)

#define iscoil(A) (istype(A, /obj/item/stack/cable_coil))

// OBJECTS

#define isitem(A) (istype(A, /obj/item))

#define isunder(A) (istype(A, /obj/item/clothing/under))

// ROLES / ANTAG

#define isfaction(A) (istype(A, /datum/faction))

#define isrole(type, H) (H?.mind ? H.mind.GetRole(type) : FALSE)

#define isrolebytype(type, H) (H?.mind ? H.mind.GetRoleByType(type) : FALSE)

#define isanyantag(H) (H?.mind && H.mind.antag_roles.len)

#define isabductor(H) isrolebytype(/datum/role/abductor, H)

#define isabductorsci(H) isrole(ABDUCTOR_SCI, H)

#define isabductoragent(H) isrole(ABDUCTOR_AGENT, H)

#define isshadowling(H) isrole(SHADOW, H)

#define isshadowthrall(H) isrole(SHADOW_THRALL, H)

#define iscultist(mob) (mob && global.cult_religion?.is_member(mob))

#define iseminence(A) (istype(A, /mob/camera/eminence))

#define isvoxraider(H) isrole(VOXRAIDER, H)

#define ischangeling(H) isrolebytype(/datum/role/changeling, H)

#define isanyrev(H) (isrev(H) || isrevhead(H))

#define isrev(H) isrole(REV, H)

#define isrevhead(H) isrole(HEADREV, H)

#define istraitor(H) isrole(TRAITOR, H)

#define iselitesyndie(H) isrole(SYNDIESQUADIE, H)

#define ismalf(H) isrole(MALF, H)

#define isnukeop(H) (isrole(NUKE_OP, H) || isrole(NUKE_OP_LEADER, H) || isrole(SYNDIESQUADIE, H))

#define iswizard(H) isrole(WIZARD, H)

#define iswizardapprentice(H) isrole(WIZ_APPRENTICE, H)

#define isdeathsquad(H) isrole(DEATHSQUADIE, H)

#define isninja(H) isrole(NINJA, H)

#define isERT(H) isrole(RESPONDER, H)

#define isrolezombie(H) isrole(ZOMBIE, H)

#define iszombie(H) (H.get_species() in global.all_zombie_species_names)

#define isalien(H) isrole(XENOMORPH, H)

#define isgangster(H) isrole(GANGSTER, H)

#define isgangsterlead(H) isrole(GANGSTER_LEADER, H)

#define isanygangster(H) isrolebytype(/datum/role/gangster, H)

#define isgundealer(H) isrole(GANGSTER_DEALER, H)

#define isanycop(H) isrolebytype(/datum/role/cop, H)

#define isanyblob(H) isrolebytype(/datum/role/blob_overmind, H)

// BLOB

#define isblob(A) (istype(A, /obj/structure/blob))

#define isblobnormal(A) (istype(A, /obj/structure/blob/normal))

#define isblobcore(A) (istype(A, /obj/structure/blob/core))

#define isblobnode(A) (istype(A, /obj/structure/blob/node))

#define isblobfactory(A) (istype(A, /obj/structure/blob/factory))

#define isblobshield(A) (istype(A, /obj/structure/blob/shield))

#define isblobresource(A) (istype(A, /obj/structure/blob/resource))
