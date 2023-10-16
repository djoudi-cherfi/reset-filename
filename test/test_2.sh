#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/files_list.sh"

error_missing_argument="missing argument"

print_error_and_exit() {
    echo "Error: $1"
    exit 1
}

check_argument() {
    if [[ -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
        print_error_and_exit "$1 $error_missing_argument"
    fi
}

folder_path_and_folder_name() {
    folder_path=$(dirname "${directory_path:-"$PWD/test0"}")
    folder_name=$(basename "${directory_path:-"$PWD/test0"}")
    directory="$folder_path/$folder_name"
}

process_file() {
    if [[ $1 == "-dir" ]]; then
        check_argument "-dir" "$2"
        directory_path=$2
        shift 2
    fi
}

create_file() {
    for file in "${files_list[@]}"; do
        echo "File: 01" > "$1/${file}"
    done
}

create_folder_and_file() {
    local iteration=1
    local number_of_files="$1"

    echo "Create ${folder_name} folder and subfolder with files."

    mkdir -p "${directory}"
    create_file "${directory}"

    while [[ "${iteration}" -le "${number_of_files}" ]]; do
        directory+="/${folder_name}${iteration}"

        mkdir -p "${directory}"
        create_file "${directory}"

        iteration=$(( "${iteration}" + 1 ))
    done
}

delete_folder_and_file() {
    echo "The $2 folder was found and deleted."
    rm -rf "$1"
}

help() {
    echo "
    NAME:
        ${0##*/}  -  Brief description

    USAGE:
        program-name.sh [ -h | --help ]
                        [ -dir | directory_path ] <directory_path>
                        [ -c | --create ] <arg>
                        ...
    OPTIONS:
        -dir, directory_path
            Defines the path of the directory where the files must be created.
            program-name.sh -dir <directory_path>
        
        -c, --create
            If folder "test" not exist create folder and subfolder with files.
            program-name.sh -c <arg>
        
        -d, --delete
            If folder "test" exist delete folder and subfolder with files.
        
        -g, --global
            If folder "test" exist delete folder and subfolder with files and
            if folder "test" not exist create folder and subfolder with files.
  "
}

main() {
    if [[ $# -eq 0 ]]; then
        print_error_and_exit "no arguments provided. Use -h or --help for usage."
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help )
                shift 1
                help
                ;;
            -dir | directory_path )
                check_argument "-dir" "$2"
                directory_path="$2"
                shift 2
                ;;
            -c | --create )
                local option=$1
                local arg=$2
                shift 2
                process_file $1 $2
                check_argument $option $arg
                folder_path_and_folder_name
                if [[ ! -d "${directory_path:-"$PWD/test0"}" ]]; then
                    create_folder_and_file "${arg}"
                else
                    echo "The ${folder_name} folder already exists"
                fi
                ;;
            -d | --delete )
                shift 1
                process_file $1 $2
                folder_path_and_folder_name
                if [[ -d "${directory_path:-"$PWD/test0"}" ]]; then
                    delete_folder_and_file "${directory}" "${folder_name}"
                else
                    echo "The ${folder_name} folder does not exist"
                fi
                ;;
            -g | --global )
                local option=$1
                local arg=$2
                shift 2
                process_file $1 $2
                check_argument $option $arg
                folder_path_and_folder_name
                if [[ -d "${directory_path:-"$PWD/test0"}" ]]; then
                    delete_folder_and_file "${directory}" "${folder_name}"
                fi

                if [[ ! -d "${directory_path:-"$PWD/test0"}" ]]; then
                    create_folder_and_file "${arg}"
                fi
                ;;
            * )
                print_error_and_exit "unknown option: $1. Use -h or --help for usage."
                ;;
        esac
    done
}

main "$@"
