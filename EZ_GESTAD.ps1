# EZ-GESTION-AD / administration d�un domaine Active Directory via une interface GUI
# Par sbeteta@beteta.org

# Boucle principale : elle tourne en continu tant que l'utilisateur ne choisit pas de quitter.
while ($true) {

    # Efface le contenu de la console pour afficher un menu propre.
    Clear-Host
    Start-Sleep -Milliseconds 125
    # Affiche une ligne d�corative pour le menu, avec une couleur cyan.
    Write-Host "========================================" -ForegroundColor Cyan

    # Affiche le titre "MENU PRINCIPAL" avec texte cyan sur fond noir.
    Write-Host "           MENU PRINCIPAL" -ForegroundColor Cyan -BackgroundColor Black

    # Affiche une autre ligne d�corative + retour � la ligne (`n = new line).
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Affiche l'option 0 : quitter le programme.
    Write-Host " 0 - Quitter" -ForegroundColor Yellow

    # Affiche l'option 1 : configurer les unit�s d'organisation (OU).
    Write-Host " 1 - Configuration des OU" -ForegroundColor Yellow

    # Affiche l'option 2 : configurer les utilisateurs.
    Write-Host " 2 - Configuration des USERS" -ForegroundColor Yellow

    # Affiche l'option 3 : configurer les groupes.
    Write-Host " 3 - Configuration des Groupes" -ForegroundColor Yellow

    # Affiche l'option 4 : configurer les strat�gies de groupe (GPO).
    Write-Host " 4 - Configuration des GPO" -ForegroundColor Yellow

    # Affiche l'option 5 : g�rer les journaux d'�v�nements (logs Windows).
    Write-Host " 5 - Gestion des �v�nements" -ForegroundColor Yellow

    # Affiche l'option 6 : g�rer les processus en cours.
    Write-Host " 6 - Gestion des Processus" -ForegroundColor Yellow

    # Affiche l'option 7 : g�rer les services (Windows Services).
    Write-Host " 7 - Gestion des Services" -ForegroundColor Yellow

    # Affiche l'option 8 : supervision corrective (par exemple, red�marrer un service arr�t�).
    Write-Host " 8 - Supervision corrective des Services" -ForegroundColor Yellow

    # Invite l'utilisateur � entrer son choix entre 0 et 8.
    # La valeur saisie est stock�e dans la variable $maVar.
    $maVar = Read-Host "Veuillez saisir votre choix (0-8)"

    # Teste si l'utilisateur a saisi "0".
    # Cela signifie qu'il veut quitter le programme.
    if ($maVar -eq "0") {
        
        # Affiche un message pour dire que le programme va se fermer.
        Write-Host " Fermeture du programme."

        # Utilise le mot-cl� 'break' pour sortir de la boucle while.
        # Cela met fin � l'ex�cution du script.
        break
    }

############## CONFIGURATION DES UNIT�S D'ORGANISATION ##############

# Si l'utilisateur a saisi "1" dans le menu principal, on entre ici
elseif ($maVar -eq "1") {

    # On cr�e une variable qui servira � sortir du menu des OU quand ce sera n�cessaire
    $exitOUMenu = $false

    # Cette boucle s'ex�cute tant que l'utilisateur ne demande pas � revenir au menu principal
    while (-not $exitOUMenu) {

        # Efface l'affichage pr�c�dent dans la console
        Clear-Host

        # Affiche l'en-t�te du sous-menu de gestion des OU
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "           OPTION CONFIG OU          " -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        # Affiche les options disponibles dans ce menu secondaire
        Write-Host " 0 - Retour au menu principal" -ForegroundColor Yellow
        Write-Host " 1 - Ajout d'OU" -ForegroundColor Yellow
        Write-Host " 2 - Suppression d'OU`n" -ForegroundColor Yellow

        # Demande � l'utilisateur de saisir son choix et stocke la r�ponse
        $choix_ou = Read-Host "Votre choix"

        # En fonction du choix saisi, on utilise la structure switch pour ex�cuter une action
        switch ($choix_ou) {

            # Si l'utilisateur tape "0", on met fin � la boucle et on retourne au menu principal
            "0" {
                $exitOUMenu = $true
            }

            # Si l'utilisateur tape "1", on va lancer le processus de cr�ation d'une OU
            "1" {
                # Affiche la liste actuelle des OU pr�sentes dans le domaine
                Write-Host "`nOU existantes :"
                Get-ADOrganizationalUnit -Filter * -SearchBase "DC=formation,DC=lan" |
                    Sort-Object Name |                                     # Trie les OU par ordre alphab�tique
                    Select-Object -ExpandProperty Name |                   # R�cup�re uniquement le nom de chaque OU
                    ForEach-Object { Write-Host " - $_" }                  # Affiche chaque nom d'OU

                # Demande � l'utilisateur le nom de l'OU qu'il souhaite ajouter
                $nom_ou = Read-Host "Nom de l'OU � ajouter"

                # V�rifie si une OU portant ce nom existe d�j� dans le domaine
                $ouExist = Get-ADOrganizationalUnit -Filter "Name -eq '$nom_ou'" -SearchBase "DC=formation,DC=lan" -ErrorAction SilentlyContinue

                # Si aucune OU du m�me nom n'existe, on proc�de � la cr�ation
                if (-not $ouExist) {
                    try {
                        # Cr�e l'OU dans l'annuaire Active Directory
                        New-ADOrganizationalUnit -Name $nom_ou -Path "DC=formation,DC=lan" -ErrorAction Stop
                        Write-Host "OU '$nom_ou' cr��e." -ForegroundColor Green
                    } catch {
                        # Si une erreur survient, on l'affiche
                        Write-Host "Erreur lors de la cr�ation : $_" -ForegroundColor Red
                    }
                } else {
                    # Si une OU du m�me nom existe d�j�, on en informe l'utilisateur
                    Write-Host "OU '$nom_ou' existe d�j�." -ForegroundColor Yellow
                }

                # Demande � l'utilisateur d'appuyer sur Entr�e avant de continuer
                Write-Host "`nAppuyez sur Entr�e pour continuer..."
                Read-Host | Out-Null
            }

            # Si l'utilisateur tape "2", on lance la suppression d'une OU
            "2" {
                # Affiche la liste actuelle des OU disponibles
                Write-Host "`nOU existantes :"
                Get-ADOrganizationalUnit -Filter * -SearchBase "DC=formation,DC=lan" |
                    Sort-Object Name |
                    Select-Object -ExpandProperty Name |
                    ForEach-Object { Write-Host " - $_" }

                # Demande � l'utilisateur le nom de l'OU � supprimer
                $nom_ou = Read-Host "Nom de l'OU � supprimer"

                # Recherche l'OU dans le domaine avec le nom donn�
                $ouToDelete = Get-ADOrganizationalUnit -Filter "Name -eq '$nom_ou'" -SearchBase "DC=formation,DC=lan" -ErrorAction SilentlyContinue

                # Si aucune OU ne correspond, on affiche un message d'erreur
                if ($null -eq $ouToDelete) {
                    Write-Host "L'OU '$nom_ou' n'existe pas." -ForegroundColor Red
                } else {
                    # V�rifie si l'OU contient des objets (utilisateurs, groupes, etc.)
                    $childObjects = Get-ADObject -SearchBase $ouToDelete.DistinguishedName -Filter * -SearchScope OneLevel

                    # Si l'OU contient des objets, la suppression est interdite
                    if ($childObjects.Count -gt 0) {
                        Write-Host "`nImpossible de supprimer l'OU '$nom_ou' car elle contient des objets enfants :" -ForegroundColor Yellow
                        $childObjects | ForEach-Object {
                            # Affiche le nom et le type de chaque objet contenu dans l'OU
                            Write-Host " - $($_.Name) ($($_.ObjectClass))"
                        }
                    } else {
                        try {
                            # Retire la protection contre suppression accidentelle
                            Set-ADOrganizationalUnit -Identity $ouToDelete.DistinguishedName -ProtectedFromAccidentalDeletion $false -ErrorAction Stop

                            # Supprime l'OU sans demander confirmation
                            Remove-ADOrganizationalUnit -Identity $ouToDelete.DistinguishedName -Confirm:$false -ErrorAction Stop
                            Write-Host "OU '$nom_ou' supprim�e." -ForegroundColor Green
                        } catch {
                            # En cas d'erreur, on l'affiche
                            Write-Host "Erreur lors de la suppression : $_" -ForegroundColor Red
                        }
                    }
                }

                # Pause pour permettre � l'utilisateur de lire les messages
                Write-Host "`nAppuyez sur Entr�e pour continuer..."
                Read-Host | Out-Null
            }

            # Si l'utilisateur entre une valeur incorrecte (autre que 0, 1, 2)
            default {
                Write-Host "Erreur : veuillez saisir 0, 1 ou 2." -ForegroundColor Red
                Write-Host "`nAppuyez sur Entr�e pour r�essayer..."
                Read-Host | Out-Null
            }
        }
    }
}

############## CONFIGURATION DES UTILISATEURS ##############

# Si l'utilisateur a saisi "2" dans le menu principal, on entre ici
elseif ($maVar -eq "2") {

    # On cr�e une variable vide pour y stocker les choix saisis par l'utilisateur dans ce sous-menu
    $choix_user = ""

    # Boucle infinie : on reste dans ce menu tant que l'utilisateur ne tape pas "0"
    while ($true) {

        # Affiche l'en-t�te du menu de configuration des utilisateurs
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "           OPTION CONFIG USER           " -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        # Affiche les diff�rentes options disponibles pour g�rer les utilisateurs
        Write-Host " 0 - Retour au menu principal" -ForegroundColor Yellow
        Write-Host " 1 - Ajout d'utilisateur" -ForegroundColor Yellow
        Write-Host " 2 - Suppression" -ForegroundColor Yellow
        Write-Host " 3 - Affectation � une OU" -ForegroundColor Yellow
        Write-Host " 4 - Affectation � un groupe" -ForegroundColor Yellow
        Write-Host " 5 - Gestion des ACL`n" -ForegroundColor Yellow

        # Demande � l'utilisateur de saisir une option et la stocke dans la variable
        $choix_user = Read-Host "Votre choix"

        # Si l'utilisateur tape "0", on quitte cette boucle pour revenir au menu principal
        if ($choix_user -eq "0") {
            break
        }

        # === OPTION 1 : AJOUT D'UN UTILISATEUR ===
        elseif ($choix_user -eq "1") {
            Write-Host "===== AJOUT UTILISATEUR ======" -ForegroundColor Yellow

            # Demande le nom complet de l'utilisateur
            $nom_user = Read-Host "Nom complet"

            # Demande le nom de connexion (identifiant de l'utilisateur)
            $login_user = Read-Host "Nom d'utilisateur (login)"

            # Demande un mot de passe, saisi de mani�re masqu�e
            $mdp = Read-Host "Mot de passe" -AsSecureString

            # Affiche toutes les OU disponibles pour aider l'utilisateur � choisir
            Write-Host "Liste des OU disponibles :"
            Get-ADOrganizationalUnit -SearchBase "DC=formation,DC=lan" -Filter * |
                Select-Object -ExpandProperty Name |
                ForEach-Object { Write-Host " - $_" }

            # L'utilisateur indique dans quelle OU cr�er le compte
            $ou = Read-Host "OU cible (choisir parmi la liste ci-dessus)"

            # Cr�e un nouvel utilisateur avec les informations fournies
            New-ADUser -Name $nom_user -SamAccountName $login_user -UserPrincipalName "${login_user}@formation.lan" `
                -AccountPassword $mdp -Enabled $true -Path "OU=$ou,DC=formation,DC=lan"

            # Affiche un message de confirmation
            Write-Host "Utilisateur '$nom_user' ajout� avec succ�s."
        }

        # === OPTION 2 : SUPPRESSION D'UN UTILISATEUR ===
        elseif ($choix_user -eq "2") {
            Write-Host "===== SUPPRESSION UTILISATEUR =====" -ForegroundColor Yellow

            # Liste tous les utilisateurs existants
            Write-Host "Liste des utilisateurs disponibles :"
            Get-ADUser -Filter * -Properties Name | ForEach-Object {
                Write-Host " - Login : $($_.SamAccountName) | Nom : $($_.Name)"
            }

            # Demande quel utilisateur supprimer, via son login
            $login_user = Read-Host "Login de l'utilisateur � supprimer"

            # V�rifie si l'utilisateur existe, puis le supprime s'il est trouv�
            if (Get-ADUser -Identity $login_user -ErrorAction SilentlyContinue) {
                Remove-ADUser -Identity $login_user -Confirm:$false
                Write-Host "Utilisateur '$login_user' supprim�."
            } else {
                Write-Host "Utilisateur '$login_user' introuvable."
            }
        }

        # === OPTION 3 : D�PLACER UN UTILISATEUR DANS UNE AUTRE OU ===
        elseif ($choix_user -eq "3") {
            Write-Host "===== D�PLACEMENT DANS UNE OU =====" -ForegroundColor Yellow

            # Demande le login de l'utilisateur concern�
            $login_user = Read-Host "Login de l'utilisateur"

            # Affiche la liste des OU disponibles
            Write-Host "Liste des OU disponibles :"
            Get-ADOrganizationalUnit -SearchBase "DC=formation,DC=lan" -Filter * |
                Select-Object -ExpandProperty Name | ForEach-Object { Write-Host " - $_" }

            # L'utilisateur indique la nouvelle OU
            $ou = Read-Host "Nouvelle OU (choisir parmi la liste ci-dessus)"

            try {
                # R�cup�re l'utilisateur dans l'AD
                $user = Get-ADUser -Identity $login_user -ErrorAction Stop

                # D�place l'utilisateur dans la nouvelle OU choisie
                Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=$ou,DC=formation,DC=lan"

                Write-Host "Utilisateur d�plac� avec succ�s dans OU=$ou"
            } catch {
                # Message d'erreur si utilisateur ou OU incorrect
                Write-Host "Erreur : utilisateur '$login_user' introuvable ou OU incorrecte."
            }
        }

        # === OPTION 4 : AJOUTER UN UTILISATEUR � UN GROUPE ===
        elseif ($choix_user -eq "4") {
            Write-Host "===== AJOUT � UN GROUPE =====" -ForegroundColor Yellow

            # Demande le login de l'utilisateur � ajouter
            $login_user = Read-Host "Login de l'utilisateur"

            # Affiche la liste des groupes existants
            Write-Host "Liste des groupes disponibles :"
            Get-ADGroup -Filter * | Select-Object -ExpandProperty Name | ForEach-Object { Write-Host " - $_" }

            # Demande � l'utilisateur de choisir un groupe
            $groupe = Read-Host "Nom du groupe (choisir parmi la liste ci-dessus)"

            # V�rifie que l'utilisateur et le groupe existent dans l'AD
            if ((Get-ADUser -Identity $login_user -ErrorAction SilentlyContinue) -and (Get-ADGroup -Identity $groupe -ErrorAction SilentlyContinue)) {
                # Ajoute l'utilisateur au groupe
                Add-ADGroupMember -Identity $groupe -Members $login_user
                Write-Host "Utilisateur '$login_user' ajout� au groupe '$groupe'."
            } else {
                Write-Host "Erreur : utilisateur ou groupe introuvable."
            }
        }

        # === OPTION 5 : GESTION DES DROITS D'ACC��S (ACL) SUR DOSSIER ===
        elseif ($choix_user -eq "5") {

            # Affiche l'en-t�te de la section ACL
            Write-Host "=====================================================" -ForegroundColor Cyan
            Write-Host "               CONFIG USER - Gestion ACL             " -ForegroundColor Cyan
            Write-Host "=====================================================`n" -ForegroundColor Cyan

            # Affiche un aide-m�moire des droits disponibles (FileSystemRights)
            Write-Host "Rappel des principaux types de permissions (FileSystemRights) disponibles :`n"

            # Affiche la liste compl�te des types de droits avec leur signification
            Write-Host "`t* FullControl`t: Contr�le total (toutes les permissions)"
            Write-Host "`t* Modify`t: Lire, �crire, supprimer, cr�er, modifier"
            Write-Host "`t* ReadAndExecute`t: Lire le contenu et ex�cuter les fichiers"
            Write-Host "`t* Read`t: Lire les fichiers et les attributs"
            Write-Host "`t* Write`t: �crire dans les fichiers, cr�er des fichiers/dossiers"
            Write-Host "`t* ListDirectory`t: Voir le contenu du dossier"
            Write-Host "`t* ReadAttributes`t: Lire les attributs des fichiers/dossiers"
            Write-Host "`t* ReadExtendedAttributes`t: Lire les attributs �tendus (m�tadonn�es)"
            Write-Host "`t* WriteAttributes`t: Modifier les attributs"
            Write-Host "`t* WriteExtendedAttributes`t: Modifier les attributs �tendus"
            Write-Host "`t* CreateFiles`t: Cr�er des fichiers dans un dossier"
            Write-Host "`t* CreateDirectories`t: Cr�er des sous-dossiers"
            Write-Host "`t* DeleteSubdirectoriesAndFiles`t: Supprimer les fichiers et sous-dossiers"
            Write-Host "`t* Delete`t: Supprimer le fichier ou le dossier"
            Write-Host "`t* ReadPermissions`t: Lire les permissions d�finies sur l'objet"
            Write-Host "`t* ChangePermissions`t: Modifier les ACL"
            Write-Host "`t* TakeOwnership`t: Prendre possession de l'objet"
            Write-Host "`t* Synchronize`t: Synchroniser l'acc�s aux fichiers (usage syst�me)"

            Write-Host "=====================================================`n"

            # D�finit un chemin de dossier cible sur lequel appliquer les permissions
            $folderPath = "C:\Partage\Docs"

            # Si le dossier n'existe pas, on le cr�e
            if (-Not (Test-Path -Path $folderPath)) {
                Write-Host "Le dossier '$folderPath' n'existe pas, je le cr�e..."
                New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
                Write-Host "Dossier cr��."
            } else {
                Write-Host "Le dossier '$folderPath' existe d�j�."
            }

            # Demande le login de l'utilisateur concern�
            $user = Read-Host "Entrez l'identit� de l'utilisateur concern�"

            # Demande le type de permission � accorder
            $permission = Read-Host "Entrez la permission"

            try {
                # R�cup�re les droits actuels (ACL) du dossier
                $acl = Get-Acl $folderPath

                # Cr�e une nouvelle r�gle de permission pour cet utilisateur
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    "formation\$user",                          # Utilisateur concern�
                    $permission,                            # Type de droit accord�
                    "ContainerInherit,ObjectInherit",       # Les droits s'appliquent aussi aux sous-dossiers/fichiers
                    "None",                                 # Pas d'h�ritage sp�cial
                    "Allow"                                 # Autoriser l'acc�s
                )

                # Ajoute cette r�gle aux ACL existantes et applique le tout
                $acl.SetAccessRule($rule)
                Set-Acl -Path $folderPath -AclObject $acl

                Write-Host "Permission '$permission' attribu�e � l'utilisateur '$user' sur $folderPath." -ForegroundColor Green
            }
            catch {
                # Affiche un message si une erreur survient
                Write-Host "Une erreur est survenue : $_" -ForegroundColor Red
            }
        }

        # === GESTION D'UNE ENTR�E NON VALIDE ===
        else {
            Write-Host "Erreur : saisie invalide."
        }
    }
}

