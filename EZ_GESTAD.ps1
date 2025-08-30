# EZ-GESTION-AD / administration d’un domaine Active Directory via une interface GUI
# Par sbeteta@beteta.org

# Boucle principale : elle tourne en continu tant que l'utilisateur ne choisit pas de quitter.
while ($true) {

    # Efface le contenu de la console pour afficher un menu propre.
    Clear-Host
    Start-Sleep -Milliseconds 125
    # Affiche une ligne décorative pour le menu, avec une couleur cyan.
    Write-Host "========================================" -ForegroundColor Cyan

    # Affiche le titre "MENU PRINCIPAL" avec texte cyan sur fond noir.
    Write-Host "           MENU PRINCIPAL" -ForegroundColor Cyan -BackgroundColor Black

    # Affiche une autre ligne décorative + retour à  la ligne (`n = new line).
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Affiche l'option 0 : quitter le programme.
    Write-Host " 0 - Quitter" -ForegroundColor Yellow

    # Affiche l'option 1 : configurer les unités d'organisation (OU).
    Write-Host " 1 - Configuration des OU" -ForegroundColor Yellow

    # Affiche l'option 2 : configurer les utilisateurs.
    Write-Host " 2 - Configuration des USERS" -ForegroundColor Yellow

    # Affiche l'option 3 : configurer les groupes.
    Write-Host " 3 - Configuration des Groupes" -ForegroundColor Yellow

    # Affiche l'option 4 : configurer les stratégies de groupe (GPO).
    Write-Host " 4 - Configuration des GPO" -ForegroundColor Yellow

    # Affiche l'option 5 : gérer les journaux d'événements (logs Windows).
    Write-Host " 5 - Gestion des événements" -ForegroundColor Yellow

    # Affiche l'option 6 : gérer les processus en cours.
    Write-Host " 6 - Gestion des Processus" -ForegroundColor Yellow

    # Affiche l'option 7 : gérer les services (Windows Services).
    Write-Host " 7 - Gestion des Services" -ForegroundColor Yellow

    # Affiche l'option 8 : supervision corrective (par exemple, redémarrer un service arrêté).
    Write-Host " 8 - Supervision corrective des Services" -ForegroundColor Yellow

    # Invite l'utilisateur à  entrer son choix entre 0 et 8.
    # La valeur saisie est stockée dans la variable $maVar.
    $maVar = Read-Host "Veuillez saisir votre choix (0-8)"

    # Teste si l'utilisateur a saisi "0".
    # Cela signifie qu'il veut quitter le programme.
    if ($maVar -eq "0") {
        
        # Affiche un message pour dire que le programme va se fermer.
        Write-Host " Fermeture du programme."

        # Utilise le mot-clé 'break' pour sortir de la boucle while.
        # Cela met fin à  l'exécution du script.
        break
    }

############## CONFIGURATION DES UNITéS D'ORGANISATION ##############

# Si l'utilisateur a saisi "1" dans le menu principal, on entre ici
elseif ($maVar -eq "1") {

    # On crée une variable qui servira à  sortir du menu des OU quand ce sera nécessaire
    $exitOUMenu = $false

    # Cette boucle s'exécute tant que l'utilisateur ne demande pas à  revenir au menu principal
    while (-not $exitOUMenu) {

        # Efface l'affichage précédent dans la console
        Clear-Host

        # Affiche l'en-tête du sous-menu de gestion des OU
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "           OPTION CONFIG OU          " -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        # Affiche les options disponibles dans ce menu secondaire
        Write-Host " 0 - Retour au menu principal" -ForegroundColor Yellow
        Write-Host " 1 - Ajout d'OU" -ForegroundColor Yellow
        Write-Host " 2 - Suppression d'OU`n" -ForegroundColor Yellow

        # Demande à  l'utilisateur de saisir son choix et stocke la réponse
        $choix_ou = Read-Host "Votre choix"

        # En fonction du choix saisi, on utilise la structure switch pour exécuter une action
        switch ($choix_ou) {

            # Si l'utilisateur tape "0", on met fin à  la boucle et on retourne au menu principal
            "0" {
                $exitOUMenu = $true
            }

            # Si l'utilisateur tape "1", on va lancer le processus de création d'une OU
            "1" {
                # Affiche la liste actuelle des OU présentes dans le domaine
                Write-Host "`nOU existantes :"
                Get-ADOrganizationalUnit -Filter * -SearchBase "DC=formation,DC=lan" |
                    Sort-Object Name |                                     # Trie les OU par ordre alphabétique
                    Select-Object -ExpandProperty Name |                   # Récupère uniquement le nom de chaque OU
                    ForEach-Object { Write-Host " - $_" }                  # Affiche chaque nom d'OU

                # Demande à  l'utilisateur le nom de l'OU qu'il souhaite ajouter
                $nom_ou = Read-Host "Nom de l'OU à  ajouter"

                # Vérifie si une OU portant ce nom existe déjà  dans le domaine
                $ouExist = Get-ADOrganizationalUnit -Filter "Name -eq '$nom_ou'" -SearchBase "DC=formation,DC=lan" -ErrorAction SilentlyContinue

                # Si aucune OU du même nom n'existe, on procède à  la création
                if (-not $ouExist) {
                    try {
                        # Crée l'OU dans l'annuaire Active Directory
                        New-ADOrganizationalUnit -Name $nom_ou -Path "DC=formation,DC=lan" -ErrorAction Stop
                        Write-Host "OU '$nom_ou' créée." -ForegroundColor Green
                    } catch {
                        # Si une erreur survient, on l'affiche
                        Write-Host "Erreur lors de la création : $_" -ForegroundColor Red
                    }
                } else {
                    # Si une OU du même nom existe déjà , on en informe l'utilisateur
                    Write-Host "OU '$nom_ou' existe déjà ." -ForegroundColor Yellow
                }

                # Demande à  l'utilisateur d'appuyer sur Entrée avant de continuer
                Write-Host "`nAppuyez sur Entrée pour continuer..."
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

                # Demande à  l'utilisateur le nom de l'OU à  supprimer
                $nom_ou = Read-Host "Nom de l'OU à  supprimer"

                # Recherche l'OU dans le domaine avec le nom donné
                $ouToDelete = Get-ADOrganizationalUnit -Filter "Name -eq '$nom_ou'" -SearchBase "DC=formation,DC=lan" -ErrorAction SilentlyContinue

                # Si aucune OU ne correspond, on affiche un message d'erreur
                if ($null -eq $ouToDelete) {
                    Write-Host "L'OU '$nom_ou' n'existe pas." -ForegroundColor Red
                } else {
                    # Vérifie si l'OU contient des objets (utilisateurs, groupes, etc.)
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
                            Write-Host "OU '$nom_ou' supprimée." -ForegroundColor Green
                        } catch {
                            # En cas d'erreur, on l'affiche
                            Write-Host "Erreur lors de la suppression : $_" -ForegroundColor Red
                        }
                    }
                }

                # Pause pour permettre à  l'utilisateur de lire les messages
                Write-Host "`nAppuyez sur Entrée pour continuer..."
                Read-Host | Out-Null
            }

            # Si l'utilisateur entre une valeur incorrecte (autre que 0, 1, 2)
            default {
                Write-Host "Erreur : veuillez saisir 0, 1 ou 2." -ForegroundColor Red
                Write-Host "`nAppuyez sur Entrée pour réessayer..."
                Read-Host | Out-Null
            }
        }
    }
}

############## CONFIGURATION DES UTILISATEURS ##############

