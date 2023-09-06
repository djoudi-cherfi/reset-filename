#!/usr/bin/env bash

declare -a files_list

files_list=(
    "01-Foo.# .baR #. ... bAz.txt"
    "02-Foo.@ .baR @. ... bAz.txt"
    "03-Foo.& .baR &. ... bAz.txt"
    "04-Foo."". baR"". ...bAz.txt"
    "05-Foo.' .baR '. ... bAz.txt"
    "06-Foo.( .baR (. ... bAz.txt"
    "07-Foo.{ .baR {. ... bAz.txt"
    "08-Foo.[ .baR [. ... bAz.txt"
    "09-Foo.§ .baR §. ... bAz.txt"
    "10-Foo.è .baR è. ... bAz.txt"
    "11-Foo.! .baR !. ... bAz.txt"
    "12-Foo.ç .baR ç. ... bAz.txt"
    "13-Foo.à .baR à. ... bAz.txt"
    "14-Foo.) .baR ). ... bAz.txt"
    "15-Foo.} .baR }. ... bAz.txt"
    "16-Foo.] .baR ]. ... bAz.txt"
    "17-Foo._ .baR _. ... bAz.txt"
    "18-Foo.- .baR -. ... bAz.txt"
    "19-Foo.¨ .baR ¨. ... bAz.txt"
    "20-Foo.^ .baR ^. ... bAz.txt"
    "21-Foo.* .baR *. ... bAz.txt"
    "22-Foo.$ .baR $. ... bAz.txt"
    "23-Foo € baR € . bAz.txt"
    "24-Foo % baR %  bAz.txt"
    "25-Foo ù baR ù  bAz.txt"
    "26-Foo £ baR £  bAz.txt"
    "27-Foo `` baR ``  bAz.txt"
    "28-Foo < baR <  bAz.txt"
    "29-Foo > baR >  bAz.txt"
    "30-Foo ? baR ?  bAz.txt"
    "31-Foo , baR ,  bAz.txt"
    "32-Foo . baR .  bAz.txt"
    "33-Foo ; baR ;  bAz.txt"
    "34-Foo 1234 baR 56789 bAz.txt"
    "35-Foo \ baR \  bAz.txt"
    ".36-.Foo | baR . | . bAz.txt"
    ".37-.Foo : baR . : . bAz.txt"
    ".38-.Foo + baR . + . bAz.txt"
    ".39-.Foo = baR . = . bAz.txt"
    ".40-.Foo é baR . é . bAz.txt"
    ".41-.Foo è baR . è . bAz.txt"
    ".42-.Foo ê baR . ê . bAz.txt"
    ".43-.Foo à baR . à . bAz.txt"
    ".44-.Foo œ baR . œ . bAz.txt"
    ".45-.Foo ù baR . ù . bAz.txt"
    ".46-.Foo ç baR . ç . bAz.txt"
)

error_missing_argument="missing argument"

print_error_and_exit() {
    echo "Error: $1"
    exit 1
}

check_argument() {
    option_pattern='^-[a-zA-Z]+$'
    if [[ -z $2 || $2 =~ $option_pattern ]]; then
        print_error_and_exit "$1 $error_missing_argument"
    fi
}

folder_path_and_folder_name() {
    folder_path=$(dirname "${directory_path:-"$PWD/test0"}")
    folder_name=$(basename "${directory_path:-"$PWD/test0"}")
    directory="$folder_path/$folder_name"
}

process_file() {
    if [[ $1 == "-f" ]]; then
        check_argument "-f" "$2"
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
                        [ -f | --file ] <directory_path>
                        [ -c | --create ] <arg>
                        ...
    OPTIONS:
        -f, --file
            Defines the path of the directory where the files must be created.
            program-name.sh -f <directory_path>
        
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
            -f | --file )
                check_argument "-f" "$2"
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