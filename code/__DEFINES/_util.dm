//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)
