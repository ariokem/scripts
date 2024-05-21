#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Aucun paramètre fourni. Veuillez fournir une variable en tant qu'argument."
    exit 1
fi

if [ -z "$1" ]; then
    echo "le message de commit dois être donnée en paramètre du script"
    exit
fi

echo $1

while true; do
    git status
    read -p "commit add ok? (y/n): " yn
    case $yn in
        [Yy]* ) commit_add_check="true"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ "$commit_add_check" = "true" ]; then
    while true; do
	read -p "branch develop? (y/n): " yn
        case $yn in
            [Yy]* ) branch_develop_check="true"; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

if [ "$branch_develop_check" = "true" ]; then
    git pull
    git commit -m "$1"
    git push
    git checkout master
    git pull
    git merge develop
    git push

    latest_tag=$(git tag --sort=-v:refname | head -n 1)

    # Vérification si aucun tag n'est disponible
    if [ -z "$latest_tag" ]; then
        echo "Aucun tag n'est disponible. vous devez en définir un manuellement et faire un push --tags"
    else
        echo "Le dernier tag est : $latest_tag"
	# Séparation de la version en parties
	IFS='.' read -ra tag_parts <<< "$latest_tag"
	
	# Incrémentation de la partie de la version
	((tag_parts[2]++))

	# Reconstruction de la nouvelle version
	new_tag="${tag_parts[0]}.${tag_parts[1]}.${tag_parts[2]}"
        git tag $new_tag
        git push --tags
	git checkout develop
    fi
fi