############## CONFIGURATION DES GROUPES ##############

# Si la variable $maVar vaut "3", alors l'utilisateur a choisi l'option "Config Groupe" dans le menu principal
elseif ($maVar -eq "3") {

    # D�finition d'une fonction qui d�code le type d'un groupe AD en texte lisible
    function Get-GroupTypeDescription {
        # La fonction attend une variable en param�tre : $groupType
        param($groupType)

        # Utilise une structure switch pour d�terminer la port�e (scope) du groupe
        # On applique un "ET logique binaire" (bitwise AND) pour extraire les bons bits
        $scope = switch ($groupType -band 0x00000003) {
            0x00000000 { "lan" }         # Port�e lane au domaine
            0x00000001 { "Global" }        # Port�e globale
            0x00000002 { "Universel" }     # Port�e universelle
            default { "Inconnu" }          # Valeur inattendue
        }

        # On v�rifie si le bit de s�curit� est activ� dans groupType (bit 31)
        # Cela permet de savoir si le groupe est de type "S�curit�" ou "Distribution"
        $type = if (($groupType -band 0x80000000) -eq 0x80000000) {
            "S�curit�"
        } else {
            "Distribution"
        }

        # Retourne la description compl�te : ex. "Global - S�curit�"
        return "$scope - $type"
    }

    # Affiche un titre dans le terminal pour signaler l'entr�e dans la section Groupes
    Write-Host "===== CONFIGURATION DES GROUPES UTILISATEURS =====" -ForegroundColor Cyan

    # Initialise la variable $choix_grp vide (sera utilis�e pour naviguer dans le menu)
    $choix_grp = ""

    # Tant que $choix_grp est diff�rent de "0", on reste dans cette boucle de menu
    while ($choix_grp -ne "0") {

        # Affiche la liste de tous les groupes AD avec leur nom et leur type lisible
        Write-Host "`nListe des groupes existants (Nom - Type) :"
        Get-ADGroup -Filter * -Properties groupType | ForEach-Object {
            # Pour chaque groupe, on d�code son type avec la fonction d�finie plus haut
            $typeDesc = Get-GroupTypeDescription $_.groupType
            # Affiche le nom et le type de chaque groupe
            Write-Host " - $($_.Name) - $typeDesc"
        }

        # Ligne vide pour l'esth�tique
        Write-Host ""

        # Affiche le sous-menu d�di� � la configuration des groupes
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "                 OPTION CONFIG GROUPE                 " -ForegroundColor Cyan
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " 0 - Retour au menu principal" -ForegroundColor Yellow
        Write-Host " 1 - Cr�ation d'un groupe" -ForegroundColor Yellow
        Write-Host " 2 - Suppression d'un groupe" -ForegroundColor Yellow
        Write-Host ""

        # Demande � l'utilisateur d'entrer son choix (0, 1 ou 2)
        $choix_grp = Read-Host -Prompt "Votre choix (0, 1 ou 2)"

        # En fonction du choix saisi, ex�cute une action diff�rente
        switch ($choix_grp) {

            # Choix 0 : retour au menu principal
            "0" {
                Write-Host "Retour au menu principal..." -ForegroundColor Yellow
                break  # Sortie de la boucle while
            }

            # Choix 1 : cr�ation d'un groupe AD
            "1" {
                # Demande le nom du nouveau groupe
                $nom_grp = Read-Host "Nom du groupe � cr�er"

                # V�rifie si le groupe existe d�j�
                $existe = Get-ADGroup -Filter "Name -eq '$nom_grp'" -ErrorAction SilentlyContinue
                if ($existe) {
                    Write-Host "Erreur : Le groupe '$nom_grp' existe d�j�." -ForegroundColor Red
                    continue  # Revient au d�but de la boucle
                }

                # Dictionnaire pour traduire les types saisis en fran�ais vers la syntaxe AD
                $scopeOptions = @{ "lan" = "Domainlan"; "global" = "Global"; "universel" = "Universal" }

                # Initialise une variable vide pour le type
                $type_grp = ""
                # Tant que la saisie de l'utilisateur ne correspond pas � une cl� du dictionnaire
                while (-not $scopeOptions.ContainsKey($type_grp.ToLower())) {
                    $type_grp = Read-Host "Type de groupe (lan / Global / Universel)"
                }
                # R�cup�re la version AD du scope (ex : Domainlan)
                $type_grp_ad = $scopeOptions[$type_grp.ToLower()]

                # Dictionnaire pour traduire la cat�gorie (s�curit�/distribution)
                $catOptions = @{ "s�curit�" = "Security"; "distribution" = "Distribution" }

                # M�me logique que pour le type
                $cat_grp = ""
                while (-not $catOptions.ContainsKey($cat_grp.ToLower())) {
                    $cat_grp = Read-Host "Cat�gorie du groupe (S�curit� / Distribution)"
                }
                $cat_grp_ad = $catOptions[$cat_grp.ToLower()]

                # Bloc try/catch pour g�rer les erreurs lors de la cr�ation du groupe
                try {
                    # Cr�e le groupe dans le conteneur CN=Users du domaine
                    New-ADGroup -Name $nom_grp -GroupScope $type_grp_ad -GroupCategory $cat_grp_ad -Path "CN=Users,DC=formation,DC=lan"
                    Write-Host " Groupe '$nom_grp' ($type_grp - $cat_grp) cr�� avec succ�s." -ForegroundColor Green
                }
                catch {
                    # Affiche le message d'erreur en cas d'�chec
                    Write-Host "Erreur lors de la cr�ation du groupe : $_" -ForegroundColor Red
                }
            }

            # Choix 2 : suppression d'un groupe AD
            "2" {
                # Demande le nom du groupe � supprimer
                $nom_grp = Read-Host "Nom du groupe � supprimer"

                # V�rifie si le groupe existe dans l'AD
                if (Get-ADGroup -Identity $nom_grp -ErrorAction SilentlyContinue) {
                    try {
                        # Supprime le groupe sans demander de confirmation
                        Remove-ADGroup -Identity $nom_grp -Confirm:$false
                        Write-Host " Groupe '$nom_grp' supprim� avec succ�s." -ForegroundColor Green
                    }
                    catch {
                        # Affiche un message d'erreur en cas d'�chec
                        Write-Host "Erreur lors de la suppression : $_" -ForegroundColor Red
                    }
                }
                else {
                    # Si le groupe n'existe pas, affiche un message d'erreur
                    Write-Host " Groupe '$nom_grp' introuvable." -ForegroundColor Red
                }
            }

            # Cas par d�faut : gestion d'une mauvaise saisie
            default {
                Write-Host "Erreur : veuillez entrer 0, 1 ou 2." -ForegroundColor Red
            }
        }
    } # Fin boucle while
} # Fin du bloc elseif pour la config des groupes

