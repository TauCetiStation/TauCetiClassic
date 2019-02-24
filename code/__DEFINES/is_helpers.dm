// HUMAN

#define isabductor(A) (istype(A, /mob/living/carbon/human/abductor))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

// CARBON
#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/queen))

#define isaliendrone(A) (istype(A, /mob/living/carbon/alien/humanoid/drone))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isfacehugger(A) (istype(A, /mob/living/carbon/alien/facehugger))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

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

// MOB

#define isobserver(A) (istype(A, /mob/dead/observer))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

// ELSE

#define isbodypart(A) (istype(A, /obj/item/organ/external))

#define isbot(A) (istype(A, /obj/machinery/bot))

#define islist(A) (istype(A, /list))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ismovableatom(A) (istype(A, /atom/movable))

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

// KNOWLEDGE

#define is_knowledge_chem(A) (ishuman(A) && A.job in list("Chemist", "Chief Medical Officer", "Research Director", "Scientist", "Xenoarchaeologist"))


