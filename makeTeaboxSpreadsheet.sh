#! /bin/bash
# Create a .csv spreadsheet of teas available on Teabox

# Use "-d" switch to output a "diffs" file useful for debugging
# Use :-u" switch to leave spreadsheet unsorted, i.e. in the order found on the web
while getopts ":dtu" opt; do
    case $opt in
    d)
        DEBUG="yes"
        ;;
    u)
        UNSORTED="yes"
        ;;
    \?)
        echo "Ignoring invalid option: -$OPTARG" >&2
        ;;
    esac
done
shift $((OPTIND - 1))

# Tea Packs we are interested in
#    https://www.teabox.com/tea/black-tea-sample-set
#    https://www.teabox.com/tea/collection-of-all-teas
#    https://www.teabox.com/tea/samples-of-all-2015-darjeeling-spring-first-flush-teas
#    https://www.teabox.com/tea/sample-of-all-muscatel-teas
#    https://www.teabox.com/tea/sample-of-all-black-darjeeling-teas
#    https://www.teabox.com/tea/sample-of-all-darjeeling-teas
#    https://www.teabox.com/tea/sample-of-all-nilgiri-teas
#    https://www.teabox.com/tea/sample-of-all-summer-teas
#    https://www.teabox.com/tea/spring-tea-collection