############## GPO ##############

# Si l'utilisateur a choisi l'option 4 dans le menu principal
elseif ($maVar -eq "4") {

    # Affiche un titre clair pour signaler � l'utilisateur qu'il entre dans le module de configuration GPO
    Write-Host "===== CONFIGURATION GPO - PARAM��TRES D�DI�S =====" -ForegroundColor Cyan

    # �tape 1 : On commence par afficher les OU existantes pour aider � choisir la cible
    Write-Host "Liste des OUs disponibles :"

    # La commande r�cup�re toutes les unit�s d'organisation (OUs) de l'annuaire Active Directory
    # Chaque OU est ensuite affich�e avec son nom et son chemin LDAP (DN)
    Get-ADOrganizationalUnit -Filter * | ForEach-Object {
        Write-Host " - $($_.Name) : $($_.DistinguishedName)"
    }

    # Ligne vide pour a�rer l'affichage
    Write-Host ""

    # Demande � l'utilisateur de saisir manuellement le DN (DistinguishedName) de l'OU cible
    $ouToLink = Read-Host "Merci de saisir le DistinguishedName (DN) de l'OU cible (exemple : OU=Utilisateurs,DC=formation,DC=lan)"

    # Si l'utilisateur ne saisit rien, on affiche un message d'annulation
    if (-not $ouToLink) {
        Write-Host "Aucune OU saisie, annulation." -ForegroundColor Red
        Start-Sleep -Seconds 3   # Pause de 3 secondes avant de relancer le menu
        Continue                 # Retour au menu principal
    }

    # �tape 2 : Cr�ation d'une liste de GPO pr�d�finies sous forme de tableau d'objets
    $gpoList = @(
        @{Name="GPO_NoControlPanel"; Desc="Bloquer l'acc�s au Panneau de Configuration"},
        @{Name="GPO_NoChangingWallpaper"; Desc="Interdire changement fond d'�cran"},
        @{Name="GPO_ScreenLock"; Desc="Verrouillage automatique session 10 minutes"},
        @{Name="GPO_DeployWallpaper"; Desc="D�ployer un fond d'�cran personnalis�"},
        @{Name="GPO_NoRun"; Desc="Bloquer la commande Ex�cuter (Run)"},
        @{Name="GPO_BlockCMD"; Desc="Bloquer l'acc�s � l'invite de commandes"}
    )

    # Initialisation du nombre de GPO � appliquer � 0
    $nbGPO = 0

    # Tant que l'utilisateur ne saisit pas un nombre valide (entre 1 et le total), on redemande
    while (($nbGPO -lt 1) -or ($nbGPO -gt $gpoList.Count)) {
        $nbGPO = [int](Read-Host "Combien de GPO voulez-vous appliquer ? (1 � $($gpoList.Count))")
    }

    # �tape 3 : Affiche toutes les GPO disponibles avec un num�ro devant pour les s�lectionner facilement
    Write-Host "Liste des GPO disponibles :"
    for ($i=0; $i -lt $gpoList.Count; $i++) {
        Write-Host " [$($i+1)] $($gpoList[$i].Name) : $($gpoList[$i].Desc)"
    }
    Write-Host ""

    # �tape 4 : L'utilisateur choisit une par une les GPO � appliquer (pas de doublons autoris�s)
    $selectedIndexes = @()  # Cr�e un tableau vide pour stocker les num�ros choisis

    for ($j=1; $j -le $nbGPO; $j++) {
        $choice = 0
        while (($choice -lt 1) -or ($choice -gt $gpoList.Count) -or ($selectedIndexes -contains $choice)) {
            $choice = [int](Read-Host "S�lectionnez le num�ro de la GPO #$j � appliquer (choix non r�p�t�)")
        }
        $selectedIndexes += $choice  # Ajoute le choix � la liste
    }

    # D�finition d'une fonction nomm�e CreateAndConfigureGPO
    # Cette fonction prend un nom de GPO en param�tre et cr�e/configure cette GPO
    function CreateAndConfigureGPO($gpoName) {

        # Si la GPO n'existe pas d�j�, on la cr�e
        if (-not (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue)) {
            New-GPO -Name $gpoName | Out-Null  # Cr�ation silencieuse
            Write-Host " GPO '$gpoName' cr��e."
        } else {
            Write-Host " GPO '$gpoName' d�j� existante."
        }

        # On d�finit les param�tres � appliquer selon le nom de la GPO
        switch ($gpoName) {

            # Cas 1 : GPO qui bloque le panneau de configuration
            "GPO_NoControlPanel" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
                    -ValueName "NoControlPanel" -Type DWord -Value 1
            }

            # Cas 2 : GPO qui emp�che de changer le fond d'�cran
            "GPO_NoChangingWallpaper" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" `
                    -ValueName "NoChangingWallPaper" -Type DWord -Value 1
            }

            # Cas 3 : GPO qui active le verrouillage automatique de l'�cran apr�s 10 minutes
            "GPO_ScreenLock" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "ScreenSaveTimeOut" -Type String -Value "600"
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "ScreenSaverIsSecure" -Type String -Value "1"
            }

            # Cas 4 : GPO qui d�ploie un fond d'�cran sp�cifique sur les postes
            "GPO_DeployWallpaper" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "Wallpaper" -Type String -Value "C:\Wallpapers\image.jpg"
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "WallpaperStyle" -Type String -Value "2"  # Style �tir� ou centr�
            }

            # Cas 5 : GPO qui bloque la commande "Ex�cuter" (Win+R)
            "GPO_NoRun" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
                    -ValueName "NoRun" -Type DWord -Value 1
            }

            # Cas 6 : GPO qui bloque l'acc�s � l'invite de commande (cmd.exe)
            "GPO_BlockCMD" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
                    -ValueName "DisableCMD" -Type DWord -Value 1
            }
        }
    }

    # �tape 5 : pour chaque GPO s�lectionn�e par l'utilisateur
    foreach ($idx in $selectedIndexes) {

        # On r�cup�re le nom exact de la GPO � partir de son index
        $gpoName = $gpoList[$idx - 1].Name

        # On appelle la fonction pour cr�er et configurer cette GPO
        CreateAndConfigureGPO -gpoName $gpoName

        # On tente de lier cette GPO � l'OU cible saisie plus t�t
        try {
            New-GPLink -Name $gpoName -Target $ouToLink -LinkEnabled Yes -ErrorAction Stop
            Write-Host " GPO '$gpoName' li�e � '$ouToLink'." -ForegroundColor Green
        } catch {
            # Si une erreur survient, on l'affiche
            Write-Host " Erreur lors de la liaison de la GPO '$gpoName' : $_" -ForegroundColor Red
        }
    }
}

