#!/bin/bash

while true; do
    echo "\nColetando odds de futebol da Bet365..."
    curl https://www.bet365.com/#/AC/B1/C1/D13/E51799487/F2/ | grep -oP '(?<=sl-CouponParticipantWithBookCloses_Name">).*?(?=</)' | while read -r match; do
        echo "Jogo: $match"
    done
    # sleep 60
done