# Which tea URLs to process
TEABOX_TARGET="$1"
PACK_ID=${TEABOX_TARGET##*/}

# Make sure we can execute curl.
if [ ! -x "$(which curl 2>/dev/null)" ]; then
    echo "[Error] Can't run curl. Install curl and rerun this script."
    echo "        To test, type:  curl -Is https://github.com/ | head -5"
    exit 1
fi

# Make sure network is up and the Teabox site is reachable
if ! curl -o /dev/null -Isf $TEABOX_TARGET; then
    echo "[Error] $TEABOX_TARGET isn't available, or your network is down."
    echo "        Try accessing $TEABOX_TARGET in your browser"
    exit 1
fi

DATE="$(date +%y%m%d)"
LONGDATE="$(date +%y%m%d.%H%M%S)"

COLUMNS="Teabox-columns"
BASELINE="Teabox-baseline"
mkdir -p $COLUMNS $BASELINE

# File names are used in saveTodaysTeaboxFiles.sh
# so if you change them here, change them there as well
# they are named with today's date so running them twice
# in one day will only generate one set of results
URL_FILE="$COLUMNS/urls-$PACK_ID-$DATE.csv"
PUBLISHED_URLS="$BASELINE/urls-$PACK_ID.txt"
PACK_FILE="$COLUMNS/packs-$PACK_ID-$DATE.csv"
PUBLISHED_PACKS="$BASELINE/packs-$PACK_ID.txt"
DESCRIPTION_FILE="$COLUMNS/descriptions-$PACK_ID-$DATE.csv"
PUBLISHED_DESCRIPTIONS="$BASELINE/descriptions-$PACK_ID.txt"
PACK_SPREADSHEET_FILE="Teabox_Packs-$PACK_ID-$DATE.csv"
PACK_PUBLISHED_SPREADSHEET="$BASELINE/spreadsheet_packs-$PACK_ID.txt"
#
TEA_FILE="$COLUMNS/teas-$PACK_ID-$DATE.csv"
PUBLISHED_TEAS="$BASELINE/teas-$PACK_ID.txt"
TEA_INFO_FILE="$COLUMNS/teaInfo-$PACK_ID-$DATE.csv"
PUBLISHED_TEA_INFO="$BASELINE/teaInfo-$PACK_ID.txt"
TEA_DESCRIPTION_FILE="$COLUMNS/teaDescriptions-$PACK_ID-$DATE.csv"
PUBLISHED_TEA_DESCRIPTION="$BASELINE/teaDescriptions-$PACK_ID.txt"
TEA_PASTED_FILE="$COLUMNS/teaPasted-$PACK_ID-$DATE.csv"
PUBLISHED_TEA_PASTED="$BASELINE/teaPasted-$PACK_ID.txt"
TEA_SPREADSHEET_FILE="Teabox_Teas-$PACK_ID-$DATE.csv"
TEA_PUBLISHED_SPREADSHEET="$BASELINE/spreadsheet_teas-$PACK_ID.txt"
#
PACK_NOTE_FILE="Pack_Note-$PACK_ID-$DATE.txt"
TEA_NOTE_FILE="Tea_Note-$PACK_ID-$DATE.txt"
NOTE_FILE="$COLUMNS/notes-$PACK_ID-$DATE.txt"
PUBLISHED_NOTES="$BASELINE/notes-$PACK_ID.txt"
#
# Name diffs with both date and time so every run produces a new result
POSSIBLE_DIFFS="Teabox_diffs-$PACK_ID-$LONGDATE.txt"

rm -f $URL_FILE $PACK_FILE $DESCRIPTION_FILE $PACK_SPREADSHEET_FILE \
    $TEA_FILE $TEA_INFO_FILE $TEA_DESCRIPTION_FILE $TEA_PASTED_FILE $TEA_SPREADSHEET_FILE \
    $PACK_NOTE_FILE $TEA_NOTE_FILE $NOTE_FILE

# Output pack header
printf "#\tTea\tPrice\tDescription\tDiscount\tSale Price\tIn Stock\n" >$PACK_SPREADSHEET_FILE

# Create a list of tea URLs for later processing, and data for the pack spreadsheet
curl -s $TEABOX_TARGET |
    awk -v URL_FILE=$URL_FILE -v PACK_FILE=$PACK_FILE -v DESCRIPTION_FILE=$DESCRIPTION_FILE \
        -v PACK_SPREADSHEET_FILE=$PACK_SPREADSHEET_FILE -v TEA_NOTE_FILE=$TEA_NOTE_FILE \
        -f getTeaboxFrom-pack.awk

# keep track of the number of rows in the spreadsheet
lastRow=1
# loop through the list of tea URLs from $URL_FILE
while read -r line; do
    # Create column files with data for the tea spreadsheet
    curl -s "$line" |
        awk -v TEA_FILE=$TEA_FILE -v TEA_DESCRIPTION_FILE=$TEA_DESCRIPTION_FILE \
            -v TEA_INFO_FILE=$TEA_INFO_FILE -v SERIES_NUMBER=$lastRow \
            -v NOTE_FILE=$NOTE_FILE -f getTeaboxFrom-tea.awk
    ((lastRow++))
done <"$URL_FILE"

# Output pack body
if [ "$UNSORTED" = "yes" ]; then
    # sort key 1 sorts in the order found on the web
    # sort key 4 sorts by title
    cat -n $PACK_FILE |
        sort --key=1,1n --key=4 --field-separator=\" >>$PACK_SPREADSHEET_FILE
    cat $NOTE_FILE >>$TEA_NOTE_FILE
else
    cat -n $PACK_FILE |
        sort --key=4 --field-separator=\" >>$PACK_SPREADSHEET_FILE
    sort $NOTE_FILE >>$TEA_NOTE_FILE
fi

# Output pack note
cut -f1,2 -d'|' $TEA_NOTE_FILE | sed -e 's/ $//' >$PACK_NOTE_FILE

# Output tea header
HEADER="#\tTea\tGrams\tOunces\tCups\tPrice\tPer Cup\tInstructions\tSteeps\tDrink With"
HEADER+="\tTags\tPicking Date\tTime of Day\tCaffeine\tBest Consumed\tSeason\tSpecialty"
HEADER+="\tSKU\tGrade\tInvoice\tDescription\tAppearance\tAroma\tTaste\tComplements"
HEADER+="\tDry Leaf Appearance\tDry Leaf Aroma\tInfusion Appearance\tInfusion Aroma\tTea Estate"
printf "$HEADER\n" >$TEA_SPREADSHEET_FILE
#
# Output tea body
if [ "$UNSORTED" = "yes" ]; then
    # sort key 1 sorts in the order found on the web
    # sort key 4 sorts by title
    cat -n $TEA_FILE |
        sort --key=1,1n --key=4,4 --field-separator=\" >>$TEA_SPREADSHEET_FILE
else
    cat -n $TEA_FILE |
        sort --key=4,4 --field-separator=\" >>$TEA_SPREADSHEET_FILE
fi

# If we don't want to create a "diffs" file for debugging, exit here
if [ "$DEBUG" != "yes" ]; then
    exit
fi

# Shortcut for checking differences between two files.
# checkdiffs basefile newfile
function checkdiffs() {
    echo
    if [ ! -e "$2" ]; then
        echo "==> $2 does not exist. Skipping diff."
        return 1
    fi
    if [ ! -e "$1" ]; then
        # If the basefile file doesn't yet exist, assume no differences
        # and copy the newfile to the basefile so it can serve
        # as a base for diffs in the future.
        echo "==> $1 does not exist. Creating it, assuming no diffs."
        cp -p "$2" "$1"
    else
        echo "==> what changed between $1 and $2:"
        # first the stats
        diff -c "$1" "$2" | diffstat -sq \
            -D $(cd $(dirname "$2") && pwd -P) |
            sed -e "s/ 1 file changed,/==>/" -e "s/([+-=\!])//g"
        # then the diffs
        diff \
            --unchanged-group-format='' \
            --old-group-format='==> deleted %dn line%(n=1?:s) at line %df <==
%<' \
            --new-group-format='==> added %dN line%(N=1?:s) after line %de <==
%>' \
            --changed-group-format='==> changed %dn line%(n=1?:s) at line %df <==
%<------ to:
%>' "$1" "$2"
        if [ $? == 0 ]; then
            echo "==> no diffs found"
        fi
    fi
}

# Preserve any possible errors for debugging
cat >>$POSSIBLE_DIFFS <<EOF
==> ${0##*/} completed: $(date)

$(checkdiffs $PUBLISHED_URLS $URL_FILE)
$(checkdiffs $PUBLISHED_PACKS $PACK_FILE)
$(checkdiffs $PUBLISHED_DESCRIPTIONS $DESCRIPTION_FILE)
$(checkdiffs $PUBLISHED_TEAS $TEA_FILE)
$(checkdiffs $PUBLISHED_TEA_INFO $TEA_INFO_FILE)
$(checkdiffs $PUBLISHED_TEA_DESCRIPTION $TEA_DESCRIPTION_FILE)
$(checkdiffs $PUBLISHED_NOTES $NOTE_FILE)


### Any funny stuff with file lengths? Any differences in
### number of lines indicates the website was updated in the
### middle of processing. You should rerun the script!

$(wc $COLUMNS/*-$PACK_ID-$DATE.csv)

EOF

echo
echo "==> ${0##*/} completed: $(date)"
