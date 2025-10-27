/// Checks if potential_weakref is a weakref of a thing.
#define IS_WEAKREF_OF(thing, potential_weakref) (isdatum(thing) && !isnull(potential_weakref) && thing.weak_reference == potential_weakref)
