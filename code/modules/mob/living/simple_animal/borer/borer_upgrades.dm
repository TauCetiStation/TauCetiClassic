#define STATUS_OUTSIDE      1
#define STATUS_INFESTED     2
#define STATUS_CONTROLLING  4

/obj/effect/proc_holder/borer
    panel = "Borer"
    name = "c===3"
    desc = ""

    var/cost = 0
    var/chemical_cost = 0
    var/status_required

/obj/effect/proc_holder/borer/Click()
