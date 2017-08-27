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

# Which tea file to process
TEABOX_TARGET="$1"
FULL_ID=${TEABOX_TARGET##*/}
PACK_ID=${FULL_ID%.*}

DATE="$(date +%y%m%d)"
LONGDATE="$(date +%y%m%d.%H%M%S)"

COLUMNS="Teabox-columns"
BASELINE="Teabox-baseline"
mkdir -p $COLUMNS $BASELINE

# File names are used in saveTodaysTeaboxFiles.sh
# so if you change them here, change them there as well
# they are named with today's date so running them twice
# in one day will only generate one set of results
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
# Name diffs with both date and time so every run produces a new result
POSSIBLE_DIFFS="Teabox_diffs-$PACK_ID-$LONGDATE.txt"

rm -f $TEA_FILE $TEA_INFO_FILE $TEA_DESCRIPTION_FILE $TEA_PASTED_FILE $TEA_SPREADSHEET_FILE

# Create a list of tea URLs for later processing, and data for the pack spreadsheet
awk -v TEA_FILE=$TEA_FILE -v TEA_DESCRIPTION_FILE=$TEA_DESCRIPTION_FILE \
    -v TEA_INFO_FILE=$TEA_INFO_FILE -v SERIES_NUMBER=$lastRow \
    -f getTeaboxFrom-tea.awk $TEABOX_TARGET

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
    cat $TEA_FILE | nl -n ln |
        sort --key=1,1n --key=4,4 --field-separator=\" >>$TEA_SPREADSHEET_FILE
else
    cat $TEA_FILE | nl -n ln |
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
$(checkdiffs $PUBLISHED_TEA_INFO $TEA_INFO_FILE)
$(checkdiffs $PUBLISHED_TEA_DESCRIPTION $TEA_DESCRIPTION_FILE)


### Any funny stuff with file lengths? Any differences in
### number of lines indicates the website was updated in the
### middle of processing. You should rerun the script!

$(wc $COLUMNS/*-$PACK_ID-$DATE.csv)

EOF

echo
echo "==> ${0##*/} completed: $(date)"
