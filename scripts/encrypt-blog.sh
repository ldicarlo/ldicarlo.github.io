#!/bin/bash
set -e

LOCATION="$HOME/projects/ldicarlo.github.io"
MASTERPASSWORD="$(cat "$LOCATION/.masterpassword")"
FILE="$LOCATION/kvstore"
EXPORT="$LOCATION/_data/passwords.yml"
toencrypt="$LOCATION/_private"
encrypted="$LOCATION/_posts"

mkdir -p "$toencrypt"
mkdir -p "$encrypted"

declare -A kv

loadKVStore(){
    touch "$FILE"
    while IFS=' ' read -r key value
    do
        kv[$key]="$value"
    done < "$FILE"
}

get(){
    loadKVStore
    echo "${kv[$1]}"
}

put(){
    loadKVStore
    kv["$1"]="$2"
    rm "$FILE"
    for i in "${!kv[@]}"
    do
        echo "$i ${kv[$i]}" >> "$FILE"
    done
}

exportAsYML(){
    loadKVStore
    rm "$EXPORT"
    for i in "${!kv[@]}"
    do
        echo "- link: $i" >> "$EXPORT"
        echo "  password: ${kv[$i]}" >> "$EXPORT"
    done
}

# $1 file to encrypt
# $2 destination
# $3 password
encryptFile(){
    TEXT=$(cat "$1")
    DEST="$2/$(decryptedFileToKey "$1")"
    FRONTMATTER=$(frontMatter "$TEXT")
    ENCRYPTED=$(partToEncrypt "$TEXT" | kramdown | gpg --quiet --passphrase="$3" --batch --armor -c - | base64 | tr -d '\n')
    ORIGINAL_ENCRYPTED=$(partToEncrypt "$TEXT" | gpg --quiet --passphrase="$3" --batch --armor -c - | base64 | tr -d '\n')
    FILENAME="$(basename "$1" | gpg --quiet --passphrase="$3" --batch --armor -c - | base64 | tr -d '\n')"
    {
        echo "---";
        echo "$FRONTMATTER";
        echo "original_content: $ORIGINAL_ENCRYPTED";
        echo "filename: $FILENAME"
        echo "---";
        echo "";
        echo "$ENCRYPTED";
    } > "$DEST"
}

# $1 file to decrypt
# $2 destination
# $3 password
decryptFile(){
    TEXT=$(cat "$1" | grep -v "private: true")
    DEST="$2/$(basename "$1")"
    FRONTMATTER=$(frontMatter "$TEXT")
    ENCRYPTED=$(originalContent "$TEXT" | base64 -d | gpg --batch --passphrase="$3" -d -)
    {
        echo "---";
        echo "$FRONTMATTER";
        echo "---";
        echo "";
        echo "$ENCRYPTED";
    } > "$DEST"
}

frontMatterEnd(){
    echo "$1" | grep -n "\-\-\-" | head -n 2 | tail -n 1 | sed -E 's/(.*):.*/\1/g'
}

frontMatter(){
    END=$(frontMatterEnd "$1")
    echo  "$1" | head -n "$END" | grep -v "original_content: *" | grep -v "\-\-\-"
}

partToEncrypt(){
    echo  "$1" | tr '\n' '~' | sed -E 's/\-\-\-.*\-\-\-~+(.*)/\1/g' | tr '~' '\n'
}

originalContent(){
    echo  "$1" | grep "original_content:" | sed -E 's/original_content: (.*)/\1/g'
}

encryptText(){
    echo "ENCRYPTED TEXT"
}

getPassword(){
    VALUE=$(get "$1")
    if [[ -z "$VALUE" ]]; then
        VALUE=$(pwgen -s 64 1)
        ENCRYPTEDPASS=$(echo "$VALUE" | gpg --quiet --passphrase="$MASTERPASSWORD" --batch --armor -c -  | base64 | tr -d '\n')
        put "$1" "$ENCRYPTEDPASS"
        echo "$VALUE"
    else
        DECRYPTED="$(echo "$VALUE" | base64 -d  | gpg --batch --passphrase="$MASTERPASSWORD" -d -)"
        echo "$DECRYPTED"
    fi


}

decryptedFileToKey(){
  datePart="${1:0:10}"
  textPart="${1:11}"
  shaText="$(echo "$textPart" | sha256sum | tr -d ' -')"
  echo "$datePart-${shaText:0:10}"
}

encryptAll(){
    if [[ -n "$(ls -A "$1")" ]]; then
        for f in "$1"/*; do
            # KEY="$(basename "$f" | sha256sum | tr -d ' -' )"
            # PASS="$(getPassword "$KEY")"
            # encryptFile "$KEY" "$2" "$PASS"
            # echo "LINK: $KEY $f $PASS"
            PASS="$(getPassword "$(basename "$f")")"
            encryptFile "$f" "$2" "$PASS"
            echo "LINK: $f $PASS"
        done
        exportAsYML
    fi
}

decryptAll(){
    if [[ -n "$(ls -A "$1")" ]]; then
        for f in "$1"/*; do
            EXISTS=$(get "$(basename "$f")")
            if [[ -n "$EXISTS" ]]; then
                echo "Decrypting $f"
                VALUE=$(getPassword "$(basename "$f")")
                decryptFile "$f" "$2" "$VALUE"
                echo "Decrypted $f"
            fi

        done
        exportAsYML
    fi
}

if [[ ! $# -eq 0 ]] ; then
    case "$1" in
        "--encrypt-all") encryptAll "$toencrypt" "$encrypted" ;;
        "--decrypt-all") decryptAll "$encrypted" "$toencrypt" ;;
    esac
fi
