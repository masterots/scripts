$svnLog = svn log -q http://svn/core/mobi-reports
$authors = @()
foreach ($line in $svnLog) {
    if ($line -Match "r") {
        $lineSplitArray = $line.split("|")
        $authors = $authors + $lineSplitArray[1]
        #$authors.length
    }
}

$svnAuthors = $authors | sort -unique
Write-Output $svnAuthors