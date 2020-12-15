local u = mw.ustring.char

-- UTF-8 encoded strings for some commonly-used diacritics
local GRAVE     = u(0x0300)
local ACUTE     = u(0x0301)
local CIRC      = u(0x0302)
local TILDE     = u(0x0303)
local MACRON    = u(0x0304)
local BREVE     = u(0x0306)
local DOTABOVE  = u(0x0307)
local DIAER     = u(0x0308)
local CARON     = u(0x030C)
local DGRAVE    = u(0x030F)
local INVBREVE  = u(0x0311)
local COMMA		= u(0x0313) -- combining smooth breathing
local REV_COMMA = u(0x0314) -- combining rough breathing
local DOTBELOW  = u(0x0323)
local RINGBELOW = u(0x0325)
local CEDILLA   = u(0x0327)
local GRC_CIRC  = u(0x0342)
local UNDERTIE	= u(0x035C) -- actually "combining double breve below"
local RSQUO     = u(0x2019)
local PSILI     = u(0x1FBD)
local CORONIS   = u(0x1FBF)

-- Puncuation to be used for standardChars field
local PUNCTUATION = ' !#$%&*+,-./:;<=>?@^_`|~\'()'

local Latn = {"Latn"}

local m = {}

m["gaa"] = { 
	"Ga",
	"Q33287",
	"alv-gda",
	scripts = Latn,
}

m["gab"] = {
	"Gabri",
	"Q3441237",
	"cdc",
	aliases = {"Southern Gabri"},
	scripts = Latn,
}

m["gac"] = { 
	"Mixed Great Andamanese",
	nil,
	"qfa-adn",
	otherNames = {"Great Andamanese creole", "Great Andamanese"},
	scripts = Latn,
}

m["gad"] = { -- not to be confused with gdk, gdg
	"Gaddang",
	"Q3438830",
	"phi",
	otherNames = {"Cagayan"},
	scripts = Latn,
}

m["gae"] = {
	"Warekena",
	"Q1091095",
	"awd-nwk",
	otherNames = {"Guarequena", "Arekena"},
	scripts = Latn,
}

m["gaf"] = {
	"Gende",
	"Q3100425",
	"paa-kag",
	otherNames = {"Gendeka", "Gene"},
	scripts = Latn,
}

m["gag"] = {
	"Gagauz",
	"Q33457",
	"trk-ogz",
	scripts = {"Latn", "Cyrl"},
	ancestors = {"trk-oat"},
}

m["gah"] = {
	"Alekano",
	"Q3441595",
	"paa-kag",
	otherNames = {"Gahuku"},
	scripts = Latn,
}

m["gai"] = {
	"Borei",
	"Q6799756",
	"paa",
	scripts = Latn,
}

m["gaj"] = {
	"Gadsup",
	"Q5516467",
	"paa-kag",
	scripts = Latn,
}

m["gak"] = {
	"Gamkonora",
	"Q5520226",
	"paa-wpa",
	scripts = Latn,
}

m["gal"] = {
	"Galoli",
	"Q35322",
	"poz-tim",
	otherNames = {"Galolen", "Talur"},
	scripts = Latn,
}

m["gam"] = {
	"Kandawo",
	"Q6361369",
	"ngf",
	otherNames = {"Narake"},
	scripts = Latn,
}

m["gan"] = {
	"Gan",
	"Q33475",
	"zhx",
	scripts = {"Hani"},
	ancestors = {"ltc"},
}

m["gao"] = {
	"Gants",
	"Q5521529",
	"ngf-mad",
	otherNames = {"Gaj"},
	scripts = Latn,
}

m["gap"] = {
	"Gal",
	"Q5517742",
	"ngf-mad",
	scripts = Latn,
}

m["gaq"] = {
	"Gata'",
	"Q3501920",
	"mun",
}

m["gar"] = {
	"Galeya",
	"Q5518509",
	"poz-ocw",
	scripts = Latn,
}

m["gas"] = {
	"Adiwasi Garasia",
	"Q12953522",
	"inc-bhi",
	ancestors = {"bhb"},
}

m["gat"] = {
	"Kenati",
	"Q4219330",
	"paa-kag",
	scripts = Latn,
}

m["gau"] = {
	"Kondekor",
	"Q12952433",
	"dra",
	otherNames = {"Gadaba", "San Gadaba", "Gadba", "Sano", "Kondekar", "Kondkor", "Konḍekor Gadaba", "Mudhili Gadaba"},
}

m["gaw"] = {
	"Nobonob",
	"Q11732205",
	"paa",
	otherNames = {"Garuh", "Nobanob", "Nobnob"},
	scripts = Latn,
}

m["gay"] = {
	"Gayo",
	"Q33286",
	"poz-nws",
	scripts = Latn,
}

m["gba"] = {
	"Gbaya",
	"Q3099986",
	"alv-gba",
	scripts = Latn,
}

m["gbb"] = {
	"Kaytetye",
	"Q6380709",
	"aus-rnd",
	scripts = Latn,
}

m["gbd"] = {
	"Karadjeri",
	"Q3913837",
	"aus-pam",
	aliases = {"Garadjari", "Karajarri"},
	scripts = Latn,
}

m["gbe"] = {
	"Niksek",
	"Q56375",
	"paa",
	scripts = Latn,
}

m["gbf"] = {
	"Gaikundi",
	"Q5517032",
	"paa-spk",
	scripts = Latn,
}

m["gbg"] = {
	"Gbanziri",
	"Q35306",
	"nic-nkg",
	otherNames = {"Banziri", "Gbandere", "Gbanzili"},
	scripts = Latn,
}

m["gbh"] = {
	"Defi Gbe",
	"Q12952446",
	"alv-gbe",
	scripts = Latn,
}

m["gbi"] = {
	"Galela",
	"Q3094570",
	"paa-wpa",
	scripts = Latn,
}

m["gbj"] = {
	"Bodo Gadaba",
	"Q3347070",
	"mun",
	otherNames = {"Gutob", "Gadaba", "Gadba", "Gutop", "Gudwa", "Godwa", "Gadwa", "Boi Gadaba"},
	scripts = {"Orya"},
}

