#!/usr/bin/env bash

declare -A options

options=(
    ["-h"]="help"
    ["-dir"]="directory_path"
    ["-g"]="global"
    ["-l"]="lowercase"
    ["-u"]="uppercase"
    ["-pma"]="punctuation_mark_accent"
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

check_missing_argument() {
    if [[ -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
        print_error_and_exit "$1 $error_missing_argument"
    fi
}

check_too_many_argument() {
    if [[ -n $2 && ! $2 =~ ^-[a-zA-Z]+$ ]]; then
        print_error_and_exit "$1 $error_too_many_argument"
    fi
}

rename_files() {
    local regex="$1"
    local replacement="$2"
    local start_substitution="$3"
    local end_substitution="$4"
    find "${directory_path:-"."}" -name '*' -execdir rename -f -- "${start_substitution:-"s"}/$regex/$replacement/${end_substitution:-"g"}" '{}' \;
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

        -dir, --directory_path
            Defines the path of the directory where the elements must be renamed.
            program-name.sh -dir <directory_path> -sc <arg1> <arg2>
                            -sc <arg1> <arg2> -dir <directory_path>
                            ...
        
        -g, --global
            Executes several options with the default dash character as argument.
            lowercase, without_accent, punctuation_mark_accent,
            dots_to_dashes, consecutive_dashes_to_one
        
        -l, --lowercase
            Convert file names to all lower case.

        -u, --uppercase
            Convert file names to all upper case.

        -pma, --punctuation_mark_accent <arg1>
            Replaces all punctuation marks and accented characters.
            program-name.sh -pma        | 01_foo+bar%baz.txt > 01-foo-bar-baz.txt
                            -pma \"\+\" | 01_foo+bar%baz.txt > 01+foo+bar+baz.txt
        
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

directory_path() {
    while [[ $# -gt 0 ]]; do
        if [[ -n "${options[$1]}" ]]; then
            local actions="${options[$1]}"

            for action in $actions; do
                case "$action" in
                "help") shift 1 ;;
                "directory_path")
                    check_missing_argument "$1" "$2"
                    directory_path="$2"
                    shift 2
                    ;;
                "global") shift 1 ;;
                "lowercase") shift 1 ;;
                "uppercase") shift 1 ;;
                "punctuation_mark_accent")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        shift 1
                    else
                        check_too_many_argument $1 $3
                        shift 2
                    fi
                    ;;
                "start_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        shift 1
                    else
                        check_missing_argument $1 $3
                        check_too_many_argument $1 $4
                        shift 3
                    fi
                    ;;
                "end_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        shift 1
                    else
                        check_missing_argument $1 $3
                        check_too_many_argument $1 $4
                        shift 3
                    fi
                    ;;
                "dots_to_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        shift 1
                    else
                        check_too_many_argument $1 $3
                        shift 2
                    fi
                    ;;
                "consecutive_characters_to_one")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        shift 1
                    else
                        check_too_many_argument $1 $3
                        shift 2
                    fi
                    ;;
                "switch_two_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        shift 1
                    else
                        check_missing_argument $1 $3
                        check_too_many_argument $1 $4
                        shift 3
                    fi
                    ;;
                esac
            done
        else
            print_error_and_exit "unknown option: $1. Use -h or --help for usage."
        fi
    done
}

main() {
    if [[ $# -eq 0 ]]; then
        print_error_and_exit "no arguments provided. Use -h or --help for usage."
    fi

    directory_path "$@"

    while [[ $# -gt 0 ]]; do
        if [[ -n "${options[$1]}" ]]; then
            local actions="${options[$1]}"

            for action in $actions; do
                case "$action" in
                "help")
                    help
                    shift 1
                    ;;
                "directory_path") shift 2 ;;
                "global")
                    # lowercase
                    rename_files "A-Z" "a-z" "y" ""
                    # punctuation_mark_accent
                    rename_files "œ" "oe"
                    rename_files "[^a-zA-Z0-9\.\-]+" "-"
                    # dots_to_character
                    rename_files "\.(?=.*\.)" "-"
                    # consecutive_characters_to_one
                    rename_files "-{2,}" "-"
                    # start_character
                    rename_files "^-" ""
                    shift 1
                    ;;
                "lowercase")
                    rename_files "A-Z" "a-z" "y" ""
                    shift 1
                    ;;
                "uppercase")
                    rename_files "a-z" "A-Z" "y" ""
                    shift 1
                    ;;
                "punctuation_mark_accent")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        rename_files "œ" "oe"
                        rename_files "[^a-zA-Z0-9\.\-]+" "-"
                        shift 1
                    else
                        rename_files "œ" "oe"
                        rename_files "[^a-zA-Z0-9\.\-]+" "$2"
                        shift 2
                    fi
                    ;;
                "start_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        rename_files "^-" ""
                        shift 1
                    else
                        rename_files "^$2" "$3"
                        shift 3
                    fi
                    ;;
                "end_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        rename_files "-$" ""
                        shift 1
                    else
                        rename_files "$2$" "$3"
                        shift 3
                    fi
                    ;;
                "dots_to_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        rename_files "\.(?=.*\.)" "-"
                        shift 1
                    else
                        rename_files "\.(?=.*\.)" "$2"
                        shift 2
                    fi
                    ;;
                "consecutive_characters_to_one")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        rename_files "-{2,}" "-"
                        shift 1
                    else
                        rename_files "$2{2,}" "$2"
                        shift 2
                    fi
                    ;;
                "switch_two_character")
                    if [[ -n $1 && -z $2 || $2 =~ ^-[a-zA-Z]+$ ]]; then
                        rename_files "-" "_"
                        shift 1
                    else
                        rename_files "$2" "$3"
                        shift 3
                    fi
                    ;;
                esac
            done
        else
            print_error_and_exit "unknown option: $1. Use -h or --help for usage."
        fi
    done
}

main "$@"