# Si l'utilisateur a saisi "2" dans le menu principal, on entre ici
elseif ($maVar -eq "2") {

    # On crée une variable vide pour y stocker les choix saisis par l'utilisateur dans ce sous-menu
    $choix_user = ""

    # Boucle infinie : on reste dans ce menu tant que l'utilisateur ne tape pas "0"
    while ($true) {

        # Affiche l'en-tête du menu de configuration des utilisateurs
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "           OPTION CONFIG USER           " -ForegroundColor Cyan
        Write-Host "========================================`n" -ForegroundColor Cyan

        # Affiche les différentes options disponibles pour gérer les utilisateurs
        Write-Host " 0 - Retour au menu principal" -ForegroundColor Yellow
        Write-Host " 1 - Ajout d'utilisateur" -ForegroundColor Yellow
        Write-Host " 2 - Suppression" -ForegroundColor Yellow
        Write-Host " 3 - Affectation à une OU" -ForegroundColor Yellow
        Write-Host " 4 - Affectation à un groupe" -ForegroundColor Yellow
        Write-Host " 5 - Gestion des ACL`n" -ForegroundColor Yellow

        # Demande à  l'utilisateur de saisir une option et la stocke dans la variable
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

            # Demande un mot de passe, saisi de manière masquée
            $mdp = Read-Host "Mot de passe" -AsSecureString

            # Affiche toutes les OU disponibles pour aider l'utilisateur à  choisir
            Write-Host "Liste des OU disponibles :"
            Get-ADOrganizationalUnit -SearchBase "DC=formation,DC=lan" -Filter * |
                Select-Object -ExpandProperty Name |
                ForEach-Object { Write-Host " - $_" }

            # L'utilisateur indique dans quelle OU créer le compte
            $ou = Read-Host "OU cible (choisir parmi la liste ci-dessus)"

            # Crée un nouvel utilisateur avec les informations fournies
            New-ADUser -Name $nom_user -SamAccountName $login_user -UserPrincipalName "${login_user}@formation.lan" `
                -AccountPassword $mdp -Enabled $true -Path "OU=$ou,DC=formation,DC=lan"

            # Affiche un message de confirmation
            Write-Host "Utilisateur '$nom_user' ajouté avec succès."
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
            $login_user = Read-Host "Login de l'utilisateur à  supprimer"

            # Vérifie si l'utilisateur existe, puis le supprime s'il est trouvé
            if (Get-ADUser -Identity $login_user -ErrorAction SilentlyContinue) {
                Remove-ADUser -Identity $login_user -Confirm:$false
                Write-Host "Utilisateur '$login_user' supprimé."
            } else {
                Write-Host "Utilisateur '$login_user' introuvable."
            }
        }

        # === OPTION 3 : DéPLACER UN UTILISATEUR DANS UNE AUTRE OU ===
        elseif ($choix_user -eq "3") {
            Write-Host "===== DéPLACEMENT DANS UNE OU =====" -ForegroundColor Yellow

            # Demande le login de l'utilisateur concerné
            $login_user = Read-Host "Login de l'utilisateur"

            # Affiche la liste des OU disponibles
            Write-Host "Liste des OU disponibles :"
            Get-ADOrganizationalUnit -SearchBase "DC=formation,DC=lan" -Filter * |
                Select-Object -ExpandProperty Name | ForEach-Object { Write-Host " - $_" }

            # L'utilisateur indique la nouvelle OU
            $ou = Read-Host "Nouvelle OU (choisir parmi la liste ci-dessus)"

            try {
                # Récupère l'utilisateur dans l'AD
                $user = Get-ADUser -Identity $login_user -ErrorAction Stop

                # Déplace l'utilisateur dans la nouvelle OU choisie
                Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=$ou,DC=formation,DC=lan"

                Write-Host "Utilisateur déplacé avec succès dans OU=$ou"
            } catch {
                # Message d'erreur si utilisateur ou OU incorrect
                Write-Host "Erreur : utilisateur '$login_user' introuvable ou OU incorrecte."
            }
        }

        # === OPTION 4 : AJOUTER UN UTILISATEUR à UN GROUPE ===
        elseif ($choix_user -eq "4") {
            Write-Host "===== AJOUT à UN GROUPE =====" -ForegroundColor Yellow

            # Demande le login de l'utilisateur à  ajouter
            $login_user = Read-Host "Login de l'utilisateur"

            # Affiche la liste des groupes existants
            Write-Host "Liste des groupes disponibles :"
            Get-ADGroup -Filter * | Select-Object -ExpandProperty Name | ForEach-Object { Write-Host " - $_" }

            # Demande à  l'utilisateur de choisir un groupe
            $groupe = Read-Host "Nom du groupe (choisir parmi la liste ci-dessus)"

            # Vérifie que l'utilisateur et le groupe existent dans l'AD
            if ((Get-ADUser -Identity $login_user -ErrorAction SilentlyContinue) -and (Get-ADGroup -Identity $groupe -ErrorAction SilentlyContinue)) {
                # Ajoute l'utilisateur au groupe
                Add-ADGroupMember -Identity $groupe -Members $login_user
                Write-Host "Utilisateur '$login_user' ajouté au groupe '$groupe'."
            } else {
                Write-Host "Erreur : utilisateur ou groupe introuvable."
            }
        }

        # === OPTION 5 : GESTION DES DROITS D'ACCàˆS (ACL) SUR DOSSIER ===
        elseif ($choix_user -eq "5") {

            # Affiche l'en-tête de la section ACL
            Write-Host "=====================================================" -ForegroundColor Cyan
            Write-Host "               CONFIG USER - Gestion ACL             " -ForegroundColor Cyan
            Write-Host "=====================================================`n" -ForegroundColor Cyan

            # Affiche un aide-mémoire des droits disponibles (FileSystemRights)
            Write-Host "Rappel des principaux types de permissions (FileSystemRights) disponibles :`n"

            # Affiche la liste complète des types de droits avec leur signification
            Write-Host "`t* FullControl`t: Contrà´le total (toutes les permissions)"
            Write-Host "`t* Modify`t: Lire, écrire, supprimer, créer, modifier"
            Write-Host "`t* ReadAndExecute`t: Lire le contenu et exécuter les fichiers"
            Write-Host "`t* Read`t: Lire les fichiers et les attributs"
            Write-Host "`t* Write`t: écrire dans les fichiers, créer des fichiers/dossiers"
            Write-Host "`t* ListDirectory`t: Voir le contenu du dossier"
            Write-Host "`t* ReadAttributes`t: Lire les attributs des fichiers/dossiers"
            Write-Host "`t* ReadExtendedAttributes`t: Lire les attributs étendus (métadonnées)"
            Write-Host "`t* WriteAttributes`t: Modifier les attributs"
            Write-Host "`t* WriteExtendedAttributes`t: Modifier les attributs étendus"
            Write-Host "`t* CreateFiles`t: Créer des fichiers dans un dossier"
            Write-Host "`t* CreateDirectories`t: Créer des sous-dossiers"
            Write-Host "`t* DeleteSubdirectoriesAndFiles`t: Supprimer les fichiers et sous-dossiers"
            Write-Host "`t* Delete`t: Supprimer le fichier ou le dossier"
            Write-Host "`t* ReadPermissions`t: Lire les permissions définies sur l'objet"
            Write-Host "`t* ChangePermissions`t: Modifier les ACL"
            Write-Host "`t* TakeOwnership`t: Prendre possession de l'objet"
            Write-Host "`t* Synchronize`t: Synchroniser l'accès aux fichiers (usage système)"

            Write-Host "=====================================================`n"

            # Définit un chemin de dossier cible sur lequel appliquer les permissions
            $folderPath = "C:\Partage\Docs"

            # Si le dossier n'existe pas, on le crée
            if (-Not (Test-Path -Path $folderPath)) {
                Write-Host "Le dossier '$folderPath' n'existe pas, je le crée..."
                New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
                Write-Host "Dossier créé."
            } else {
                Write-Host "Le dossier '$folderPath' existe déjà ."
            }

            # Demande le login de l'utilisateur concerné
            $user = Read-Host "Entrez l'identité de l'utilisateur concerné"

            # Demande le type de permission à  accorder
            $permission = Read-Host "Entrez la permission"

            try {
                # Récupère les droits actuels (ACL) du dossier
                $acl = Get-Acl $folderPath

                # Crée une nouvelle règle de permission pour cet utilisateur
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    "formation\$user",                          # Utilisateur concerné
                    $permission,                            # Type de droit accordé
                    "ContainerInherit,ObjectInherit",       # Les droits s'appliquent aussi aux sous-dossiers/fichiers
                    "None",                                 # Pas d'héritage spécial
                    "Allow"                                 # Autoriser l'accès
                )

                # Ajoute cette règle aux ACL existantes et applique le tout
                $acl.SetAccessRule($rule)
                Set-Acl -Path $folderPath -AclObject $acl

                Write-Host "Permission '$permission' attribuée à  l'utilisateur '$user' sur $folderPath." -ForegroundColor Green
            }
            catch {
                # Affiche un message si une erreur survient
                Write-Host "Une erreur est survenue : $_" -ForegroundColor Red
            }
        }

        # === GESTION D'UNE ENTRéE NON VALIDE ===
        else {
            Write-Host "Erreur : saisie invalide."
        }
    }
}

############## CONFIGURATION DES GROUPES ##############

