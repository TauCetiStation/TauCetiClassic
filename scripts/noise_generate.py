from sys import stdout, exit, argv
from random import randint

def makeGrid():
    newgrid = [[0 for x in range(254)] for y in range(254)]
    for i in range(len(newgrid)):
        for j in range(len(newgrid[i])):
            if i==0 or j==0 or i==len(newgrid)-1 or j==len(newgrid[0])-1:
                newgrid[i][j]=1
    return newgrid

def populateGrid(grid, chance):
    for i in range(len(grid)):
        for j in range(len(grid[0])):
            if(randint(0,100)<=chance):
                grid[i][j]=1
    return grid

def automataIteration(grid, birth_limit, death_limit):
    new_grid = [row[:] for row in grid]
    for i in range(1, len(new_grid)-1):
        for j in range(1, len(new_grid[0])-1):
            count = 0
            if j > 0:
                if new_grid[i-1][j]==1:
                    count+=1
            if i > 0:
                if new_grid[i][j-1]==1:
                    count+=1
            if i > 0 and j > 0:
                if new_grid[i-1][j-1]==1:
                    count+=1

            if j < len(new_grid[i])-1:
                if new_grid[i+1][j]:
                    count+=1

            if i < len(new_grid)-1:
                if new_grid[i][j+1]:
                    count+=1

            if i < len(new_grid)-1 and j < len(new_grid)-1:
               if new_grid[i+1][j+1]:
                   count+=1

            if i > 0 and j < len(new_grid[i])-1:
                if new_grid[i+1][j-1]:
                    count+=1

            if j > 0 and i < len(new_grid)-1:
                if new_grid[i-1][j+1]:
                    count+=1

            if new_grid[i][j]==1:
                if count < death_limit:
                    grid[i][j]=0
                else:
                    grid[i][j]=1
            else:
                if count > birth_limit:
                    grid[i][j]=1
                else:
                    grid[i][j]=0
    return grid

def main():
    iterations = int(argv[1])
    birthlimit = int(argv[2])
    deathlimit = int(argv[3])
    chance = int(argv[4])
    grid = makeGrid()
    grid = populateGrid(grid, chance)
    for i in range(iterations):
        grid = automataIteration(grid, birthlimit, deathlimit)

    flat_grid = [item for sublist in grid for item in sublist]
    str_list = ''.join(str(e) for e in flat_grid)
    stdout.write((str_list))

if __name__ == "__main__":
    if len(argv) > 1:
        exit(main())