m["gbk"] = {
	"Gaddi",
	"Q17455500",
	"him",
	scripts = {"Deva", "Takr"},
	translit_module = "hi-translit",
}

m["gbl"] = {
	"Gamit",
	"Q2731717",
	"inc-bhi",
	scripts = {"Deva", "Gujr"},
}

m["gbm"] = {
	"Garhwali",
	"Q33459",
	"inc-pah",
	scripts = {"Deva"},
	translit_module = "hi-translit",
}

m["gbn"] = {
	"Mo'da",
	"Q12755683",
	"csu-bbk",
	scripts = Latn,
}

m["gbo"] = {
	"Northern Grebo",
	"Q11157042",
	"kro-grb",
	ancestors = {"grb"},
	scripts = Latn,
}

m["gbp"] = {
	"Gbaya-Bossangoa",
	"Q11011295",
	"alv-gbw",
	otherNames = {"Bossangoa", "Gbaya of Bossangoa"},
	scripts = Latn,
}

m["gbq"] = {
	"Gbaya-Bozoum",
	"Q4952879",
	"alv-gbw",
	otherNames = {"Bozom", "Gbaya of Bozom", "Gbaya-Bozom"},
	scripts = Latn,
}

m["gbr"] = {
	"Gbagyi",
	"Q11015105",
	"alv-ngb",
	scripts = Latn,
}

m["gbs"] = {
	"Gbesi Gbe",
	"Q12952448",
	"alv-pph",
	scripts = Latn,
}

m["gbu"] = {
	"Gagadu",
	"Q35677",
	"aus-arn",
	scripts = Latn,
}

m["gbv"] = {
	"Gbanu",
	"Q3914945",
	"alv-gbf",
	scripts = Latn,
}

m["gbw"] = {
	"Gabi",
	"Q5515391",
	"aus-pam",
	aliases = {"Gabi-Gabi", "Gabi Gabi", "Gubbi-Gubbi", "Gubbi Gubbi"}, -- contrast xby
	scripts = Latn,
}

m["gbx"] = {
	"Eastern Xwla Gbe",
	"Q18379975",
	"alv-pph",
	otherNames = {"Houla", "Kpla", "Offra", "Ophra", "Phla", "Pla", "Popo", "Xwla"},
	scripts = Latn,
}

m["gby"] = {
	"Gbari",
	"Q3915451",
	"alv-ngb",
	scripts = Latn,
}

m["gcc"] = {
	"Mali",
	"Q6743338",
	"paa-bng",
	scripts = Latn,
}

m["gcd"] = {
	"Ganggalida",
	"Q3913765",
	"aus-tnk",
	scripts = Latn,
}

m["gce"] = {
	"Galice",
	"Q20711",
	"ath-pco",
	scripts = Latn,
}

m["gcf"] = {
	"Antillean Creole",
	"Q3006280",
	"crp",
	otherNames = {"Antillean Creole French", "Guadeloupean Creole", "Guadeloupean Creole French", "Saint Lucian Creole", "Saint Lucian Creole French"},
	scripts = Latn,
	ancestors = {"fr"},
}

m["gcl"] = {
	"Grenadian Creole English",
	"Q4252500",
	"crp",
	scripts = Latn,
	ancestors = {"en"},
}

m["gcn"] = {
	"Gaina",
	"Q11732195",
	"ngf",
	scripts = Latn,
}

m["gcr"] = {
	"Guianese Creole",
	"Q1363072",
	"crp",
	otherNames = {"French Guianese Creole", "Guianese French Creole", "Guyanais", "Guyanese French Creole"},
	scripts = Latn,
	ancestors = {"fr"},
}

m["gct"] = {
	"Colonia Tovar German",
	"Q1138351",
	"gmw",
	otherNames = {"Alemán Coloniero"},
	scripts = Latn,
	ancestors = {"gsw"},
}

m["gdb"] = {
	"Ollari",
	"Q33906",
	"dra",
	otherNames = {"Pottangi Ollar Gadaba", "Ollar Gadaba", "Ollaro", "Hallari", "Allar", "Hollar Gadbas"},
}

m["gdc"] = {
	"Gugu Badhun",
	"Q10510360",
	"aus-pam",
	scripts = Latn,
}

m["gdd"] = {
	"Gedaged",
	"Q35292",
	"poz-ocw",
	scripts = Latn,
}

m["gde"] = {
	"Gude",
	"Q3441230",
	"cdc-cbm",
	scripts = Latn,
}

m["gdf"] = {
	"Guduf-Gava",
	"Q3441350",
	"cdc-cbm",
	scripts = Latn,
}

m["gdg"] = { -- not to be confused with gad, gdk
	"Ga'dang",
	"Q5515189",
	"phi",
}

m["gdh"] = {
	"Gadjerawang",
	"Q3913817",
	"aus-jar",
	scripts = Latn,
}

m["gdi"] = {
	"Gundi",
	"Q11137851",
	"nic-nkb",
	scripts = Latn,
}

m["gdj"] = {
	"Kurtjar",
	"Q5619931",
	"aus-pmn",
	otherNames = {"Gurdjar", "Kunggara"},
	scripts = Latn,
}

m["gdk"] = { -- not to be confused with gad, gdg
	"Gadang",
	"Q56256",
	"cdc-est",
	scripts = Latn,
}

m["gdl"] = {
	"Dirasha",
	"Q56809",
	"cus",
	scripts = {"Ethi"},
}

m["gdm"] = {
	"Laal",
	"Q33436",
	scripts = Latn,
}

m["gdn"] = {
	"Umanakaina",
	"Q7881084",
	"ngf",
	scripts = Latn,
}

m["gdo"] = {
	"Godoberi",
	"Q56515",
	"cau-ava",
	aliases = {"Ghodoberi"},
	scripts = {"Cyrl"},
}

m["gdq"] = {
	"Mehri",
	"Q13361",
	"sem-sar",
	aliases = {"Mahri"},
	scripts = {"Arab", "Latn"},
}

m["gdr"] = {
	"Wipi",
	"Q8026711",
	"paa",
	scripts = Latn,
}

m["gds"] = {
	"Ghandruk Sign Language",
	"Q15971577",
	"sgn",
}

