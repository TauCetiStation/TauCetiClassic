@Grab(group = 'org.eclipse.jgit', module = 'org.eclipse.jgit', version = '5.0.2.201807311906-r')
import org.eclipse.jgit.api.Git

println 'Dependencies installed!'
println 'Installing hooks...'

def git = Git.open(new File('../../.'))
def config = git.repository.config

new File('.').eachFile { file ->
    def splittedName = file.name.split(/\./)
    def cleanFileName = splittedName[0]
    def extension = splittedName[1]

    switch (extension) {
        case 'merge':
            config.unsetSection('merge', "merge-$cleanFileName")

            def setMergeSection = { subSectionName, line -> config.setString('merge', "merge-$cleanFileName", subSectionName, line) }
            def lines = file.readLines()

            setMergeSection('name', lines.get(0))
            setMergeSection('driver', lines.get(1).replace('{OS_EXT}', getOSExt()).trim())

            println "Merge driver for `$cleanFileName` files installed!"

            break
        case 'hook':
            def hookFile = new File("../../.git/hooks/$cleanFileName")
            hookFile.delete()
            hookFile.createNewFile()
            hookFile << file.text

            println "$cleanFileName hook installed!"

            break
    }
}

config.save()
git.close()

println 'All dependencies and hooks are installed! You may close the window.'

def getOSExt() {
    System.env['OS'].toLowerCase().contains('windows') ? 'bat' : 'sh'
}