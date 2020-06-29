// Backpack styles for jobs, factions... for outfit.dm

#define PREFERENCE_BACKPACK 1
#define PREFERENCE_BACKPACK_FORCE 2 // if select "Nothing" => give backpack
#define DEFAULT_FORCED_BACKPACK 2   // number of default backpack, when PREFERENCE_BACKPACK_FORCE 

// default style
#define BACKPACK_STYLE_COMMON list( \
	null, \
	/obj/item/weapon/storage/backpack, \
	/obj/item/weapon/storage/backpack/alt, \
	/obj/item/weapon/storage/backpack/satchel/norm, \
	/obj/item/weapon/storage/backpack/satchel \
)

// Departments
#define BACKPACK_STYLE_SECURITY list( \
	null, \
	/obj/item/weapon/storage/backpack/security, \
	/obj/item/weapon/storage/backpack/alt, \
	/obj/item/weapon/storage/backpack/satchel/sec, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_ENGINEERING list( \
	null, \
	/obj/item/weapon/storage/backpack/industrial, \
	/obj/item/weapon/storage/backpack/alt, \
	/obj/item/weapon/storage/backpack/satchel/eng, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_RESEARCH list( \
	null, \
	/obj/item/weapon/storage/backpack/backpack_tox, \
	/obj/item/weapon/storage/backpack/alt/tox, \
	/obj/item/weapon/storage/backpack/satchel/tox, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_MEDICAL list( \
	null, \
	/obj/item/weapon/storage/backpack/medic, \
	/obj/item/weapon/storage/backpack/alt, \
	/obj/item/weapon/storage/backpack/satchel/med, \
	/obj/item/weapon/storage/backpack/satchel \
)

// jobs
#define BACKPACK_STYLE_CAPTAIN list( \
	, \
	/obj/item/weapon/storage/backpack/captain, \
	/obj/item/weapon/storage/backpack/alt, \
	/obj/item/weapon/storage/backpack/satchel/cap, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_HYDROPONIST list( \
	null, \
	/obj/item/weapon/storage/backpack/backpack_hyd, \
	/obj/item/weapon/storage/backpack/alt/hyd, \
	/obj/item/weapon/storage/backpack/satchel/hyd, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_MIME list( \
	null, \
	/obj/item/weapon/storage/backpack/mime, \
	/obj/item/weapon/storage/backpack/alt, \
	/obj/item/weapon/storage/backpack/satchel/norm, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_CHEMIST list( \
	null, \
	/obj/item/weapon/storage/backpack/backpack_chem, \
	/obj/item/weapon/storage/backpack/alt/chem, \
	/obj/item/weapon/storage/backpack/satchel/chem, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_GENETICIST list( \
	null, \
	/obj/item/weapon/storage/backpack/backpack_gen, \
	/obj/item/weapon/storage/backpack/alt/gen, \
	/obj/item/weapon/storage/backpack/satchel/gen, \
	/obj/item/weapon/storage/backpack/satchel \
)

#define BACKPACK_STYLE_VIROLOGIST list( \
	null, \
	/obj/item/weapon/storage/backpack/backpack_vir, \
	/obj/item/weapon/storage/backpack/alt/vir, \
	/obj/item/weapon/storage/backpack/satchel/vir, \
	/obj/item/weapon/storage/backpack/satchel \
)
