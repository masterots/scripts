param([String]$svnPath)

$svnLog = svn log -q $svnPath
$authors = @()

foreach ($line in $svnLog) {
    if ($line -Match "r") {
        $lineSplitArray = $line.split("|")
        $authors = $authors + ($lineSplitArray[1] -replace " ", "")
    }
}

$svnAuthors = $authors | sort -unique
$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.SearchScope = "Subtree"
$colPropList = "name", "mail", "sAMAccountName", "givenName"

foreach ($i in $colPropList) {
    $objSearcher.PropertiesToLoad.Add($i) | Out-Null
}
    
foreach ($svnAuthor in $svnAuthors) {
    $strFilter = "((sAMAccountName=$svnAuthor))"
    $objSearcher.Filter = $strFilter
    $colResults = $objSearcher.FindAll()

    foreach($objResult in $colResults) {
        $objItem = $objResult.Properties; 
        $authorFullName = "" #getAuthorName($objItem.name)
        
        if ($objItem.name | %{$_.contains(", ")}) {
            $tempData = $objItem.name | %{$_.split(", ")}
            $authorFullName = $tempData[2] + " " + $tempData[0]
        }
        else {
            $authorFullName = $objItem.name
        }
                
        if (($objItem.mail | %{$_}).length -lt 1) {
            $authorEmail = $svnAuthor + "@mobicorp.com"
        }
        else {
            $authorEmail = $objItem.mail
        }
        
        Add-Content svnauthors.txt -Value ($svnAuthor + " = " + $authorFullName + " <"+$authorEmail+">")
    }
}

svn2git $svnPath --authors svnauthors.txt --verbose