m["gdt"] = {
	"Kungardutyi",
	"Q6444517",
	"aus-kar",
	scripts = Latn,
}

m["gdu"] = {
	"Gudu",
	"Q3441172",
	"cdc-cbm",
	scripts = Latn,
}

m["gdx"] = {
	"Godwari",
	"Q3540922",
	"inc-wes",
	ancestors = {"mwr"}
}

m["gea"] = {
	"Geruma",
	"Q3438789",
	"cdc-wst",
	scripts = Latn,
}

m["geb"] = {
	"Kire",
	"Q11129733",
	"paa",
	scripts = Latn,
}

m["gec"] = {
	"Gboloo Grebo",
	"Q11019342",
	"kro-grb",
	ancestors = {"grb"},
	scripts = Latn,
}

m["ged"] = {
	"Gade",
	"Q3914459",
	"alv-nup",
	scripts = Latn,
}

m["geg"] = {
	"Gengle",
	"Q3438345",
	"alv-mye",
	ancestors = {"kow"},
	scripts = Latn,
}

m["geh"] = {
	"Hutterisch",
	"Q33385",
	"gmw",
	aliases = {"Hutterite German", "Tirolean"},
	scripts = Latn,
	ancestors = {"bar"},
}

m["gei"] = {
	"Gebe",
	"Q3100032",
	"poz-hce",
	scripts = Latn,
}

m["gej"] = {
	"Gen",
	"Q33450",
	"alv-gbe",
	scripts = Latn,
}

m["gek"] = {
	"Gerka",
	"Q3441277",
	"cdc-wst",
	otherNames = {"Yiwom"},
	scripts = Latn,
}

m["gel"] = {
	"Fakkanci",
	"Q36627",
	"nic-knn",
	otherNames = {"Kag-Fer-Jiir-Koor-Ror-Us-Zuksun", "ut-Ma'in", "Fakai", "Kag", "Puku", "Fakanchi", "Et-Kag", "Jiir", "Gelanchi", "Et-Jiir", "Kur", "Kere", "Kar", "Keri-Ni", "Kelli-Ni", "Kelanchi", "Kelinci", "Zuksun", "Zussun", "Et-Zuksun", "Ror", "Et-Maror", "Tudanchi", "Er-Gwar", "Fer", "Fere", "Et-Fer", "Wipsi-Ni", "Kukum", "Us", "Et-Us", "Koor", "Kulu"},
	scripts = Latn,
}

m["geq"] = {
	"Geme",
	"Q3915851",
	"znd",
	scripts = Latn,
}

m["ges"] = {
	"Geser-Gorom",
	"Q5553579",
	"poz-cma",
	scripts = Latn,
}

m["gev"] = {
	"Viya",
	"Q7937974",
	"bnt-tso",
	aliases = {"Eviya"},
	scripts = Latn,
}

m["gew"] = {
	"Gera",
	"Q3438725",
	"cdc-wst",
	scripts = Latn,
}

m["gex"] = {
	"Garre",
	"Q56618",
	"cus",
	scripts = Latn,
}

m["gey"] = {
	"Enya",
	"Q5381452",
	"bnt-mbe",
	scripts = Latn,
}

m["gez"] = {
	"Ge'ez",
	"Q35667",
	"sem-eth",
	aliases = {"Ethiopic", "Gi'iz", "Geez"},
	scripts = {"Ethi"},
	translit_module = "Ethi-translit",
}

m["gfk"] = {
	"Patpatar",
	"Q3368846",
	"poz-ocw",
	scripts = Latn,
}

m["gft"] = {
	"Gafat",
	"Q56910",
	"sem-eth",
	scripts = {"Ethi", "Latn"},
}

m["gga"] = {
	"Gao",
	"Q3095228",
	"poz-ocw",
	scripts = Latn,
}

m["ggb"] = {
	"Gbii",
	"Q3914390",
	"kro-wkr",
	scripts = Latn,
}

m["ggd"] = {
	"Gugadj",
	"Q5615186",
	"aus-pmn",
	scripts = Latn,
}

m["gge"] = {
	"Guragone",
	"Q5619801",
	"aus-arn",
	scripts = Latn,
}

m["ggg"] = {
	"Gurgula",
	"Q5620032",
	"inc-wes",
	scripts = {"Arab"},
	ancestors = {"mwr"},
}

m["ggk"] = {
	"Kungarakany",
	"Q6444516",
	"aus-arn",
	scripts = Latn,
}

m["ggl"] = {
	"Ganglau",
	"Q5521140",
	"ngf-mad",
	scripts = Latn,
}

m["ggn"] = {
	"Eastern Gurung",
	"Q12952472",
	"sit-tam",
	scripts = {"Deva", "Latn"},
}

m["ggt"] = {
	"Gitua",
	"Q3107865",
	"poz-ocw",
	scripts = Latn,
}

m["ggu"] = {
	"Gban",
	"Q3913317",
	"dmn-nbe",
	scripts = Latn,
}

m["ggw"] = {
	"Gogodala",
	"Q3512161",
	"paa-pag",
	scripts = Latn,
}

m["gha"] = {
	"Ghadames",
	"Q56747",
	"ber",
	aliases = {"Ghadamès"},
	scripts = Latn, -- and other scripts?
}

m["ghe"] = {
	"Southern Ghale",
	"Q12952453",
	"sit-tam",
	scripts = {"Deva"},
}

m["ghh"] = {
	"Northern Ghale",
	"Q22662104",
	"sit-tam",
	scripts = {"Deva"},
}

m["ghk"] = {
	"Geko Karen",
	"Q5530317",
	"kar",
}

m["ghl"] = {
	"Ghulfan",
	"Q16885737",
	"nub-hil",
	scripts = Latn, -- and others?
}

m["ghn"] = {
	"Ghanongga",
	"Q3104772",
	"poz-ocw",
	scripts = Latn,
}

m["gho"] = {
	"Ghomara",
	"Q35315",
	"ber",
}

m["ghr"] = {
	"Ghera",
	"Q22808992",
	"inc-hiw",
}

m["ghs"] = {
	"Guhu-Samane",
	"Q11732219",
	"ngf",
	scripts = Latn,
}

m["ght"] = {
	"Kutang Ghale",
	"Q6448337",
	"sit-tam",
	scripts = {"Tibt"},
}

