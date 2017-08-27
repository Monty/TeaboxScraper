## TeaboxScraper

**Teabox** is an online tea shop in India that offers a handpicked
selection of the freshest and the finest teas from India and Nepal.
Their catalog features a wide selection of single-origin teas from
over 150 tea gardens across Darjeeling, Assam, Kangra, the Nilgiris,
and Nepal.

Both https://www.teabox.com/tea and https://www.teabox.com/samples
have a visual interface which lists all their teas. However, you
have to click on the image for each tea or sample pack to see its
description.  I can't find any web page or document that describes
all the available teas in one place.

I wrote these scripts to fetch the descriptions and other info from
their website and create .csv spreadsheet files that contain
everything available about each tea.

I know of no way to incorporate formatting such as column width,
horizontal centering, etc. into a .csv file. However, [Google Apps
Script](https://developers.google.com/apps-script/overview) enables
you to automate formatting spreadsheets uploaded to [Google
Sheets](https://docs.google.com/spreadsheets/u/0/).
