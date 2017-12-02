## TeaboxScraper

**Teabox** is an online tea shop in India that offers a handpicked
selection of the freshest and the finest teas from India and Nepal.
Their catalog features a wide selection of single-origin teas from
over 150 tea gardens across Darjeeling, Assam, Kangra, the Nilgiris,
and Nepal.

Both https://www.teabox.com/tea and https://www.teabox.com/samples
have a visual interface which lists all their teas. However, you
have to click on the image for each tea or sample pack to see its
description.

I wrote these scripts to fetch the descriptions and other info from
their website and create .txt and .csv spreadsheet files that contain
everything available about each tea. 'Note' files are suitable for
use as checklists in Apple's Notes App.

+ **Tea Note:** Tea | Per Cup | Caffeine | Appearance | Aroma |
Taste | Description
* **Pack Spreadsheet:** # | Tea | Price | Description | Discount |
Sale Price | In Stock
+ **Tea Spreadsheet:** # | Tea | Grams | Price | Per Cup | Instructions
| Caffeine | Appearance | Aroma | Taste | Description | Complements
| Tea Estate | Dry Leaf Appearance | Dry Leaf Aroma | Infusion
Appearance | Infusion Aroma | Season | Tags | Specialty | Grade |
Drink With | Time of Day | Ounces | Cups | Steeps | Best Consumed
| Picking Date | SKU | Invoice

I know of no way to incorporate formatting such as column width,
horizontal centering, etc. into a .csv file. However, [Google Apps
Script](https://developers.google.com/apps-script/overview) enables
you to automate formatting spreadsheets uploaded to [Google
Sheets](https://docs.google.com/spreadsheets/u/0/).
