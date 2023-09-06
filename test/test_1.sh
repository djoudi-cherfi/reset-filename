#!/usr/bin/env bash

create_file() {
    echo "File: 01" > "$1/01-Foo.# .baR #. ... bAz.txt"
    echo "File: 02" > "$1/02-Foo.@ .baR @. ... bAz.txt"
    echo "File: 03" > "$1/03-Foo.& .baR &. ... bAz.txt"
    echo "File: 04" > "$1/04-Foo."". baR"". ...bAz.txt"
    echo "File: 05" > "$1/05-Foo.' .baR '. ... bAz.txt"
    echo "File: 06" > "$1/06-Foo.( .baR (. ... bAz.txt"
    echo "File: 07" > "$1/07-Foo.{ .baR {. ... bAz.txt"
    echo "File: 08" > "$1/08-Foo.[ .baR [. ... bAz.txt"
    echo "File: 09" > "$1/09-Foo.§ .baR §. ... bAz.txt"
    echo "File: 10" > "$1/10-Foo.è .baR è. ... bAz.txt"
    echo "File: 11" > "$1/11-Foo.! .baR !. ... bAz.txt"
    echo "File: 12" > "$1/12-Foo.ç .baR ç. ... bAz.txt"
    echo "File: 13" > "$1/13-Foo.à .baR à. ... bAz.txt"
    echo "File: 14" > "$1/14-Foo.) .baR ). ... bAz.txt"
    echo "File: 15" > "$1/15-Foo.} .baR }. ... bAz.txt"
    echo "File: 16" > "$1/16-Foo.] .baR ]. ... bAz.txt"
    echo "File: 17" > "$1/17-Foo._ .baR _. ... bAz.txt"
    echo "File: 18" > "$1/18-Foo.- .baR -. ... bAz.txt"
    echo "File: 19" > "$1/19-Foo.¨ .baR ¨. ... bAz.txt"
    echo "File: 20" > "$1/20-Foo.^ .baR ^. ... bAz.txt"
    echo "File: 21" > "$1/21-Foo.* .baR *. ... bAz.txt"
    echo "File: 22" > "$1/22-Foo.$ .baR $. ... bAz.txt"
    echo "File: 23" > "$1/23-Foo € baR € . bAz.txt"
    echo "File: 24" > "$1/24-Foo % baR %  bAz.txt"
    echo "File: 25" > "$1/25-Foo ù baR ù  bAz.txt"
    echo "File: 26" > "$1/26-Foo £ baR £  bAz.txt"
    echo "File: 27" > "$1/27-Foo `` baR ``  bAz.txt"
    echo "File: 28" > "$1/28-Foo < baR <  bAz.txt"
    echo "File: 29" > "$1/29-Foo > baR >  bAz.txt"
    echo "File: 30" > "$1/30-Foo ? baR ?  bAz.txt"
    echo "File: 31" > "$1/31-Foo , baR ,  bAz.txt"
    echo "File: 32" > "$1/32-Foo . baR .  bAz.txt"
    echo "File: 33" > "$1/33-Foo ; baR ;  bAz.txt"
    echo "File: 34" > "$1/34-Foo 1234 baR 56789 bAz.txt"
    echo "File: 35" > "$1/35-Foo \ baR \  bAz.txt"
    echo "File: 36" > "$1/.36-.Foo | baR . | . bAz.txt"
    echo "File: 37" > "$1/.37-.Foo : baR . : . bAz.txt"
    echo "File: 38" > "$1/.38-.Foo + baR . + . bAz.txt"
    echo "File: 39" > "$1/.39-.Foo = baR . = . bAz.txt"
    echo "File: 40" > "$1/.40-.Foo é baR . é . bAz.txt"
    echo "File: 41" > "$1/.41-.Foo è baR . è . bAz.txt"
    echo "File: 42" > "$1/.42-.Foo ê baR . ê . bAz.txt"
    echo "File: 43" > "$1/.43-.Foo à baR . à . bAz.txt"
    echo "File: 44" > "$1/.44-.Foo œ baR . œ . bAz.txt"
    echo "File: 45" > "$1/.45-.Foo ù baR . ù . bAz.txt"
    echo "File: 46" > "$1/.46-.Foo ç baR . ç . bAz.txt"
}

directory_path=$1

if [[ -z $directory_path ]]; then
    directory_path=$PWD
fi

create_folder_and_file() {
    echo "The test folder was not found."
    echo "Creation of the folder test, test1, test2 and files."

    mkdir -p "${directory_path}/test"
    create_file "${directory_path}/test"

    mkdir -p "${directory_path}/test/test1"
    create_file "${directory_path}/test/test1"

    mkdir -p "${directory_path}/test/test1/test2"
    create_file "${directory_path}/test/test1/test2"
}

delete_folder_and_file() {
    echo "The test folder was found and deleted"
    rm -rf "${directory_path}/test"
}

if [[ ! -d "${directory_path}/test" ]]; then
    create_folder_and_file
else
    delete_folder_and_file
    create_folder_and_file
fi
