#!/usr/bin/env bash

# NixOS Management
options=(
    "Edit Configuration"
    "Rebuild & Switch"
    "Rebuild & Boot"
    "Garbage Collection"
    "Reboot Now"
    "Exit"
)
current=0

# Clean up terminal and restore cursor on exit
trap "tput cnorm; clear; exit" SIGINT SIGTERM

function show_menu() {
    clear
    echo "--- NixOS Management Menu (2026) ---"
    echo "Use arrow keys to navigate, Enter to select."
    echo "-------------------------------------"
    for i in "${!options[@]}"; do
        if [[ $i -eq $current ]]; then
            echo -e "\e[1;32m> ${options[$i]}\e[0m" # Highlight green
        else
            echo "  ${options[$i]}"
        fi
    done
}

tput civis # Hide cursor

while true; do
    show_menu
    read -rsn3 key # Capture arrow keys

    case "$key" in
        $'\e[A') # Up arrow
            ((current--))
            [[ $current -lt 0 ]] && current=$((${#options[@]} - 1))
            ;;
        $'\e[B') # Down arrow
            ((current++))
            [[ $current -ge ${#options[@]} ]] && current=0
            ;;
        "") # Enter key
            tput cnorm
            case $current in
                0)
                    echo "Opening /etc/nixos/configuration.nix with Kate..."
                    kate /etc/nixos/configuration.nix & disown
                    ;;
                1)
                    echo "Applying changes immediately..."
                    sudo nixos-rebuild switch
                    ;;
                2)
                    echo "Building new configuration for next boot..."
                    sudo nixos-rebuild boot
                    ;;
                3)
                    echo "Cleaning up old generations and store garbage..."
                    sudo nix-collect-garbage -d
                    ;;
                4)
                    echo "Rebooting system..."
                    sudo systemctl reboot
                    ;;
                5)
                    clear
                    exit 0
                    ;;
            esac
            echo -e "\nPress any key to return to menu..."
            read -n1
            tput civis
            ;;
    esac
done