m["gia"] = {
	"Kitja",
	"Q1284877",
	"aus-jar",
	scripts = Latn,
}

m["gib"] = {
	"Gibanawa",
	"Q12953530",
	"crp",
	ancestors = {"ha"},
	scripts = Latn,
}

m["gid"] = {
	"Gidar",
	"Q35265",
	"cdc-cbm",
	scripts = Latn,
}

m["gie"] = {
	"Guébie",
	nil,
	"kro-did",
	otherNames = {"Gaɓogbo", "Gabogbo"},
	scripts = Latn,
}

m["gig"] = {
	"Goaria",
	"Q33269",
	"inc-wes",
	scripts = {"Arab"},
	ancestors = {"mwr"},
}

m["gih"] = {
	"Githabul",
	nil,
	"aus-pam",
	scripts = Latn,
}

m["gil"] = {
	"Gilbertese",
	"Q30898",
	"poz-mic",
	aliases = {"Kiribati", "Kiribatese"},
	scripts = Latn,
}

m["gim"] = {
	"Gimi (Goroka)",
	"Q11732209",
	"paa",
	aliases = {"Gimi", "Papuan Gimi", "Labogai"},
	scripts = Latn,
}

m["gin"] = {
	"Hinukh",
	"Q33283",
	"cau-tsz",
	aliases = {"Hinuq", "Hinux", "Ginukh", "Ginux"},
	scripts = {"Cyrl"},
}

m["gio"] = {
	"Gelao",
	"Q56401",
	"qfa-tak",
}

m["gip"] = {
	"Gimi (Austronesian)",
	"Q12952457",
	"poz-ocw",
	aliases = {"Gimi", "Austronesian Gimi", "Loko"},
}

m["giq"] = {
	"Green Gelao",
	"Q12953525",
	"qfa-gel",
	otherNames = {"Hagei", "Hakhi"},
}

m["gir"] = {
	"Red Gelao",
	"Q3100264",
	"qfa-gel",
	otherNames = {"Vandu"},
}

m["gis"] = {
	"North Giziga",
	"Q3515084",
	"cdc-cbm",
}

m["git"] = {
	"Gitxsan",
	"Q3107862",
	"nai-tsi",
}

m["giu"] = {
	"Mulao",
	"Q11092831",
	"qfa-gel",
}

m["giw"] = {
	"White Gelao",
	"Q8843040",
	"qfa-gel",
	otherNames = {"Telue", "Doulou", "Tolo"},
}

m["gix"] = {
	"Gilima",
	"Q10977716",
	"nic-nkm",
	scripts = Latn,
}

m["giy"] = {
	"Giyug",
	"Q5565906",
}

m["giz"] = {
	"South Giziga",
	"Q3502232",
	"cdc-cbm",
}

m["gji"] = {
	"Geji",
	"Q3914890",
	"cdc-wst",
	scripts = Latn,
}

m["gjk"] = {
	"Kachi Koli",
	"Q12953646",
	"inc-wes",
}

m["gjm"] = {
	"Gunditjmara",
	"Q6448731",
	"aus-pam",
}

m["gjn"] = {
	"Gonja",
	"Q35267",
	"alv-gng",
	scripts = Latn,
}

m["gju"] = {
	"Gojri",
	"Q3241731",
	"inc-wes",
	aliases = {"Gujari"},
	ancestors = {"raj"},
}

m["gka"] = {
	"Guya",
	"Q11732221",
	"ngf-fin",
	scripts = Latn,
}

m["gkd"] = {
	"Magɨ",
	nil,
	"ngf-mad",
	aliases = {"Magi"},
	scripts = Latn,
}

m["gke"] = {
	"Ndai",
	"Q6983667",
	"alv-mbm",
}

m["gkn"] = {
	"Gokana",
	"Q3075137",
	"nic-ogo",
	scripts = Latn,
}

m["gko"] = {
	"Kok-Nar",
	"Q6426526",
	"aus-pmn",
	scripts = Latn,
}

m["gkp"] = {
	"Guinea Kpelle",
	"Q11052867",
	"dmn-msw",
	ancestors = {"kpe"},
}

m["glc"] = {
	"Bon Gula",
	"Q289816",
	"alv-bua",
}

m["gld"] = {
	"Nanai",
	"Q13303",
	"tuw",
	otherNames = {"Goldi", "Hezhen"},
	scripts = {"Cyrl"},
	entry_name = {
		from = {"[Ӣ]", "[ӣ]", "[Ӯ]", "[ӯ]", MACRON},
		to   = { "И",   "и",   "У",   "у" }},
}

m["glh"] = {
	"Northwest Pashayi",
	"Q23713532",
	"inc-dar",
}

m["glj"] = {
	"Kulaal",
	"Q33360",
	"alv-bua",
}

m["glk"] = {
	"Gilaki",
	"Q33657",
	"ira-csp",
	scripts = {"fa-Arab"},
}

m["glo"] = {
	"Galambu",
	"Q2598797",
	"cdc-wst",
	scripts = Latn,
}

m["glr"] = {
	"Glaro-Twabo",
	"Q3915313",
	"kro-wee",
}

m["glu"] = {
	"Gula",
	"Q5617176",
	"csu-bgr",
	aliases = {"Sara Gula"},
}

m["glw"] = {
	"Glavda",
	"Q3441285",
	"cdc-cbm",
	scripts = Latn,
}

m["gly"] = {
	"Gule",
	"Q3120736",
	"ssa-kom",
}

m["gma"] = {
	"Gambera",
	"Q10502327",
	"aus-wor",
}

m["gmb"] = {
	"Gula'alaa",
	"Q3120733",
	"poz-sls",
	scripts = Latn,
}

m["gmd"] = {
	"Mághdì",
	"Q3914475",
	"alv-bwj",
}

m["gmg"] = {
	"Magiyi",
	"Q16926155",
	"ngf-mad",
	aliases = {"Magɨyi"},
	scripts = Latn,
}

