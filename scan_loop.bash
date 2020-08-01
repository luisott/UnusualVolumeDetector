#!/bin/bash
# This script runs market_scanner.py in a loop and only reports new tickers detected once
# if Twilio account information passed it will send an sms on every ticker detected
# See more information about setting up a Twilio account for sending sms here
# https://www.twilio.com/docs/sms/quickstart/python#sign-up-for-or-sign-in-to-twilio

helpFunction()
{
   echo "Stock scanner in a loop, if twilio account info passed it'll send a text message when new ticker detected"
   echo "Usage: $0 -f \"+18004567898\" -t \"+18004567899\" -s \"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\" -p \"XXXXXXXXXXXXXXXXXXXXXXXXXXXXX\""
   echo -e "\t-f From phone number (e.g. +18004567898). This will be the one you created with Twilio"
   echo -e "\t-t To phone number (e.g. +18004567899)"
   echo -e "\t-s Twilio account sid"
   echo -e "\t-p Twilio auth token"
   exit 1 # Exit script after printing help
}

while getopts f:t:s:p: flag
do
    case "${flag}" in
        f) from=${OPTARG};;
        t) to=${OPTARG};;
        s) sid=${OPTARG};;
        p) token=${OPTARG};;
        ? ) helpFunction ;;
    esac
done

tickers_found=()
while true; do python3 ./market_scanner.py; done |
while read line; do
  if [[ $line == Ticker* ]] && [[ ! " ${tickers_found[@]} " =~ " ${line} " ]]
  then
    tickers_found+=( "$line" )
    echo "FOUND TICKER $line"
    if [ -z "$from" ] || [ -z "$to" ] || [ -z "$sid" ] || [ -z "$token" ]
    then
      continue
    fi
    curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$sid/Messages.json" \
      --data-urlencode "Body=Buy this shit $line" --data-urlencode "From=$from" --data-urlencode "To=$to" \
      -u "$sid":"$token"
  fi
done
