#!/bin/bash
# backup.sh
. /home/pi/ShellBackup/backup.config
type read
NOW=`date '+%F'`;
mkdir "${backupfile}_${NOW}"
mkdir "${backupfile}_${NOW}/sql"
mkdir "${backupfile}_${NOW}/logs"

echo "Lien du dossier www à copier : $wwwfile"
echo "Lien du dossier backupfile : $backupfile"
echo "Existance d'un db : $aredb"
echo "Système de gestion de base de données : $SGBD"
echo "Database Name : $dbname"
echo "DB Host : $dbhost"
echo "DB User : $dbuser"
echo "DB Password : $dbpsswd"
echo "Existance de virtuals hosts : $arevh"
echo "Lien du dossier virtual host : $vhfile"
echo ""

logs() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "${backupfile}_${NOW}/logs/logs_${NOW}.txt"
}
# Ititialization

mainmenu() {
    echo "Voulez vous lancez la procédure ? "
    read -n 1 -p "Y/N : " input
    if  [ "$input" = "Y" ]; then
        clear
        logs "------------------------"
        logs "-- logs du ${NOW} --"
        logs "------------------------"
        logs ""
        backup
        elif [ "$input" = "N" ]; then
        rm -r "${backupfile}_${NOW}"
        echo "bye"
        exit
    else
        rm -r "${backupfile}_${NOW}"
        echo "input invalid"
        exit
    fi
    
}

backup() {
    cd "/var/www/"
    echo "DÉBUT DE LA COPIE DES FICHIER WWW"
    logs "DÉBUT DE LA COPIE DES FICHIER WWW"
    case $? in
        0) cp -R "${wwwfile}" -t "${backupfile}_${NOW}"
            case $? in
                0) echo "COPIE DU FICHIER WWW EFFECTUÉ"
                    logs "COPIE DU FICHIER WWW EFFECTUÉ"
                ;;
                1) echo "ERREUR DANS LA COPIE DU FICHIER WWW"
                    logs "ERREUR DANS LA COPIE DU FICHIER WWW"
                    exit
                ;;
                *) echo "ERREUR SYSTEME"
                    logs "ERREUR SYSTEM"
                    exit
                ;;
        esac ;;
        1) echo "ERREUR ACCES AU FICHIER WWW"
            logs "ERREUR ACCES AU FICHIER WWW"
        exit ;;
    esac
    case $arevh in
        Y) cd "/etc/apache2/sites-available"
            echo "DÉBUT DE LA COPIE DES FICHIER VH"
            case $? in
                0) cp -R "${$vhfile}" -t "${backupfile}_${NOW}"
                    case $? in
                        0) echo "COPIE DU DOSSIER VIRTUALS HOSTS EFFECTUÉ"
                            logs "COPIE DU DOSSIER VIRTUALS HOSTS EFFECTUÉ"
                        ;;
                        1) echo "ERREUR DANS LA COPIE DES VIRTUALS HOSTS"
                            logs "ERREUR DANS LA COPIE DES VIRTUALS HOSTS"
                            exit
                        ;;
                        *) echo "ERREUR SYSTEME"
                            logs "ERREUR SYSTEME"
                            exit
                        ;;
                esac ;;
                N)
                ;;
                *) echo "ERREUR CONFIG FILE"
                exit;;
            esac
    esac
    case $aredb in
        Y) case $SGBD in
                MYSQL)
                    echo "DEBUT DE LA COPIE DE LA DB MYSQL"
                    logs "DEBUT DE LA COPIE DE LA DB MYSQL"
                    mysqldump -h $dbhost --user="$dbuser" --password="$dbpsswd" $dbname > ${backupfile}_${NOW}/sql/dump_bdd_mysql.sql
                    if [ $? -eq 0 ]
                    then
                        echo "COPIE DE LA DB EFFECTUÉ"
                        logs "COPIE DE LA DB EFFECTUÉ"
                    else
                        echo "ERREUR DE LA COPIE DE LA DB"
                        logs "ERREUR DE LA COPIE DE LA DB"
                    fi
                ;;
                POSTGRESQL)
                    echo "DEBUT DE LA COPIE DE LA DB POSTGRESQL"
                    lgos "DEBUT DE LA COPIE DE LA DB POSTGRESQL"
                    pg_dump -h $dbhost -u $dbuser -w $dbpsswd -d $dbname > ${backupfile}_${NOW}/sql/dump_bdd_Postgre.sql
                    if [ $? -eq 0 ]
                    then
                        echo "COPIE DE LA DB EFFECTUÉ"
                        logs "COPIE DE LA DB EFFECTUÉ"
                    else
                        echo "ERREUR DE LA COPIE DE LA DB"
                        logs "ERREUR DE LA COPIE DE LA DB"
                    fi
                ;;
                SQLSERVER)
                    echo "DEBUT DE LA COPIE DE LA DB SQL SERVER"
                    logs "DEBUT DE LA COPIE DE LA DB SQL SERVER"
                    sqlcmd -S $dbhost -U $dbuser -P $dbpsswd -Q "BACKUP DATABASE [$dbname] TO DISK = N'${backupfile}_${NOW}/sql/dump_bdd_SQLserv.sql"
                    if [ $? -eq 0 ]
                    then
                        echo "COPIE DE LA DB EFFECTUÉ"
                        logs "COPIE DE LA DB EFFECTUÉ"
                    else
                        echo "ERREUR DE LA COPIE DE LA DB"
                        logs "ERREUR DE LA COPIE DE LA DB"
                    fi
                ;;
                N)
                ;;
                *) echo "SGBD NON SUPPORTÉ"
                    echo "ERREUR DANS LE CONFIG FILE"
                    logs "SGBD NON SUPPORTÉ"
                    logs "ERREUR DANS LE CONFIG FILE"
                ;;
            esac
    esac
    
}
mainmenu

echo "FIN DU SCRIPT"
logs "FIN DU SCRIPT"