####### GESTION DES EVENEMENTS ######

# Si l'utilisateur a choisi l'option 5 dans le menu principal...
elseif ($maVar -eq "5") {

    # D�finition d'une fonction pour afficher rapidement les �v�nements syst�me r�cents
    function Show-RecentSystemLogs {
        # On d�finit que l'on veut uniquement les journaux "System"
        $defaultLogs = @("System")
        # On limite l'affichage aux 3 derniers jours
        $days = 3
        # On affiche un message d'information
        Write-Host "`nPr�visualisation des �v�nements syst�me r�cents (3 derniers jours, niveaux Critique, Erreur, Avertissement)..." -ForegroundColor Cyan
        # On utilise Get-WinEvent avec un filtre sur le journal, le niveau de gravit� et la date
        Get-WinEvent -FilterHashtable @{
            LogName   = $defaultLogs
            Level     = @(1, 2, 3)  # Niveaux Critique, Erreur, Avertissement
            StartTime = (Get-Date).AddDays(-$days)  # Date de d�but : aujourd'hui - 3 jours
        } |
        # On s�lectionne certaines propri�t�s � afficher
        Select-Object TimeCreated, Id, LevelDisplayName, Message |
        # Formatage en tableau lisible automatiquement
        Format-Table -AutoSize
        # Ligne de s�paration
        Write-Host "`n---------------------------------------------`n"
    }

    # Fonction compl�te pour consulter les logs avec options
    function Get-ErrorLogs {
        param (
            [string[]]$LogNames = @("System"),  # Par d�faut, journal "System"
            [int]$Days = 7,  # Nombre de jours d'historique (par d�faut 7)
            [switch]$Export,  # Param�tre bool�en : export ou non ?
            [string]$ExportFolder = "C:\\Logs\\EventLogs"  # Dossier d'export par d�faut
        )
        # Nettoie l'�cran
        Clear-Host
        # Pour chaque journal demand�...
        foreach ($LogName in $LogNames) {
            # Affiche le journal en cours de traitement
            Write-Host "===== CONSULTATION DES �V�NEMENTS : $LogName =====" -ForegroundColor Cyan
            try {
                # Cr�ation du filtre pour Get-WinEvent
                $filter = @{
                    LogName   = $LogName
                    Level     = @(1, 2, 3)
                    StartTime = (Get-Date).AddDays(-$Days)
                }
                # R�cup�ration des �v�nements
                $events = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop
                # Si aucun �v�nement trouv�...
                if ($events.Count -eq 0) {
                    Write-Host "Aucun �v�nement critique, erreur ou avertissement trouv�." -ForegroundColor Yellow
                } else {
                    # Sinon, afficher les �v�nements
                    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -AutoSize
                    # Si l'utilisateur a demand� un export...
                    if ($Export) {
                        # V�rifie si le dossier d'export existe, sinon le cr�e
                        if (-not (Test-Path $ExportFolder)) {
                            New-Item -ItemType Directory -Path $ExportFolder -Force | Out-Null
                        }
                        # Cr�e un nom de fichier bas� sur la date
                        $exportPath = Join-Path $ExportFolder "Logs_${LogName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                        # Export des donn�es au format CSV
                        $events | Select-Object TimeCreated, Id, LevelDisplayName, Message | Export-Csv -Path $exportPath -NoTypeInformation
                        # Message de confirmation d'export
                        Write-Host "`nExport r�alis� vers : $exportPath" -ForegroundColor Green
                    }
                }
            } catch {
                # En cas d'erreur, afficher un message
                Write-Host "Erreur lors de la r�cup�ration des logs : $_" -ForegroundColor Red
            }
            # Ligne de s�paration
            Write-Host "`n---------------------------------------`n"
        }
        # Pause pour que l'utilisateur lise les r�sultats
        Write-Host "Appuyez sur Entr�e pour continuer..." -ForegroundColor DarkGray
        Read-Host | Out-Null
    }

    # Fonction qui surveille les �checs de connexion (�v�nement 4625)
    function Watch-FailedLogons {
        # Fonction appel�e quand un �v�nement 4625 est d�tect�
        function OnEventDetected {
            param($e)  # �v�nement intercept� (nom diff�rent de $Event)

            # Convertit l'�v�nement en XML pour faciliter l'extraction des donn�es
            $eventXml = [xml]$e.SourceEventArgs.NewEvent.ToXml()
            $timeCreated = $eventXml.Event.System.TimeCreated.SystemTime
            $accountName = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" } | Select-Object -ExpandProperty '#text'
            $ipAddress = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "IpAddress" } | Select-Object -ExpandProperty '#text'

            # Si pas d'IP (par exemple en lan), on affiche N/A
            if ([string]::IsNullOrEmpty($ipAddress)) {
                $ipAddress = "N/A"
            }

            # Message d'alerte � afficher et � enregistrer
            $message = "[$timeCreated] �chec de connexion pour l'utilisateur '$accountName' depuis l'adresse IP $ipAddress."
            Write-Host $message -ForegroundColor Red

            # Pr�paration du fichier de log
            $logFolder = "C:\\Logs"
            $logFile = Join-Path $logFolder "FailedLogons.log"

            # Cr�ation du dossier s'il n'existe pas
            if (-not (Test-Path $logFolder)) {
                New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
            }

            # Enregistre le message dans le fichier
            $message | Out-File -FilePath $logFile -Append -Encoding UTF8
        }

        # Affiche le lancement de la surveillance
        Write-Host "Surveillance des �v�nements 4625 (�checs de connexion) en cours..." -ForegroundColor Cyan

        # Construction de la requ�te XML pour filtrer l'�v�nement 4625
        $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4625)]]</Select>
  </Query>