m["gmh"] = {
	"Middle High German",
	"Q837985",
	"gmw",
	scripts = Latn,
	ancestors = {"goh"},
	entry_name = {
		from = {"[ĀÂ]", "[āâ]", "[ĒÊË]", "[ēêë]", "[ĪÎ]", "[īî]", "[ŌÔ]", "[ōô]", "[ŪÛ]", "[ūû]"},
		to   = {"A"   , "a"   , "E"	   , "e"    , "I"   , "i"   , "O"   , "o"   , "U"   , "u"   },
	},
}

m["gml"] = {
	"Middle Low German",
	"Q505674",
	"gmw",
	scripts = Latn,
	ancestors = {"osx"},
	entry_name = {
		from = {"[ĀÂÄǞ]", "[āâäǟ]", "[ĒÊ]", "[ēê]", "[ĪÎ]", "[īî]", "[ŌÔÖȪ]", "[ōôöȫ]", "[ŪÛÜǕ]", "[ūûüǖ]", "[̂]"},
		to   = {"A"     , "a"     , "E"   , "e"   , "I"   , "i"   , "O"     , "o"     , "U"     , "u"     , ""  },
	},
}

m["gmm"] = {
	"Gbaya-Mbodomo",
	"Q6799713",
	"alv-gbf",
	scripts = Latn,
}

m["gmn"] = {
	"Gimnime",
	"Q11016905",
	"alv-dur",
}

m["gmu"] = {
	"Gumalu",
	"Q5618027",
	"ngf-mad",
}

m["gmv"] = {
	"Gamo",
	"Q16116386",
	"omv-nom",
}

m["gmx"] = {
	"Magoma",
	"Q16939552",
	"bnt-bki",
}

m["gmy"] = {
	"Mycenaean Greek",
	"Q668366",
	"grk",
	scripts = {"Linb"},
	translit_module = "Linb-translit",
	override_translit = true,	
}

m["gmz"] = {
	"Mgbo",
	"Q6826835",
	"alv-igb",
	ancestors = {"izi"},
	otherNames = {"Mgbolizhia"},
}

m["gna"] = {
	"Kaansa",
	"Q56802",
	"nic-gur",
}

m["gnb"] = {
	"Gangte",
	"Q12952442",
	"tbq-kuk",
}

m["gnc"] = {
	"Guanche",
	"Q35762",
	"ber",
}

m["gnd"] = {
	"Zulgo-Gemzek",
	"Q56800",
	"cdc-cbm",
	otherNames = {"Zulgo", "Gemzek", "Mineo"},
	scripts = Latn,
}

m["gne"] = {
	"Ganang",
	nil,
	"nic-plc",
	ancestors = {"izr"},
}

m["gng"] = {
	"Ngangam",
	"Q35888",
	"nic-grm",
}

m["gnh"] = {
	"Lere",
	"Q3915319",
	"nic-jer",
}

m["gni"] = {
	"Gooniyandi",
	"Q2669219",
	"aus-bub",
	scripts = Latn,
}

m["gnj"] = {
	"Ngen",
	nil,
	"dmn-nbe",
	otherNames = {"Ngen of Djonkro"},
	scripts = Latn,
}

m["gnk"] = {
	"ǁGana",
	"Q1975199",
	"khi-kal",
	aliases = {"Gana", "Gǁana", "Gxana", "Dxana", "Xgana"},
}

m["gnl"] = {
	"Gangulu",
	"Q4916329",
	"aus-pam",
}

m["gnm"] = {
	"Ginuman",
	"Q11732210",
	"ngf",
}

m["gnn"] = {
	"Gumatj",
	"Q10510745",
	"aus-yol",
	scripts = Latn,
}

m["gnq"] = {
	"Gana",
	"Q5520523",
	"poz-san",
}

m["gnr"] = {
	"Gureng Gureng",
	"Q5619998",
	"aus-pam",
}

m["gnt"] = {
	"Guntai",
	"Q12952475",
	"paa",
}

m["gnu"] = {
	"Gnau",
	"Q3915810",
	"qfa-tor",
}

m["gnw"] = {
	"Western Bolivian Guaraní",
	"Q3775037",
	"tup-gua",
	otherNames = {"Simba", "Simba Guarani"},
	scripts = Latn,
	ancestors = {"gn"},
}

m["gnz"] = {
	"Ganzi",
	"Q11137942",
	"nic-nkb",
	scripts = Latn,
}

m["goa"] = {
	"Guro",
	"Q35251",
	"dmn-mda",
	scripts = Latn,
}

m["gob"] = {
	"Playero",
	"Q3027923",
	"sai-guh",
}

m["goc"] = {
	"Gorakor",
	"Q12952463",
	"poz-ocw",
	scripts = Latn,
}

m["god"] = {
	"Godié",
	"Q3914412",
	"kro-bet",
}

m["goe"] = {
	"Gongduk",
	"Q2669221",
	"sit",
}

m["gof"] = {
	"Gofa",
	"Q12631584",
	"omv-nom",
	scripts = {"Latn", "Ethi"},
}

m["gog"] = {
	"Gogo",
	"Q3272630",
	"bnt-ruv",
	scripts = Latn,
}

m["goh"] = {
	"Old High German",
	"Q35218",
	"gmw",
	scripts = Latn,
	entry_name = {
		from = {"[ĀÂ]", "[āâ]", "[ĒÊË]", "[ēêë]", "[ĪÎ]", "[īî]", "[ŌÔ]", "[ōô]", "[ŪÛ]", "[ūû]", "ʒ"},
		to   = {"A"   , "a"   , "E"	,    "e"	, "I"   , "i"   , "O"   , "o"   , "U"   , "u"   , "z" }} ,
}

m["goi"] = {
	"Gobasi",
	"Q5575414",
	"ngf",
	otherNames = {"Gobosi", "Gebusi", "Bibo", "Nomad"},
	scripts = Latn,
}

m["goj"] = {
	"Gowlan",
	"Q12953532",
	"inc-sou",
}

-- gok is a spurious language, see [[w:Spurious languages]]

m["gol"] = {
	"Gola",
	"Q35482",
	"alv",
}

m["gon"] = {
	"Gondi",
	"Q1775361",
	"dra",
	otherNames = {"Southern Gondi", "Northern Gondi", "Aheri Gondi", "Adilabad Gondi", "Dorla Gondi", "Koya Gondi", "Maria Gondi", "Muria Gondi", "Raj Gondi"},
	scripts = {"Telu", "Gonm", "Gong"},
}

