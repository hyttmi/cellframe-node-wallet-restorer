#!/bin/bash

restore_wallet() {
    read -p "--- Input your 24 word seed phrase: " words
    count=$(echo $words | wc -w)
    if [[ $count -lt 24 ]] || [[ $count -gt 24 ]]; then
        echo "--- Invalid word amount ($count words), was expecting 24 words!"
        restore_wallet
    fi
    read -p "--- Input your wallet password (if any): " password
    read -p "--- Input desired name to your wallet (WITHOUT SPACES, A-Z, a-z, 0-9!): " wallet_name
    if [[ -z $wallet_name ]]; then
        echo "--- Invalid wallet name!"
        exit 1
    fi

    if [[ -z $password ]]; then
        sha256=$(echo -n $words | tr -d [:blank:] | sha256sum | cut -d " " -f1)
        sh -c "/opt/cellframe-node/bin/cellframe-node-cli wallet new -w $wallet_name -sign sig_dil -restore 0x$sha256 -force"
    elif [[ $count -eq 24 ]] && [[ ! -z $password ]]; then
        sha256=$(echo -n $words$password | tr -d [:blank:] | sha256sum | cut -d " " -f1)
        sh -c "/opt/cellframe-node/bin/cellframe-node-cli wallet new -w $wallet_name -sign sig_dil -restore 0x$sha256 -password $password -force"
    else
        echo "--- Not a 24 word seed phrase, your seed phrase had $count words!"
        read -p "--- Try again? (y/n): " try_again
        if [[ $try_again =~ ^[yY]$ ]]; then
            restore_wallet
        else
            echo "--- Exiting..."
            exit 1
        fi
    fi
}

restore_wallet
