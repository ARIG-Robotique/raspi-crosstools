# raspi-crosstools

Ce repository permet de récupérer tous les éléments nécéssaire à la cross compilation des binaires pour nos RaspberryPI utilisé dans les robots ou autres équipement base sur ce micro ordinateur.

## Définition du sysroot

Afin de pouvoir faire de la cross compilation il faut disposer d'une image du système de fichier avec les différentes librairies, include nécéssaire à la compilation d'autres projets.

Afin de constituer celui-ci il faut installer une Raspberry PI (avec [ansible-raspi](https://github.com/ARIG-Robotique/ansible-raspi) ou manuellement) et y ajouter toutes les dépendances packagé nécéssaire a notre usage.

Une fois toutes les dépendances installé sur la Raspberry PI il faut les récupérer afin de disposer du fameux `sysroot` nécéssaire à la cross compilation.

Pour cela il faut depuis une machine :

```
$> mkdir sysroot-<version_rapios>-raspios-<release_name>-<cpu_architecture>
$> rsync -avz --delete odin:/lib sysroot-<version_rapios>-raspios-<release_name>-<cpu_architecture>
$> rsync -avz --delete odin:/usr/include sysroot-<version_rapios>-raspios-<release_name>-<cpu_architecture>/usr
$> rsync -avz --delete odin:/usr/lib sysroot-<version_rapios>-raspios-<release_name>-<cpu_architecture>/usr
$> rsync -avz --delete odin:/opt/vc sysroot-<version_rapios>-raspios-<release_name>-<cpu_architecture>/opt
```

NB : Il faut pouvoir se connecter en SSH a à la raspberry pi

* `<version_rapios>` : Version de l'image de Raspbian/RaspiOS utilisé. Exemple 2021.05.07
* `<release_name>` : Nom de la release utilisé. Exemple buster
* `<cpu_architecture>` : Architecture du processeur utilisé. Exemples armhf, aarch64

Une fois le sysroot récupérer, il est temps de le mettre à disposition de tous.

Pour cela il sera publié dans le registre Maven de ce repo GitHub. Il faut donc au préalable être authentifié sur celui-ci. Pour cela voici la [documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-apache-maven-registry)

```
$> mvn deploy:deploy-file -DgroupId=org.arig -DartifactId=sysroot-raspi -Dversion=<version_rapios> -Dpackaging=tar.gz -Dclassifier=<release_name>-<cpu_architecture> -Dfile=<file> -DrepositoryId=<maven-config-for-auth> -Durl=https://maven.pkg.github.com/ARIG-Robotique/raspi-crosstools
```
Exemple : `mvn deploy:deploy-file -DgroupId=org.arig -DartifactId=sysroot-raspi -Dversion=2021.05.07 -Dpackaging=tar.gz -Dclassifier=buster-aarch64 -Dfile=sysroot-2021-05-07-raspios-buster-aarch64.tar.gz -DrepositoryId=gh-raspi-crosstools -Durl=https://maven.pkg.github.com/ARIG-Robotique/raspi-crosstools`

mvn deploy:deploy-file -DgroupId=org.arig -DartifactId=sysroot-raspi -Dversion=2022.01.28 -Dpackaging=tar.gz -Dclassifier=bullseye-aarch64 -Dfile=sysroot-2022-01-28-raspios-bullseye-aarch64.tar.gz -DrepositoryId=gh-raspi-crosstools -Durl=https://maven.pkg.github.com/ARIG-Robotique/raspi-crosstools

## Construction d'un Kit pour QT

TODO