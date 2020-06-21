// Backpack styles for jobs, factions... for outfit.dm

#define PREFERANCE_BACKPACK 1
#define PREFERANCE_BACKPACK_FORCE 2 // if select "Nothing" => give backpack

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

#define BACKPACK_STYLE_CARGO list( \
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
