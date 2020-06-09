@Grab(group = 'org.eclipse.jgit', module = 'org.eclipse.jgit', version = '5.0.2.201807311906-r')
import org.eclipse.jgit.api.Git
import org.eclipse.jgit.treewalk.TreeWalk

import java.nio.file.Files

JTGMERGE = 'java -jar ./tools/dmm-merge-tool/JTGMerge.jar'

def git = Git.open(new File('.'))
def currentStatus = git.status().call()

if (!currentStatus.conflicting.empty) {
    git.close()
    println 'Error: You need to resolve merge conflicts first.'
    System.exit(1)
}
if (git.repository.resolve('MERGE_HEAD')) {
    git.close()
    println 'Not running mapmerge for merge commit.'
    System.exit(0)
}

currentStatus.added.each { filePath ->
    if (!filePath.endsWith('.dmm'))
        return

    println "Converting new map to TGM: $filePath"
    /$JTGMERGE convert --separator=NIX "$filePath" -f tgm/.execute().waitFor()

    git.add().addFilepattern(filePath).call()
}

def objReader = git.repository.newObjectReader()
def lastCommitId = git.repository.resolve("${git.repository.fullBranch}^{tree}")

currentStatus.changed.each { filePath ->
    if (!filePath.endsWith('.dmm'))
        return

    def treeWalk = TreeWalk.forPath(git.repository, filePath, lastCommitId)
    def blobId = treeWalk.getObjectId(0)

    def tmpMap = Files.createTempFile('dmm.', null).toFile()
    tmpMap.deleteOnExit()
    tmpMap << objReader.open(blobId).bytes

    println "Cleaning map: $filePath"
    /$JTGMERGE clean --separator=NIX "${tmpMap.path}" "$filePath"/.execute().waitFor()

    tmpMap.delete()
    treeWalk.close()

    git.add().addFilepattern(filePath).call()
}

objReader.close()
git.close()
