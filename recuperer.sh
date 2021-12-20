#! /bin/bash

# Nom : recuperer.sh : exemple de script pour récupérer une arborescence ou un fichier sur une machine distante ou sur une série de machines distantes


# Arguments possibles :

# -l -d (-p ou -s) ||| ARGUMENTS OBLIGATOIRES !

# -v -h -lo ||| ARGUMENTS OPTIONNELS !


# Exemple :

# recuperer.sh -l . -p 01 -d Bureau/arbo

# recuperer.sh -l . -s linserv -d Bureau/arbo

# recuperer.sh -l . -s linserv -d Bureau/arbo -v -lo Leslogs

#---------------------------Définition des variables--------------------------------------------------------------

CheminDeLaCopie=0 ; CheminDeElementCopie=0 ; NomPoste=0 ; NomSalle=0 #On définit les variables essentielles au principe de base de la fonction

variable1=0 ; variable2=0 ; VerboseMode=0 ; LogMode=0 ; FichierLog=0 #On définit les variables d'erreur & les variables d'options

#--------------------------Création du fichier de log-------------------------------------------------------------

if [ ! -e recupererLog ] || [ ! -d recupererLog ]
then
	mkdir recupererLog
fi

#-------------------------Identifiant de connection---------------------------------------------------------------

read -p "Veuillez saisir votre identifiant" id

#-------------------------Vérification du nombre d'argument dans la fonction--------------------------------------

#On vérifie s'il n'y a pas de parametres fournis par l'utilisateur

if [ $# = 0 ]		
then
	echo Il y a aucun argument dans la fonction ; exit	
fi

#-------------------------Vérification du help--------------------------------------------------------------------

#On vérifie si l'utilisateur demande de l'aide et s'il en a besoin on quitte le programme après avoir afficher le man

case $1 in 

"-h" | "--help")
	if [ -e man_fonction_recuperer.txt ] && [ -f man_fonction_recuperer.txt ] && [ -r man_fonction_recuperer.txt ]
	then
		cat man_fonction_recuperer.txt
	else
		echo ""
		echo "[NOM]"
		echo "recuperer – Récupérer une arborescence ou un fichier sur une machine
		distante ou sur une série de machines distantes"
		echo ""
		echo "[SYNOPSIS]"
		echo "		recuperer [OPTION]..."
		echo ""
		echo "[DESCRIPTION]"
		echo "		Récupère une arborescence ou un fichier situé sur une machine distante
				ou sur une série de machines distantes."
		echo ""
		echo "		Il n’y a pas d’ordre dans les options. En cas de présence multiple, la"
		echo "		dernière (de gauche à droite) est prise en compte."
		echo ""
		echo "	Les options disponibles sont :"
		echo ""
		echo "	-l, --local <CHEMIN>"
		echo "		Indique le répertoire de la machine locale où l’arborescence distante ou le"
		echo "		fichier distant doit être copié."
		echo ""
		echo "	-d, --distant <CHEMIN>"
		echo "		Indique le chemin de l'arborescence distante ou le ifchier distant à transférer."
		echo ""
		echo "	-p, --poste <NOM-POSTE>"
		echo "		Nom du poste distant"
		echo ""
		echo "	-s, --salle <NOM-SALLE> ..."
		echo "		Noms du ou des salles cibles. Les noms des postes de la salle sont obtenus par filtrage du fichier"
		echo "		des salles nommé FICHIER-DES-SALLES dont lerépertoire d’accueil est indiqué "
		echo "		par la variable d’environnement REP_SALLES."
		echo "		Cf. commande <ajouterposte>."
		echo ""
		echo "	-v, --verbose"
		echo "		Affiche les différentes étapes de la commande"
		echo ""
		echo "	-h, --help"
		echo "		Affiche un résumé du manuel de la commande"
		echo ""
		echo "	-l, --log <FICHIER-LOCAL>"
		echo "		ecrit dans <FICHIER-LOCAL> tous les messages produits par la commande sur la
				sortie standard locale et sur la sortie d’erreur locale."
		echo ""
	fi
exit

esac

#-----------------------------------------------------------------------------------------------------------------

NbArgument=$# #On déclare le nombre de variable qui sont passé en paramètre

#--------------------On passe à la traite des paramètres du programme---------------------------------------------

