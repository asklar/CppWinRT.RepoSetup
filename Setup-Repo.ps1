function Sub {
  param (
    [hashtable]$subs,
    [string]$content
  )

  $subs.GetEnumerator() | % {
    $content = $content.Replace($_.Name, $_.Value, 'OrdinalIgnoreCase')
  }
  return $content
}

function Setup-Repo {
param (
    [string]$ProjectName,
    [string]$RepoFullName,
    [string]$RepoAuthorFull,
    [string]$RepoAuthor,
    [string]$RootNamespace
  )

  if ($RootNamespace -eq $null) {
    $RootNamespace = $ProjectName
  }

  $RepoTemplate = $RepoFullName
  $Repo_Template = $RepoTemplate.Replace('.', '_')

  $RepoRoot = "$PSScriptRoot\RepoTemplate"

  Write-Output "RepoRoot: $RepoRoot"

  $subs = @{
    REPOTEMPLATE = $RepoTemplate;
    REPO_TEMPLATE = $Repo_Template;
    PROJECTNAME = $ProjectName;
    "REPO.TEMPLATE" = $RepoFullName;
    REPOAUTHOR = $RepoAuthor;
    REPOAUTHORFULL = $RepoAuthorFull;
    ROOTNAMESPACE = $RootNamespace
  }

  $files = gci $RepoRoot -Recurse -File
  $files | % {
    $sourcePath = $_.FullName
    $relPath = [System.IO.Path]::GetRelativePath($RepoRoot, $sourcePath)
    $fname = Sub $subs $relPath;
    $path = Join-Path $pwd $fname
    Write-Output "$relPath => $path"
    $folder = [system.io.path]::GetDirectoryName($path)
    if (!(Test-Path $folder)) {
      mkdir $folder
    }
    $content = gc $sourcePath -Raw
    $content = Sub $subs $content
    $content | Out-File -FilePath $path
  }
}