m["goo"] = {
	"Gone Dau",
	"Q3110470",
	"poz-occ",
	scripts = Latn,
}

m["gop"] = {
	"Yeretuar",
	"Q8052565",
	"poz-hce",
	scripts = Latn,
}

m["goq"] = {
	"Gorap",
	"Q3110816",
	"crp",
	ancestors = {"ms"},
}

m["gor"] = {
	"Gorontalo",
	"Q2501174",
	"phi",
	scripts = Latn,
}

m["got"] = {
	"Gothic",
	"Q35722",
	"gme",
	scripts = {"Goth", "Runr"},
	translit_module = "Goth-translit",
	link_tr = true,
	entry_name = {
		from = {"Ā", "ā", "Ē", "ē", "Ī", "ī", "Ō", "ō", "Ū", "ū"},
		to   = {"A", "a", "E", "e", "I", "i", "O", "o", "U", "u"}} ,
}

m["gou"] = {
	"Gavar",
	"Q3441180",
	"cdc-cbm",
	aliases = {"Gawar"},
}

m["gow"] = {
	"Gorowa",
	"Q3437626",
	"cus",
}

m["gox"] = {
	"Gobu",
	"Q7194986",
	"bad-cnt",
}

m["goy"] = {
	"Goundo",
	"Q317636",
	"alv-kim",
}

m["goz"] = {
	"Gozarkhani",
	"Q5590235",
	"xme-ttc",
	ancestors = {"xme-ttc-eas"},
}

m["gpa"] = {
	"Gupa-Abawa",
	"Q3915352",
	"alv-ngb",
}

m["gpn"] = {
	"Taiap",
	"Q56237",
	"paa",
	otherNames = {"Tayap", "Gapun"},
}

m["gqa"] = {
	"Ga'anda",
	"Q56245",
	"cdc-cbm",
	scripts = Latn,
}

m["gqi"] = {
	"Guiqiong",
	"Q3120647",
	"sit-qia",
	aliases = {"Guìqióng", "Guichong"},
}

m["gqn"] = { -- a variety of 'ter'
	"Kinikinao",
	nil,
	"awd",
	otherNames = {"Guana", "Guaná", "Guana (Brazil)", "Arawakan Guana"},
}

m["gqr"] = {
	"Gor",
	"Q759992",
	"csu-sar",
}

m["gqu"] = {
	"Qau",
	"Q17284874",
	"qfa-gel",
	otherNames = {"Gao", "Aqao", "Qau Gelao"},
}

m["gra"] = {
	"Rajput Garasia",
	"Q21041529",
	"inc-bhi",
	ancestors = {"bhb"},
	scripts = {"Deva", "Gujr"},
}

m["grb"] = {
	"Grebo",
	"Q35257",
	"kro-grb",
	scripts = Latn,
}

m["grc"] = {
	"Ancient Greek",
	"Q35497",
	"grk",
	scripts = {"polytonic", "Cprt"},
	translit_module = "translit-redirect",
	override_translit = true,
	-- Keep this synchronized with el, cpg, pnt; compare ine-pae
	sort_key = {remove_diacritics = ACUTE..GRAVE..GRC_CIRC..DIAER..COMMA..REV_COMMA},
	entry_name = {remove_diacritics = MACRON..BREVE..UNDERTIE,
		from = {"["..RSQUO..PSILI..CORONIS.."]"}, to = {"'"},
	},
	standardChars = "ͺ;΄-ώϜϝ" .. PUNCTUATION .. "ἀ-῾𐠀-𐠿",
}

m["grd"] = {
	"Guruntum",
	"Q3441272",
	"cdc-wst",
	scripts = Latn,
}

m["grg"] = {
	"Madi",
	"Q6727664",
	"ngf-fin",
	scripts = Latn,
}

m["grh"] = {
	"Gbiri-Niragu",
	"Q3913936",
	"nic-kau",
	scripts = Latn,
}

m["gri"] = {
	"Ghari",
	"Q3104782",
	"poz-sls",
	otherNames = {"Gari", "Tangarare", "Sughu", "West Guadalcanal"},
	scripts = Latn,
}

m["grj"] = {
	"Southern Grebo",
	"Q3914444",
	"kro-grb",
	ancestors = {"grb"},
	scripts = Latn,
}

m["grm"] = {
	"Kota Marudu Talantang",
	"Q6433808",
	"poz-san",
	scripts = Latn,
}

m["gro"] = {
	"Groma",
	"Q56551",
	"sit-tib",
}

m["grq"] = {
	"Gorovu",
	"Q56355",
	"paa",
	scripts = Latn,
}

m["grr"] = {
	"Taznatit",
	"Q3063974",
	"ber",
}

m["grs"] = {
	"Gresi",
	"Q5607612",
	"paa-nim",
	scripts = Latn,
}

m["grt"] = {
	"Garo",
	"Q36137",
	"tbq-bdg",
	scripts = {"Beng", "Latn", "Brai"},
}

m["gru"] = {
	"Kistane",
	"Q13273",
	"sem-eth",
	otherNames = {"Soddo", "Aymälläl"},
	scripts = Latn,
}

m["grv"] = {
	"Central Grebo",
	"Q18385114",
	"kro-grb",
	ancestors = {"grb"},
	scripts = Latn,
}

m["grw"] = {
	"Gweda",
	"Q5623387",
	"poz-ocw",
	scripts = Latn,
}

m["grx"] = {
	"Guriaso",
	"Q12631954",
	"paa-kwm",
	scripts = Latn,
}

m["gry"] = {
	"Barclayville Grebo",
	"Q11157342",
	"kro-grb",
	ancestors = {"grb"},
	scripts = Latn,
}

m["grz"] = {
	"Guramalum",
	"Q3120935",
	"poz-ocw",
	scripts = Latn,
}

m["gse"] = {
	"Ghanaian Sign Language",
	"Q35289",
	"sgn",
	scripts = Latn, -- when documented
}

m["gsg"] = {
	"German Sign Language",
	"Q33282",
	"sgn-gsl",
	aliases = {"Deutsche Gebärdensprache"},
	scripts = {"Sgnw"},
}

