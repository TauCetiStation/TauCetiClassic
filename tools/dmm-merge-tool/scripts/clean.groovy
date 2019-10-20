import groovy.io.FileType

def mapFiles = []

new File('../../maps').traverse (type: FileType.FILES, nameFilter: ~/.*\.dmm$/) { file ->
    if (new File("${file.path}.backup").exists())
        mapFiles << file
}

if (mapFiles.empty) {
    println 'Error: No maps available for cleaning.'
    System.exit(1)
}

println 'Available maps:'
mapFiles.eachWithIndex { file, index ->
    printf ' [%2d]: %s\n', index, file.name
}

def userChoice = System.console().readLine '\nPlease select maps to clean (example: 1,3-5,12):\n>> '
def mapNumbersToClean = []

try {
    userChoice.tokenize(',').each { 
        if (it.contains('-')) {
            def range = it.split('-')
            ((range[0] as int)..(range[1] as int)).each { mapNumbersToClean << it }
        } else {
            mapNumbersToClean << (it as int)
        }
    }
} catch (NumberFormatException e) {
    println 'Error: Invalid map input. Please provide number value.'
    System.exit(1)
}

if (mapNumbersToClean.empty) {
    println 'Error: Please specify maps to clean.'
    System.exit(1)
} else {
    mapNumbersToClean.each {
        if (it >= mapFiles.size()) {
            println "Error: Provide valid map number (map with number $it does not exists)."
            System.exit(1)
        }
    }

    println '\nNext maps will be cleaned:'
    mapNumbersToClean.each { mapIndex ->
        printf ' [%2d]: %s\n', mapIndex, mapFiles.get(mapIndex).name 
    }

    userChoice = System.console().readLine '\nContinue? (y/n): '

    if (!'y'.equalsIgnoreCase(userChoice.trim())) {
        println 'Aborted by user.'
        System.exit(0)
    }
}

mapNumbersToClean.each { number ->
    def mapFile = mapFiles.get(number)
    def p = /java -jar JTGMerge.jar clean --separator=NIX "${mapFile.path}.backup" "$mapFile.path"/.execute()
    p.consumeProcessOutput(System.out, System.err)
    p.waitFor()
}

println "All (${mapNumbersToClean.size()}) maps successfully cleaned."
