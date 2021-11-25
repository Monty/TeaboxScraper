# Aroma, Palate, Instructions, Region, Specialty, Caffeine, Add-Ons, SKU, Date

# Price
# Description
# Liquor: Aroma, Appearance, Taste, Complements
# Dry Leaf: Aroma, Appearance
# Infusion: Aroma, Appearance
# Steeping Notes: Hot, 6 fl oz, 176oF -185oF, 3.0 tsp / 2.5 g, 4 mins
# Recommended number of steeps - 1
# Drink Plain
# Picking Date 08-06-2017
# Time of Day: Afternoon
# Caffeine: Medium
# Best Consumed: Hot
# Season: First
# Specialty: Clonal | Chinary
# SKU FFJPCLB | Grade SFTGFOP1
# Estate description

# 124: <meta property="og:title" content="Darjeeling Special Spring White">
/<meta property="og:title" content="/ {
    split ($0,fld,"\"")
    tea_title = fld[4]
    gsub (/&#39;/,"’",tea_title)
    print "tea_title = " tea_title >> TEA_INFO_FILE
    next
}

# 144: <meta property="og:description" content="
# If you are looking to get acquainted ... ahead in your tea journey.">
/<meta property="og:description" content="/ {
    getline
    split ($0,fld,"\"")
    tea_description = fld[1]
    gsub (/&#39;/,"’",tea_description)
    gsub (/&lsquo;/,"’",tea_description)
    gsub (/&rsquo;/,"’",tea_description)
    gsub (/&ldquo;/,"“",tea_description)
    gsub (/&rdquo;/,"”",tea_description)
    gsub (/&amp;/,"\\&",tea_description)
    gsub (/\r/,"",tea_description)
    print tea_description >> TEA_DESCRIPTION_FILE
    next
}

# 146: <meta property="og:price:amount" content="62.96">
/<meta property="og:price:amount" content="/ {
    split ($0,fld,"\"")
    tea_price = fld[4]
    print "tea_price = " tea_price >> TEA_INFO_FILE
    next
}

# 149: <meta property="og:url" content="\
#     https://www.teabox.com/products/wonder-spring-darjeeling-white-tea">
/<meta property="og:url" content="/{
    split ($0,fld,"\"")
    tea_URL = fld[4]
    print "tea_URL = " tea_URL >> TEA_INFO_FILE
    next
}

# <ul class="horz-list pdt-tag-list">
#     <li><p>Darjeeling</p></li>
#     <li><p>Single Estate</p></li>
# </ul>
# /<ul class="horz-list pdt-tag-list">/,/<\/ul>/ {
#     if ($0 ~ /<li>/)  {
#         split ($0,fld,"[<>]")
#         tag = fld[5]
#         # lowercase everything but the first character
#         tag = substr(tag,1,1) tolower(substr(tag,2))
#         # uppercase the first character of any second word
#         if (match (tag,/ /) > 0)
#             tag = substr(tag,1,RSTART) toupper(substr(tag,RSTART+1,1)) \
#             (substr(tag,RSTART+2))
#         tagsFound += 1
#         tagsFound == 1 ? tea_tags = tag : tea_tags = tea_tags ", " tag
#         print "tag = "  tag >> TEA_INFO_FILE
#         print "tea_tags = "  tea_tags >> TEA_INFO_FILE
#         next
#     }
# }

# <li class="sec-child-pdt " id="sec-child-pdt526132838418" data-price="67.49" \
#     data-sp-price="8999" data-percentage="25" ... data-variant-weight="3.5">
# /<li class="sec-child-pdt .* data-variant-weight="/ {
#     split ($0,fld,"\"")
#     if (fld[26] == 0.4)
#         next
#     tea_currentPrice = fld[6]
#     print "tea_currentPrice = " tea_currentPrice >> TEA_INFO_FILE
#     tea_cups = fld[12]
#     print "tea_cups = " tea_cups >> TEA_INFO_FILE
#     tea_per_cup = tea_currentPrice / tea_cups
#     print "tea_per_cup = " tea_per_cup >> TEA_INFO_FILE
#     tea_grams = tea_cups * 2.5
#     print "tea_grams = " tea_grams >> TEA_INFO_FILE
#     tea_oz = fld[26]
#     print "tea_oz = " tea_oz >> TEA_INFO_FILE
# }


#  <p class="liquor-text">(liquor)</p>
#      <h5 class="exp-content-title header-10">aroma</h5>
#      <h5 class="exp-content-title header-10">appearance</h5>
#      <h5 class="exp-content-title header-10">taste</h5>
#      <h5 class="exp-content-title header-10">COMPLEMENTS</h5>
#  <h3 class="exp-main-title header-4">dry leaf</h3>
#      <h5 class="exp-content-title header-10">aroma</h5>
#      <h5 class="exp-content-title header-10">appearance</h5>
#  <h3 class="exp-main-title header-4">infusion</h3>
#      <h5 class="exp-content-title header-10">aroma</h5>
#      <h5 class="exp-content-title header-10">appearance</h5>
#
#      <h5 class="steeping-note-hot">6 fl oz / 180 ml</h5>
#      <h5 class="steeping-note-hot">185<sup>o</sup>F -194<sup>o</sup>F \
#          / 85<sup>o</sup>C -90<sup>o</sup>C</h5>
#      <h5 class="steeping-note-hot">3 tsp  /
#        0.09 oz / 2.5 g </h5>
#      <h5 class="steeping-note-hot">5 mins</h5>

