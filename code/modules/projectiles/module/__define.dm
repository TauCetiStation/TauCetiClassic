#define ENERGY "energy"
#define BULLET "bullet"

#define MODULE istype(A, /obj/item/weapon/gun_module)
#define MODULE_MAGAZINE istype(A, /obj/item/weapon/gun_module/magazine)
#define AMMO istype(A, /obj/item/ammo_casing)
#define MAGAZINE istype(A, /obj/item/ammo_box/magazine)
#define CELL istype(A, /obj/item/weapon/stock_parts/cell)
#define MAGTYPE (istype(A, mag_type) || istype(A, mag_type2))
#define LENS istype(A, /obj/item/ammo_casing/energy)
#define GUN obj/item/weapon/gunmodule/gun

#define CONTINUED 2
#define INTERRUPT 4
#define IGNORING 6