while [[ $# -gt 0 ]] ; do #On répète la boucle par rapport au nombre d'argument

	case $1 in
	
	"-l" | "--local") #On traite le paramètre -l qui doit indiquer le répertoire de la machine locale où l’arborescence distante ou le fichier distant doit être copié.
	
		if [ -z $2 ] || [[ $2 == "-"* ]] # On vérifie que le paramètre ne soit pas vide et que le deuxième argument ne soit pas un autre paramètre
		
			then 
				echo "$0: Je suis trop faible pour réaliser ce que tu m'as demandé" ; exit 2 # On prévient qu'il y a une erreur et que la fonction ne peut continuer
			else
				CheminDeLaCopie=$2
			fi
		
		shift ; shift ;;
		
	"-d" | "--distant")
	
		if [ -z $2 ] || [[ $2 == "-"* ]] # On vérifie que le paramètre ne soit pas vide et que le deuxième argument ne soit pas un autre paramètre
		
			then 
				echo "$0: Je suis trop faible pour réaliser ce que tu m'as demandé" ; exit 2 # On prévient qu'il y a une erreur et que la fonction ne peut continuer
			else
				CheminDeElementCopie=$2
			fi
		
		shift ; shift ;;
		

	"-p" | "--poste") variable1=1
	
		if [[ $variable2 == 1 ]] || [ -z $2 ] || [[ $2 == "-"* ]]  # On vérifie que le paramètre ne soit pas vide et que le deuxième argument ne soit pas un autre paramètre ou que le parametre salle n'est pas déjà executé
			then
				echo "$0: Je suis trop faible pour réaliser ce que tu m'as demandé" ; exit 2 # On prévient qu'il y a une erreur et que la fonction ne peut continuer
			else
				NomPoste=$2
			fi
		shift ; shift ;;


	"-s" | "--salle") variable2=1
	
		if [[ $variable1 == 1 ]] || [ -z $2 ] || [[ $2 == "-"* ]] # On vérifie que le paramètre soit vide et que -p a déjà été exécuté 
			then	
				echo "$0: Je suis trop faible pour réaliser ce que tu m'as demandé" ; exit 2 # On prévient qu'il y a une erreur et que la fonction ne peut continuer
			else
				read -p "Où est le dossier où il y aurait $2 ?" DossierSalle
				listes_serveur=`grep $2 $DossierSalle/FICHIER-DES-SALLES`
				NomDossier=$2
			fi
		shift ; shift ;;
		
		
	"-v" | "--verbose") VerboseMode=1
		shift ;;
	
	
	"-h" | "--help") # Ici on va accepter qu'on puisse faire un -h mais on va retourner une erreur (sans pour autant arrêter le programme)
		echo "Je ne peut pas tout faire en même temps !" > 2
		shift ;;
		
		
	"-lo" | "--log")
		if [ -z $2 ] || [[ $2 == "-"* ]]
		
		then 
		
			echo "$0: Et J'écris sur quoi, moi ?" ; exit 2 # On prévient qu'il y a une erreur et que la fonction ne peut continuer
		
		else
			touch recupererLog/$2
			chmod 777 recupererLog/$2
			LogMode=1
			FichierLog=$2
		fi
		
		shift ; shift ;;
	
	*   ) echo "$0: Syntaxe : $1 est un parametre illegal"  ; exit 2 # On arrête le programme si on voit un paramètre qui n'est pas dans la fonction
	
	esac
done

#----------------------------------Fin du traitement de tout les arguments----------------------------------------

#-------------------------------------------Début de la fonction--------------------------------------------------

#-----------------------------------------Version Verbose + log---------------------------------------------------
#-----------------------------------------Début de la méthode Poste-----------------------------------------------

