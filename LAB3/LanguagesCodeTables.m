function cName=LanguagesCodeTables(cd)

Cname={"Unknown_not_applicable", "Albanian", "Breton", "Catalan", "Croatian", "Welsh", "Czech", "Danish", "German", "English", "Spanish", "Esperanto", "Estonian", "Basque", "Faroese", "French", "Frisian", "Irish", "Gaelic", "Galician", "Icelandic", "Italian", "Sami", "Latin", "Latvian", "Luxembourgian", "Lithuanian", "Hungarian", "Maltese", "Dutch", "Norwegian", "Occitan", "Polish", "Portuguese", "Romanian", "Romansh", "Serbian", "Slovak", "Slovene", "Finnish", "Swedish", "Turkish", "Flemish", "Walloon", "rfu", "rfu", "rfu", "rfu"};

id = {"00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0A", "0B", "0C", "0D", "0E", "0F", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1A", "1B", "1C", "1D", "1E", "1F", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "2A", "2B", "2C", "2D", "2E", "2F"};

n=size(id,2);
idnum=zeros(1,n);
for it = 1 : n
    idnum(it) = hex2dec(id{it});
end

cName=Cname{find(idnum==cd)};