# Si la variable $maVar vaut "3", alors l'utilisateur a choisi l'option "Config Groupe" dans le menu principal
elseif ($maVar -eq "3") {

    # Définition d'une fonction qui décode le type d'un groupe AD en texte lisible
    function Get-GroupTypeDescription {
        # La fonction attend une variable en paramètre : $groupType
        param($groupType)

        # Utilise une structure switch pour déterminer la portée (scope) du groupe
        # On applique un "ET logique binaire" (bitwise AND) pour extraire les bons bits
        $scope = switch ($groupType -band 0x00000003) {
            0x00000000 { "lan" }         # Portée lane au domaine
            0x00000001 { "Global" }        # Portée globale
            0x00000002 { "Universel" }     # Portée universelle
            default { "Inconnu" }          # Valeur inattendue
        }

        # On vérifie si le bit de sécurité est activé dans groupType (bit 31)
        # Cela permet de savoir si le groupe est de type "Sécurité" ou "Distribution"
        $type = if (($groupType -band 0x80000000) -eq 0x80000000) {
            "Sécurité"
        } else {
            "Distribution"
        }

        # Retourne la description complète : ex. "Global - Sécurité"
        return "$scope - $type"
    }

    # Affiche un titre dans le terminal pour signaler l'entrée dans la section Groupes
    Write-Host "===== CONFIGURATION DES GROUPES UTILISATEURS =====" -ForegroundColor Cyan

    # Initialise la variable $choix_grp vide (sera utilisée pour naviguer dans le menu)
    $choix_grp = ""

    # Tant que $choix_grp est différent de "0", on reste dans cette boucle de menu
    while ($choix_grp -ne "0") {

        # Affiche la liste de tous les groupes AD avec leur nom et leur type lisible
        Write-Host "`nListe des groupes existants (Nom - Type) :"
        Get-ADGroup -Filter * -Properties groupType | ForEach-Object {
            # Pour chaque groupe, on décode son type avec la fonction définie plus haut
            $typeDesc = Get-GroupTypeDescription $_.groupType
            # Affiche le nom et le type de chaque groupe
            Write-Host " - $($_.Name) - $typeDesc"
        }

        # Ligne vide pour l'esthétique
        Write-Host ""

        # Affiche le sous-menu dédié à  la configuration des groupes
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host "                 OPTION CONFIG GROUPE                 " -ForegroundColor Cyan
        Write-Host "=====================================================" -ForegroundColor Cyan
        Write-Host " 0 - Retour au menu principal" -ForegroundColor Yellow
        Write-Host " 1 - Création d'un groupe" -ForegroundColor Yellow
        Write-Host " 2 - Suppression d'un groupe" -ForegroundColor Yellow
        Write-Host ""

        # Demande à  l'utilisateur d'entrer son choix (0, 1 ou 2)
        $choix_grp = Read-Host -Prompt "Votre choix (0, 1 ou 2)"

        # En fonction du choix saisi, exécute une action différente
        switch ($choix_grp) {

            # Choix 0 : retour au menu principal
            "0" {
                Write-Host "Retour au menu principal..." -ForegroundColor Yellow
                break  # Sortie de la boucle while
            }

            # Choix 1 : création d'un groupe AD
            "1" {
                # Demande le nom du nouveau groupe
                $nom_grp = Read-Host "Nom du groupe à  créer"

                # Vérifie si le groupe existe déjà 
                $existe = Get-ADGroup -Filter "Name -eq '$nom_grp'" -ErrorAction SilentlyContinue
                if ($existe) {
                    Write-Host "Erreur : Le groupe '$nom_grp' existe déjà ." -ForegroundColor Red
                    continue  # Revient au début de la boucle
                }

                # Dictionnaire pour traduire les types saisis en franà§ais vers la syntaxe AD
                $scopeOptions = @{ "lan" = "Domainlan"; "global" = "Global"; "universel" = "Universal" }

                # Initialise une variable vide pour le type
                $type_grp = ""
                # Tant que la saisie de l'utilisateur ne correspond pas à  une clé du dictionnaire
                while (-not $scopeOptions.ContainsKey($type_grp.ToLower())) {
                    $type_grp = Read-Host "Type de groupe (lan / Global / Universel)"
                }
                # Récupère la version AD du scope (ex : Domainlan)
                $type_grp_ad = $scopeOptions[$type_grp.ToLower()]

                # Dictionnaire pour traduire la catégorie (sécurité/distribution)
                $catOptions = @{ "sécurité" = "Security"; "distribution" = "Distribution" }

                # Même logique que pour le type
                $cat_grp = ""
                while (-not $catOptions.ContainsKey($cat_grp.ToLower())) {
                    $cat_grp = Read-Host "Catégorie du groupe (Sécurité / Distribution)"
                }
                $cat_grp_ad = $catOptions[$cat_grp.ToLower()]

                # Bloc try/catch pour gérer les erreurs lors de la création du groupe
                try {
                    # Crée le groupe dans le conteneur CN=Users du domaine
                    New-ADGroup -Name $nom_grp -GroupScope $type_grp_ad -GroupCategory $cat_grp_ad -Path "CN=Users,DC=formation,DC=lan"
                    Write-Host " Groupe '$nom_grp' ($type_grp - $cat_grp) créé avec succès." -ForegroundColor Green
                }
                catch {
                    # Affiche le message d'erreur en cas d'échec
                    Write-Host "Erreur lors de la création du groupe : $_" -ForegroundColor Red
                }
            }

            # Choix 2 : suppression d'un groupe AD
            "2" {
                # Demande le nom du groupe à  supprimer
                $nom_grp = Read-Host "Nom du groupe à  supprimer"

                # Vérifie si le groupe existe dans l'AD
                if (Get-ADGroup -Identity $nom_grp -ErrorAction SilentlyContinue) {
                    try {
                        # Supprime le groupe sans demander de confirmation
                        Remove-ADGroup -Identity $nom_grp -Confirm:$false
                        Write-Host " Groupe '$nom_grp' supprimé avec succès." -ForegroundColor Green
                    }
                    catch {
                        # Affiche un message d'erreur en cas d'échec
                        Write-Host "Erreur lors de la suppression : $_" -ForegroundColor Red
                    }
                }
                else {
                    # Si le groupe n'existe pas, affiche un message d'erreur
                    Write-Host " Groupe '$nom_grp' introuvable." -ForegroundColor Red
                }
            }

            # Cas par défaut : gestion d'une mauvaise saisie
            default {
                Write-Host "Erreur : veuillez entrer 0, 1 ou 2." -ForegroundColor Red
            }
        }
    } # Fin boucle while
} # Fin du bloc elseif pour la config des groupes

############## GPO ##############

