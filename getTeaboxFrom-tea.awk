# Aroma, Palate, Instructions, Region, Specialty, Caffeine, Add-Ons, SKU, Date

# Price
# Description
# Liquor: Aroma, Appearance, Taste, Complements
# Dry Leaf: Aroma, Appearance
# Infusion: Aroma, Appearance
# Steeping Notes: Hot, 6 fl oz, 185-194 oF, 3.0 tsp / 2.5 g, 4 mins
# Recommended number of steeps - one
# Drink Plain
# Picking Date Mar 04, 2017
# Time of Day: Afternoon
# Caffeine: Medium
# Best Consumed: Hot
# Season: First
# Specialty: Clonal | Chinary
# SKU FFJPCLB | Grade SFTGFOP1 | Invoice EXN-08
# Estate description

# <span class="weight-span hidden">3.5 oz </span>
# <span class="child-border-left no-cups-span hidden">40 cups</span>
# <span class="price-span hidden">$ 12.99</span>

# <p>SAMPLE-0.35 oz</p>
# <p class="no-cups-sm">4 cups </p>
# <span class="price-span hidden">$ 3</span>
# /<span class="price-span hidden"/

# 184   <meta property="og:url"   content="\
#           https://www.teabox.com/tea/mission-hill-spring-darjeeling-black-tea" />
/<meta property="og:url"   content="/{
    split ($0,fld,"\"")
    tea_URL = fld[4]
    next
}

# 185   <meta property="og:title" content="Mission Hill Classic Spring Black Tea" />
/<meta property="og:title" content="/ {
    split ($0,fld,"\"")
    tea_title = fld[4]
    gsub (/&#39;/,"’",tea_title)
    next
}

# 192 <meta property="product:weight:value"   content="100.0000" />
/<meta property="product:weight:value"   content="/ {
    split ($0,fld,"\"")
    tea_grams = fld[4]
    next
}

# 194 <meta property="og:price:amount" content="12.99" />
/<meta property="og:price:amount" content="/ {
    split ($0,fld,"\"")
    tea_price = fld[4]
    next
}

# 352   <ul class="horz-list pdt-tag-list">
# 355       <li><p>Darjeeling</p></li>
# 358       <li><p>Single Estate</p></li>
# 360   </ul>
/<ul class="horz-list pdt-tag-list">/,/<\/ul>/ {
    if ($0 ~ /<li>/)  {
        split ($0,fld,"[<>]")
        tag = fld[5]
        # lowercase everything but the first character
        tag = substr(tag,1,1) tolower(substr(tag,2))
        # uppercase the first character of any second word
        if (match (tag,/ /) > 0)
            tag = substr(tag,1,RSTART) toupper(substr(tag,RSTART+1,1)) \
            (substr(tag,RSTART+2))
        tagsFound += 1
        tagsFound == 1 ? tea_tags = tag : tea_tags = tea_tags ", " tag
        next
    }
}

# 617   <span class="weight-span hidden">3.5 oz </span>
/<span class="weight-span hidden"/ {
    split ($0,fld,"[<>]")
    tea_oz = fld[3]
    sub (/ oz /,"",tea_oz) 
}

# 619   <span class="child-border-left no-cups-span hidden">40 cups</span
/<span class="child-border-left no-cups-span hidden">/ {
    split ($0,fld,"[<>]")
    tea_cups = fld[3]
    print "Cups = " tea_cups >> TEA_INFO_FILE
    sub (/ cups/,"",tea_cups) 
    if (tea_cups !~ /None/) {
        tea_per_cup = tea_price/tea_cups
    } else {
        tea_per_cup = 0
    }
}

