#!/usr/bin/env bash

error_missing_argument="missing argument"

print_error_and_exit() {
    echo "Error: $1"
    exit 1
}

check_non_empty_argument() {
    if [[ -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
        print_error_and_exit "$1 $error_missing_argument"
    fi
}

process_file() {
    if [[ $1 == "-f" ]]; then
        check_non_empty_argument "-f" "$2"
        directory_path=$2
        shift 2
    fi
}

help() {
    echo "
    NAME:
        ${0##*/}  -   Brief description

    USAGE:
        program-name.sh [ -h  | --help ]
                        [ -l  | --lowercase ]
                        [ -stc | --switch_two_character ] <arg1> <arg2>
                        [ -dc | --dots_to_character ] <arg1>
                        ...

    OPTIONS:
        => For special characters you must escape them \"\#\".

        -f, --file
            Defines the path of the directory where the elements must be renamed.
            program-name.sh -f <directory_path> -sc <arg1> <arg2>
                            -sc <arg1> <arg2> -f <directory_path>
                            ...
        
        -g, --global
            Executes several options with the default dash character as argument.
            lowercase, without_accent, punctuation_mark,
            dots_to_dashes, consecutive_dashes_to_one
        
        -l, --lowercase
            Convert file names to all lower case.

        -u, --uppercase
            Convert file names to all upper case.

        -wa, --without_accent
            Replaces the accented character with the unaccented one.
            program-name.sh -wa | 01-foo-bàr-bäz.txt > 01-foo-bar-baz.txt

        -pm, --punctuation_mark <arg1>
            Replaces all characters except those in the range
            [a-z a-Z 0-9 .] with the one of your choice.
            program-name.sh -pm        | 01_foo+bar%baz.txt > 01-foo-bar-baz.txt
                            -pm \"\+\" | 01_foo+bar%baz.txt > 01+foo+bar+baz.txt
        
        -sc, --start_character <arg1> <arg2>
            Replaces the first of character defined in the start.
            program-name.sh -sc - ""       | -01-foo-bar-baz.txt   > 01-foo-bar-baz.txt
                            -sc \"\&\" ""  | &01-foo-bar-baz.txt   > 01-foo-bar-baz.txt
                            -sc \"\%+\" "" | %%%01-foo-bar-baz.txt > 01-foo-bar-baz.txt
        
        -ec, --end_character <arg1> <arg2>
            Replaces the first of character defined in the end.
            program-name.sh -ec - ""       | 01-foo-bar-baz.txt-   > 01-foo-bar-baz.txt
                            -ec \"\+\" ""  | 01-foo-bar-baz.txt+   > 01-foo-bar-baz.txt
                            -ec \"\%+\" "" | 01-foo-bar-baz.txt%%% > 01-foo-bar-baz.txt
        
        -dd, --dots_to_character <arg1>
            Replaces all dots (not the last) with one of your choice.
            program-name.sh -dd -      | 01.foo.bar.baz.txt > 01-foo-bar-baz.txt
                            -dd \"\+\" | 01.foo.bar.baz.txt > 01+foo+bar+baz.txt
        
        -cco, --consecutive_characters_to_one <arg1>
            Reduces the number of consecutive characters to a single repetition.
            program-name.sh -cco -      | 01.foo-bar----baz.txt > 01.foo-bar-baz.txt
                            -cco \"\+\" | 01.foo++bar+++baz.txt > 01.foo+bar+baz.txt
        
        -stc, --switch_two_character <arg1> <arg2>
            Switches two characters.
            program-name.sh -tc _ -      | 01.foo_bar_baz.txt > 01.foo-bar-baz.txt
                            -tc \"\+\" - | 01.foo+bar+baz.txt > 01.foo-bar-baz.txt
  "
}

convert_character_to_lowercase(){
    find ${directory_path:-"."} -name '*' -execdir rename -f -- 'y/A-Z/a-z/' '{}' \;
}

convert_character_to_uppercase(){
    find ${directory_path:-"."} -name '*' -execdir rename -f -- 'y/a-z/A-Z/' '{}' \;
}

replace_accented_character_with_unaccented() {
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/œ/oe/g" '{}' \;
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/[à-üÀ-Ü]/-/g" '{}' \;
}

replace_punctuation_mark() (
    local option="$1"
    local arg="$2"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/œ/oe/g" '{}' \;
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/[^a-zA-Z0-9\.\-]+/$arg/g" '{}' \;
)

replace_start_character() {
    local option="$1"
    local arg1="$2"
    local arg2="$3"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/^$arg1/$arg2/g" '{}' \;
}

replace_end_character() {
    local option="$1"
    local arg1="$2"
    local arg2="$3"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/$arg1$/$arg2/g" '{}' \;
}

replace_dots_to_character() {
    local option="$1"
    local arg="$2"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/\.(?=.*\.)/$arg/g" '{}' \;
}

number_of_consecutive_characters_to_one() {
    local option="$1"
    local arg="$2"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/$arg{2,}/$arg/g" '{}' \;
}

switch_two_character() {
    local option="$1"
    local arg1="$2"
    local arg2="$3"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "s/$arg1/$arg2/g" '{}' \;
}

main() {
    if [[ $# = 0 ]]; then
        print_error_and_exit "no arguments provided. Use -h or --help for usage."
    fi
    
    while [[ $# > 0 ]]; do
        case $1 in
        -h | --help )
            help
            ;;
        -f | --file )
            check_non_empty_argument "-f" "$2"
            directory_path=$2
            shift 2
            ;;
        -g | --global )
            local option=$1
            shift 1
            process_file $1 $2
            convert_character_to_lowercase
            replace_accented_character_with_unaccented
            replace_punctuation_mark "$option" "-"
            replace_dots_to_character "$option" "-"
            number_of_consecutive_characters_to_one "$option" "-"
            replace_start_character "$option" "-" ""
            ;;
        -l | --lowercase )
            shift 1
            process_file $1 $2
            convert_character_to_lowercase
            ;;
        -u | --uppercase )
            shift 1
            process_file $1 $2
            convert_character_to_uppercase
            ;;
        -wa | --without_accent )
            shift 1
            process_file $1 $2
            replace_accented_character_with_unaccented
            ;;
        -pm | --punctuation_mark )
            local option=$1
            local arg=$2
            if [[ -n $option && -z $arg || $arg =~ ^-[a-zA-Z]+$  ]]; then
                shift 1
                process_file $1 $2
                replace_punctuation_mark "$option" "-"
            else
                shift 2
                process_file $1 $2
                replace_punctuation_mark "$option" "$arg"
            fi
            ;;
        -sc | --start_character )
            local option=$1
            local arg1=$2
            local arg2=$3
            if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                shift 1
                process_file $1 $2
                replace_start_character "$option" "-" ""
            elif [[ -n $arg1 && -z $arg2 ]]; then
                shift 2
                print_error_and_exit "$option $error_missing_argument $option"
            else
                shift 3
                process_file $1 $2
                replace_start_character "$option" "$arg1" "$arg2"
            fi
            ;;
        -ec | --end_character )
            local option=$1
            local arg1=$2
            local arg2=$3
            if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                shift 1
                process_file $1 $2
                replace_start_character "$option" "-" ""
            elif [[ -n $arg1 && -z $arg2 ]]; then
                shift 2
                print_error_and_exit "$option $error_missing_argument $option"
            else
                shift 3
                process_file $1 $2
                replace_start_character "$option" "$arg1" "$arg2"
            fi
            ;;
        -dc | --dots_to_character )
            local option=$1
            local arg=$2
            if [[ -n $option && -z $arg || $arg =~ ^-[a-zA-Z]+$  ]]; then
                shift 1
                process_file $1 $2
                replace_dots_to_character "$option" "-"
            else
                shift 2
                process_file $1 $2
                replace_dots_to_character "$option" "$arg"
            fi
            ;;
        -cco | --consecutive_characters_to_one )
            local option=$1
            local arg=$2
            if [[ -n $option && -z $arg || $arg =~ ^-[a-zA-Z]+$  ]]; then
                shift 1
                process_file $1 $2
                number_of_consecutive_characters_to_one "$option" "-"
            else
                shift 2
                process_file $1 $2
                number_of_consecutive_characters_to_one "$option" "$arg"
            fi
            ;;
        -stc | --switch_two_character )
            local option=$1
            local arg1=$2
            local arg2=$3
            if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                shift 1
                process_file $1 $2
                switch_two_character "$option" "-" "_"
            elif [[ -n $arg1 && -z $arg2 ]]; then
                shift 2
                print_error_and_exit "$option $error_missing_argument $option"
            else
                shift 3
                process_file $1 $2
                switch_two_character "$option" "$arg1" "$arg2"
            fi
            ;;
        *)
            print_error_and_exit "unknown option: $1. Use -h or --help for usage."
            ;;
        esac
    done
}

main "$@"
