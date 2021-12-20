#! /bin/bash

# M111 - TP11 - ajouterposte.sh (version prototype a terminer)
# Ajout  a la fin d'un fichier (ou creation du fichier) de lignes composées 
# d'un mot, chaque mot terminé par 00 à 99.
# Le fichier de nom FICHIER-DES-SALLES se trouve dans le répertoire indiqué 
# par la variable d'environnement REP_SALLES.

# Exemple : 
# $ q6 S756P 01 11 
# $ cat $REP_SALLES/FICHIER-DES-SALLES 
# S756P01
# S756P02
# S756P03
# S756P05
# S756P06
# S756P07
# S756P08
# S756P09
# S756P10
# S756P11
# $ 

read -p "Entrer le répertoire des Salles :" REP_SALLES

if [ ! -d $REP_SALLES ]
then
mkdir $REP_SALLES
fi

if [[ $# -ne 3 ]]  ; then echo "Syntaxe : $0 salle debut fin" ; exit 2 ; fi
if [[  ! -d $REP_SALLES  ]] ; then echo '$REP_SALLE absente ou incorrecte' ; exit 2 ; fi
if [[ $3 -gt 99 ]] ; then echo "Nombre entre 0 et 99 !" ; exit 2 ; fi 
for NB in $(seq $2 $3)
do
   if [[ $NB -le 9 ]]
     then echo ${1}0$NB
     else echo $1$NB
   fi
done >> $REP_SALLES/FICHIER-DES-SERVEURS
