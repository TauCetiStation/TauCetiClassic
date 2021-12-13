/// A wrapper for _create_spawners that allows us to pretend we're using normal named arguments
#define create_spawners(type, id, num, arguments...) _create_spawners(type, id, num, list(##arguments)

#define create_spawner(type, id, arguments...) create_spawners(type, id, 1, ##arguments)
