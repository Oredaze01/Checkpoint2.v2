# Q.5.7 Importer la fonction log du fichier Functions.psm1 sans la copier.
Import-Module -Name "$Path\Functions.psm1" -Force

# Q.5.8 Création d'une journalisation d'un evenement au choix

Function Random-Password
{
    param ([Int]$Length = 8)
    
    $Punc = 46..46
    $Digits = 48..57
    $Letters = 65..90 + 97..122

    $Password = Get-Random -Count $Length -Input ($Punc + $Digits + $Letters) |`
        ForEach -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $Password.ToString()
}

Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

# Q.5.3 On change le -skip2 en -skip 1 pour ne pas sauter la deuxieme ligne mais la premiere.
# Q.5.5 Seul les champs utilisés seront importé : prénom, nom et description.
$Users = Import-Csv -Path $CsvFile -Delimiter ";" `
    -Header "prenom","nom","description" `
    -Encoding UTF8  | Select-Object -Skip 1

foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.Nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = Random-Password
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.Description) - $($User.Fonction)"
        # Q.5.4 Ajout de la variable description dans le $UserInfo.
        # Q.5.11 Pas d'expiration pour le mot de passe du compte
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
            Password             = $Password
	    Description          = $Description
            AccountNeverExpires  = $True
            PasswordNeverExpires = $True

        }

        New-LocalUser @UserInfo
         #Q.5.10 Ajout des utilisateurs dans le groupe des utilisateurs locaux. 
        Add-LocalGroupMember -Group "Utilisateur" -Member "$Prenom.$Nom"
        # Q.5.6 Affichage a l'ecran en vert , avec le nom et le mot de passe en clair
        Write-Host "L'utilisateur $Prenom.$Nom a été crée avec le mot de passe $Pass" -ForegroundColor Green
    }
     # Q.5.9 Affichage en rouge du message "Le compte "Utilisateur" existe déja
    Else
    {
        Write-Host "Le compte $Prenom.$Nom existe déjà" -ForegroundColor Red
    }
}