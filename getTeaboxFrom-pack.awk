# Produce a list of hyperlinks for a spreadsheet from a TeaBox Sample Pack URL
#
# USAGE:
#       awk -f getTeaboxFrom-pack.awk \
#           https://www.teabox.com/tea/samples-of-all-2015-darjeeling-spring-first-flush-teas
#
# INPUT:
#       <meta property="og:url"   content=\
#           "https://www.teabox.com/tea/samples-of-all-2015-darjeeling-spring-first-flush-teas" />
#       <meta property="og:title" content="Darjeeling First Flush Tea Collection" />
#       <meta property="og:price:amount" content="117" />
#
#       <div class="child-pdt active-child" data-price="400" data-discount="30" \
#       datasp-price="280" data-id="52031" data-pid="4468" data-in-stock="True" data-num-stock="90">
#
#       <p class="message"><p>Experience the very best ... collection of teas.</p>i\
#       <br><p><b>Note:</b> This image...vary from the one shown.</p></p>
# ---
#       <td><a class="text-link-3" \
#       href="https://www.teabox.com/tea/mission-hill-spring-darjeeling-black-tea">\
#       Mission Hill Classic Spring Black Tea - Sample</a></td>
#       <td class="tb-center">$ 4.00</td>
#
# OUTPUT
#       =HYPERLINK("https://www.teabox.com/tea/mission-hill-spring-darjeeling-black-tea";\
#       "Mission Hill Classic Spring Black Tea")
/<meta property="og:url"   content="/ {
    split($0, fld, "\"")
    pack_URL = fld[4]
    next
}

/<meta property="og:title" content="/ {
    split($0, fld, "\"")
    pack_title = fld[4]
    next
}

/<meta property="og:price:amount" content="/ {
    split($0, fld, "\"")
    pack_price = fld[4]
    next
}

/ data-discount=".* data-sp-price="/ {
    split($0, fld, "\"")
    data_discount = fld[6]
    data_sp_price = fld[8]
    data_num_stock = fld[16]
}

/<p class="message"><p>/ {
    split($0, fld, "[<>]")
    pack_description = fld[5]
    gsub(/&#39;/, "’", pack_description)
    print pack_description >> DESCRIPTION_FILE
    printf(\
        "0\t=HYPERLINK(\"%s\";\"%s\")\t$ %.2f\t%s",
        pack_URL,
        pack_title,
        pack_price,
        pack_description\
    ) >> PACK_SPREADSHEET_FILE
    printf(\
        "\t%d %%\t$ %.2f\t%d\n", data_discount, data_sp_price, data_num_stock\
    ) >> PACK_SPREADSHEET_FILE
    printf(\
        "%s | $%.2f\n\nTea | Per Cup | Caffeine | Appearance | Aroma | Taste | Description\n\n",
        pack_title,
        data_sp_price\
    ) >> TEA_NOTE_FILE
    next
}

/<td><a class="text-link-3" href="https:\/\/www.teabox.com\/tea\// {
    split($0, fld, "\"")
    URL = fld[4]
    print URL >> URL_FILE
    title = fld[5]
    sub(/ - Sample.*/, "", title)
    sub(/>/, "", title)
    gsub(/&#39;/, "’", title)
    next
}

/<td class="tb-center">/ {
    split($0, fld, "[<>]")
    price = fld[3]
    printf("=HYPERLINK(\"%s\";\"%s\")\t%s\n", URL, title, price) >> PACK_FILE
}
