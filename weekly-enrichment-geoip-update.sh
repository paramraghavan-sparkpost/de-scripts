function geoiptest {
    local geoip_test_email='param.raghavan@sparkpost.com'
    local geoip_test_dt=`date +"%m-%d-%Y"`
    if [[ "$1" == "stg" ]]; then
       send_test_email 'app.stg.sparkpost' 'staging' 279301 ${geoip_test_dt} ${geoip_test_email} ${2}
    elif [[ "$1" == "prd" ]]; then
       send_test_email 'app.prd.sparkpost' 'spc' 105 ${geoip_test_dt} ${geoip_test_email} ${2}
    elif [[ "$1" == "eu" ]]; then
       send_test_email 'app.aws-euw1.prd.sparkpost' 'spceu' 6 ${geoip_test_dt} ${geoip_test_email} ${2}
    else
       echo 'USAGE: geoiptest ENV [test]\nENV must be stg, prd, or eu\nIf "test" is passed no CURL commands will be run instead they will be printed'
    fi
}

function send_test_email {
    local geoip_test_start=`date`
    local geoip_test_command="curl --location --request POST 'http://$1:8888/api/v1/transmissions' \
--header 'Content-Type: application/json' \
--header 'x-msys-tenant: $2' \
--header 'x-msys-customer: $3' \
--data-raw '{
  \"content\": {
    \"template_id\": \"geo-ip\"
  },
  \"campaign_id\": \"$4\",
  \"recipients\": [
    {
     \"address\": {
       \"email\": \"$5\"
     }
    }
  ]
}'"
    local geoip_test_monitor_command="curl --silent --location --request GET 'http://$1:8888/api/v1/events/message?campaigns=$4&events=open,click,initial_open' \
--header 'Content-Type: application/json' \
--header 'x-msys-tenant: $2' \
--header 'x-msys-customer: $3'  jq '.results[]  .type, .subject, .geo_ip, .user_agent, .user_agent_parsed'; echo '\n\nStarted running at $geoip_test_start\n\n'"

    if [[ "$6" == "test" ]]; then
       echo "url : $1"
       echo "tenant : $2"
       echo "customer : $3"
       echo "campaign-id : $4"
       echo "email_address : $5"
       echo "send message curl : $geoip_test_command"
       echo "review results command : $geoip_test_monitor_command"
    else
       eval $geoip_test_command
       watch -n 15 "$geoip_test_monitor_command"
    fi

}

geoiptest eu