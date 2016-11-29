#define isbot(A) (istype(A, /obj/machinery/bot))

#define isdrone(A) (istype(A, /mob/living/silicon/robot/drone))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

#define isabductor(A) (istype(A, /mob/living/carbon/human/abductor))

#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isbrain(A) (istype(A, /mob/living/carbon/brain))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define isfacehugger(A) (istype(A, /mob/living/carbon/alien/facehugger))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isslime(A) (istype(A, /mob/living/carbon/slime))

#define isslimeadult(A) (istype(A, /mob/living/carbon/slime/adult))

#define isrobot(A) (istype(A, /mob/living/silicon/robot))

#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/corgi))

#define iscrab(A) (istype(A, /mob/living/simple_animal/crab))

#define iscat(A) (istype(A, /mob/living/simple_animal/cat))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define isbear(A) (istype(A, /mob/living/simple_animal/hostile/bear))

#define iscarp(A) (istype(A, /mob/living/simple_animal/hostile/carp))

#define isclown(A) (istype(A, mob/living/simple_animal/hostile/retaliate/clown))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

#define iscarbon(A) (istype(A, /mob/living/carbon))

#define issilicon(A) (istype(A, /mob/living/silicon))

#define isliving(A) (istype(A, /mob/living))

#define isnewplayer(A) (istype(A, /mob/new_player))

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define isorgan(A) (istype(A, /datum/organ/external))

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