</QueryList>
"@

        # Cr�ation de l'objet EventLogWatcher bas� sur cette requ�te
        $eventWatcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher (
            New-Object System.Diagnostics.Eventing.Reader.EventLogQuery(
                "Security",
                [System.Diagnostics.Eventing.Reader.PathType]::LogName,
                $query
            )
        )

        # Abonnement � l'�v�nement d�clench�
        Register-ObjectEvent -InputObject $eventWatcher -EventName "EventRecordWritten" -Action { OnEventDetected $e } | Out-Null
        # Active la surveillance
        $eventWatcher.Enabled = $true

        Write-Host "Appuyer sur Q pour quitter"
        # Boucle en attente d'appuyer la touche Q par l'utilisateur
         while ($key.KeyChar -ne 'Q') { $key = [System.Console]::ReadKey($true)}
    } # Ne fonctionne pas sur Powershell ISE mais bien sur Powershell

    # ==================== MENU SECONDAIRE EN BOUCLE ====================
    do {
        # Nettoie l'affichage
        Clear-Host
        # Affiche les logs syst�me r�cents
        Show-RecentSystemLogs

        # Affiche le sous-menu �v�nement
        Write-Host "###### MENU DE GESTION DES �V�NEMENTS ######" -ForegroundColor Cyan
        Write-Host "0 - Revenir au Menu Principal" -ForegroundColor Yellow
        Write-Host "1 - Consulter les erreurs d'autres journaux" -ForegroundColor Yellow
        Write-Host "2 - Surveiller en temps r�el les �checs de connexion (4625)" -ForegroundColor Yellow
        # Lecture du choix de l'utilisateur
        $choice = Read-Host "`nVeuillez saisir votre choix 0-2"

        # Si l'utilisateur veut revenir au menu principal
        if ($choice -eq "0") {
            break  # On sort de la boucle => retour au menu principal
        }
        # Si l'utilisateur veut consulter d'autres journaux
        elseif ($choice -eq "1") {
            # Liste des journaux disponibles
            $logList = @(
                "Active Directory Web Services", "DNS Server", "Security", "Application", "HardwareEvents", "System",
                "DFS Replication", "Internet Explorer", "Windows PowerShell", "Directory Service", "Key Management Service"
            )

            # Nettoyage de l'affichage
            Clear-Host
            Write-Host "===== GESTION DES EVENEMENTS (ERREURS) =====" -ForegroundColor Cyan
            Write-Host "Journaux disponibles :" -ForegroundColor Yellow
            # Affiche chaque journal
            $logList | ForEach-Object { Write-Host "- $_" }

            # Demande � l'utilisateur quels journaux il veut analyser
            do {
                $inputLogs = Read-Host "`nEntrez les noms exacts des journaux � analyser, s�par�s par des virgules"
                $logNames = $inputLogs -split ',' | ForEach-Object { $_.Trim() }
                # V�rifie que les noms sont valides
                $invalidLogs = $logNames | Where-Object { -not ($logList -contains $_) }

                if ($invalidLogs.Count -gt 0) {
                    Write-Host "Journaux invalides : $($invalidLogs -join ', '). Veuillez r�essayer." -ForegroundColor Red
                } else {
                    break
                }
            } while ($true)

            # Demande le nombre de jours � analyser
            do {
                $daysInput = Read-Host "Nombre de jours � analyser (par d�faut 7)"
                if ([string]::IsNullOrWhiteSpace($daysInput)) { $days = 7; break }
                elseif ($daysInput -match '^\d+$' -and [int]$daysInput -gt 0) { $days = [int]$daysInput; break }
                else { Write-Host "Veuillez entrer un nombre entier positif valide." -ForegroundColor Red }
            } while ($true)

            # Demande si on veut exporter les r�sultats
            $exportChoice = Read-Host "Voulez-vous exporter les r�sultats ? (O/N)"
            $export = ($exportChoice.ToUpper() -eq 'O')

            # Appelle la fonction avec les param�tres choisis
            Get-ErrorLogs -LogNames $logNames -Days $days -Export:($export)
        }
        # Si l'utilisateur choisit la surveillance en temps r�el
        elseif ($choice -eq "2") {
            Watch-FailedLogons
        }
        else {
            # Si entr�e invalide
            Write-Host "Choix invalide, retour au menu des �v�nements." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }

    } while ($true)  # FIN DE LA BOUCLE DU SOUS-MENU

}  # FIN DU elseif ($maVar -eq "5")

############## GESTION DES PROCESSUS ##############