# Si l'utilisateur a choisi l'option 4 dans le menu principal
elseif ($maVar -eq "4") {

    # Affiche un titre clair pour signaler à  l'utilisateur qu'il entre dans le module de configuration GPO
    Write-Host "===== CONFIGURATION GPO - PARAMàˆTRES DéDIéS =====" -ForegroundColor Cyan

    # étape 1 : On commence par afficher les OU existantes pour aider à  choisir la cible
    Write-Host "Liste des OUs disponibles :"

    # La commande récupère toutes les unités d'organisation (OUs) de l'annuaire Active Directory
    # Chaque OU est ensuite affichée avec son nom et son chemin LDAP (DN)
    Get-ADOrganizationalUnit -Filter * | ForEach-Object {
        Write-Host " - $($_.Name) : $($_.DistinguishedName)"
    }

    # Ligne vide pour aérer l'affichage
    Write-Host ""

    # Demande à  l'utilisateur de saisir manuellement le DN (DistinguishedName) de l'OU cible
    $ouToLink = Read-Host "Merci de saisir le DistinguishedName (DN) de l'OU cible (exemple : OU=Utilisateurs,DC=formation,DC=lan)"

    # Si l'utilisateur ne saisit rien, on affiche un message d'annulation
    if (-not $ouToLink) {
        Write-Host "Aucune OU saisie, annulation." -ForegroundColor Red
        Start-Sleep -Seconds 3   # Pause de 3 secondes avant de relancer le menu
        Continue                 # Retour au menu principal
    }

    # étape 2 : Création d'une liste de GPO prédéfinies sous forme de tableau d'objets
    $gpoList = @(
        @{Name="GPO_NoControlPanel"; Desc="Bloquer l'accès au Panneau de Configuration"},
        @{Name="GPO_NoChangingWallpaper"; Desc="Interdire changement fond d'écran"},
        @{Name="GPO_ScreenLock"; Desc="Verrouillage automatique session 10 minutes"},
        @{Name="GPO_DeployWallpaper"; Desc="Déployer un fond d'écran personnalisé"},
        @{Name="GPO_NoRun"; Desc="Bloquer la commande Exécuter (Run)"},
        @{Name="GPO_BlockCMD"; Desc="Bloquer l'accès à  l'invite de commandes"}
    )

    # Initialisation du nombre de GPO à  appliquer à  0
    $nbGPO = 0

    # Tant que l'utilisateur ne saisit pas un nombre valide (entre 1 et le total), on redemande
    while (($nbGPO -lt 1) -or ($nbGPO -gt $gpoList.Count)) {
        $nbGPO = [int](Read-Host "Combien de GPO voulez-vous appliquer ? (1 à  $($gpoList.Count))")
    }

    # étape 3 : Affiche toutes les GPO disponibles avec un numéro devant pour les sélectionner facilement
    Write-Host "Liste des GPO disponibles :"
    for ($i=0; $i -lt $gpoList.Count; $i++) {
        Write-Host " [$($i+1)] $($gpoList[$i].Name) : $($gpoList[$i].Desc)"
    }
    Write-Host ""

    # étape 4 : L'utilisateur choisit une par une les GPO à  appliquer (pas de doublons autorisés)
    $selectedIndexes = @()  # Crée un tableau vide pour stocker les numéros choisis

    for ($j=1; $j -le $nbGPO; $j++) {
        $choice = 0
        while (($choice -lt 1) -or ($choice -gt $gpoList.Count) -or ($selectedIndexes -contains $choice)) {
            $choice = [int](Read-Host "Sélectionnez le numéro de la GPO #$j à  appliquer (choix non répété)")
        }
        $selectedIndexes += $choice  # Ajoute le choix à  la liste
    }

    # Définition d'une fonction nommée CreateAndConfigureGPO
    # Cette fonction prend un nom de GPO en paramètre et crée/configure cette GPO
    function CreateAndConfigureGPO($gpoName) {

        # Si la GPO n'existe pas déjà , on la crée
        if (-not (Get-GPO -Name $gpoName -ErrorAction SilentlyContinue)) {
            New-GPO -Name $gpoName | Out-Null  # Création silencieuse
            Write-Host " GPO '$gpoName' créée."
        } else {
            Write-Host " GPO '$gpoName' déjà  existante."
        }

        # On définit les paramètres à  appliquer selon le nom de la GPO
        switch ($gpoName) {

            # Cas 1 : GPO qui bloque le panneau de configuration
            "GPO_NoControlPanel" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
                    -ValueName "NoControlPanel" -Type DWord -Value 1
            }

            # Cas 2 : GPO qui empêche de changer le fond d'écran
            "GPO_NoChangingWallpaper" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" `
                    -ValueName "NoChangingWallPaper" -Type DWord -Value 1
            }

            # Cas 3 : GPO qui active le verrouillage automatique de l'écran après 10 minutes
            "GPO_ScreenLock" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "ScreenSaveTimeOut" -Type String -Value "600"
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "ScreenSaverIsSecure" -Type String -Value "1"
            }

            # Cas 4 : GPO qui déploie un fond d'écran spécifique sur les postes
            "GPO_DeployWallpaper" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "Wallpaper" -Type String -Value "C:\Wallpapers\image.jpg"
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Control Panel\Desktop" `
                    -ValueName "WallpaperStyle" -Type String -Value "2"  # Style étiré ou centré
            }

            # Cas 5 : GPO qui bloque la commande "Exécuter" (Win+R)
            "GPO_NoRun" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
                    -ValueName "NoRun" -Type DWord -Value 1
            }

            # Cas 6 : GPO qui bloque l'accès à  l'invite de commande (cmd.exe)
            "GPO_BlockCMD" {
                Set-GPRegistryValue -Name $gpoName `
                    -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
                    -ValueName "DisableCMD" -Type DWord -Value 1
            }
        }
    }

    # étape 5 : pour chaque GPO sélectionnée par l'utilisateur
    foreach ($idx in $selectedIndexes) {

        # On récupère le nom exact de la GPO à  partir de son index
        $gpoName = $gpoList[$idx - 1].Name

        # On appelle la fonction pour créer et configurer cette GPO
        CreateAndConfigureGPO -gpoName $gpoName

        # On tente de lier cette GPO à  l'OU cible saisie plus tà´t
        try {
            New-GPLink -Name $gpoName -Target $ouToLink -LinkEnabled Yes -ErrorAction Stop
            Write-Host " GPO '$gpoName' liée à  '$ouToLink'." -ForegroundColor Green
        } catch {
            # Si une erreur survient, on l'affiche
            Write-Host " Erreur lors de la liaison de la GPO '$gpoName' : $_" -ForegroundColor Red
        }
    }
}

####### GESTION DES EVENEMENTS ######

# Si l'utilisateur a choisi l'option 5 dans le menu principal...
elseif ($maVar -eq "5") {

    # Définition d'une fonction pour afficher rapidement les événements système récents
    function Show-RecentSystemLogs {
        # On définit que l'on veut uniquement les journaux "System"
        $defaultLogs = @("System")
        # On limite l'affichage aux 3 derniers jours
        $days = 3
        # On affiche un message d'information
        Write-Host "`nPrévisualisation des événements système récents (3 derniers jours, niveaux Critique, Erreur, Avertissement)..." -ForegroundColor Cyan
        # On utilise Get-WinEvent avec un filtre sur le journal, le niveau de gravité et la date
        Get-WinEvent -FilterHashtable @{
            LogName   = $defaultLogs
            Level     = @(1, 2, 3)  # Niveaux Critique, Erreur, Avertissement
            StartTime = (Get-Date).AddDays(-$days)  # Date de début : aujourd'hui - 3 jours
        } |
        # On sélectionne certaines propriétés à  afficher
        Select-Object TimeCreated, Id, LevelDisplayName, Message |
        # Formatage en tableau lisible automatiquement
        Format-Table -AutoSize
        # Ligne de séparation
        Write-Host "`n---------------------------------------------`n"
    }

    # Fonction complète pour consulter les logs avec options
    function Get-ErrorLogs {
        param (
            [string[]]$LogNames = @("System"),  # Par défaut, journal "System"
            [int]$Days = 7,  # Nombre de jours d'historique (par défaut 7)
            [switch]$Export,  # Paramètre booléen : export ou non ?
            [string]$ExportFolder = "C:\\Logs\\EventLogs"  # Dossier d'export par défaut
        )
        # Nettoie l'écran
        Clear-Host
        # Pour chaque journal demandé...
        foreach ($LogName in $LogNames) {
            # Affiche le journal en cours de traitement
            Write-Host "===== CONSULTATION DES éVéNEMENTS : $LogName =====" -ForegroundColor Cyan
            try {
                # Création du filtre pour Get-WinEvent
                $filter = @{
                    LogName   = $LogName
                    Level     = @(1, 2, 3)
                    StartTime = (Get-Date).AddDays(-$Days)
                }
                # Récupération des événements
                $events = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop
                # Si aucun événement trouvé...
                if ($events.Count -eq 0) {
                    Write-Host "Aucun événement critique, erreur ou avertissement trouvé." -ForegroundColor Yellow
                } else {
                    # Sinon, afficher les événements
                    $events | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -AutoSize
                    # Si l'utilisateur a demandé un export...
                    if ($Export) {
                        # Vérifie si le dossier d'export existe, sinon le crée
                        if (-not (Test-Path $ExportFolder)) {
                            New-Item -ItemType Directory -Path $ExportFolder -Force | Out-Null
                        }
                        # Crée un nom de fichier basé sur la date
                        $exportPath = Join-Path $ExportFolder "Logs_${LogName}_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                        # Export des données au format CSV
                        $events | Select-Object TimeCreated, Id, LevelDisplayName, Message | Export-Csv -Path $exportPath -NoTypeInformation
                        # Message de confirmation d'export
                        Write-Host "`nExport réalisé vers : $exportPath" -ForegroundColor Green
                    }
                }
            } catch {
                # En cas d'erreur, afficher un message
                Write-Host "Erreur lors de la récupération des logs : $_" -ForegroundColor Red
            }
            # Ligne de séparation
            Write-Host "`n---------------------------------------`n"
        }
        # Pause pour que l'utilisateur lise les résultats
        Write-Host "Appuyez sur Entrée pour continuer..." -ForegroundColor DarkGray
        Read-Host | Out-Null
    }

    # Fonction qui surveille les échecs de connexion (événement 4625)
    function Watch-FailedLogons {
        # Fonction appelée quand un événement 4625 est détecté
        function OnEventDetected {
            param($e)  # événement intercepté (nom différent de $Event)

            # Convertit l'événement en XML pour faciliter l'extraction des données
            $eventXml = [xml]$e.SourceEventArgs.NewEvent.ToXml()
            $timeCreated = $eventXml.Event.System.TimeCreated.SystemTime
            $accountName = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" } | Select-Object -ExpandProperty '#text'
            $ipAddress = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq "IpAddress" } | Select-Object -ExpandProperty '#text'

            # Si pas d'IP (par exemple en lan), on affiche N/A
            if ([string]::IsNullOrEmpty($ipAddress)) {
                $ipAddress = "N/A"
            }

            # Message d'alerte à  afficher et à  enregistrer
            $message = "[$timeCreated] échec de connexion pour l'utilisateur '$accountName' depuis l'adresse IP $ipAddress."
            Write-Host $message -ForegroundColor Red

            # Préparation du fichier de log
            $logFolder = "C:\\Logs"
            $logFile = Join-Path $logFolder "FailedLogons.log"

            # Création du dossier s'il n'existe pas
            if (-not (Test-Path $logFolder)) {
                New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
            }

            # Enregistre le message dans le fichier
            $message | Out-File -FilePath $logFile -Append -Encoding UTF8
        }

        # Affiche le lancement de la surveillance
        Write-Host "Surveillance des événements 4625 (échecs de connexion) en cours..." -ForegroundColor Cyan

        # Construction de la requête XML pour filtrer l'événement 4625
        $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4625)]]</Select>
  </Query>
