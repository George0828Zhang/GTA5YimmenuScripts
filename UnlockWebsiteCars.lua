local tabName = "GUI_TAB_VEHICLE"
local Tab = gui.get_tab(tabName)

-- Credits 
-- https://www.unknowncheats.me/forum/3775272-post144.html
-- https://www.unknowncheats.me/forum/3785923-post154.html 

local addr = 262145
local vehlist = {
    35473, -- hotring
    14908,14909,14910,14911,14912,14913,14914,14915,14916,17482,17483,17484,17485,17486,17487,17488,17489,17490,17491,17492,17493,17494,17495,17496,17497,17498,17499,17500,17654,17655,17656,17657,17658,17659,17660,17661,17662,17663,17664,17665,17666,17667,17668,17669,17670,17671,17672,17673,17674,17675,19311,19312,19313,19314,19315,19316,19317,19318,19319,19320,19321,19322,19323,19324,19325,19326,19327,19328,19329,19330,19331,19332,19333,19334,19335,20392,20393,20394,20395,21274,21275,21276,21277,21278,21279,22073,22074,22075,22076,22077,22078,22079,22080,22081,22082,22083,22084,22085,22086,22087,22088,22089,22090,22091,22092,23041,23042,23043,23044,23045,23046,23047,23048,23049,23050,23051,23052,23053,23054,23055,23056,23057,23058,23059,23060,23061,23062,23063,23064,23065,23066,23067,23068,24262,24263,24264,24265,24266,24267,24268,24269,24270,24271,24272,24273,24274,24275,24276,24277,24353,24354,24355,24356,24357,24358,24359,24360,24361,24362,24363,24364,24365,24366,24367,24368,24369,24370,24371,24372,24373,24374,24375,25969,25970,25971,25972,25973,25974,25975,25980,25981,25982,25983,25984,25985,25986,25987,25988,25989,25990,25991,25992,25993,25994,25995,25996,25997,25998,25999,26000,26956,26957,28820,28821,28822,28823,28824,28825,28826,28827,28828,28829,28830,28831,28832,28833,28834,28835,28836,28837,28838,28839,28840,28863,28866,29534,29535,29536,29537,29538,29539,29540,29541,29883,29884,29885,29886,29887,29888,29889,30348,30349,30350,30351,30352,30353,30354,30355,30356,30357,30358,30359,30360,30361,30362,30363,30364,31216,31217,31218,31219,31220,31221,31222,31223,31224,31225,31226,31227,31228,31229,31230,31231,31232,32099,32100,32101,32102,32103,32104,32105,32106,32107,32108,32109,32110,32111,32112,32113,33341,33342,33343,33344,33345,33346,33347,33348,33349,33350,33351,33353,33354,33355,33356,33357,33359,34212,34213,34214,34215,34216,34217,34218,34219,34220,34221,34222,34223,34224,34225,34226,34227,35167,35169,35171,35173,35175,35177,35179,35181,35183,35185,35187,35189,35191,35193,35195,35197,35199,35201,35203,35205,35207,35209,35211,35213,35215,35217,35219,35221,35223,35225,35227,35229,35231,35233,35235,35237,35239,35241,35243,35245,35247,35249,35251,35253,35255,35257,35259,35261,35263,35265,35267,35269,35271,35273,35275,35277,35279,35281,35283,35285,35287,35289,35291,35293,35295,35297,35299,35301,35303,35305,35307,35309,35311,35313,35315,35317,35319,35321,35323,35325,35327,35329,35331,35333,35335,35337,35339,35341,35343,35345,35347,35349,35351,35353,35355,35357,35359,35361,35363,35365,35367,35369,35371,35373,35375,35377,35379,35381,35383,35385,35387,35389,35391,35393,35395,35397,35399,35401,35403,35405,35407,35409,35411,35413,35415,35417,35419,35421,35423,35425,35427,35429,35431,35433,35435,35437,35439,35441,35443
}

Tab:add_button("Unlock Website Cars", function()
    for _, i in pairs(vehlist) do
        globals.set_int(262145 + i, 1)
    end
end)