# V�rifie si la variable $maVar est �gale � "6"
elseif ($maVar -eq "6") {

    # D�finit le chemin du dossier o� seront stock�s les logs
    $logFolder = "C:\Logs\ProcessManager"

    # V�rifie si le dossier de logs n'existe pas
    if (-not (Test-Path $logFolder)) {
        # Cr�e le dossier de logs (et dossiers parents si besoin)
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
        # Out-Null supprime la sortie affich�e � l'�cran pour rendre le script plus propre
    }

    # D�finit le chemin complet du fichier log du jour, avec la date au format yyyyMMdd
    $logFile = Join-Path $logFolder "process_manager_log_$(Get-Date -Format 'yyyyMMdd').log"

    # D�finition d'une fonction pour �crire un message dans le fichier log
    function Write-Log {
        # Param�tres de la fonction : Message (texte � enregistrer) et Level (niveau, par d�faut INFO)
        param(
            [string]$Message,
            [string]$Level = "INFO"
        )
        # R�cup�re la date et l'heure actuelles au format "aaaa-MM-jj HH:mm:ss"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # Compose la ligne � �crire dans le log : date, niveau et message
        $logEntry = "$timestamp [$Level] - $Message"
        # Ajoute cette ligne � la fin du fichier log
        Add-Content -Path $logFile -Value $logEntry
    }

    # Fonction pour bloquer certains processus les week-ends
    function Block-WeekendProcesses {
        # Liste des noms de processus � bloquer (en majuscules)
        $blockedProcesses = @("EXCEL", "WINWORD")

        # Fichier log sp�cifique pour le blocage week-end
        $weekendLogFile = Join-Path $logFolder "weekend_block_log_$(Get-Date -Format 'yyyyMMdd').log"

        # V�rifie si ce fichier log n'existe pas
        if (-not (Test-Path $weekendLogFile)) {
            # Cr�e un fichier vide pour le log
            New-Item -Path $weekendLogFile -ItemType File -Force | Out-Null
        }

        # Petite fonction interne pour �crire dans le log du blocage week-end
        function Write-WeekendLog {
            param([string]$message)
            # R�cup�re la date et l'heure
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            # Compose la ligne et l'ajoute � la fin du fichier weekend_log
            "$timestamp - $message" | Out-File -FilePath $weekendLogFile -Append -Encoding UTF8
        }

        # R�cup�re le jour actuel de la semaine (exemple : Monday, Saturday...)
        $today = (Get-Date).DayOfWeek

        # V�rifie si on est samedi ou dimanche
        if ($today -eq 'Saturday' -or $today -eq 'Sunday') {
            # Affiche un message pour pr�venir que le blocage est actif
            Write-Host "Blocage des processus activ� (jour : $today). Appuyez sur Ctrl+C pour arr�ter." -ForegroundColor Cyan

            # Commence une boucle infinie dans un bloc try (pour g�rer l'arr�t propre avec Ctrl+C)
            try {
                while ($true) {
                    # Pour chaque nom de processus interdit
                    foreach ($procName in $blockedProcesses) {
                        # Recherche tous les processus en cours avec ce nom (insensible � la casse)
                        $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName.ToUpper() -eq $procName }
                        # Pour chaque processus trouv�
                        foreach ($proc in $procs) {
                            try {
                                # Tente de tuer le processus (par son Id) avec -Force (arr�t imm�diat)
                                Stop-Process -Id $proc.Id -Force
                                # Pr�pare un message de log indiquant que le processus a �t� arr�t�
                                $logMsg = "Processus $($proc.ProcessName) (ID $($proc.Id)) tu� car interdit le week-end."
                                # Affiche ce message en rouge
                                Write-Host $logMsg -ForegroundColor Red
                                # �crit ce message dans le fichier log weekend
                                Write-WeekendLog $logMsg
                            } catch {
                                # En cas d'erreur, affiche un message d'erreur rouge
                                Write-Host "Erreur en tuant $($proc.ProcessName) (ID $($proc.Id)) : $_" -ForegroundColor Red
                            }
                        }
                    }
                    # Attend 10 secondes avant de recommencer la v�rification
                    Start-Sleep -Seconds 10
                }
            }
            catch [System.Exception] {
                # Si l'utilisateur interrompt (Ctrl+C), ce bloc catch est ex�cut�
                Write-Host "`nBlocage arr�t�. Retour au menu..." -ForegroundColor Cyan
                # Pause de 2 secondes avant de revenir au menu
                Start-Sleep -Seconds 2
            }
        }
        else {
            # Si ce n'est pas le week-end, affiche que le blocage ne s'applique pas
            Write-Host "Aujourd'hui c'est $today, pas de blocage des processus le week-end." -ForegroundColor Green
            # Attend une touche pour continuer (emp�che la fermeture directe)
            Read-Host "Appuyez sur une touche pour continuer..."
        }
    }

    # Fonction principale qui affiche le menu de gestion des processus et traite les choix
    function Show-ProcessManager {
        do {
            # Nettoie l'�cran (console)
            Clear-Host

            # Affiche une barre d�corative en cyan
            Write-Host "=====================================" -ForegroundColor Cyan
            # Affiche le titre avec fond bleu fonc� et texte cyan
            Write-Host "          GESTION DES PROCESSUS       " -ForegroundColor Cyan -BackgroundColor DarkBlue
            Write-Host "=====================================" -ForegroundColor Cyan
            Write-Host ""

            # Affiche les options du menu en jaune
            Write-Host " 0. Retour au menu principal" -ForegroundColor Yellow
            Write-Host " 1. Lister les processus" -ForegroundColor Yellow
            Write-Host " 2. Arr�ter un processus" -ForegroundColor Yellow
            Write-Host " 3. Lancer un programme" -ForegroundColor Yellow
            Write-Host " 4. Voir les derniers logs" -ForegroundColor Yellow
            Write-Host " 5. Surveillance des processus interdits" -ForegroundColor Yellow
            Write-Host " 6. Blocage des processus le week-end" -ForegroundColor Yellow
            Write-Host ""

            Write-Host "=====================================" -ForegroundColor Cyan
            Write-Host "Veuillez saisir votre choix : " -NoNewline  # Affiche sans saut de ligne

            # Lit le choix de l'utilisateur depuis la console
            $choice = Read-Host "Choix"

            # Switch pour traiter la valeur du choix
            switch ($choice) {
                # Si l'utilisateur tape 0
                "0" {
                    Write-Host "Retour au menu principal..." -ForegroundColor Cyan
                }
                # Si choix 1 : afficher les 20 processus les plus gourmands en CPU
                "1" {
                    Write-Host "`nTop 20 des processus par usage CPU :`n" -ForegroundColor Yellow
                    try {
                        # R�cup�re tous les processus avec une valeur CPU valide, trie par CPU d�croissant,
                        # prend les 20 premiers, affiche un tableau avec Id, Nom, CPU et m�moire utilis�e
                        Get-Process |
                            Where-Object { $_.CPU -is [double] } |
                            Sort-Object CPU -Descending |
                            Select-Object -First 20 |
                            Format-Table Id, ProcessName, CPU, WorkingSet -AutoSize
                        # Log que la liste a �t� affich�e
                        Write-Log "Liste des 20 processus les plus consommateurs de CPU affich�e."
                    } catch {
                        # En cas d'erreur, affiche un message rouge et log l'erreur
                        Write-Host "Erreur lors de l'affichage des processus : $_" -ForegroundColor Red
                        Write-Log "Erreur lors de l'affichage des processus : $_" "ERROR"
                    }
                    # Attend que l'utilisateur appuie sur une touche avant de continuer
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 2 : arr�ter un processus donn� par son nom
                "2" {
                    # Demande � l'utilisateur le nom du processus � arr�ter
                    $procName = Read-Host "Nom du processus � arr�ter"
                    try {
                        # Tente d'arr�ter le processus par son nom avec option -Force
                        Stop-Process -Name $procName -Force -ErrorAction Stop
                        # Affiche un message vert si r�ussi
                        Write-Host "Processus $procName arr�t� avec succ�s." -ForegroundColor Green
                        # Log l'arr�t r�ussi
                        Write-Log "Processus '$procName' arr�t� avec succ�s."
                    } catch {
                        # En cas d'erreur, affiche un message rouge et log l'erreur
                        Write-Host "Erreur : impossible d'arr�ter $procName. $_" -ForegroundColor Red
                        Write-Log "Erreur lors de l'arr�t du processus '$procName' : $_" "ERROR"
                    }
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 3 : lancer un programme � partir de son chemin complet
                "3" {
                    # Demande le chemin complet du programme
                    $exePath = Read-Host "Chemin complet du programme � lancer"
                    try {
                        # D�marre le programme demand�
                        Start-Process $exePath
                        # Affiche un message vert pour confirmation
                        Write-Host "Programme lanc� : $exePath" -ForegroundColor Green
                        # Log du lancement du programme
                        Write-Log "Programme lanc� : $exePath"
                    } catch {
                        # En cas d'erreur, affiche un message rouge et log l'erreur
                        Write-Host "Erreur : $_" -ForegroundColor Red
                        Write-Log "Erreur lors du lancement du programme '$exePath' : $_" "ERROR"
                    }
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 4 : afficher les 20 derni�res lignes du fichier log principal
                "4" {
                    # V�rifie si le fichier log principal existe
                    if (Test-Path $logFile) {
                        Write-Host "`n=== Derniers logs ===`n" -ForegroundColor Cyan
                        # Affiche les 20 derni�res lignes du fichier log
                        Get-Content $logFile -Tail 20 | ForEach-Object { Write-Host $_ }
                        # Log la consultation des logs
                        Write-Log "Consultation des derniers logs."
                    } else {
                        # Si pas de fichier log, affiche un message jaune
                        Write-Host "Aucun log trouv�." -ForegroundColor Yellow
                    }
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 5 : surveiller les processus interdits (chrome, firefox)
                "5" {
                    # Liste des processus interdits � surveiller
                    $interdits = @("chrome", "firefox")
                    # Fichier log pour cette surveillance
                    $logPath = "C:\logs\surveillance.log"
                    # Si ce fichier n'existe pas, le cr�e
                    if (-not (Test-Path -Path $logPath)) {
                        New-Item -Path $logPath -ItemType File -Force | Out-Null
                    }

                    # Variable pour contr�ler la boucle de surveillance
                    $continueMonitoring = $true
                    # Affiche instruction � l'utilisateur
                    Write-Host "Surveillance en cours. Tapez 'q' puis Entr�e pour arr�ter."

                    # Boucle infinie tant que $continueMonitoring est vrai
                    while ($continueMonitoring) {
                        # Pour chaque processus interdit
                        foreach ($nom in $interdits) {
                            # Recherche les processus en cours portant ce nom
                            $proc = Get-Process -Name $nom -ErrorAction SilentlyContinue
                            if ($proc) {
                                # R�cup�re le nom d'utilisateur courant
                                $utilisateur = $env:USERNAME
                                # R�cup�re la date et l'heure actuelles
                                $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                                # Pour chaque processus trouv�
                                foreach ($p in $proc) {
                                    # Tente de tuer le processus
                                    Stop-Process -Id $p.Id -Force
                                    # Compose la ligne de log avec date, utilisateur et nom du processus interdit
                                    $ligne = "$date - $utilisateur a lanc� un processus interdit : $($p.ProcessName)"
                                    # Ajoute la ligne au fichier log
                                    Add-Content -Path $logPath -Value $ligne
                                    # Affiche la ligne � l'�cran
                                    Write-Host $ligne
                                }
                            }
                        }

                        # Demande � l'utilisateur s'il veut arr�ter la surveillance
                        Write-Host "Tapez 'q' puis Entr�e pour arr�ter la surveillance, ou juste Entr�e pour continuer..."
                        $i = Read-Host
                        if ($i -eq "q") {
                            # Si 'q' tap�, stoppe la boucle
                            $continueMonitoring = $false
                            Write-Host "Surveillance arr�t�e. Retour au menu..." -ForegroundColor Cyan
                            # Pause de 2 secondes avant retour au menu
                            Start-Sleep -Seconds 2
                        }
                    }
                }
                # Si choix 6 : appelle la fonction de blocage des processus le week-end
                "6" {
                    Block-WeekendProcesses
                }
                # Pour toute autre saisie non pr�vue
                default {
                    # Affiche un message d'erreur en rouge
                    Write-Host "Choix invalide." -ForegroundColor Red
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
            }

        # Tant que l'utilisateur n'a pas choisi "0", la boucle continue
        } while ($choice -ne "0")
    }

    # Appelle la fonction Show-ProcessManager pour lancer le menu
    Show-ProcessManager
}

############## GESTION DES SERVICES ##############

# Si je choisis l'option 7 dans le menu principal, j'ex�cute ce bloc
elseif ($maVar -eq "7") {

    # D�finition d'une fonction qui va tout regrouper : v�rification + actions possibles sur les services
    function Show-ServiceManager {
        Clear-Host  # Efface l'�cran pour rendre l'affichage plus lisible
        Write-Host "=== GESTION DES SERVICES ===" -ForegroundColor Cyan  # Affiche le titre principal en cyan

        # Liste des services critiques � surveiller sur un contr�leur de domaine
        $servicesCritiques = @(
            "wuauserv", "NTDS", "DNS", "Netlogon", "KDC", "W32Time",
            "LanmanServer", "LanmanWorkstation", "DFSR", "RpcSs", "SamSs"
        )

        # Affiche un sous-titre pour la v�rification des services critiques, avec retour � la ligne
        Write-Host "`n=== V�RIFICATION DES SERVICES CRITIQUES ===" -ForegroundColor Cyan

        # Pour chaque service dans la liste des services critiques, on effectue la v�rification
        foreach ($svc in $servicesCritiques) {
            try {
                # Essaye de r�cup�rer l'�tat du service nomm� $svc
                $etat = (Get-Service -Name $svc).Status
                # Si le service est en cours d'ex�cution ("Running")
                if ($etat -eq "Running") {
                    # Affiche le nom du service format� sur 20 caract�res et "OK" en vert
                    Write-Host ("{0,-20}: OK" -f $svc) -ForegroundColor Green
                } else {
                    # Sinon, affiche que le service est non disponible, avec son �tat en rouge
                    Write-Host ("{0,-20}: NON DISPONIBLE (�tat = {1})" -f $svc, $etat) -ForegroundColor Red
                }
            } catch {
                # En cas d'erreur (service introuvable), affiche un message d'erreur en rouge fonc�
                Write-Host ("{0,-20}: ERREUR - service introuvable" -f $svc) -ForegroundColor DarkRed
            }
        }

        # Obtient la date et l'heure actuelles
        $date = Get-Date
        # Formate la date pour l'horodatage du rapport (ex: 2025-07-18_15-30)
        $horodatage = $date.ToString("yyyy-MM-dd_HH-mm")
        # D�finit le chemin du dossier de rapport, organis� par ann�e et mois (ex: C:\Rapports\2025\08)
        $cheminRapport = "C:\Rapports\$($date.Year)\$("{0:D2}" -f $date.Month)"
        # D�finit le chemin complet du fichier rapport texte
        $rapportTxt = Join-Path $cheminRapport "services_AD_$horodatage.txt"
        # D�finit le chemin complet du fichier rapport HTML
        $rapportHtml = Join-Path $cheminRapport "services_AD_$horodatage.html"
        # D�finit le chemin complet du fichier rapport PDF
        $rapportPDF = Join-Path $cheminRapport "services_AD_$horodatage.pdf"

        # V�rifie si le dossier de rapport existe, sinon le cr�e
        if (!(Test-Path $cheminRapport)) {
            New-Item -Path $cheminRapport -ItemType Directory -Force | Out-Null
        }

        # R�cup�re l'�tat de tous les services critiques (nom, affichage et statut)
        $etatServices = Get-Service -Name $servicesCritiques | Select-Object DisplayName, Name, Status
        # Filtre les services en fonctionnement
        $servicesOK = $etatServices | Where-Object { $_.Status -eq "Running" }
        # Filtre les services qui ne tournent pas (arr�t�s ou en erreur)
        $servicesKO = $etatServices | Where-Object { $_.Status -ne "Running" }

        # ===== CR�ATION DU RAPPORT TEXTE =====
        # �crit l'en-t�te du rapport texte avec la date actuelle
        @"
Rapport de supervision des services Active Directory
Date de g�n�ration : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
=====================================================

Services en cours d'ex�cution :
"@ | Out-File $rapportTxt  # Enregistre ce bloc dans le fichier texte

        # Ajoute dans le fichier texte la liste format�e des services en fonctionnement
        $servicesOK | Format-Table -AutoSize | Out-String | Out-File $rapportTxt -Append

        # Ajoute un titre dans le fichier texte pour les services arr�t�s ou indisponibles
        "`nServices arr�t�s ou non disponibles :" | Out-File $rapportTxt -Append
        # Si la liste des services KO n'est pas vide
        if ($servicesKO.Count -gt 0) {
            # Ajoute la liste format�e des services KO au fichier texte
            $servicesKO | Format-Table -AutoSize | Out-String | Out-File $rapportTxt -Append
        } else {
            # Sinon indique qu'aucun probl�me n'a �t� d�tect�
            "Aucun probl�me d�tect�." | Out-File $rapportTxt -Append
        }

        # ===== CR�ATION DU RAPPORT HTML =====
        # Convertit l'�tat des services en tableau HTML avec titre et contenu personnalis�
        $etatServices | ConvertTo-Html -Title "�tat des services AD - $horodatage" `
            -PreContent "<h2 style='color:navy;'>Supervision des services Active Directory</h2><p>Date : $horodatage</p>" |
            ForEach-Object {
                # Si des services sont arr�t�s, change la couleur de fond du corps HTML en rouge clair
                if ($servicesKO.Count -gt 0) {
                    $_ -replace "<body>", "<body style='background-color:#ffe6e6;'>"
                } else {
                    # Sinon ne modifie pas le corps
                    $_
                }
            } | Out-File $rapportHtml  # Sauvegarde le rapport HTML dans un fichier

        # ===== CONVERSION HTML → PDF AVEC EDGE =====
        # D�finit le chemin vers l'ex�cutable Microsoft Edge (version 32 bits)
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
        # V�rifie si Edge est install� sur ce chemin
        if (Test-Path $edgePath) {
            # Lance Edge en mode headless pour imprimer le HTML en PDF dans le fichier PDF d�fini
            & $edgePath --headless --disable-gpu --print-to-pdf="$rapportPDF" "file:///$rapportHtml"
            # Indique que le PDF a �t� g�n�r� avec succ�s
            Write-Host "Rapport PDF g�n�r� : $rapportPDF" -ForegroundColor Cyan
        } else {
            # Si Edge n'est pas trouv�, affiche un message d'erreur en rouge
            Write-Host "Microsoft Edge non trouv�. Impossible de g�n�rer le PDF." -ForegroundColor Red
        }

        # Affiche les chemins des rapports g�n�r�s (texte et HTML)
        Write-Host "`nRapport g�n�r� avec succ�s :" -ForegroundColor Green
        Write-Host " - Texte : $rapportTxt"
        Write-Host " - HTML  : $rapportHtml"

        # Si au moins un service est arr�t�, affiche une alerte rouge invitant � v�rifier le rapport
        if ($servicesKO.Count -gt 0) {
            Write-Host "`nServices arr�t�s d�tect�s ! V�rifiez le rapport." -ForegroundColor Red
        }

        # ===== MENU INTERACTIF POUR G�RER LES SERVICES =====
        # Affiche les options du menu interactif en jaune
        Write-Host "`n0. Retour au menu principal" -ForegroundColor Yellow
        Write-Host "1. Lister les services" -ForegroundColor Yellow    
        Write-Host "2. D�marrer un service" -ForegroundColor Yellow
        Write-Host "3. Arr�ter un service" -ForegroundColor Yellow
        Write-Host "4. Red�marrer un service" -ForegroundColor Yellow
        
        # Demande � l'utilisateur de saisir son choix
        $choice = Read-Host "`nVotre choix"

        # Ex�cute une action selon le choix de l'utilisateur
        switch ($choice) {
            "0" {
                # Retour au menu principal, message informatif en cyan
                Write-Host "Retour au menu principal..." -ForegroundColor Cyan
            }
            "1" {
                # Affiche la liste compl�te des services tri�s par statut et nom
                Write-Host "`nListe compl�te des services :" -ForegroundColor Yellow
                Get-Service | Sort-Object Status, DisplayName | Format-Table Status, DisplayName, Name -AutoSize
            }
            "2" {
                # Demande le nom du service � d�marrer
                $svcName = Read-Host "Nom du service � d�marrer"
                try {
                    # Essaie de d�marrer le service avec gestion des erreurs
                    Start-Service -Name $svcName -ErrorAction Stop
                    # Confirmation en vert du d�marrage
                    Write-Host "Service $svcName d�marr�." -ForegroundColor Green
                } catch {
                    # Affiche l'erreur en rouge si probl�me lors du d�marrage
                    Write-Host "Erreur : $_" -ForegroundColor Red
                }
            }
            "3" {
                # Demande le nom du service � arr�ter
                $svcName = Read-Host "Nom du service � arr�ter"
                try {
                    # Essaie d'arr�ter le service, en for�ant l'arr�t si n�cessaire
                    Stop-Service -Name $svcName -Force -ErrorAction Stop
                    # Confirmation en vert de l'arr�t
                    Write-Host "Service $svcName arr�t�." -ForegroundColor Green
                } catch {
                    # Affiche l'erreur en rouge si probl�me lors de l'arr�t
                    Write-Host "Erreur : $_" -ForegroundColor Red
                }
            }
            "4" {
                # Demande le nom du service � red�marrer
                $svcName = Read-Host "Nom du service � red�marrer"
                try {
                    # Essaie de red�marrer le service
                    Restart-Service -Name $svcName -ErrorAction Stop
                    # Confirmation en vert du red�marrage
                    Write-Host "Service $svcName red�marr�." -ForegroundColor Green
                } catch {
                    # Affiche l'erreur en rouge si probl�me lors du red�marrage
                    Write-Host "Erreur : $_" -ForegroundColor Red
                }
            }
            
            default {
                # Si le choix ne correspond � aucune option, affiche une erreur
                Write-Host "Choix invalide." -ForegroundColor Red
            }
        }

        Pause  # Met en pause l'ex�cution pour que l'utilisateur puisse lire les r�sultats
    }

    # J'appelle ma fonction pour ex�cuter le gestionnaire de services
    Show-ServiceManager
}

#### SUPERVISION CORRECTIVE ############

# V�rifie si la variable $maVar vaut "8" (condition d'entr�e du script)
if ($maVar -eq "8") {
    # Affiche un message indiquant le lancement du script, en jaune
    Write-Host "=== Lancement du script de supervision corrective ===" -ForegroundColor Yellow

    # === Script de Supervision Corrective pour Administrateur Syst�mes et R�seaux ===
    # Compatible PowerShell 5+ - � ex�cuter avec privil�ges administrateur

    # === CONFIGURATION GLOBALE ===
    # R�cup�re le chemin complet du script en cours d'ex�cution
    $scriptPath = $MyInvocation.MyCommand.Path
    # D�finit le nom de la t�che planifi�e � cr�er
    $taskName = "Surveillance_Corrective"
    # D�finit la source utilis�e pour l'�criture dans le journal des �v�nements
    $eventSource = "SupervisionTSSR"

    # V�rifie si la source d'�v�nements existe d�j� dans le journal Windows
    if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
        # Si non, cr�e une nouvelle source dans le journal "Application"
        New-EventLog -LogName "Application" -Source $eventSource
    }

    # D�finition d'une fonction pour �crire dans le journal des �v�nements Windows
    Function Write-Log {
        param(
            [string]$Message,  # Message � �crire
            [string]$Type = "Information"  # Type d'entr�e (Information par d�faut)
        )
        # Convertit la cha�ne en type d'entr�e d'�v�nement Windows
        $entryType = [System.Diagnostics.EventLogEntryType]::$Type
        # �crit l'entr�e dans le journal "Application" avec la source d�finie
        Write-EventLog -LogName "Application" -Source $eventSource -EntryType $entryType -EventId 1000 -Message $Message
    }

    # === MENU PRINCIPAL ===
    do {
        Clear-Host  # Efface l'�cran de la console
        Write-Host "===== MENU DE SUPERVISION CORRECTIVE =====" -ForegroundColor Cyan
        Write-Host "0. Quitter" -ForegroundColor Yellow
        Write-Host "1. Lancer la supervision corrective" -ForegroundColor Yellow
        Write-Host "2. Cr�er la t�che planifi�e automatique" -ForegroundColor Yellow
        # Demande � l'utilisateur de choisir une option via saisie clavier
        $maVar = Read-Host "Choisissez une option"

        # Si l'utilisateur choisit "0", quitter la boucle et donc le script
        if ($maVar -eq "0") {
            Write-Host "Fermeture du script." -ForegroundColor Yellow
            break
        }

        # Si l'utilisateur choisit "1", lancer la supervision corrective
        elseif ($maVar -eq "1") {
            Clear-Host  # Efface la console
            Write-Host "=== Lancement du script de supervision corrective ===" -ForegroundColor Cyan

            # === CONFIGURATION DE LA SUPERVISION ===
            # D�finition d'une liste noire de noms de processus suspects � surveiller
            $blacklist = @(
                'notepad', 'mimikatz', 'metasploit', 'powershell', 'cmd',
                'wmic', 'taskmgr', 'netstat', 'rundll32', 'cscript', 'wscript'
            )

            # Liste des services critiques � v�rifier et red�marrer si arr�t�s
            $criticalServices = @(
                'Spooler', 'WinDefend', 'W32Time', 'LanmanServer', 'LanmanWorkstation',
                'EventLog', 'Dhcp', 'Dnscache', 'Netlogon', 'RpcSs', 'BITS',
                'WinRM', 'TermService', 'CryptSvc', 'TrustedInstaller'
            )

            # === V�RIFICATION DES PROCESSUS SUSPECTS ===
            Write-Host "`n[*] V�rification des processus suspects..." -ForegroundColor Yellow
            # R�cup�re la liste compl�te des processus en cours
            $processes = Get-Process
            # Filtre les processus dont le nom figure dans la liste noire
            $suspects = $processes | Where-Object { $_.ProcessName -in $blacklist }

            # Si aucun processus suspect d�tect�
            if ($suspects.Count -eq 0) {
                Write-Host "Aucun processus suspect d�tect�." -ForegroundColor Green
            } else {
                # Sinon, pour chaque processus suspect d�tect�
                foreach ($proc in $suspects) {
                    try {
                        # Affiche le nom du processus suspect d�tect�
                        Write-Host "[!] Processus suspect d�tect� : $($proc.ProcessName)" -ForegroundColor Red
                        # Tente de forcer l'arr�t du processus
                        Stop-Process -Id $proc.Id -Force
                        Write-Host "    -> Processus arr�t�." -ForegroundColor Red

                        # Tentative de d�sactivation des interfaces r�seau pour confinement
                        # V�rifie si le module NetAdapter est disponible
                        if (-not (Get-Module -ListAvailable -Name NetAdapter)) {
                            Write-Host "    -> Module NetAdapter non trouv�, d�sactivation r�seau impossible." -ForegroundColor Yellow
                        } else {
                            # Importe le module NetAdapter
                            Import-Module NetAdapter
                            # R�cup�re toutes les interfaces r�seau actives (status "Up")
                            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
                            # Pour chaque interface active, la d�sactive sans confirmation
                            foreach ($adapter in $adapters) {
                                Disable-NetAdapter -Name $adapter.Name -Confirm:$false
                                Write-Host "    -> Interface r�seau $($adapter.Name) d�sactiv�e." -ForegroundColor Red
                            }
                        }

                        # �crit un log indiquant que le processus suspect a �t� stopp� et le r�seau d�sactiv�
                        Write-Log "Processus suspect $($proc.ProcessName) stopp� et interfaces r�seau d�sactiv�es."
                    } catch {
                        # En cas d'erreur, affiche et log l'erreur de confinement
                        Write-Host "Erreur de confinement : $_" -ForegroundColor Red
                        Write-Log "Erreur confinement $($proc.ProcessName) : $_" "Error"
                    }
                }
            }

            # === CONTR�LE DES SERVICES CRITIQUES ===
            Write-Host "`nV�rification des services critiques..." -ForegroundColor Yellow
            # Pour chaque service critique dans la liste
            foreach ($svc in $criticalServices) {
                try {
                    # R�cup�re l'�tat du service (stoppe si erreur)
                    $service = Get-Service -Name $svc -ErrorAction Stop
                    # Si le service n'est pas en cours d'ex�cution
                    if ($service.Status -ne 'Running') {
                        # D�marre le service
                        Start-Service -Name $svc
                        Write-Host "    -> Service critique '$svc' red�marr�." -ForegroundColor Green
                        # Log du red�marrage automatique
                        Write-Log "Service '$svc' red�marr� automatiquement."
                    } else {
                        Write-Host "    -> Service '$svc' op�rationnel." -ForegroundColor Green
                    }
                } catch {
                    # En cas d'erreur lors de la r�cup�ration du service, affiche et log un avertissement
                    Write-Host "    -> Erreur service '$svc' : $_" -ForegroundColor Red
                    Write-Log "Erreur service '$svc' : $_" "Warning"
                }
            }

            # === COLLECTE D'INFORMATIONS SYST��ME ===
            Write-Host "`nCollecte d'un snapshot syst�me..." -ForegroundColor Yellow
            # D�finit un timestamp pour nommer le dossier snapshot
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            # D�finit le chemin de sauvegarde du snapshot syst�me
            $snapshotDir = "C:\Logs\Snapshot_$timestamp"
            # Cr�e le dossier pour le snapshot (force cr�ation m�me si existant)
            New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

            try {
                # R�cup�re les infos m�moire et exporte en CSV dans le dossier snapshot
                Get-CimInstance Win32_OperatingSystem |
                    Select-Object TotalVisibleMemorySize, FreePhysicalMemory |
                    Export-Csv -Path "$snapshotDir\Memory.csv" -NoTypeInformation

                # R�cup�re les volumes/disques et exporte en CSV dans le dossier snapshot
                Get-Volume |
                    Select-Object DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size |
                    Export-Csv -Path "$snapshotDir\Disks.csv" -NoTypeInformation

                # Indique � l'utilisateur que le snapshot a �t� sauvegard�
                Write-Host "Snapshot syst�me sauvegard� dans $snapshotDir" -ForegroundColor Green
                # Log l'enregistrement r�ussi du snapshot
                Write-Log "Snapshot syst�me enregistr� dans $snapshotDir"
            } catch {
                # En cas d'erreur lors de la collecte snapshot, affiche et log l'erreur
                Write-Host "Erreur snapshot : $_" -ForegroundColor Red
                Write-Log "Erreur snapshot syst�me : $_" "Error"
            }

            # Indique la fin de la supervision corrective
            Write-Host "`n=== Supervision corrective termin�e ===" -ForegroundColor Cyan
            # Attend que l'utilisateur appuie sur Entr�e pour revenir au menu
            Read-Host "`nAppuyez sur Entr�e pour revenir au menu principal..."
        }

        # Si l'utilisateur choisit "2", cr�ation de la t�che planifi�e automatique
        elseif ($maVar -eq "2") {
            Clear-Host
            Write-Host "=== Cr�ation de la t�che planifi�e ===" -ForegroundColor Cyan

            # V�rifie si la t�che planifi�e existe d�j�
            if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
                Write-Host "La t�che planifi�e '$taskName' existe d�j�. Elle ne sera pas modifi�e." -ForegroundColor Yellow
                Write-Log "La t�che planifi�e '$taskName' existe d�j�. Aucun changement effectu�."
            } else {
                try {
                    # Cr�e un trigger de t�che planifi�e : lance une fois dans 1 minute,
                    # puis r�p�te toutes les 10 minutes pendant 10 ans
                    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
                        -RepetitionInterval (New-TimeSpan -Minutes 10) `
                        -RepetitionDuration ([TimeSpan]::FromDays(3650))  # 10 ans

                    # D�finit l'action � ex�cuter : lancement de powershell avec param�tres pour ex�cuter ce script
                    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
                                -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

                    # D�finit le compte d'ex�cution SYSTEM avec privil�ges �lev�s
                    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

                    # Enregistre la t�che planifi�e avec nom, trigger, action, principal et description
                    Register-ScheduledTask -TaskName $taskName -Trigger $trigger `
                                           -Action $action -Principal $principal `
                                           -Description "Supervision corrective automatique PowerShell"

                    Write-Host "[OK] T�che planifi�e '$taskName' cr��e." -ForegroundColor Green
                    Write-Log "T�che planifi�e '$taskName' enregistr�e avec succ�s."
                } catch {
                    # En cas d'erreur lors de la cr�ation, affiche et log l'erreur
                    Write-Host "Erreur cr�ation t�che : $_" -ForegroundColor Red
                    Write-Log "Erreur cr�ation t�che planifi�e : $_" "Error"
                }
            }

            # Attend que l'utilisateur appuie sur Entr�e pour revenir au menu
            Read-Host "`nAppuyez sur Entr�e pour revenir au menu principal..."
        }

        else {
            # Si le choix ne correspond � aucune option valide, affiche un message d'erreur
            Write-Host "Choix invalide. R�essayez." -ForegroundColor Red
            # Pause de 2 secondes avant de redemander
            Start-Sleep -Seconds 2
        }

    } while ($true)  # Boucle infinie du menu tant que l'utilisateur ne quitte pas
} # Fin du if initial

# Si la saisie de l'utilisateur ne correspond � aucune option pr�vue
else {
    # On affiche un message d'erreur et on redemande un choix
    Write-Host "Choix non reconnu, merci de recommencer."
}
# Fin de la boucle ou du bloc principal
}

