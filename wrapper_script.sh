# Inconsistency Audit Script

filepath="$OPSTMP/Inconsistency_Audit/$(date +'%Y-%m-%d')"
mkdir -p $filepath
touch $filepath/InconsistentServers_$FIELDS_STAGE

ah-site list % > $filepath/$FIELDS_STAGE

touch $filepath/temp_to_process_$FIELDS_STAGE.txt

for site in $(cat $filepath/$FIELDS_STAGE); do
  echo -e "[ $(date) ] - Examining $site now ..."
  esl_op=$(esl $site | sed '1,4d')
  all_servers=$(echo -e "$esl_op" | sed '1,4d' | awk '{print $1}' | tr -d ',')
  echo -e "$esl_op"  | awk '{print $1 , $3}' | tr -d ',' > $filepath/temp_to_process_$FIELDS_STAGE.txt
  inconsistent_servers=$(python3 find_inconsistency.py $filepath/temp_to_process_$FIELDS_STAGE.txt)

  if [ -z "$inconsistent_servers" ]; then
    echo -e "No Inconsistency Found. Moving On !"
  else
    echo -e "- - - - - $site - - - - -\n$inconsistent_servers\n\n- - - - - - - - - -\n\n" >> $filepath/InconsistentServers_$FIELDS_STAGE
    echo -e "Inconsistency Found:\n$inconsistent_servers"
  fi

  echo;echo;
  grep -vwE "$site" $filepath/$FIELDS_STAGE > $OPSTMP/Inconsistency_Audit/temp_file_for_processing && mv $OPSTMP/Inconsistency_Audit/temp_file_for_processing $filepath/$FIELDS_STAGE
done


cat $filepath/InconsistentServers_$FIELDS_STAGE
