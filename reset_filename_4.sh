#!/usr/bin/env bash

declare -A options

options=(
    ["-g"]="global"
    ["-l"]="lowercase"
    ["-u"]="uppercase"
    ["-wa"]="without_accent"
    ["-pm"]="punctuation_mark"
    ["-sc"]="start_character"
    ["-ec"]="end_character"
    ["-dc"]="dots_to_character"
    ["-cco"]="consecutive_characters_to_one"
    ["-stc"]="switch_two_character"
)

error_missing_argument="missing argument"
error_too_many_argument="too many arguments"

print_error_and_exit() {
    echo "Error: $1"
    exit 1
}

check_argument() {
    if [[ -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
        print_error_and_exit "$1 $error_missing_argument"
    fi
}

check_next_argument() {
    if [[ -n $2 && ! $2 =~ ^-[a-zA-Z]+$ ]]; then
        print_error_and_exit "$1 $error_too_many_argument"
    fi
}

process_file() {
    if [[ $1 == "-f" ]]; then
        check_next_argument $1 $3
        check_argument "-f" "$2"
        directory_path=$2
        shift 2
    fi
}

rename_files() {
    local regex="$1"
    local replacement="$2"
    local start_substitution="$3"
    local end_substitution="$4"
    find ${directory_path:-"."} -name '*' -execdir rename -f -- "$start_substitution/$regex/$replacement/$end_substitution" '{}' \;
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

main() {
    if [[ $# -eq 0 ]]; then
        print_error_and_exit "no arguments provided. Use -h or --help for usage."
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
        -h | --help)
            help
            ;;
        -f)
            check_argument "-f" "$2"
            directory_path="$2"
            shift 2
            ;;
        *)
            if [[ -n "${options[$1]}" ]]; then
                local actions="${options[$1]}"

                for action in $actions; do
                    case "$action" in
                    "global")
                        shift 1
                        process_file $1 $2
                        # lowercase
                        rename_files "A-Z" "a-z" "y" ""
                        # without_accent
                        rename_files "œ" "oe" "s" "g"
                        rename_files "[à-üÀ-Ü]" "-" "s" "g"
                        # punctuation_mark
                        rename_files "[^a-zA-Z0-9\.\-]+" "-" "s" "g"
                        # dots_to_character
                        rename_files "\.(?=.*\.)" "-" "s" "g"
                        # consecutive_characters_to_one
                        rename_files "-{2,}" "-" "s" "g"
                        # start_character
                        rename_files "^-" "" "s" "g"
                        ;;
                    "lowercase")
                        shift 1
                        process_file $1 $2
                        rename_files "A-Z" "a-z" "y" ""
                        ;;
                    "uppercase")
                        shift 1
                        process_file $1 $2
                        rename_files "a-z" "A-Z" "y" ""
                        ;;
                    "without_accent")
                        shift 1
                        process_file $1 $2
                        rename_files "œ" "oe" "s" "g"
                        rename_files "[à-üÀ-Ü]" "-" "s" "g"
                        ;;
                    "punctuation_mark")
                        local option=$1
                        local arg1=$2
                        if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 1
                            process_file $1 $2
                            rename_files "œ" "oe" "s" "g"
                            rename_files "[^a-zA-Z0-9\.\-]+" "-" "s" "g"
                        else
                            shift 2
                            process_file $1 $2
                            rename_files "œ" "oe" "s" "g"
                            rename_files "[^a-zA-Z0-9\.\-]+" "$arg1" "s" "g"
                        fi
                        ;;
                    "start_character")
                        local option=$1
                        local arg1=$2
                        local arg2=$3
                        if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 1
                            process_file $1 $2
                            rename_files "^-" "" "s" "g"
                        elif [[ -n $arg1 && -z $arg2 || $arg2 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 2
                            check_argument $option $arg2
                        else
                            shift 3
                            check_next_argument $option $1
                            process_file $1 $2
                            rename_files "^$arg1" "$arg2" "s" "g"
                        fi
                        ;;
                    "end_character")
                        local option=$1
                        local arg1=$2
                        local arg2=$3
                        if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 1
                            process_file $1 $2
                            rename_files "-$" "" "s" "g"
                        elif [[ -n $arg1 && -z $arg2 || $arg2 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 2
                            check_argument $option $arg2
                        else
                            shift 3
                            check_next_argument $option $1
                            process_file $1 $2
                            rename_files "$arg1$" "$arg2" "s" "g"
                        fi
                        ;;
                    "dots_to_character")
                        local option=$1
                        local arg1=$2
                        if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 1
                            process_file $1 $2
                            rename_files "\.(?=.*\.)" "-" "s" "g"
                        else
                            shift 2
                            process_file $1 $2
                            rename_files "\.(?=.*\.)" "$arg1" "s" "g"
                        fi
                        ;;
                    "consecutive_characters_to_one")
                        local option=$1
                        local arg1=$2
                        if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 1
                            process_file $1 $2
                            rename_files "-{2,}" "-" "s" "g"
                        else
                            shift 2
                            process_file $1 $2
                            rename_files "$arg1{2,}" "$arg1" "s" "g"
                        fi
                        ;;
                    "switch_two_character")
                        local option=$1
                        local arg1=$2
                        local arg2=$3
                        if [[ -n $option && -z $arg1 || $arg1 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 1
                            process_file $1 $2
                            rename_files "-" "_" "s" "g"
                        elif [[ -n $arg1 && -z $arg2 || $arg2 =~ ^-[a-zA-Z]+$ ]]; then
                            shift 2
                            check_argument $option $arg2
                        else
                            shift 3
                            check_next_argument $option $1
                            process_file $1 $2
                            rename_files "$arg1$" "$arg2" "s" "g"
                        fi
                        ;;
                    esac
                done
            else
                print_error_and_exit "unknown option: $1. Use -h or --help for usage."
            fi
            ;;
        esac
    done
}

main "$@"
