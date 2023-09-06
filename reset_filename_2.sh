#!/usr/bin/env bash

convert_character_to_lowercase(){
    find . -name '*' -execdir rename -f -- 'y/A-Z/a-z/' '{}' \;
}

convert_character_to_uppercase(){
    find . -name '*' -execdir rename -f -- 'y/a-z/A-Z/' '{}' \;
}

replace_accented_character_with_unaccented() {
    find . -name '*' -execdir rename -f -- 's/é/e/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/è/e/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/ê/e/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/î/i/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/ï/i/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/à/a/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/ä/a/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/œ/oe/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/ù/u/g' '{}' \;
    find . -name '*' -execdir rename -f -- 's/ç/c/g' '{}' \;
}

# Replaces all characters except those in the range [a-z a-Z 0-9 .] with a dash.
replace_punctuation_mark_with_dash() {
    find . -name '*' -execdir rename -f -- 's/[^a-zA-Z0-9\.]+/-/g' '{}' \;
}

remove_start_punctuation_mark() {
    find . -name '*' -execdir rename -f -- "s/^[#\@\&\"\'\(\{\[\§\!\)\}\]\_\-\¨\^\*\$\€\%\£\`\<\>\?\,\.\;\/\\\|\:\+\=]+//g" '{}' \;
}

remove_end_punctuation_mark() {
    find . -name '*' -execdir rename -f -- "s/[#\@\&\"\'\(\{\[\§\!\)\}\]\_\-\¨\^\*\$\€\%\£\`\<\>\?\,\.\;\/\\\|\:\+\=]+$//g" '{}' \;
}

replace_dots_with_dashes() {
    find . -name '*' -execdir rename -f -- 's/\.(?=.*\.)/-/gm' '{}' \;
}

number_of_consecutive_dashes_to_one() {
    find . -name '*' -execdir rename -f -- 's/-{2,}/-/g' '{}' \;
}

replace_dashes_with_underscore() {
    find . -name '*' -execdir rename -f -- 's/-/_/g' '{}' \;
}

replace_underscores_with_dashe() {
    find . -name '*' -execdir rename -f -- 's/_/-/g' '{}' \;
}

help() {
    echo "
    NAME:
        ${0##*/}  -   Brief description

    USAGE:
        program-name.sh [ -h  | --help ]
                        [ -l  | --lowercase ]
                        [ -pm | --punctuation_mark ]
                        [ -dd | --dots_to_dashes ]
                        ...

    OPTIONS:
        -g, --global
            Executes several options: lowercase, without_accent,
            punctuation_mark, dots_to_dashes, consecutive_dashes_to_one

        -l, --lowercase
            Convert file names to all lower case.

        -u, --uppercase
            Convert file names to all upper case.

        -wa, --without_accent
            Replaces the accented character with the unaccented one.

        -pm, --punctuation_mark
            Replaces all characters except those in the range
            [a-z a-Z 0-9 .] with a dash.

        -spm, --start_punctuation_mark
            Remove the first of punctuation mark defined in the start.

        -epm, --end_punctuation_mark
            Remove the first of punctuation mark defined in the end.

        -dd, --dots_to_dashes
            Replaces all dots (not the last) with dashes.
        
        -cdo, --consecutive_dashes_to_one
            Reduces the number of consecutive dashes to a single repetition.
        
        -du, --dashes_to_underscore
            Replaces all dashes with an underscore.
                
        -ud, --underscores_to_dashe
            Replaces all underscores with an dashe.
  "
}

main() {
    while [[ -n $1 ]]; do
        case $1 in

        -h | --help )
            help
            ;;

        -g | --global )
            convert_character_to_lowercase
            replace_accented_character_with_unaccented
            replace_punctuation_mark_with_dash
            replace_dots_with_dashes
            number_of_consecutive_dashes_to_one
            ;;
        
        -l | --lowercase )
            convert_character_to_lowercase
            ;;

        -u | --uppercase )
            convert_character_to_uppercase
            ;;

        -wa | --without_accent )
            replace_accented_character_with_unaccented
            ;;

        -pm | --punctuation_mark )
            replace_punctuation_mark_with_dash
            ;;

        -spm | --start_punctuation_mark )
            remove_start_punctuation_mark
            ;;
        
        -epm | --end_punctuation_mark )
            remove_end_punctuation_mark
            ;;    

        -dd | --dots_to_dashes )
            replace_dots_with_dashes
            ;;

        -cdo | --consecutive_dashes_to_one )
            number_of_consecutive_dashes_to_one
            ;;

        -du | --dashes_to_underscore )
            replace_dashes_with_underscore
            ;;

        -ud | --underscores_to_dashe )
            replace_underscores_with_dashe
            ;;

        *)
            echo "Unknown option: $1 - Use -h or --help for usage."
            ;;

        esac
        shift
    done
}

main "$@"