if [[ $VerboseMode == 1 ]] && [[ $LogMode == 1 ]]
then
	echo "-----------------------------------------------" &>> recupererLog/$FichierLog
	echo "$0 : Debut de la fonction" &>> recupererLog/$FichierLog
	echo "$0 : Vous avez bien rentrés $NbArgument arguments" &>> recupererLog/$FichierLog
	echo "-----------------------------------------------" &> recupererLog/$FichierLog
	echo "$0 : Le mode Verbose est activé" &>> recupererLog/$FichierLog
	echo "$0 : Le mode Log est activé" &>> recupererLog/$FichierLog
	echo "-----------------------------------------------" &> recupererLog/$FichierLog

	if [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [ ! $NomPoste == 0 ]
	then
		echo "$0 : Les paramètres sont bien tous rentrés :" &>> recupererLog/$FichierLog
		echo "	Le chemin où l on va copier : $CheminDeLaCopie" &>> recupererLog/$FichierLog
		echo "	Le chemin de l élement qu on va copier : $CheminDeElementCopie" &>> recupererLog/$FichierLog
		echo "	Le nom du serveur où l on va copier : $NomPoste" &>> recupererLog/$FichierLog
		echo "-----------------------------------------------" &>> recupererLog/$FichierLog
		echo "$0 : Début de l opération de copie" &>> recupererLog/$FichierLog
		echo "-----------------------------------------------" &>> recupererLog/$FichierLog
		
		scp -prv $id"@linserv-info-"$NomPoste".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie &>> recupererLog/$FichierLog # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier
		
		echo "-----------------------------------------------" &>> recupererLog/$FichierLog
		echo "Fin de l opération de copie" &>> recupererLog/$FichierLog
#-----------------------------------------Fin de la méthode Poste-------------------------------------------------

#-----------------------------------------Début de la méthode salle-----------------------------------------------

	elif [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [[ ! -z $listes_serveur ]]
	then
		echo "$0 : Les paramètres sont bien tous rentrés :" &>> recupererLog/$FichierLog
		echo "	Le chemin où l on va copier : $CheminDeLaCopie" &>> recupererLog/$FichierLog
		echo "	Le chemin de l élement qu on va copier : $CheminDeElementCopie" &>> recupererLog/$FichierLog
		echo "	Le nom du serveur où l on va copier : $NomPoste" &>> recupererLog/$FichierLog
		echo "-----------------------------------------------" &>> recupererLog/$FichierLog
		echo "$0 : Début de l opération de copie" &>> recupererLog/$FichierLog
		echo "-----------------------------------------------" &>> recupererLog/$FichierLog
		
		mkdir $CheminDeLaCopie/$NomDossier
		
		for NomSalle in $listes_serveur #On repete tant que les serveurs n'ont pas été tous touché
		do
			echo "-----------------------------------------------" &>> recupererLog/$FichierLog
			echo "$0 : Essai sur $NomSalle" &>> recupererLog/$FichierLog
			echo "-----------------------------------------------" &>> recupererLog/$FichierLog
			
			mkdir $CheminDeLaCopie/$NomDossier/$NomSalle &>> recupererLog/$FichierLog #On crée le fichier qui va recevoir les fichiers/dossiers pour chaque serveur
			
			scp -prv $id"@"$NomSalle".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie/$NomDossier/$NomSalle &>> recupererLog/$FichierLog  # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier
			
			if [ ! -n "$(ls -A $CheminDeLaCopie/$NomDossier/$NomSalle)" ]
			then
				rm -r $CheminDeLaCopie/$NomDossier/$NomSalle # On supprime les dossier vides
			fi
		done
		
		echo "-----------------------------------------------" &>> recupererLog/$FichierLog
		echo "Fin de l opération de copie" &>> recupererLog/$FichierLog

#-----------------------------------------Fin de la méthode salle-------------------------------------------------

#-----------------------------------------Traitement des erreurs--------------------------------------------------
	else
		echo "Les paramètres n'ont pas été tous donnés ou mal utilisé" &>> recupererLog/$FichierLog
	fi
	
	echo "-----------------------------------------------" &>> recupererLog/$FichierLog
	echo "$0 : Fin de la fonction" &>> recupererLog/$FichierLog
	echo "-----------------------------------------------" &>> recupererLog/$FichierLog

#---------------------------------------------Version Verbose-----------------------------------------------------
#-----------------------------------------Début de la méthode Poste-----------------------------------------------

elif [[ $VerboseMode == 1 ]]
then
	echo "-----------------------------------------------"
	echo "$0 : Debut de la fonction"
	echo "$0 : Vous avez bien rentrés $NbArgument arguments"
	echo "-----------------------------------------------"
	echo "$0 : Le mode Verbose est activé"
	echo "-----------------------------------------------"

	if [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [ ! $NomPoste == 0 ]
	then
		echo "$0 : Les paramètres sont bien tous rentrés :"
		echo "		 Le chemin où l'on va copier : $CheminDeLaCopie"
		echo "		 Le chemin de l'élement qu'on va copier : $CheminDeElementCopie"
		echo "		 Le nom du serveur où l'on va copier : $NomPoste"
		echo "-----------------------------------------------"
		echo "$0 : Début de l'opération de copie"
		echo "-----------------------------------------------"
		
		scp -prv $id"@linserv-info-"$NomPoste".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier 
#-----------------------------------------Fin de la méthode Poste-------------------------------------------------

#-----------------------------------------Début de la méthode salle-----------------------------------------------

	elif [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [[ ! -z $listes_serveur ]]
	then
		echo "$0 : Les paramètres sont bien tous rentrés :"
		echo "	Le chemin où l on va copier : $CheminDeLaCopie"
		echo "	Le chemin de l élement qu on va copier : $CheminDeElementCopie"
		echo "	Le nom du serveur où l on va copier : $NomPoste"
		echo "-----------------------------------------------"
		echo "$0 : Début de l opération de copie"
		echo "-----------------------------------------------"
		
		mkdir $CheminDeLaCopie/$NomDossier
		
		for NomSalle in $listes_serveur #On repete tant que les serveurs n'ont pas été tous touché
		do
			echo "-----------------------------------------------"
			echo "$0 : Essai sur $NomSalle"
			echo "-----------------------------------------------"
			
			mkdir $CheminDeLaCopie/$NomDossier/$NomSalle #On crée le fichier qui va recevoir les fichiers/dossiers pour chaque serveur 
			scp -prv $id"@"$NomSalle".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie/$NomDossier/$NomSalle  # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier
			
			if [ ! -n "$(ls -A $CheminDeLaCopie/$NomDossier/$NomSalle)" ]
			then
				rm -r $CheminDeLaCopie/$NomDossier/$NomSalle # On supprime les dossier vides
			fi
		done
		
		echo "-----------------------------------------------"
		echo "Fin de l opération de copie"

#-----------------------------------------Fin de la méthode salle-------------------------------------------------

#-----------------------------------------Traitement des erreurs--------------------------------------------------
	else
		echo "Les paramètres n'ont pas été tous donnés"
	fi
	
	echo "-----------------------------------------------"
	echo "$0 : Fin de la fonction"
	echo "-----------------------------------------------"

#---------------------------------------------Version Log---------------------------------------------------------
#-----------------------------------------Début de la méthode Poste-----------------------------------------------

elif [[ $LogMode == 1 ]]
then

	if [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [ ! $NomPoste == 0 ]
	then
		scp -pr $id"@linserv-info-"$NomPoste".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie &>> recupererLog/$FichierLog # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier

#-----------------------------------------Fin de la méthode Poste-------------------------------------------------

#-----------------------------------------Début de la méthode salle-----------------------------------------------


elif [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [[ ! -z $listes_serveur ]]
	then
		mkdir $CheminDeLaCopie/$NomDossier
		
		for NomSalle in $listes_serveur #On repete tant que les serveurs n'ont pas été tous touché
		do
			mkdir $CheminDeLaCopie/$NomDossier/$NomSalle &>> recupererLog/$FichierLog #On crée le fichier qui va recevoir les fichiers/dossiers pour chaque serveur
			
			scp -pr $id"@"$NomSalle".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie/$NomDossier/$NomSalle &>> recupererLog/$FichierLog  # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier
			
			if [ ! -n "$(ls -A $CheminDeLaCopie/$NomDossier/$NomSalle)" ]
			then
				rm -r $CheminDeLaCopie/$NomDossier/$NomSalle # On supprime les dossier vides
			fi
		done


#-----------------------------------------Fin de la méthode salle-------------------------------------------------

#-----------------------------------------Traitement des erreurs--------------------------------------------------

	else
		echo "Les paramètres n'ont pas été tous donnés" &>> recupererLog/$FichierLog
	fi

#---------------------------------------------Version Normal------------------------------------------------------
#-----------------------------------------Début de la méthode Poste-----------------------------------------------

else

	if [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [ ! $NomPoste == 0 ]
	then
		scp -pr $id"@linserv-info-"$NomPoste".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier
		
#-----------------------------------------Fin de la méthode Poste-------------------------------------------------

#-----------------------------------------Début de la méthode salle-----------------------------------------------

	elif [ ! $CheminDeLaCopie == 0 ] && [ ! $CheminDeElementCopie == 0 ] && [[ ! -z $listes_serveur ]]
		then
			mkdir $CheminDeLaCopie/$NomDossier
			
			for NomSalle in $listes_serveur #On repete tant que les serveurs n'ont pas été tous touché
			do

				mkdir $CheminDeLaCopie/$NomDossier/$NomSalle #On crée le fichier qui va recevoir les fichiers/dossiers pour chaque serveur
				
				scp -pr $id"@"$NomSalle".campus.unice.fr:"$CheminDeElementCopie $CheminDeLaCopie/$NomDossier/$NomSalle  # On appelle la fonction la plus importante de notre fonction qui va s'occuper de copier
				
				if [ ! -n "$(ls -A $CheminDeLaCopie/$NomDossier/$NomSalle)" ]
				then
					rm -r $CheminDeLaCopie/$NomDossier/$NomSalle # On supprime les dossier vides
				fi
			done
			

#-----------------------------------------Fin de la méthode salle-------------------------------------------------

#-----------------------------------------Traitement des erreurs--------------------------------------------------

	else
		echo "Les paramètres n'ont pas été tous donnés"
	fi
fi

#------------------------------------------Fin de la fonction-----------------------------------------------------