/<h3 class="exp-main-title header-4">/ {
    split ($0,fld,"[<>]")
    type = fld[3]
    gsub (/ /,"-",type)
    print "type = " type >> TEA_INFO_FILE
    next
}

/<h5 class="exp-content-title header-10">aroma<\/h5>/ {
    getline
    sub (/\r/,"")
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    if (type == "") {
        type = "liquor"
        print "type = " type >> TEA_INFO_FILE
    }
    tea_aroma[type] = fld[3]
    print type "_tea_aroma = " fld[3] >> TEA_INFO_FILE
    next
}

/<h5 class="exp-content-title header-10">appearance<\/h5>/ {
    getline
    sub (/\r/,"")
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_appearance[type] = fld[3]
    print type "_tea_appearance = " fld[3] >> TEA_INFO_FILE
    next
}

/<h5 class="exp-content-title header-10">taste<\/h5>/ {
    getline
    sub (/\r/,"")
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_taste[type] = fld[3]
    print type "_tea_taste = " fld[3] >> TEA_INFO_FILE
    next
}

/<h5 class="exp-content-title header-10">COMPLEMENTS<\/h5>/ {
    getline
    sub (/\r/,"")
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_complements = fld[3]
    print "tea_complements = " fld[3] >> TEA_INFO_FILE
    next
}

/<h5 class="steeping-note-hot">/ {
    sub (/^[ \t]*/,"")
    split ($0,fld,"[<>]")
    note = fld[3]
    if (note ~ / fl oz /)
        sub (/ *\/ .*/,"",note)
    if (note ~ / tsp /) {
        getline
        sub (/.* \/ /,"")
        sub (/ g .*/,"g")
        note = $0
    }
    if (note ~ /185/)
        note = "185-194F"
    if (note ~ /176/)
        note = "176-185F"
    notesFound += 1
    notesFound == 1 ? tea_notes = note : tea_notes = tea_notes " | " note
    print "note = " note >> TEA_INFO_FILE
    print "tea_notes = " tea_notes >> TEA_INFO_FILE
}

# <span id="no-steep-text">Recommended Steeps </span>
# <span id="no-steep-val">1</span>
/<span id="no-steep-text">/ {
    getline
    split ($0,fld,"[<>]")
    tea_steeps = fld[3]
    print "tea_steeps = " tea_steeps >> TEA_INFO_FILE
    next
}

# <h5 class="header-10">condiments</h5>
#     <div class="condiment-cnt">
#         <svg class="drink_plain">\
#             <use xlink:href="/media/icons/sprite_v2.svg#drink_plain">     </use></svg>
#         <p>Drink Plain</p>
#        </div>
/<div class="condiment-cnt"/,/<\/div>/ {
    if ($0 ~ /<p>/) {
        split ($0,fld,"[<>]")
        condiment = fld[3]
        condimentsFound += 1
        condimentsFound == 1 ? drink_with = condiment : drink_with = drink_with ", " condiment
        print "Drink_with = " drink_with >> TEA_INFO_FILE
        next
    }
}

