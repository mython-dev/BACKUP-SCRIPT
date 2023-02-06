#!/bin/bash 

                                      # ______            _                      _____           _       _   
                                      # | ___ \          | |                    /  ___|         (_)     | |  
                                      # | |_/ / __ _  ___| | ___   _ _ __ ______\ `--.  ___ _ __ _ _ __ | |_ 
                                      # | ___ \/ _` |/ __| |/ / | | | '_ \______|`--. \/ __| '__| | '_ \| __|
                                      # | |_/ / (_| | (__|   <| |_| | |_) |     /\__/ / (__| |  | | |_) | |_ 
                                      # \____/ \__,_|\___|_|\_\\__,_| .__/      \____/ \___|_|  |_| .__/ \__|
                                      #                             | |                           | |        
                                      #                             |_|                           |_|        


                                                          # Code by: myth-dev
                                                          # Github: @mython-dev
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

############################### PARAMETRES ###############################
BACKUP_DATE_DIR=/home/myth/backup
BACKUP_DIR=$BACKUP_DATE_DIR/$(date +%Y%m%d%H%M)
DIRECTORIES="/home/myth/data /home/myth/config"
DBUSER=
PASS=
DAYS_TO_STORE=7
############################### PARAMETRES ################################

echo "Started at: "$(date)

mkdir $BACKUP_DIR

# Making and archivation DB dumps

mysqldump --opt -u $DBUSER -p$PASS --events --all-database > $BACKUP_DIR/all.sql

tar -cjf $BACKUP_DIR/all.sql.tbz -C $BACKUP_DIR/ all.sql

rm $BACKUP_DIR/all.sql

echo "Database backup finished!"

# Making directory backups

echo "Start Backup DIRECTORIES"

for DIRNAME in $DIRECTORIES
do 
    echo "Backuping $DIRNAME"
    cd $DIRNAME
    FILENAME=`echo $DIRNAME | sed 's/[\/]/\_/g' | sed 's/^\_\+\|\_\+$//g'`
    tar -cjf $BACKUP_DIR/$FILENAME.tbz ./
done

echo "DIRECTORIES backup finished!!!"

# Changing mode

chmod -R 700 $BACKUP_DIR

# Removing old backups 

cd $BACKUP_DATE_DIR
find ./* -type d -mtime +$DAYS_TO_STORE | xargs -r rm -R

echo -e "Finished at: " $(date)"\n"