m["gsl"] = {
	"Gusilay",
	"Q35439",
	"alv-jol",
	scripts = Latn,
}

m["gsm"] = {
	"Guatemalan Sign Language",
	"Q2886781",
	"sgn",
	scripts = Latn, -- when documented
}

m["gsn"] = {
	"Gusan",
	"Q11732224",
	"ngf-fin",
	scripts = Latn,
}

m["gso"] = {
	"Southwest Gbaya",
	"Q4919322",
	"alv-gbs",
	scripts = Latn,
}

m["gsp"] = {
	"Wasembo",
	"Q7971402",
	"ngf-mad",
	scripts = Latn,
}

m["gss"] = {
	"Greek Sign Language",
	"Q3565084",
	"sgn",
}

m["gsw"] = {
	"Alemannic German",
	"Q131339",
	"gmw",
	otherNames = {"Swiss German", "Walser German", "Walserdeutsch", "Walser", "Wallisertiitsch", "Italian Walser", "Pomattertitsch", "Formazza", "Kampel", "Remmaljertittschu", "Rimella", "Chalchoufe", "Titzschu", "Alagna", "Greschóneytitsch", "Greschóney", "Greschoney", "Gressoney", "Éischemtöitschu", "Issime"},
	scripts = Latn,
	ancestors = {"gmh"},
	wikimedia_codes = {"als"},
}

m["gta"] = {
	"Guató",
	"Q3027940",
	"qfa-iso",
	scripts = Latn,
}

m["gtu"] = {
	"Aghu Tharrnggala",
	"Q16825981",
	"aus-pmn",
	aliases = {"Aghu Tharnggala", "Aghu Tharnggalu", "Tharrnggala", "Gogo Mini", "Kuku Mini"},
	scripts = Latn,
}

m["gua"] = {
	"Shiki",
	"Q3913946",
	"nic-jrn",
	scripts = Latn,
}

m["gub"] = {
	"Guajajára",
	"Q7699720",
	"tup-gua",
	scripts = Latn,
}

m["guc"] = {
	"Wayuu",
	"Q891085",
	"awd-taa",
	ancestors = {"awd-taa-pro"},
	aliases = {"Guajiro", "Goajiro", "Uagiro"},
	scripts = Latn,
}

m["gud"] = {
	"Yocoboué Dida",
	"Q21074781",
	"kro-did",
	scripts = Latn,
}

m["gue"] = {
	"Gurindji",
	"Q10511016",
	"aus-pam",
	scripts = Latn,
}

m["guf"] = {
	"Gupapuyngu",
	"Q10511004",
	"aus-yol",
	scripts = Latn,
}

m["gug"] = {
	"Paraguayan Guaraní",
	"Q17478066",
	"tup-gua",
	otherNames = {"Jopará", "Yopará"},
	scripts = Latn,
	ancestors = {"gn"},
}

m["guh"] = {
	"Guahibo",
	"Q2669193",
	"sai-guh",
	scripts = Latn,
}

m["gui"] = {
	"Eastern Bolivian Guaraní",
	"Q2963912",
	"tup-gua",
	otherNames = {"Ava Guaraní", "Chiriguanos"},
	scripts = Latn,
	ancestors = {"gn"},
}

m["guk"] = {
	"Gumuz",
	"Q2396970",
	"ssa",
	scripts = {"Latn", "Ethi"},
}

m["gul"] = {
	"Gullah",
	"Q33395",
	"crp",
	otherNames = {"Geechee", "Sea Island Creole English"},
	scripts = Latn,
	ancestors = {"en"},
}

m["gum"] = {
	"Guambiano",
	"Q2744745",
	"sai-bar",
	scripts = Latn,
}

m["gun"] = {
	"Mbyá Guaraní",
	"Q3915584",
	"tup-gua",
	otherNames = {"Mbyá", "Mbya", "Mbyhá", "Mbiá", "Mbua", "Mbüá", "Mbü'a", "Mbü'a Guaraní", "Jeguaká Tenondé", "Bwihá", "Caiua", "Kaiwá", "Kayová", "Cahygua", "Caingua"},
	scripts = Latn,
	ancestors = {"gn"},
}

m["guo"] = {
	"Guayabero",
	"Q2980375",
	"sai-guh",
	scripts = Latn,
}

m["gup"] = {
	"Gunwinggu",
	"Q1406574",
	"aus-gun",
	otherNames = {"Bininj Gunwok", "Bininj Gun-Wok", "Bininj Kunwok", "Bininj Kun-Wok", "Kunwinjkuan", "Kunwinjku", "Gunwinjgu", "Kuninjku", "Kundjeyhmi", "Gundjeihmi", "Manyallaluk Mayali", "Mayali", "Kundedjnjenghmi", "Kune Dulerayek", "Kune Narayek", "Kune"},
	scripts = Latn,
}

m["guq"] = {
	"Aché",
	"Q383701",
	"tup",
	otherNames = {"Guayaki"},
	scripts = Latn,
}

m["gur"] = {
	"Farefare",
	"Q35331",
	"nic-mre",
	otherNames = {"Frafra", "Gurene", "Gurenɛ", "Gurenne", "Gudenne", "Gudeni", "Zuadeni", "Nankani", "Naani", "Nankanse", "Ninkare", "Booni"},
	scripts = Latn,
}

m["gus"] = {
	"Guinean Sign Language",
	"Q15983937",
	"sgn",
	scripts = Latn, -- when documented
}

m["gut"] = {
	"Maléku Jaíka",
	"Q3915782",
	"cba",
	scripts = Latn,
}

m["guu"] = {
	"Yanomamö",
	"Q8048928",
	"sai-ynm",
	scripts = Latn,
}

m["guv"] = {
	"Gey",
	nil,
	"alv-sav",
	scripts = Latn,
}

m["guw"] = {
	"Gun",
	"Q3111668",
	"alv-gbe",
	otherNames = {"Gun-Gbe", "Gungbe"},
	scripts = Latn,
}

m["gux"] = {
	"Gourmanchéma",
	"Q35474",
	"nic-grm",
	scripts = Latn,
}