</QueryList>
"@

        # Création de l'objet EventLogWatcher basé sur cette requête
        $eventWatcher = New-Object System.Diagnostics.Eventing.Reader.EventLogWatcher (
            New-Object System.Diagnostics.Eventing.Reader.EventLogQuery(
                "Security",
                [System.Diagnostics.Eventing.Reader.PathType]::LogName,
                $query
            )
        )

        # Abonnement à  l'événement déclenché
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
        # Affiche les logs système récents
        Show-RecentSystemLogs

        # Affiche le sous-menu événement
        Write-Host "###### MENU DE GESTION DES éVéNEMENTS ######" -ForegroundColor Cyan
        Write-Host "0 - Revenir au Menu Principal" -ForegroundColor Yellow
        Write-Host "1 - Consulter les erreurs d'autres journaux" -ForegroundColor Yellow
        Write-Host "2 - Surveiller en temps réel les échecs de connexion (4625)" -ForegroundColor Yellow
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

            # Demande à  l'utilisateur quels journaux il veut analyser
            do {
                $inputLogs = Read-Host "`nEntrez les noms exacts des journaux à  analyser, séparés par des virgules"
                $logNames = $inputLogs -split ',' | ForEach-Object { $_.Trim() }
                # Vérifie que les noms sont valides
                $invalidLogs = $logNames | Where-Object { -not ($logList -contains $_) }

                if ($invalidLogs.Count -gt 0) {
                    Write-Host "Journaux invalides : $($invalidLogs -join ', '). Veuillez réessayer." -ForegroundColor Red
                } else {
                    break
                }
            } while ($true)

            # Demande le nombre de jours à  analyser
            do {
                $daysInput = Read-Host "Nombre de jours à  analyser (par défaut 7)"
                if ([string]::IsNullOrWhiteSpace($daysInput)) { $days = 7; break }
                elseif ($daysInput -match '^\d+$' -and [int]$daysInput -gt 0) { $days = [int]$daysInput; break }
                else { Write-Host "Veuillez entrer un nombre entier positif valide." -ForegroundColor Red }
            } while ($true)

            # Demande si on veut exporter les résultats
            $exportChoice = Read-Host "Voulez-vous exporter les résultats ? (O/N)"
            $export = ($exportChoice.ToUpper() -eq 'O')

            # Appelle la fonction avec les paramètres choisis
            Get-ErrorLogs -LogNames $logNames -Days $days -Export:($export)
        }
        # Si l'utilisateur choisit la surveillance en temps réel
        elseif ($choice -eq "2") {
            Watch-FailedLogons
        }
        else {
            # Si entrée invalide
            Write-Host "Choix invalide, retour au menu des événements." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }

    } while ($true)  # FIN DE LA BOUCLE DU SOUS-MENU

}  # FIN DU elseif ($maVar -eq "5")

############## GESTION DES PROCESSUS ##############

