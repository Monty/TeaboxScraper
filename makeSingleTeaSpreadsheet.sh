#! /bin/bash
# Create a .csv spreadsheet of a single tea available on Teabox
# Process a single tea file downloaded from teabox -- e.g.
#   curl -O https://www.teabox.com/tea/goomtee-summer-darjeeling-black-tea1
#   ./makeSingleTeaSpreadsheet.sh goomtee-summer-darjeeling-black-tea1

# Use "-d" switch to output a "diffs" file useful for debugging
while getopts ":dtu" opt; do
    case $opt in
    d)
        DEBUG="yes"
        ;;
    \?)
        echo "Ignoring invalid option: -$OPTARG" >&2
        ;;
    esac
done
shift $((OPTIND - 1))

# Which tea file to process
TEABOX_TARGET="$1"
FULL_ID=${TEABOX_TARGET##*/}
PACK_ID=${FULL_ID%.*}

DATE="$(date +%y%m%d)"
LONGDATE="$(date +%y%m%d.%H%M%S)"

COLUMNS="Teabox-columns"
BASELINE="Teabox-baseline"
mkdir -p $COLUMNS $BASELINE

# Files are named with today's date so running scripts twice
# in one day will only generate one set of results
#
TEA_FILE="$COLUMNS/teas-$PACK_ID-$DATE.csv"
PUBLISHED_TEAS="$BASELINE/teas-$PACK_ID.txt"
TEA_INFO_FILE="$COLUMNS/teaInfo-$PACK_ID-$DATE.txt"
PUBLISHED_TEA_INFO="$BASELINE/teaInfo-$PACK_ID.txt"
TEA_DESCRIPTION_FILE="$COLUMNS/teaDescriptions-$PACK_ID-$DATE.txt"
PUBLISHED_TEA_DESCRIPTION="$BASELINE/teaDescriptions-$PACK_ID.txt"
TEA_SPREADSHEET_FILE="Teabox_Teas-$PACK_ID-$DATE.csv"
TEA_PUBLISHED_SPREADSHEET="$BASELINE/spreadsheet_teas-$PACK_ID.txt"
#
TEA_NOTE_FILE="Tea_Note-$PACK_ID-$DATE.txt"
NOTE_FILE="$COLUMNS/notes-$PACK_ID-$DATE.txt"
PUBLISHED_NOTES="$BASELINE/notes-$PACK_ID.txt"
#
# Name diffs with both date and time so every run produces a new result
POSSIBLE_DIFFS="Teabox_diffs-$PACK_ID-$LONGDATE.txt"

rm -f $TEA_FILE $TEA_INFO_FILE $TEA_DESCRIPTION_FILE $TEA_NOTE_FILE $NOTE_FILE $TEA_SPREADSHEET_FILE

# Create data for tea note and spreadsheet
awk -v TEA_FILE=$TEA_FILE -v TEA_DESCRIPTION_FILE=$TEA_DESCRIPTION_FILE \
    -v TEA_INFO_FILE=$TEA_INFO_FILE -v SERIES_NUMBER=$lastRow \
    -v NOTE_FILE=$NOTE_FILE -f getTeaboxFrom-tea.awk $TEABOX_TARGET

# Output note file
printf "Tea | Per Cup | Caffeine | Appearance | Aroma | Taste | Description\n\n" >$TEA_NOTE_FILE
cat $NOTE_FILE >>$TEA_NOTE_FILE

# Build tea header
# Primary
HEADER="#\tTea\tGrams\tPrice\tPer Cup\tInstructions\tCaffeine\tAppearance\tAroma\tTaste"
HEADER+="\tDescription\tComplements\tTea Estate"
# Secondary
HEADER+="\tDry Leaf Appearance\tDry Leaf Aroma\tInfusion Appearance\tInfusion Aroma\tSeason"
HEADER+="\tTags\tSpecialty\tGrade\tDrink With\tTime of Day"
# Tertiary
HEADER+="\tOunces\tCups\tSteeps\tBest Consumed\tPicking Date\tSKU\tInvoice"

# Output tea header
printf "$HEADER\n" >$TEA_SPREADSHEET_FILE

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

$(checkdiffs $PUBLISHED_TEAS $TEA_FILE)
$(checkdiffs $PUBLISHED_NOTES $NOTE_FILE)
$(checkdiffs $PUBLISHED_TEA_INFO $TEA_INFO_FILE)
$(checkdiffs $PUBLISHED_TEA_DESCRIPTION $TEA_DESCRIPTION_FILE)


### Any funny stuff with file length?

$(wc $COLUMNS/*-$PACK_ID-$DATE.csv)

EOF

echo
echo "==> ${0##*/} completed: $(date)"