m["guz"] = {
	"Gusii",
	"Q33603",
	"bnt-lok",
	scripts = Latn,
}

m["gva"] = {
	"Kaskihá",
	"Q3033534",
	"sai-mas",
	otherNames = {"Guana", "Guaná", "Guana (Paraguay)", "Mascoian Guana"},
	scripts = Latn,
}

m["gvc"] = {
	"Guanano",
	"Q3566001",
	"sai-tuc",
	scripts = Latn,
}

m["gve"] = {
	"Duwet",
	"Q5317647",
	"poz-ocw",
	scripts = Latn,
}

m["gvf"] = {
	"Golin",
	"Q3110291",
	"ngf",
	scripts = Latn,
}

m["gvj"] = {
	"Guajá",
	"Q3915506",
	"tup",
	otherNames = {"Awá", "Ayaya", "Guaxare", "Wazaizara"},
	scripts = Latn,
}

m["gvl"] = {
	"Gulay",
	"Q641737",
	"csu-sar",
	scripts = Latn,
}

m["gvm"] = {
	"Gurmana",
	"Q3913363",
	"nic-shi",
	scripts = Latn,
}

m["gvn"] = {
	"Kuku-Yalanji",
	"Q5621973",
	"aus-pam",
	scripts = Latn,
}

m["gvo"] = {
	"Gavião do Jiparaná",
	"Q5528335",
	"tup",
	otherNames = {"Gavião of Jiparaná", "Digüt", "Ikolen", "Gavião do Rondônia", "Zoró"},
	scripts = Latn,
}

m["gvp"] = {
	"Pará Gavião",
	"Q3365443",
	"sai-nje",
	scripts = Latn,
}

m["gvr"] = {
	"Western Gurung",
	"Q2392342",
	"sit-tam",
	scripts = {"Deva"},
}

m["gvs"] = {
	"Gumawana",
	"Q5618041",
	"poz-ocw",
	scripts = Latn,
}

m["gvy"] = {
	"Guyani",
	"Q10511230",
	"aus-pam",
	scripts = Latn,
}

m["gwa"] = {
	"Mbato",
	"Q3914941",
	"alv-ptn",
	scripts = Latn,
}

m["gwb"] = {
	"Gwa",
	"Q5623219",
	"nic-jrn",
	scripts = Latn,
}

m["gwc"] = {
	"Kalami",
	"Q1675961",
	"inc-dar",
	scripts = {"Arab"},
}

m["gwd"] = {
	"Gawwada",
	"Q3032135",
	"cus",
}

m["gwe"] = {
	"Gweno",
	"Q3358211",
	"bnt-chg",
	scripts = Latn,
}

m["gwf"] = {
	"Gowro",
	"Q3812403",
	"inc-dar",
}

m["gwg"] = {
	"Moo",
	"Q6907057",
	"alv-bwj",
	scripts = Latn,
}

m["gwi"] = {
	"Gwich'in",
	"Q21057",
	"ath-nor",
	otherNames = {"Gwich’in", "Kutchin", "Takudh", "Tukudh", "Loucheux"},
	scripts = Latn,
}

m["gwj"] = {
	"Gcwi",
	"Q12631978",
	"khi-kal",
	aliases = {"Gǀwi", "Gǀui", "ǀGwi", "Dcui", "Gcui", "Cgui"},
	scripts = {"Latinx"},
}

m["gwm"] = {
	"Awngthim",
	"Q4830109",
	"aus-pmn",
	scripts = Latn,
}

m["gwn"] = {
	"Gwandara",
	"Q56521",
	"cdc-wst",
	scripts = Latn,
}

m["gwr"] = {
	"Gwere",
	"Q5623559",
	"bnt-nyg",
	scripts = Latn,
}

m["gwt"] = {
	"Gawar-Bati",
	"Q33894",
	"inc-dar",
}

m["gwu"] = {
	"Guwamu",
	"Q10511225",
	"aus-pam",
	scripts = Latn,
}

m["gww"] = {
	"Kwini",
	"Q10551249",
	"aus-wor",
	scripts = Latn,
}

m["gwx"] = {
	"Gua",
	"Q35422",
	"alv-gng",
	scripts = Latn,
}

m["gxx"] = {
	"Wè Southern",
	"Q19921582",
	"kro-wee",
	scripts = Latn,
}

m["gya"] = {
	"Northwest Gbaya",
	"Q36594",
	"alv-gbw",
	scripts = Latn,
}

m["gyb"] = {
	"Garus",
	"Q5524492",
	"ngf-mad",
	scripts = Latn,
}

m["gyd"] = {
	"Kayardild",
	"Q3913770",
	"aus-tnk",
	scripts = Latn,
}

m["gye"] = {
	"Gyem",
	"Q5624046",
	"nic-jer",
	scripts = Latn,
}

m["gyf"] = {
	"Gungabula",
	"Q10510783",
	"aus-pam",
	scripts = Latn,
}

m["gyg"] = {
	"Gbayi",
	"Q11137618",
	"nic-ngd",
	scripts = Latn,
}

m["gyi"] = {
	"Gyele",
	"Q35434",
	"bnt-mnj",
	scripts = Latn,
}

m["gyl"] = {
	"Gayil",
	"Q5528771",
	"omv-aro",
	scripts = Latn,
}

m["gym"] = {
	"Ngäbere",
	"Q3915581",
	"cba",
	scripts = Latn,
}

m["gyn"] = {
	"Guyanese Creole English",
	"Q3305477",
	"crp",
	aliases = {"Guyanese Creole", "Creolese", "Guyanese"},
	scripts = Latn,
	ancestors = {"en"},
}

m["gyo"] = {
	"Gyalsumdo",
	"Q53575940",
	"sit-kyk",
}

m["gyr"] = {
	"Guarayu",
	"Q3118779",
	"tup",
	aliases = {"Gwarayú"},
	scripts = Latn,
}

m["gyy"] = {
	"Gunya",
	"Q10511001",
	"aus-pam",
	scripts = Latn,
}

m["gza"] = {
	"Ganza",
	"Q5521556",
	"omv-mao",
	scripts = Latn,
}

m["gzn"] = {
	"Gane",
	"Q3095108",
	"poz-hce",
	scripts = Latn,
}

return m