# Vérifie si la variable $maVar est égale à  "6"
elseif ($maVar -eq "6") {

    # Définit le chemin du dossier oà¹ seront stockés les logs
    $logFolder = "C:\Logs\ProcessManager"

    # Vérifie si le dossier de logs n'existe pas
    if (-not (Test-Path $logFolder)) {
        # Crée le dossier de logs (et dossiers parents si besoin)
        New-Item -ItemType Directory -Path $logFolder -Force | Out-Null
        # Out-Null supprime la sortie affichée à  l'écran pour rendre le script plus propre
    }

    # Définit le chemin complet du fichier log du jour, avec la date au format yyyyMMdd
    $logFile = Join-Path $logFolder "process_manager_log_$(Get-Date -Format 'yyyyMMdd').log"

    # Définition d'une fonction pour écrire un message dans le fichier log
    function Write-Log {
        # Paramètres de la fonction : Message (texte à  enregistrer) et Level (niveau, par défaut INFO)
        param(
            [string]$Message,
            [string]$Level = "INFO"
        )
        # Récupère la date et l'heure actuelles au format "aaaa-MM-jj HH:mm:ss"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        # Compose la ligne à  écrire dans le log : date, niveau et message
        $logEntry = "$timestamp [$Level] - $Message"
        # Ajoute cette ligne à  la fin du fichier log
        Add-Content -Path $logFile -Value $logEntry
    }

    # Fonction pour bloquer certains processus les week-ends
    function Block-WeekendProcesses {
        # Liste des noms de processus à  bloquer (en majuscules)
        $blockedProcesses = @("EXCEL", "WINWORD")

        # Fichier log spécifique pour le blocage week-end
        $weekendLogFile = Join-Path $logFolder "weekend_block_log_$(Get-Date -Format 'yyyyMMdd').log"

        # Vérifie si ce fichier log n'existe pas
        if (-not (Test-Path $weekendLogFile)) {
            # Crée un fichier vide pour le log
            New-Item -Path $weekendLogFile -ItemType File -Force | Out-Null
        }

        # Petite fonction interne pour écrire dans le log du blocage week-end
        function Write-WeekendLog {
            param([string]$message)
            # Récupère la date et l'heure
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            # Compose la ligne et l'ajoute à  la fin du fichier weekend_log
            "$timestamp - $message" | Out-File -FilePath $weekendLogFile -Append -Encoding UTF8
        }

        # Récupère le jour actuel de la semaine (exemple : Monday, Saturday...)
        $today = (Get-Date).DayOfWeek

        # Vérifie si on est samedi ou dimanche
        if ($today -eq 'Saturday' -or $today -eq 'Sunday') {
            # Affiche un message pour prévenir que le blocage est actif
            Write-Host "Blocage des processus activé (jour : $today). Appuyez sur Ctrl+C pour arrêter." -ForegroundColor Cyan

            # Commence une boucle infinie dans un bloc try (pour gérer l'arrêt propre avec Ctrl+C)
            try {
                while ($true) {
                    # Pour chaque nom de processus interdit
                    foreach ($procName in $blockedProcesses) {
                        # Recherche tous les processus en cours avec ce nom (insensible à  la casse)
                        $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName.ToUpper() -eq $procName }
                        # Pour chaque processus trouvé
                        foreach ($proc in $procs) {
                            try {
                                # Tente de tuer le processus (par son Id) avec -Force (arrêt immédiat)
                                Stop-Process -Id $proc.Id -Force
                                # Prépare un message de log indiquant que le processus a été arrêté
                                $logMsg = "Processus $($proc.ProcessName) (ID $($proc.Id)) tué car interdit le week-end."
                                # Affiche ce message en rouge
                                Write-Host $logMsg -ForegroundColor Red
                                # écrit ce message dans le fichier log weekend
                                Write-WeekendLog $logMsg
                            } catch {
                                # En cas d'erreur, affiche un message d'erreur rouge
                                Write-Host "Erreur en tuant $($proc.ProcessName) (ID $($proc.Id)) : $_" -ForegroundColor Red
                            }
                        }
                    }
                    # Attend 10 secondes avant de recommencer la vérification
                    Start-Sleep -Seconds 10
                }
            }
            catch [System.Exception] {
                # Si l'utilisateur interrompt (Ctrl+C), ce bloc catch est exécuté
                Write-Host "`nBlocage arrêté. Retour au menu..." -ForegroundColor Cyan
                # Pause de 2 secondes avant de revenir au menu
                Start-Sleep -Seconds 2
            }
        }
        else {
            # Si ce n'est pas le week-end, affiche que le blocage ne s'applique pas
            Write-Host "Aujourd'hui c'est $today, pas de blocage des processus le week-end." -ForegroundColor Green
            # Attend une touche pour continuer (empêche la fermeture directe)
            Read-Host "Appuyez sur une touche pour continuer..."
        }
    }

    # Fonction principale qui affiche le menu de gestion des processus et traite les choix
    function Show-ProcessManager {
        do {
            # Nettoie l'écran (console)
            Clear-Host

            # Affiche une barre décorative en cyan
            Write-Host "=====================================" -ForegroundColor Cyan
            # Affiche le titre avec fond bleu foncé et texte cyan
            Write-Host "          GESTION DES PROCESSUS       " -ForegroundColor Cyan -BackgroundColor DarkBlue
            Write-Host "=====================================" -ForegroundColor Cyan
            Write-Host ""

            # Affiche les options du menu en jaune
            Write-Host " 0. Retour au menu principal" -ForegroundColor Yellow
            Write-Host " 1. Lister les processus" -ForegroundColor Yellow
            Write-Host " 2. Arrêter un processus" -ForegroundColor Yellow
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
                        # Récupère tous les processus avec une valeur CPU valide, trie par CPU décroissant,
                        # prend les 20 premiers, affiche un tableau avec Id, Nom, CPU et mémoire utilisée
                        Get-Process |
                            Where-Object { $_.CPU -is [double] } |
                            Sort-Object CPU -Descending |
                            Select-Object -First 20 |
                            Format-Table Id, ProcessName, CPU, WorkingSet -AutoSize
                        # Log que la liste a été affichée
                        Write-Log "Liste des 20 processus les plus consommateurs de CPU affichée."
                    } catch {
                        # En cas d'erreur, affiche un message rouge et log l'erreur
                        Write-Host "Erreur lors de l'affichage des processus : $_" -ForegroundColor Red
                        Write-Log "Erreur lors de l'affichage des processus : $_" "ERROR"
                    }
                    # Attend que l'utilisateur appuie sur une touche avant de continuer
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 2 : arrêter un processus donné par son nom
                "2" {
                    # Demande à  l'utilisateur le nom du processus à  arrêter
                    $procName = Read-Host "Nom du processus à  arrêter"
                    try {
                        # Tente d'arrêter le processus par son nom avec option -Force
                        Stop-Process -Name $procName -Force -ErrorAction Stop
                        # Affiche un message vert si réussi
                        Write-Host "Processus $procName arrêté avec succès." -ForegroundColor Green
                        # Log l'arrêt réussi
                        Write-Log "Processus '$procName' arrêté avec succès."
                    } catch {
                        # En cas d'erreur, affiche un message rouge et log l'erreur
                        Write-Host "Erreur : impossible d'arrêter $procName. $_" -ForegroundColor Red
                        Write-Log "Erreur lors de l'arrêt du processus '$procName' : $_" "ERROR"
                    }
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 3 : lancer un programme à  partir de son chemin complet
                "3" {
                    # Demande le chemin complet du programme
                    $exePath = Read-Host "Chemin complet du programme à  lancer"
                    try {
                        # Démarre le programme demandé
                        Start-Process $exePath
                        # Affiche un message vert pour confirmation
                        Write-Host "Programme lancé : $exePath" -ForegroundColor Green
                        # Log du lancement du programme
                        Write-Log "Programme lancé : $exePath"
                    } catch {
                        # En cas d'erreur, affiche un message rouge et log l'erreur
                        Write-Host "Erreur : $_" -ForegroundColor Red
                        Write-Log "Erreur lors du lancement du programme '$exePath' : $_" "ERROR"
                    }
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 4 : afficher les 20 dernières lignes du fichier log principal
                "4" {
                    # Vérifie si le fichier log principal existe
                    if (Test-Path $logFile) {
                        Write-Host "`n=== Derniers logs ===`n" -ForegroundColor Cyan
                        # Affiche les 20 dernières lignes du fichier log
                        Get-Content $logFile -Tail 20 | ForEach-Object { Write-Host $_ }
                        # Log la consultation des logs
                        Write-Log "Consultation des derniers logs."
                    } else {
                        # Si pas de fichier log, affiche un message jaune
                        Write-Host "Aucun log trouvé." -ForegroundColor Yellow
                    }
                    Read-Host "Appuyez sur une touche pour continuer..."
                }
                # Si choix 5 : surveiller les processus interdits (chrome, firefox)
                "5" {
                    # Liste des processus interdits à  surveiller
                    $interdits = @("chrome", "firefox")
                    # Fichier log pour cette surveillance
                    $logPath = "C:\logs\surveillance.log"
                    # Si ce fichier n'existe pas, le crée
                    if (-not (Test-Path -Path $logPath)) {
                        New-Item -Path $logPath -ItemType File -Force | Out-Null
                    }

                    # Variable pour contrà´ler la boucle de surveillance
                    $continueMonitoring = $true
                    # Affiche instruction à  l'utilisateur
                    Write-Host "Surveillance en cours. Tapez 'q' puis Entrée pour arrêter."

                    # Boucle infinie tant que $continueMonitoring est vrai
                    while ($continueMonitoring) {
                        # Pour chaque processus interdit
                        foreach ($nom in $interdits) {
                            # Recherche les processus en cours portant ce nom
                            $proc = Get-Process -Name $nom -ErrorAction SilentlyContinue
                            if ($proc) {
                                # Récupère le nom d'utilisateur courant
                                $utilisateur = $env:USERNAME
                                # Récupère la date et l'heure actuelles
                                $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                                # Pour chaque processus trouvé
                                foreach ($p in $proc) {
                                    # Tente de tuer le processus
                                    Stop-Process -Id $p.Id -Force
                                    # Compose la ligne de log avec date, utilisateur et nom du processus interdit
                                    $ligne = "$date - $utilisateur a lancé un processus interdit : $($p.ProcessName)"
                                    # Ajoute la ligne au fichier log
                                    Add-Content -Path $logPath -Value $ligne
                                    # Affiche la ligne à  l'écran
                                    Write-Host $ligne
                                }
                            }
                        }

                        # Demande à  l'utilisateur s'il veut arrêter la surveillance
                        Write-Host "Tapez 'q' puis Entrée pour arrêter la surveillance, ou juste Entrée pour continuer..."
                        $i = Read-Host
                        if ($i -eq "q") {
                            # Si 'q' tapé, stoppe la boucle
                            $continueMonitoring = $false
                            Write-Host "Surveillance arrêtée. Retour au menu..." -ForegroundColor Cyan
                            # Pause de 2 secondes avant retour au menu
                            Start-Sleep -Seconds 2
                        }
                    }
                }
                # Si choix 6 : appelle la fonction de blocage des processus le week-end
                "6" {
                    Block-WeekendProcesses
                }
                # Pour toute autre saisie non prévue
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

# Si je choisis l'option 7 dans le menu principal, j'exécute ce bloc
elseif ($maVar -eq "7") {

    # Définition d'une fonction qui va tout regrouper : vérification + actions possibles sur les services
    function Show-ServiceManager {
        Clear-Host  # Efface l'écran pour rendre l'affichage plus lisible
        Write-Host "=== GESTION DES SERVICES ===" -ForegroundColor Cyan  # Affiche le titre principal en cyan

        # Liste des services critiques à  surveiller sur un contrà´leur de domaine
        $servicesCritiques = @(
            "wuauserv", "NTDS", "DNS", "Netlogon", "KDC", "W32Time",
            "LanmanServer", "LanmanWorkstation", "DFSR", "RpcSs", "SamSs"
        )

        # Affiche un sous-titre pour la vérification des services critiques, avec retour à  la ligne
        Write-Host "`n=== VéRIFICATION DES SERVICES CRITIQUES ===" -ForegroundColor Cyan

        # Pour chaque service dans la liste des services critiques, on effectue la vérification
        foreach ($svc in $servicesCritiques) {
            try {
                # Essaye de récupérer l'état du service nommé $svc
                $etat = (Get-Service -Name $svc).Status
                # Si le service est en cours d'exécution ("Running")
                if ($etat -eq "Running") {
                    # Affiche le nom du service formaté sur 20 caractères et "OK" en vert
                    Write-Host ("{0,-20}: OK" -f $svc) -ForegroundColor Green
                } else {
                    # Sinon, affiche que le service est non disponible, avec son état en rouge
                    Write-Host ("{0,-20}: NON DISPONIBLE (état = {1})" -f $svc, $etat) -ForegroundColor Red
                }
            } catch {
                # En cas d'erreur (service introuvable), affiche un message d'erreur en rouge foncé
                Write-Host ("{0,-20}: ERREUR - service introuvable" -f $svc) -ForegroundColor DarkRed
            }
        }

        # Obtient la date et l'heure actuelles
        $date = Get-Date
        # Formate la date pour l'horodatage du rapport (ex: 2025-07-18_15-30)
        $horodatage = $date.ToString("yyyy-MM-dd_HH-mm")
        # Définit le chemin du dossier de rapport, organisé par année et mois (ex: C:\Rapports\2025\08)
        $cheminRapport = "C:\Rapports\$($date.Year)\$("{0:D2}" -f $date.Month)"
        # Définit le chemin complet du fichier rapport texte
        $rapportTxt = Join-Path $cheminRapport "services_AD_$horodatage.txt"
        # Définit le chemin complet du fichier rapport HTML
        $rapportHtml = Join-Path $cheminRapport "services_AD_$horodatage.html"
        # Définit le chemin complet du fichier rapport PDF
        $rapportPDF = Join-Path $cheminRapport "services_AD_$horodatage.pdf"

        # Vérifie si le dossier de rapport existe, sinon le crée
        if (!(Test-Path $cheminRapport)) {
            New-Item -Path $cheminRapport -ItemType Directory -Force | Out-Null
        }

        # Récupère l'état de tous les services critiques (nom, affichage et statut)
        $etatServices = Get-Service -Name $servicesCritiques | Select-Object DisplayName, Name, Status
        # Filtre les services en fonctionnement
        $servicesOK = $etatServices | Where-Object { $_.Status -eq "Running" }
        # Filtre les services qui ne tournent pas (arrêtés ou en erreur)
        $servicesKO = $etatServices | Where-Object { $_.Status -ne "Running" }

        # ===== CRéATION DU RAPPORT TEXTE =====
        # écrit l'en-tête du rapport texte avec la date actuelle
        @"
Rapport de supervision des services Active Directory
Date de génération : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
=====================================================

Services en cours d'exécution :
"@ | Out-File $rapportTxt  # Enregistre ce bloc dans le fichier texte

        # Ajoute dans le fichier texte la liste formatée des services en fonctionnement
        $servicesOK | Format-Table -AutoSize | Out-String | Out-File $rapportTxt -Append

        # Ajoute un titre dans le fichier texte pour les services arrêtés ou indisponibles
        "`nServices arrêtés ou non disponibles :" | Out-File $rapportTxt -Append
        # Si la liste des services KO n'est pas vide
        if ($servicesKO.Count -gt 0) {
            # Ajoute la liste formatée des services KO au fichier texte
            $servicesKO | Format-Table -AutoSize | Out-String | Out-File $rapportTxt -Append
        } else {
            # Sinon indique qu'aucun problème n'a été détecté
            "Aucun problème détecté." | Out-File $rapportTxt -Append
        }

        # ===== CRéATION DU RAPPORT HTML =====
        # Convertit l'état des services en tableau HTML avec titre et contenu personnalisé
        $etatServices | ConvertTo-Html -Title "état des services AD - $horodatage" `
            -PreContent "<h2 style='color:navy;'>Supervision des services Active Directory</h2><p>Date : $horodatage</p>" |
            ForEach-Object {
                # Si des services sont arrêtés, change la couleur de fond du corps HTML en rouge clair
                if ($servicesKO.Count -gt 0) {
                    $_ -replace "<body>", "<body style='background-color:#ffe6e6;'>"
                } else {
                    # Sinon ne modifie pas le corps
                    $_
                }
            } | Out-File $rapportHtml  # Sauvegarde le rapport HTML dans un fichier

        # ===== CONVERSION HTML â†’ PDF AVEC EDGE =====
        # Définit le chemin vers l'exécutable Microsoft Edge (version 32 bits)
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
        # Vérifie si Edge est installé sur ce chemin
        if (Test-Path $edgePath) {
            # Lance Edge en mode headless pour imprimer le HTML en PDF dans le fichier PDF défini
            & $edgePath --headless --disable-gpu --print-to-pdf="$rapportPDF" "file:///$rapportHtml"
            # Indique que le PDF a été généré avec succès
            Write-Host "Rapport PDF généré : $rapportPDF" -ForegroundColor Cyan
        } else {
            # Si Edge n'est pas trouvé, affiche un message d'erreur en rouge
            Write-Host "Microsoft Edge non trouvé. Impossible de générer le PDF." -ForegroundColor Red
        }

        # Affiche les chemins des rapports générés (texte et HTML)
        Write-Host "`nRapport généré avec succès :" -ForegroundColor Green
        Write-Host " - Texte : $rapportTxt"
        Write-Host " - HTML  : $rapportHtml"

        # Si au moins un service est arrêté, affiche une alerte rouge invitant à  vérifier le rapport
        if ($servicesKO.Count -gt 0) {
            Write-Host "`nServices arrêtés détectés ! Vérifiez le rapport." -ForegroundColor Red
        }

        # ===== MENU INTERACTIF POUR GéRER LES SERVICES =====
        # Affiche les options du menu interactif en jaune
        Write-Host "`n0. Retour au menu principal" -ForegroundColor Yellow
        Write-Host "1. Lister les services" -ForegroundColor Yellow    
        Write-Host "2. Démarrer un service" -ForegroundColor Yellow
        Write-Host "3. Arrêter un service" -ForegroundColor Yellow
        Write-Host "4. Redémarrer un service" -ForegroundColor Yellow
        
        # Demande à  l'utilisateur de saisir son choix
        $choice = Read-Host "`nVotre choix"

        # Exécute une action selon le choix de l'utilisateur
        switch ($choice) {
            "0" {
                # Retour au menu principal, message informatif en cyan
                Write-Host "Retour au menu principal..." -ForegroundColor Cyan
            }
            "1" {
                # Affiche la liste complète des services triés par statut et nom
                Write-Host "`nListe complète des services :" -ForegroundColor Yellow
                Get-Service | Sort-Object Status, DisplayName | Format-Table Status, DisplayName, Name -AutoSize
            }
            "2" {
                # Demande le nom du service à  démarrer
                $svcName = Read-Host "Nom du service à  démarrer"
                try {
                    # Essaie de démarrer le service avec gestion des erreurs
                    Start-Service -Name $svcName -ErrorAction Stop
                    # Confirmation en vert du démarrage
                    Write-Host "Service $svcName démarré." -ForegroundColor Green
                } catch {
                    # Affiche l'erreur en rouge si problème lors du démarrage
                    Write-Host "Erreur : $_" -ForegroundColor Red
                }
            }
            "3" {
                # Demande le nom du service à  arrêter
                $svcName = Read-Host "Nom du service à  arrêter"
                try {
                    # Essaie d'arrêter le service, en forà§ant l'arrêt si nécessaire
                    Stop-Service -Name $svcName -Force -ErrorAction Stop
                    # Confirmation en vert de l'arrêt
                    Write-Host "Service $svcName arrêté." -ForegroundColor Green
                } catch {
                    # Affiche l'erreur en rouge si problème lors de l'arrêt
                    Write-Host "Erreur : $_" -ForegroundColor Red
                }
            }
            "4" {
                # Demande le nom du service à  redémarrer
                $svcName = Read-Host "Nom du service à  redémarrer"
                try {
                    # Essaie de redémarrer le service
                    Restart-Service -Name $svcName -ErrorAction Stop
                    # Confirmation en vert du redémarrage
                    Write-Host "Service $svcName redémarré." -ForegroundColor Green
                } catch {
                    # Affiche l'erreur en rouge si problème lors du redémarrage
                    Write-Host "Erreur : $_" -ForegroundColor Red
                }
            }
            
            default {
                # Si le choix ne correspond à  aucune option, affiche une erreur
                Write-Host "Choix invalide." -ForegroundColor Red
            }
        }

        Pause  # Met en pause l'exécution pour que l'utilisateur puisse lire les résultats
    }

    # J'appelle ma fonction pour exécuter le gestionnaire de services
    Show-ServiceManager
}

#### SUPERVISION CORRECTIVE ############

# Vérifie si la variable $maVar vaut "8" (condition d'entrée du script)
if ($maVar -eq "8") {
    # Affiche un message indiquant le lancement du script, en jaune
    Write-Host "=== Lancement du script de supervision corrective ===" -ForegroundColor Yellow

    # === Script de Supervision Corrective pour Administrateur Systèmes et Réseaux ===
    # Compatible PowerShell 5+ - à exécuter avec privilèges administrateur

    # === CONFIGURATION GLOBALE ===
    # Récupère le chemin complet du script en cours d'exécution
    $scriptPath = $MyInvocation.MyCommand.Path
    # Définit le nom de la tâche planifiée à  créer
    $taskName = "Surveillance_Corrective"
    # Définit la source utilisée pour l'écriture dans le journal des événements
    $eventSource = "SupervisionTSSR"

    # Vérifie si la source d'événements existe déjà  dans le journal Windows
    if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
        # Si non, crée une nouvelle source dans le journal "Application"
        New-EventLog -LogName "Application" -Source $eventSource
    }

    # Définition d'une fonction pour écrire dans le journal des événements Windows
    Function Write-Log {
        param(
            [string]$Message,  # Message à  écrire
            [string]$Type = "Information"  # Type d'entrée (Information par défaut)
        )
        # Convertit la chaà®ne en type d'entrée d'événement Windows
        $entryType = [System.Diagnostics.EventLogEntryType]::$Type
        # écrit l'entrée dans le journal "Application" avec la source définie
        Write-EventLog -LogName "Application" -Source $eventSource -EntryType $entryType -EventId 1000 -Message $Message
    }

    # === MENU PRINCIPAL ===
    do {
        Clear-Host  # Efface l'écran de la console
        Write-Host "===== MENU DE SUPERVISION CORRECTIVE =====" -ForegroundColor Cyan
        Write-Host "0. Quitter" -ForegroundColor Yellow
        Write-Host "1. Lancer la supervision corrective" -ForegroundColor Yellow
        Write-Host "2. Créer la tâche planifiée automatique" -ForegroundColor Yellow
        # Demande à  l'utilisateur de choisir une option via saisie clavier
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
            # Définition d'une liste noire de noms de processus suspects à  surveiller
            $blacklist = @(
                'notepad', 'mimikatz', 'metasploit', 'powershell', 'cmd',
                'wmic', 'taskmgr', 'netstat', 'rundll32', 'cscript', 'wscript'
            )

            # Liste des services critiques à  vérifier et redémarrer si arrêtés
            $criticalServices = @(
                'Spooler', 'WinDefend', 'W32Time', 'LanmanServer', 'LanmanWorkstation',
                'EventLog', 'Dhcp', 'Dnscache', 'Netlogon', 'RpcSs', 'BITS',
                'WinRM', 'TermService', 'CryptSvc', 'TrustedInstaller'
            )

            # === VéRIFICATION DES PROCESSUS SUSPECTS ===
            Write-Host "`n[*] Vérification des processus suspects..." -ForegroundColor Yellow
            # Récupère la liste complète des processus en cours
            $processes = Get-Process
            # Filtre les processus dont le nom figure dans la liste noire
            $suspects = $processes | Where-Object { $_.ProcessName -in $blacklist }

            # Si aucun processus suspect détecté
            if ($suspects.Count -eq 0) {
                Write-Host "Aucun processus suspect détecté." -ForegroundColor Green
            } else {
                # Sinon, pour chaque processus suspect détecté
                foreach ($proc in $suspects) {
                    try {
                        # Affiche le nom du processus suspect détecté
                        Write-Host "[!] Processus suspect détecté : $($proc.ProcessName)" -ForegroundColor Red
                        # Tente de forcer l'arrêt du processus
                        Stop-Process -Id $proc.Id -Force
                        Write-Host "    -> Processus arrêté." -ForegroundColor Red

                        # Tentative de désactivation des interfaces réseau pour confinement
                        # Vérifie si le module NetAdapter est disponible
                        if (-not (Get-Module -ListAvailable -Name NetAdapter)) {
                            Write-Host "    -> Module NetAdapter non trouvé, désactivation réseau impossible." -ForegroundColor Yellow
                        } else {
                            # Importe le module NetAdapter
                            Import-Module NetAdapter
                            # Récupère toutes les interfaces réseau actives (status "Up")
                            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
                            # Pour chaque interface active, la désactive sans confirmation
                            foreach ($adapter in $adapters) {
                                Disable-NetAdapter -Name $adapter.Name -Confirm:$false
                                Write-Host "    -> Interface réseau $($adapter.Name) désactivée." -ForegroundColor Red
                            }
                        }

                        # écrit un log indiquant que le processus suspect a été stoppé et le réseau désactivé
                        Write-Log "Processus suspect $($proc.ProcessName) stoppé et interfaces réseau désactivées."
                    } catch {
                        # En cas d'erreur, affiche et log l'erreur de confinement
                        Write-Host "Erreur de confinement : $_" -ForegroundColor Red
                        Write-Log "Erreur confinement $($proc.ProcessName) : $_" "Error"
                    }
                }
            }

            # === CONTRÔLE DES SERVICES CRITIQUES ===
            Write-Host "`nVérification des services critiques..." -ForegroundColor Yellow
            # Pour chaque service critique dans la liste
            foreach ($svc in $criticalServices) {
                try {
                    # Récupère l'état du service (stoppe si erreur)
                    $service = Get-Service -Name $svc -ErrorAction Stop
                    # Si le service n'est pas en cours d'exécution
                    if ($service.Status -ne 'Running') {
                        # Démarre le service
                        Start-Service -Name $svc
                        Write-Host "    -> Service critique '$svc' redémarré." -ForegroundColor Green
                        # Log du redémarrage automatique
                        Write-Log "Service '$svc' redémarré automatiquement."
                    } else {
                        Write-Host "    -> Service '$svc' opérationnel." -ForegroundColor Green
                    }
                } catch {
                    # En cas d'erreur lors de la récupération du service, affiche et log un avertissement
                    Write-Host "    -> Erreur service '$svc' : $_" -ForegroundColor Red
                    Write-Log "Erreur service '$svc' : $_" "Warning"
                }
            }

            # === COLLECTE D'INFORMATIONS SYSTàˆME ===
            Write-Host "`nCollecte d'un snapshot système..." -ForegroundColor Yellow
            # Définit un timestamp pour nommer le dossier snapshot
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            # Définit le chemin de sauvegarde du snapshot système
            $snapshotDir = "C:\Logs\Snapshot_$timestamp"
            # Crée le dossier pour le snapshot (force création même si existant)
            New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

            try {
                # Récupère les infos mémoire et exporte en CSV dans le dossier snapshot
                Get-CimInstance Win32_OperatingSystem |
                    Select-Object TotalVisibleMemorySize, FreePhysicalMemory |
                    Export-Csv -Path "$snapshotDir\Memory.csv" -NoTypeInformation

                # Récupère les volumes/disques et exporte en CSV dans le dossier snapshot
                Get-Volume |
                    Select-Object DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size |
                    Export-Csv -Path "$snapshotDir\Disks.csv" -NoTypeInformation

                # Indique à  l'utilisateur que le snapshot a été sauvegardé
                Write-Host "Snapshot système sauvegardé dans $snapshotDir" -ForegroundColor Green
                # Log l'enregistrement réussi du snapshot
                Write-Log "Snapshot système enregistré dans $snapshotDir"
            } catch {
                # En cas d'erreur lors de la collecte snapshot, affiche et log l'erreur
                Write-Host "Erreur snapshot : $_" -ForegroundColor Red
                Write-Log "Erreur snapshot système : $_" "Error"
            }

            # Indique la fin de la supervision corrective
            Write-Host "`n=== Supervision corrective terminée ===" -ForegroundColor Cyan
            # Attend que l'utilisateur appuie sur Entrée pour revenir au menu
            Read-Host "`nAppuyez sur Entrée pour revenir au menu principal..."
        }

        # Si l'utilisateur choisit "2", création de la tâche planifiée automatique
        elseif ($maVar -eq "2") {
            Clear-Host
            Write-Host "=== Création de la tâche planifiée ===" -ForegroundColor Cyan

            # Vérifie si la tâche planifiée existe déjà 
            if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
                Write-Host "La tâche planifiée '$taskName' existe déjà . Elle ne sera pas modifiée." -ForegroundColor Yellow
                Write-Log "La tâche planifiée '$taskName' existe déjà . Aucun changement effectué."
            } else {
                try {
                    # Crée un trigger de tâche planifiée : lance une fois dans 1 minute,
                    # puis répète toutes les 10 minutes pendant 10 ans
                    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
                        -RepetitionInterval (New-TimeSpan -Minutes 10) `
                        -RepetitionDuration ([TimeSpan]::FromDays(3650))  # 10 ans

                    # Définit l'action à  exécuter : lancement de powershell avec paramètres pour exécuter ce script
                    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
                                -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

                    # Définit le compte d'exécution SYSTEM avec privilèges élevés
                    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

                    # Enregistre la tâche planifiée avec nom, trigger, action, principal et description
                    Register-ScheduledTask -TaskName $taskName -Trigger $trigger `
                                           -Action $action -Principal $principal `
                                           -Description "Supervision corrective automatique PowerShell"

                    Write-Host "[OK] Tâche planifiée '$taskName' créée." -ForegroundColor Green
                    Write-Log "Tâche planifiée '$taskName' enregistrée avec succès."
                } catch {
                    # En cas d'erreur lors de la création, affiche et log l'erreur
                    Write-Host "Erreur création tâche : $_" -ForegroundColor Red
                    Write-Log "Erreur création tâche planifiée : $_" "Error"
                }
            }

            # Attend que l'utilisateur appuie sur Entrée pour revenir au menu
            Read-Host "`nAppuyez sur Entrée pour revenir au menu principal..."
        }

        else {
            # Si le choix ne correspond à  aucune option valide, affiche un message d'erreur
            Write-Host "Choix invalide. Réessayez." -ForegroundColor Red
            # Pause de 2 secondes avant de redemander
            Start-Sleep -Seconds 2
        }

    } while ($true)  # Boucle infinie du menu tant que l'utilisateur ne quitte pas
} # Fin du if initial

# Si la saisie de l'utilisateur ne correspond à  aucune option prévue
else {
    # On affiche un message d'erreur et on redemande un choix
    Write-Host "Choix non reconnu, merci de recommencer."
}
# Fin de la boucle ou du bloc principal
}