# 767   <h2 class="header-8">description</h2>
# 768   <p class="message">This is not your typical ... other teas of this season.</p>
# Description
/<p class="message">/ {
    split ($0,fld,"[<>]")
    tea_description = fld[3]
    gsub (/&#39;/,"’",tea_description)
    gsub (/&lsquo;/,"’",tea_description)
    gsub (/&rsquo;/,"’",tea_description)
    gsub (/&ldquo;/,"“",tea_description)
    gsub (/&rdquo;/,"”",tea_description)
    gsub (/&amp;/,"\\&",tea_description)
    print tea_description >> TEA_DESCRIPTION_FILE
    next
}

# 789:  <h3 class="header-4">liquor</h3>
# 792:      <h5 class="header-10">aroma</h5>
# 798:      <h5 class="header-10">appearance</h5>
# 804:      <h5 class="header-10">taste</h5>
# 810:      <h5 class="header-10">COMPLEMENTS</h5>
# 823:  <h3 class="header-4">dry leaf</h3>
# 826:      <h5 class="header-10">aroma</h5>
# 832:      <h5 class="header-10">appearance</h5>
# 845:  <h3 class="header-4">infusion</h3>
# 848:      <h5 class="header-10">aroma</h5>
# 854:      <h5 class="header-10">appearance</h5>

/<h3 class="header-4">liquor<\/h3>/ {
    level = "liquor"
    next
}

/<h3 class="header-4">dry leaf<\/h3>/ {
    level = "dry-leaf"
    next
}

/<h3 class="header-4">infusion<\/h3>/ {
    level = "infusion"
    next
}

/<h5 class="header-10">aroma<\/h5>/ {
    getline
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_aroma[level] = fld[3]
    next
}

/<h5 class="header-10">appearance<\/h5>/ {
    getline
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_appearance[level] = fld[3]
    next
}

/<h5 class="header-10">taste<\/h5>/ {
    getline
    sub (/\r/,"")
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_taste[level] = fld[3]
    next
}

/<h5 class="header-10">COMPLEMENTS<\/h5>/ {
    getline
    gsub (/&#39;/,"’")
    gsub (/&amp;/,"\\&")
    split ($0,fld,"[<>]")
    tea_complements = fld[3]
    next
}

# 948       <tr class="grey-border-bott steep-values">
# 951             <p class="header-10">hot</p>
# 957             <p>6 fl oz</p>
# 964             <p>185-194 <sup>o</sup>F</p>
# 971             <p>1.25 tsp /
# 972             2.5 g</p>
# 984       </tr>
/<tr class="grey-border-bott steep-values">/,/<\/tr>/ {
    if ($0 ~ /<p/)  {
        sub (/^[ \t]*/,"")
        split ($0,fld,"[<>]")
        note = fld[3]
        sub (/ $/,"",note)
        sub (/ \/$/,"",note)
        print "Note = " note >> TEA_INFO_FILE
        if (note ~ /hot/) 
            next
        if (note ~ / fl oz/) 
            next
        if (note ~ /85-90/) 
            note = "185-194"
        if (note ~ /80-85/ || note ~ /85-80/) 
            note = "176-185"
        notesFound += 1
        notesFound == 1 ? tea_notes = note : tea_notes = tea_notes " | " note
        next
    }
    if ($0 ~ /<\/p>/)  {
        sub (/^[ \t]*/,"")
        split ($0,fld,"[<>]")
        note = fld[1]
        print "Note = " note >> TEA_INFO_FILE
        notesFound += 1
        notesFound == 1 ? tea_notes = note : tea_notes = tea_notes " | " note
        next
    }
}

# 990    <p><span id="no-steep-text">Recommended number of steeps - </span>\
#           <span id="no-steep-val">one</span></p>
/<p><span id="no-steep-text">/ {
    split ($0,fld,"[<>]")
    tea_steeps = fld[9]
    next
}

# 993:      <h5 class="header-10">condiments</h5>
# 998           <div class="condiment-cnt">
# 999               <svg class="drink_plain">\
#                       <use xlink:href="/media/icons/sprite_v2.svg#drink_plain">     </use></svg>
# 1000              <p>Drink Plain</p>
# 1001             </div>
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

# 1029      <span><span class="grey-txt">PICKING DATE</span><br>Mar 07, 2017</span>
/<span><span class="grey-txt">PICKING DATE/ {
    split ($0,fld,"[<>]")
    pickingDate = fld[9]
    print "Picking Date = " pickingDate >> TEA_INFO_FILE
    next
}

# 1037      <span><span class="grey-txt">TIME OF DAY</span><br>Afternoon</span>
/<span><span class="grey-txt">TIME OF DAY/ {
    split ($0,fld,"[<>]")
    timeOfDay = fld[9]
    print "Time of Day = "timeOfDay >> TEA_INFO_FILE
    next
}

# 1045      <span><span class="grey-txt">CAFFEINE</span><br>Medium</span>
/<span><span class="grey-txt">CAFFEINE/ {
    split ($0,fld,"[<>]")
    caffeine = fld[9]
    print "Caffeine = " caffeine >> TEA_INFO_FILE
    next
}

# 1053      <span><span class="grey-txt">BEST CONSUMED</span><br>Hot</span>
/<span><span class="grey-txt">BEST CONSUMED/ {
    split ($0,fld,"[<>]")
    bestConsumed = fld[9]
    print "Best Consumed = " bestConsumed >> TEA_INFO_FILE
    next
}

# 1061      <span><span class="grey-txt">SEASON</span><br>First</span>
/<span><span class="grey-txt">SEASON/ {
    split ($0,fld,"[<>]")
    season = fld[9]
    print "Season = " season >> TEA_INFO_FILE
    next
}

# 1069      <span><span class="grey-txt">SPECIALTY</span><br>Chinary</span>
/<span><span class="grey-txt">SPECIALTY/ {
    split ($0,fld,"[<>]")
    specialty = fld[9]
    print "Specialty = " specialty >> TEA_INFO_FILE
    next
}

# 1076      <span><span class="grey-txt">SKU</span> FFMIB</span>
/<span><span class="grey-txt">SKU/ {
    split ($0,fld,"[<>]")
    SKU = fld[7]
    gsub (/ /,"",SKU)
    print "SKU = " SKU >> TEA_INFO_FILE
    next
}

# 1080      | <span><span class="grey-txt">GRADE</span> FTGFOP1</span>
/<span><span class="grey-txt">GRADE/ {
    split ($0,fld,"[<>]")
    grade = fld[7]
    gsub (/ /,"",grade)
    print "Grade = " grade >> TEA_INFO_FILE
    next
}

# 1083      | <span><span class="grey-txt">INVOICE</span> DJ-06</span>
/<span><span class="grey-txt">INVOICE/ {
    split ($0,fld,"[<>]")
    invoice = fld[7]
    gsub (/ /,"",invoice)
    print "Invoice = " invoice >> TEA_INFO_FILE
    next
}

# 1110: <h3 class="header-1" style="line-height:30px;">Mission Hill Tea Estate,\
#       <span id="estate-small-text">Darjeeling, India</span></h3>
# 1111  <p><span style="font-family: arial,helvetica,sans-serif; font-size: small;">\
#       Mission Hill got its name from the early Scottish ... 1919-1921.\
#       </span></p><p><span style="font-family: arial,helvetica,sans-serif; font-size: small;">\
#       Mission Hill is spread over sprawling 951 acres ... characters.</span></p>
/<h3 class="header-1"/ {
    split ($0,fld,"[<>]")
    tea_estate = fld[3] fld[5]
    print "Estate = " tea_estate >> TEA_INFO_FILE
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
    print "Estate description = " $0 >> TEA_DESCRIPTION_FILE
    print "tea_estate = " tea_estate  >> TEA_INFO_FILE
}

END {
    printf ("=HYPERLINK(\"%s\";\"%s\")", tea_URL, tea_title) >> TEA_FILE
    # printf ("\t%.2f gm", tea_grams)
    printf ("\t%d", tea_grams) >> TEA_FILE
    printf ("\t%.2f", tea_oz) >> TEA_FILE
    printf ("\t%d", tea_cups) >> TEA_FILE
    printf ("\t$ %.2f", tea_price) >> TEA_FILE
    printf ("\t$ %.2f", tea_per_cup) >> TEA_FILE
    printf ("\t%s", tea_notes) >> TEA_FILE
    printf ("\t%s", tea_steeps) >> TEA_FILE
    printf ("\t%s", drink_with) >> TEA_FILE
    printf ("\t%s", tea_tags) >> TEA_FILE
    printf ("\t%s", pickingDate) >> TEA_FILE
    printf ("\t%s", timeOfDay) >> TEA_FILE
    printf ("\t%s", caffeine) >> TEA_FILE
    printf ("\t%s", bestConsumed) >> TEA_FILE
    printf ("\t%s", season) >> TEA_FILE
    printf ("\t%s", specialty) >> TEA_FILE
    printf ("\t%s", SKU) >> TEA_FILE
    printf ("\t%s", grade) >> TEA_FILE
    printf ("\t%s", invoice) >> TEA_FILE
    #
    printf ("\t%s", tea_description) >> TEA_FILE
    #
    printf ("\t%s", tea_appearance["liquor"]) >> TEA_FILE
    printf ("\t%s", tea_aroma["liquor"]) >> TEA_FILE
    printf ("\t%s", tea_taste["liquor"]) >> TEA_FILE
    #
    printf ("\t%s", tea_complements) >> TEA_FILE
    #
    printf ("\t%s", tea_appearance["dry-leaf"]) >> TEA_FILE
    printf ("\t%s", tea_aroma["dry-leaf"]) >> TEA_FILE
    #
    printf ("\t%s", tea_appearance["infusion"]) >> TEA_FILE
    printf ("\t%s", tea_aroma["infusion"]) >> TEA_FILE
    #
    printf ("\t%s", tea_estate) >> TEA_FILE
    #
    printf ("\n") >> TEA_FILE
    print "==========" >> TEA_INFO_FILE
}