# <span><span class="grey-txt">PICKING DATE</span><br>Mar 07, 2017</span>
/<span><span class="grey-txt">PICKING DATE/ {
    split ($0,fld,"[<>]")
    pickingDate = fld[9]
    print "Picking Date = " pickingDate >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">TIME OF DAY</span><br>Afternoon</span>
/<span><span class="grey-txt">TIME OF DAY/ {
    split ($0,fld,"[<>]")
    timeOfDay = fld[9]
    print "Time of Day = "timeOfDay >> TEA_INFO_FILE
    next
}

# <span class="specs_info_content">The amount of caffeine this tea contains</span>
# 
# <span class="sub-text">Low</span>
/>The amount of caffeine this tea contains</ {
    getline
    getline
    split ($0,fld,"[<>]")
    caffeine = fld[3]
    print "Caffeine = " caffeine >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">BEST CONSUMED</span><br>Hot</span>
/<span><span class="grey-txt">BEST CONSUMED/ {
    split ($0,fld,"[<>]")
    bestConsumed = fld[9]
    print "Best Consumed = " bestConsumed >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">SEASON</span><br>First</span>
/<span><span class="grey-txt">SEASON/ {
    split ($0,fld,"[<>]")
    season = fld[9]
    print "Season = " season >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">SPECIALTY</span><br>Chinary</span>
/<span><span class="grey-txt">SPECIALTY/ {
    split ($0,fld,"[<>]")
    specialty = fld[9]
    print "Specialty = " specialty >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">SKU</span> FFMIB</span>
/<span><span class="grey-txt">SKU/ {
    split ($0,fld,"[<>]")
    SKU = fld[7]
    gsub (/ /,"",SKU)
    print "SKU = " SKU >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">GRADE</span> FTGFOP1</span>
/<span><span class="grey-txt">GRADE/ {
    split ($0,fld,"[<>]")
    grade = fld[7]
    gsub (/ /,"",grade)
    print "Grade = " grade >> TEA_INFO_FILE
    next
}

# <span><span class="grey-txt">INVOICE</span> DJ-17</span>
/<span><span class="grey-txt">INVOICE/ {
    split ($0,fld,"[<>]")
    invoice = fld[7]
    gsub (/ /,"",invoice)
    print "Invoice = " invoice >> TEA_INFO_FILE
    next
}

# <h3 class="header-1" style="line-height:30px;">Mission Hill Tea Estate,\
# <span id="estate-small-text">Darjeeling, India</span></h3>
# <p><span style="font-family: arial,helvetica,sans-serif; font-size: small;">\
# Mission Hill got its name from the early Scottish ... 1919-1921.\
# </span></p><p><span style="font-family: arial,helvetica,sans-serif; font-size: small;">\
# Mission Hill is spread over sprawling 951 acres ... characters.</span></p>
/<h3 class="header-1"/ {
    split ($0,fld,"[<>]")
    tea_estate = fld[3] fld[5]
    print "tea_estate = " tea_estate >> TEA_INFO_FILE
    getline
    getline
    getline
    sub (/\r/,"")
    sub (/^[ \t]*/,"")
    gsub (/<p>/,"")
    gsub (/<\/p>/,"")
    gsub (/<span style="font-family: arial,helvetica,sans-serif; font-size: small;">/,"")
    gsub (/<p style="text-align: left;"><span style="font-size: small; font-family: arial, helvetica, sans-serif;">/,"")
    gsub (/<\/span>/," ")
    sub (/ $/,"")
    tea_estate = tea_estate " " $0
    gsub (/&#39;/,"’",tea_estate)
    gsub (/&lsquo;/,"’",tea_estate)
    gsub (/&rsquo;/,"’",tea_estate)
    gsub (/&ldquo;/,"“",tea_estate)
    gsub (/&rdquo;/,"”",tea_estate)
    gsub (/&amp;/,"\\&",tea_estate)
    print "Estate description = " tea_estate >> TEA_INFO_FILE
    print "Estate description = " tea_estate >> TEA_DESCRIPTION_FILE
}

END {
    # Primary
    printf ("=HYPERLINK(\"%s\";\"%s\")", tea_URL, tea_title) >> TEA_FILE
    printf ("\t%d", tea_grams) >> TEA_FILE
    printf ("\t$ %.2f", tea_currentPrice) >> TEA_FILE
    printf ("\t$ %.2f", tea_per_cup) >> TEA_FILE
    printf ("\t%s", tea_notes) >> TEA_FILE
    printf ("\t%s", caffeine) >> TEA_FILE
    printf ("\t%s", tea_appearance["liquor"]) >> TEA_FILE
    printf ("\t%s", tea_aroma["liquor"]) >> TEA_FILE
    printf ("\t%s", tea_taste["liquor"]) >> TEA_FILE
    printf ("\t%s", tea_description) >> TEA_FILE
    printf ("\t%s", tea_complements) >> TEA_FILE
    printf ("\t%s", tea_estate) >> TEA_FILE
    # Secondary
    printf ("\t%s", tea_appearance["dry-leaf"]) >> TEA_FILE
    printf ("\t%s", tea_aroma["dry-leaf"]) >> TEA_FILE
    printf ("\t%s", tea_appearance["infusion"]) >> TEA_FILE
    printf ("\t%s", tea_aroma["infusion"]) >> TEA_FILE
    printf ("\t%s", season) >> TEA_FILE
    printf ("\t%s", tea_tags) >> TEA_FILE
    printf ("\t%s", specialty) >> TEA_FILE
    printf ("\t%s", grade) >> TEA_FILE
    printf ("\t%s", drink_with) >> TEA_FILE
    printf ("\t%s", timeOfDay) >> TEA_FILE
    # Tertiary
    printf ("\t%.2f", tea_oz) >> TEA_FILE
    printf ("\t%d", tea_cups) >> TEA_FILE
    printf ("\t%s", tea_steeps) >> TEA_FILE
    printf ("\t%s", bestConsumed) >> TEA_FILE
    printf ("\t%s", pickingDate) >> TEA_FILE
    printf ("\t%s", SKU) >> TEA_FILE
    printf ("\t%s", invoice) >> TEA_FILE
    #
    printf ("\n") >> TEA_FILE
    print "==========" >> TEA_INFO_FILE

    printf ("%s | $%.2f | %s | %s | %s | %s | %s\n\n", tea_title, tea_per_cup, caffeine,
        tea_appearance["liquor"], tea_aroma["liquor"], tea_taste["liquor"],
        tea_description) >> NOTE_FILE
}
