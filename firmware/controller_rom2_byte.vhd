
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"00",x"00",x"00",x"1e"),
     1 => (x"00",x"66",x"66",x"00"),
     2 => (x"00",x"00",x"00",x"00"),
     3 => (x"00",x"66",x"e6",x"80"),
     4 => (x"08",x"00",x"00",x"00"),
     5 => (x"22",x"14",x"14",x"08"),
     6 => (x"14",x"00",x"00",x"22"),
     7 => (x"14",x"14",x"14",x"14"),
     8 => (x"22",x"00",x"00",x"14"),
     9 => (x"08",x"14",x"14",x"22"),
    10 => (x"02",x"00",x"00",x"08"),
    11 => (x"0f",x"59",x"51",x"03"),
    12 => (x"7f",x"3e",x"00",x"06"),
    13 => (x"1f",x"55",x"5d",x"41"),
    14 => (x"7e",x"00",x"00",x"1e"),
    15 => (x"7f",x"09",x"09",x"7f"),
    16 => (x"7f",x"00",x"00",x"7e"),
    17 => (x"7f",x"49",x"49",x"7f"),
    18 => (x"1c",x"00",x"00",x"36"),
    19 => (x"41",x"41",x"63",x"3e"),
    20 => (x"7f",x"00",x"00",x"41"),
    21 => (x"3e",x"63",x"41",x"7f"),
    22 => (x"7f",x"00",x"00",x"1c"),
    23 => (x"41",x"49",x"49",x"7f"),
    24 => (x"7f",x"00",x"00",x"41"),
    25 => (x"01",x"09",x"09",x"7f"),
    26 => (x"3e",x"00",x"00",x"01"),
    27 => (x"7b",x"49",x"41",x"7f"),
    28 => (x"7f",x"00",x"00",x"7a"),
    29 => (x"7f",x"08",x"08",x"7f"),
    30 => (x"00",x"00",x"00",x"7f"),
    31 => (x"41",x"7f",x"7f",x"41"),
    32 => (x"20",x"00",x"00",x"00"),
    33 => (x"7f",x"40",x"40",x"60"),
    34 => (x"7f",x"7f",x"00",x"3f"),
    35 => (x"63",x"36",x"1c",x"08"),
    36 => (x"7f",x"00",x"00",x"41"),
    37 => (x"40",x"40",x"40",x"7f"),
    38 => (x"7f",x"7f",x"00",x"40"),
    39 => (x"7f",x"06",x"0c",x"06"),
    40 => (x"7f",x"7f",x"00",x"7f"),
    41 => (x"7f",x"18",x"0c",x"06"),
    42 => (x"3e",x"00",x"00",x"7f"),
    43 => (x"7f",x"41",x"41",x"7f"),
    44 => (x"7f",x"00",x"00",x"3e"),
    45 => (x"0f",x"09",x"09",x"7f"),
    46 => (x"7f",x"3e",x"00",x"06"),
    47 => (x"7e",x"7f",x"61",x"41"),
    48 => (x"7f",x"00",x"00",x"40"),
    49 => (x"7f",x"19",x"09",x"7f"),
    50 => (x"26",x"00",x"00",x"66"),
    51 => (x"7b",x"59",x"4d",x"6f"),
    52 => (x"01",x"00",x"00",x"32"),
    53 => (x"01",x"7f",x"7f",x"01"),
    54 => (x"3f",x"00",x"00",x"01"),
    55 => (x"7f",x"40",x"40",x"7f"),
    56 => (x"0f",x"00",x"00",x"3f"),
    57 => (x"3f",x"70",x"70",x"3f"),
    58 => (x"7f",x"7f",x"00",x"0f"),
    59 => (x"7f",x"30",x"18",x"30"),
    60 => (x"63",x"41",x"00",x"7f"),
    61 => (x"36",x"1c",x"1c",x"36"),
    62 => (x"03",x"01",x"41",x"63"),
    63 => (x"06",x"7c",x"7c",x"06"),
    64 => (x"71",x"61",x"01",x"03"),
    65 => (x"43",x"47",x"4d",x"59"),
    66 => (x"00",x"00",x"00",x"41"),
    67 => (x"41",x"41",x"7f",x"7f"),
    68 => (x"03",x"01",x"00",x"00"),
    69 => (x"30",x"18",x"0c",x"06"),
    70 => (x"00",x"00",x"40",x"60"),
    71 => (x"7f",x"7f",x"41",x"41"),
    72 => (x"0c",x"08",x"00",x"00"),
    73 => (x"0c",x"06",x"03",x"06"),
    74 => (x"80",x"80",x"00",x"08"),
    75 => (x"80",x"80",x"80",x"80"),
    76 => (x"00",x"00",x"00",x"80"),
    77 => (x"04",x"07",x"03",x"00"),
    78 => (x"20",x"00",x"00",x"00"),
    79 => (x"7c",x"54",x"54",x"74"),
    80 => (x"7f",x"00",x"00",x"78"),
    81 => (x"7c",x"44",x"44",x"7f"),
    82 => (x"38",x"00",x"00",x"38"),
    83 => (x"44",x"44",x"44",x"7c"),
    84 => (x"38",x"00",x"00",x"00"),
    85 => (x"7f",x"44",x"44",x"7c"),
    86 => (x"38",x"00",x"00",x"7f"),
    87 => (x"5c",x"54",x"54",x"7c"),
    88 => (x"04",x"00",x"00",x"18"),
    89 => (x"05",x"05",x"7f",x"7e"),
    90 => (x"18",x"00",x"00",x"00"),
    91 => (x"fc",x"a4",x"a4",x"bc"),
    92 => (x"7f",x"00",x"00",x"7c"),
    93 => (x"7c",x"04",x"04",x"7f"),
    94 => (x"00",x"00",x"00",x"78"),
    95 => (x"40",x"7d",x"3d",x"00"),
    96 => (x"80",x"00",x"00",x"00"),
    97 => (x"7d",x"fd",x"80",x"80"),
    98 => (x"7f",x"00",x"00",x"00"),
    99 => (x"6c",x"38",x"10",x"7f"),
   100 => (x"00",x"00",x"00",x"44"),
   101 => (x"40",x"7f",x"3f",x"00"),
   102 => (x"7c",x"7c",x"00",x"00"),
   103 => (x"7c",x"0c",x"18",x"0c"),
   104 => (x"7c",x"00",x"00",x"78"),
   105 => (x"7c",x"04",x"04",x"7c"),
   106 => (x"38",x"00",x"00",x"78"),
   107 => (x"7c",x"44",x"44",x"7c"),
   108 => (x"fc",x"00",x"00",x"38"),
   109 => (x"3c",x"24",x"24",x"fc"),
   110 => (x"18",x"00",x"00",x"18"),
   111 => (x"fc",x"24",x"24",x"3c"),
   112 => (x"7c",x"00",x"00",x"fc"),
   113 => (x"0c",x"04",x"04",x"7c"),
   114 => (x"48",x"00",x"00",x"08"),
   115 => (x"74",x"54",x"54",x"5c"),
   116 => (x"04",x"00",x"00",x"20"),
   117 => (x"44",x"44",x"7f",x"3f"),
   118 => (x"3c",x"00",x"00",x"00"),
   119 => (x"7c",x"40",x"40",x"7c"),
   120 => (x"1c",x"00",x"00",x"7c"),
   121 => (x"3c",x"60",x"60",x"3c"),
   122 => (x"7c",x"3c",x"00",x"1c"),
   123 => (x"7c",x"60",x"30",x"60"),
   124 => (x"6c",x"44",x"00",x"3c"),
   125 => (x"6c",x"38",x"10",x"38"),
   126 => (x"1c",x"00",x"00",x"44"),
   127 => (x"3c",x"60",x"e0",x"bc"),
   128 => (x"44",x"00",x"00",x"1c"),
   129 => (x"4c",x"5c",x"74",x"64"),
   130 => (x"08",x"00",x"00",x"44"),
   131 => (x"41",x"77",x"3e",x"08"),
   132 => (x"00",x"00",x"00",x"41"),
   133 => (x"00",x"7f",x"7f",x"00"),
   134 => (x"41",x"00",x"00",x"00"),
   135 => (x"08",x"3e",x"77",x"41"),
   136 => (x"01",x"02",x"00",x"08"),
   137 => (x"02",x"02",x"03",x"01"),
   138 => (x"7f",x"7f",x"00",x"01"),
   139 => (x"7f",x"7f",x"7f",x"7f"),
   140 => (x"08",x"08",x"00",x"7f"),
   141 => (x"3e",x"3e",x"1c",x"1c"),
   142 => (x"7f",x"7f",x"7f",x"7f"),
   143 => (x"1c",x"1c",x"3e",x"3e"),
   144 => (x"10",x"00",x"08",x"08"),
   145 => (x"18",x"7c",x"7c",x"18"),
   146 => (x"10",x"00",x"00",x"10"),
   147 => (x"30",x"7c",x"7c",x"30"),
   148 => (x"30",x"10",x"00",x"10"),
   149 => (x"1e",x"78",x"60",x"60"),
   150 => (x"66",x"42",x"00",x"06"),
   151 => (x"66",x"3c",x"18",x"3c"),
   152 => (x"38",x"78",x"00",x"42"),
   153 => (x"6c",x"c6",x"c2",x"6a"),
   154 => (x"00",x"60",x"00",x"38"),
   155 => (x"00",x"00",x"60",x"00"),
   156 => (x"5e",x"0e",x"00",x"60"),
   157 => (x"0e",x"5d",x"5c",x"5b"),
   158 => (x"c2",x"4c",x"71",x"1e"),
   159 => (x"4d",x"bf",x"f1",x"f8"),
   160 => (x"1e",x"c0",x"4b",x"c0"),
   161 => (x"c7",x"02",x"ab",x"74"),
   162 => (x"48",x"a6",x"c4",x"87"),
   163 => (x"87",x"c5",x"78",x"c0"),
   164 => (x"c1",x"48",x"a6",x"c4"),
   165 => (x"1e",x"66",x"c4",x"78"),
   166 => (x"df",x"ee",x"49",x"73"),
   167 => (x"c0",x"86",x"c8",x"87"),
   168 => (x"ef",x"ef",x"49",x"e0"),
   169 => (x"4a",x"a5",x"c4",x"87"),
   170 => (x"f0",x"f0",x"49",x"6a"),
   171 => (x"87",x"c6",x"f1",x"87"),
   172 => (x"83",x"c1",x"85",x"cb"),
   173 => (x"04",x"ab",x"b7",x"c8"),
   174 => (x"26",x"87",x"c7",x"ff"),
   175 => (x"4c",x"26",x"4d",x"26"),
   176 => (x"4f",x"26",x"4b",x"26"),
   177 => (x"c2",x"4a",x"71",x"1e"),
   178 => (x"c2",x"5a",x"f5",x"f8"),
   179 => (x"c7",x"48",x"f5",x"f8"),
   180 => (x"dd",x"fe",x"49",x"78"),
   181 => (x"1e",x"4f",x"26",x"87"),
   182 => (x"4a",x"71",x"1e",x"73"),
   183 => (x"03",x"aa",x"b7",x"c0"),
   184 => (x"dc",x"c2",x"87",x"d3"),
   185 => (x"c4",x"05",x"bf",x"d8"),
   186 => (x"c2",x"4b",x"c1",x"87"),
   187 => (x"c2",x"4b",x"c0",x"87"),
   188 => (x"c4",x"5b",x"dc",x"dc"),
   189 => (x"dc",x"dc",x"c2",x"87"),
   190 => (x"d8",x"dc",x"c2",x"5a"),
   191 => (x"9a",x"c1",x"4a",x"bf"),
   192 => (x"49",x"a2",x"c0",x"c1"),
   193 => (x"c2",x"87",x"e8",x"ec"),
   194 => (x"49",x"bf",x"c0",x"dc"),
   195 => (x"bf",x"d8",x"dc",x"c2"),
   196 => (x"71",x"48",x"fc",x"b1"),
   197 => (x"87",x"e8",x"fe",x"78"),
   198 => (x"c4",x"4a",x"71",x"1e"),
   199 => (x"49",x"72",x"1e",x"66"),
   200 => (x"26",x"87",x"e7",x"ea"),
   201 => (x"71",x"1e",x"4f",x"26"),
   202 => (x"48",x"d4",x"ff",x"4a"),
   203 => (x"ff",x"78",x"ff",x"c3"),
   204 => (x"e1",x"c0",x"48",x"d0"),
   205 => (x"48",x"d4",x"ff",x"78"),
   206 => (x"49",x"72",x"78",x"c1"),
   207 => (x"78",x"71",x"31",x"c4"),
   208 => (x"c0",x"48",x"d0",x"ff"),
   209 => (x"4f",x"26",x"78",x"e0"),
   210 => (x"d8",x"dc",x"c2",x"1e"),
   211 => (x"ca",x"e6",x"49",x"bf"),
   212 => (x"e9",x"f8",x"c2",x"87"),
   213 => (x"78",x"bf",x"e8",x"48"),
   214 => (x"48",x"e5",x"f8",x"c2"),
   215 => (x"c2",x"78",x"bf",x"ec"),
   216 => (x"4a",x"bf",x"e9",x"f8"),
   217 => (x"99",x"ff",x"c3",x"49"),
   218 => (x"72",x"2a",x"b7",x"c8"),
   219 => (x"c2",x"b0",x"71",x"48"),
   220 => (x"26",x"58",x"f1",x"f8"),
   221 => (x"5b",x"5e",x"0e",x"4f"),
   222 => (x"71",x"0e",x"5d",x"5c"),
   223 => (x"87",x"c8",x"ff",x"4b"),
   224 => (x"48",x"e4",x"f8",x"c2"),
   225 => (x"49",x"73",x"50",x"c0"),
   226 => (x"70",x"87",x"f0",x"e5"),
   227 => (x"9c",x"c2",x"4c",x"49"),
   228 => (x"ce",x"49",x"ee",x"cb"),
   229 => (x"49",x"70",x"87",x"ca"),
   230 => (x"e4",x"f8",x"c2",x"4d"),
   231 => (x"c1",x"05",x"bf",x"97"),
   232 => (x"66",x"d0",x"87",x"e2"),
   233 => (x"ed",x"f8",x"c2",x"49"),
   234 => (x"d6",x"05",x"99",x"bf"),
   235 => (x"49",x"66",x"d4",x"87"),
   236 => (x"bf",x"e5",x"f8",x"c2"),
   237 => (x"87",x"cb",x"05",x"99"),
   238 => (x"fe",x"e4",x"49",x"73"),
   239 => (x"02",x"98",x"70",x"87"),
   240 => (x"c1",x"87",x"c1",x"c1"),
   241 => (x"87",x"c0",x"fe",x"4c"),
   242 => (x"df",x"cd",x"49",x"75"),
   243 => (x"02",x"98",x"70",x"87"),
   244 => (x"f8",x"c2",x"87",x"c6"),
   245 => (x"50",x"c1",x"48",x"e4"),
   246 => (x"97",x"e4",x"f8",x"c2"),
   247 => (x"e3",x"c0",x"05",x"bf"),
   248 => (x"ed",x"f8",x"c2",x"87"),
   249 => (x"66",x"d0",x"49",x"bf"),
   250 => (x"d6",x"ff",x"05",x"99"),
   251 => (x"e5",x"f8",x"c2",x"87"),
   252 => (x"66",x"d4",x"49",x"bf"),
   253 => (x"ca",x"ff",x"05",x"99"),
   254 => (x"e3",x"49",x"73",x"87"),
   255 => (x"98",x"70",x"87",x"fd"),
   256 => (x"87",x"ff",x"fe",x"05"),
   257 => (x"f3",x"fa",x"48",x"74"),
   258 => (x"5b",x"5e",x"0e",x"87"),
   259 => (x"f4",x"0e",x"5d",x"5c"),
   260 => (x"4c",x"4d",x"c0",x"86"),
   261 => (x"c4",x"7e",x"bf",x"ec"),
   262 => (x"f8",x"c2",x"48",x"a6"),
   263 => (x"c0",x"78",x"bf",x"f1"),
   264 => (x"f7",x"c1",x"1e",x"1e"),
   265 => (x"87",x"cd",x"fd",x"49"),
   266 => (x"98",x"70",x"86",x"c8"),
   267 => (x"87",x"f3",x"c0",x"02"),
   268 => (x"bf",x"c0",x"dc",x"c2"),
   269 => (x"c1",x"87",x"c4",x"05"),
   270 => (x"c0",x"87",x"c2",x"7e"),
   271 => (x"c0",x"dc",x"c2",x"7e"),
   272 => (x"ca",x"78",x"6e",x"48"),
   273 => (x"66",x"c4",x"1e",x"fc"),
   274 => (x"c4",x"87",x"c9",x"02"),
   275 => (x"da",x"c2",x"48",x"a6"),
   276 => (x"87",x"c7",x"78",x"d3"),
   277 => (x"c2",x"48",x"a6",x"c4"),
   278 => (x"c4",x"78",x"de",x"da"),
   279 => (x"c9",x"c9",x"49",x"66"),
   280 => (x"c1",x"86",x"c4",x"87"),
   281 => (x"c7",x"1e",x"c0",x"1e"),
   282 => (x"87",x"c9",x"fc",x"49"),
   283 => (x"98",x"70",x"86",x"c8"),
   284 => (x"ff",x"87",x"cd",x"02"),
   285 => (x"87",x"df",x"f9",x"49"),
   286 => (x"e1",x"49",x"da",x"c1"),
   287 => (x"4d",x"c1",x"87",x"fd"),
   288 => (x"97",x"e4",x"f8",x"c2"),
   289 => (x"87",x"cf",x"02",x"bf"),
   290 => (x"bf",x"fc",x"db",x"c2"),
   291 => (x"c2",x"b9",x"c1",x"49"),
   292 => (x"71",x"59",x"c0",x"dc"),
   293 => (x"c2",x"87",x"cf",x"fa"),
   294 => (x"4b",x"bf",x"e9",x"f8"),
   295 => (x"bf",x"d8",x"dc",x"c2"),
   296 => (x"87",x"e1",x"c1",x"05"),
   297 => (x"bf",x"c0",x"dc",x"c2"),
   298 => (x"87",x"f0",x"c0",x"02"),
   299 => (x"c8",x"48",x"a6",x"c4"),
   300 => (x"c2",x"78",x"c0",x"c0"),
   301 => (x"6e",x"7e",x"c4",x"dc"),
   302 => (x"6e",x"49",x"bf",x"97"),
   303 => (x"70",x"80",x"c1",x"48"),
   304 => (x"f6",x"e0",x"71",x"7e"),
   305 => (x"02",x"98",x"70",x"87"),
   306 => (x"66",x"c4",x"87",x"c3"),
   307 => (x"48",x"66",x"c4",x"b3"),
   308 => (x"c8",x"28",x"b7",x"c1"),
   309 => (x"98",x"70",x"58",x"a6"),
   310 => (x"87",x"db",x"ff",x"05"),
   311 => (x"e0",x"49",x"fd",x"c3"),
   312 => (x"fa",x"c3",x"87",x"d9"),
   313 => (x"87",x"d3",x"e0",x"49"),
   314 => (x"ff",x"c3",x"49",x"73"),
   315 => (x"c0",x"1e",x"71",x"99"),
   316 => (x"87",x"e4",x"f8",x"49"),
   317 => (x"b7",x"c8",x"49",x"73"),
   318 => (x"c1",x"1e",x"71",x"29"),
   319 => (x"87",x"d8",x"f8",x"49"),
   320 => (x"c9",x"c6",x"86",x"c8"),
   321 => (x"ed",x"f8",x"c2",x"87"),
   322 => (x"02",x"9b",x"4b",x"bf"),
   323 => (x"dc",x"c2",x"87",x"df"),
   324 => (x"c8",x"49",x"bf",x"d4"),
   325 => (x"98",x"70",x"87",x"d6"),
   326 => (x"87",x"c4",x"c0",x"05"),
   327 => (x"87",x"d3",x"4b",x"c0"),
   328 => (x"c7",x"49",x"e0",x"c2"),
   329 => (x"dc",x"c2",x"87",x"fa"),
   330 => (x"c6",x"c0",x"58",x"d8"),
   331 => (x"d4",x"dc",x"c2",x"87"),
   332 => (x"73",x"78",x"c0",x"48"),
   333 => (x"05",x"99",x"c2",x"49"),
   334 => (x"c3",x"87",x"cf",x"c0"),
   335 => (x"de",x"ff",x"49",x"eb"),
   336 => (x"49",x"70",x"87",x"f9"),
   337 => (x"c0",x"02",x"99",x"c2"),
   338 => (x"4c",x"fb",x"87",x"c2"),
   339 => (x"99",x"c1",x"49",x"73"),
   340 => (x"87",x"cf",x"c0",x"05"),
   341 => (x"ff",x"49",x"f4",x"c3"),
   342 => (x"70",x"87",x"e0",x"de"),
   343 => (x"02",x"99",x"c2",x"49"),
   344 => (x"fa",x"87",x"c2",x"c0"),
   345 => (x"c8",x"49",x"73",x"4c"),
   346 => (x"cf",x"c0",x"05",x"99"),
   347 => (x"49",x"f5",x"c3",x"87"),
   348 => (x"87",x"c7",x"de",x"ff"),
   349 => (x"99",x"c2",x"49",x"70"),
   350 => (x"87",x"d6",x"c0",x"02"),
   351 => (x"bf",x"f5",x"f8",x"c2"),
   352 => (x"87",x"ca",x"c0",x"02"),
   353 => (x"c2",x"88",x"c1",x"48"),
   354 => (x"c0",x"58",x"f9",x"f8"),
   355 => (x"4c",x"ff",x"87",x"c2"),
   356 => (x"49",x"73",x"4d",x"c1"),
   357 => (x"c0",x"05",x"99",x"c4"),
   358 => (x"f2",x"c3",x"87",x"cf"),
   359 => (x"da",x"dd",x"ff",x"49"),
   360 => (x"c2",x"49",x"70",x"87"),
   361 => (x"dc",x"c0",x"02",x"99"),
   362 => (x"f5",x"f8",x"c2",x"87"),
   363 => (x"c7",x"48",x"7e",x"bf"),
   364 => (x"c0",x"03",x"a8",x"b7"),
   365 => (x"48",x"6e",x"87",x"cb"),
   366 => (x"f8",x"c2",x"80",x"c1"),
   367 => (x"c2",x"c0",x"58",x"f9"),
   368 => (x"c1",x"4c",x"fe",x"87"),
   369 => (x"49",x"fd",x"c3",x"4d"),
   370 => (x"87",x"ef",x"dc",x"ff"),
   371 => (x"99",x"c2",x"49",x"70"),
   372 => (x"87",x"d5",x"c0",x"02"),
   373 => (x"bf",x"f5",x"f8",x"c2"),
   374 => (x"87",x"c9",x"c0",x"02"),
   375 => (x"48",x"f5",x"f8",x"c2"),
   376 => (x"c2",x"c0",x"78",x"c0"),
   377 => (x"c1",x"4c",x"fd",x"87"),
   378 => (x"49",x"fa",x"c3",x"4d"),
   379 => (x"87",x"cb",x"dc",x"ff"),
   380 => (x"99",x"c2",x"49",x"70"),
   381 => (x"87",x"d9",x"c0",x"02"),
   382 => (x"bf",x"f5",x"f8",x"c2"),
   383 => (x"a8",x"b7",x"c7",x"48"),
   384 => (x"87",x"c9",x"c0",x"03"),
   385 => (x"48",x"f5",x"f8",x"c2"),
   386 => (x"c2",x"c0",x"78",x"c7"),
   387 => (x"c1",x"4c",x"fc",x"87"),
   388 => (x"ac",x"b7",x"c0",x"4d"),
   389 => (x"87",x"d0",x"c0",x"03"),
   390 => (x"c1",x"4a",x"66",x"c4"),
   391 => (x"02",x"6a",x"82",x"d8"),
   392 => (x"4b",x"87",x"c5",x"c0"),
   393 => (x"0f",x"73",x"49",x"74"),
   394 => (x"f0",x"c3",x"1e",x"c0"),
   395 => (x"49",x"da",x"c1",x"1e"),
   396 => (x"c8",x"87",x"c2",x"f5"),
   397 => (x"02",x"98",x"70",x"86"),
   398 => (x"c8",x"87",x"e0",x"c0"),
   399 => (x"f8",x"c2",x"48",x"a6"),
   400 => (x"c8",x"78",x"bf",x"f5"),
   401 => (x"91",x"cb",x"49",x"66"),
   402 => (x"71",x"48",x"66",x"c4"),
   403 => (x"6e",x"7e",x"70",x"80"),
   404 => (x"c6",x"c0",x"02",x"bf"),
   405 => (x"66",x"c8",x"4b",x"87"),
   406 => (x"75",x"0f",x"73",x"49"),
   407 => (x"c8",x"c0",x"02",x"9d"),
   408 => (x"f5",x"f8",x"c2",x"87"),
   409 => (x"c9",x"f0",x"49",x"bf"),
   410 => (x"dc",x"dc",x"c2",x"87"),
   411 => (x"dd",x"c0",x"02",x"bf"),
   412 => (x"f7",x"c2",x"49",x"87"),
   413 => (x"02",x"98",x"70",x"87"),
   414 => (x"c2",x"87",x"d3",x"c0"),
   415 => (x"49",x"bf",x"f5",x"f8"),
   416 => (x"c0",x"87",x"ef",x"ef"),
   417 => (x"87",x"cf",x"f1",x"49"),
   418 => (x"48",x"dc",x"dc",x"c2"),
   419 => (x"8e",x"f4",x"78",x"c0"),
   420 => (x"4a",x"87",x"e9",x"f0"),
   421 => (x"65",x"6b",x"79",x"6f"),
   422 => (x"6f",x"20",x"73",x"79"),
   423 => (x"6f",x"4a",x"00",x"6e"),
   424 => (x"79",x"65",x"6b",x"79"),
   425 => (x"66",x"6f",x"20",x"73"),
   426 => (x"5e",x"0e",x"00",x"66"),
   427 => (x"0e",x"5d",x"5c",x"5b"),
   428 => (x"c2",x"4c",x"71",x"1e"),
   429 => (x"49",x"bf",x"f1",x"f8"),
   430 => (x"4d",x"a1",x"cd",x"c1"),
   431 => (x"69",x"81",x"d1",x"c1"),
   432 => (x"02",x"9c",x"74",x"7e"),
   433 => (x"a5",x"c4",x"87",x"cf"),
   434 => (x"c2",x"7b",x"74",x"4b"),
   435 => (x"49",x"bf",x"f1",x"f8"),
   436 => (x"6e",x"87",x"f1",x"ef"),
   437 => (x"05",x"9c",x"74",x"7b"),
   438 => (x"4b",x"c0",x"87",x"c4"),
   439 => (x"4b",x"c1",x"87",x"c2"),
   440 => (x"f2",x"ef",x"49",x"73"),
   441 => (x"02",x"66",x"d4",x"87"),
   442 => (x"c0",x"49",x"87",x"c8"),
   443 => (x"4a",x"70",x"87",x"f2"),
   444 => (x"4a",x"c0",x"87",x"c2"),
   445 => (x"5a",x"e0",x"dc",x"c2"),
   446 => (x"87",x"c0",x"ef",x"26"),
   447 => (x"00",x"00",x"00",x"00"),
   448 => (x"00",x"00",x"00",x"00"),
   449 => (x"14",x"11",x"12",x"58"),
   450 => (x"23",x"1c",x"1b",x"1d"),
   451 => (x"94",x"91",x"59",x"5a"),
   452 => (x"f4",x"eb",x"f2",x"f5"),
   453 => (x"00",x"00",x"00",x"00"),
   454 => (x"00",x"00",x"00",x"00"),
   455 => (x"00",x"00",x"00",x"00"),
   456 => (x"ff",x"4a",x"71",x"1e"),
   457 => (x"72",x"49",x"bf",x"c8"),
   458 => (x"4f",x"26",x"48",x"a1"),
   459 => (x"bf",x"c8",x"ff",x"1e"),
   460 => (x"c0",x"c0",x"fe",x"89"),
   461 => (x"a9",x"c0",x"c0",x"c0"),
   462 => (x"c0",x"87",x"c4",x"01"),
   463 => (x"c1",x"87",x"c2",x"4a"),
   464 => (x"26",x"48",x"72",x"4a"),
   465 => (x"5b",x"5e",x"0e",x"4f"),
   466 => (x"71",x"0e",x"5d",x"5c"),
   467 => (x"4c",x"d4",x"ff",x"4b"),
   468 => (x"c0",x"48",x"66",x"d0"),
   469 => (x"ff",x"49",x"d6",x"78"),
   470 => (x"c3",x"87",x"d8",x"d8"),
   471 => (x"49",x"6c",x"7c",x"ff"),
   472 => (x"71",x"99",x"ff",x"c3"),
   473 => (x"f0",x"c3",x"49",x"4d"),
   474 => (x"a9",x"e0",x"c1",x"99"),
   475 => (x"c3",x"87",x"cb",x"05"),
   476 => (x"48",x"6c",x"7c",x"ff"),
   477 => (x"66",x"d0",x"98",x"c3"),
   478 => (x"ff",x"c3",x"78",x"08"),
   479 => (x"49",x"4a",x"6c",x"7c"),
   480 => (x"ff",x"c3",x"31",x"c8"),
   481 => (x"71",x"4a",x"6c",x"7c"),
   482 => (x"c8",x"49",x"72",x"b2"),
   483 => (x"7c",x"ff",x"c3",x"31"),
   484 => (x"b2",x"71",x"4a",x"6c"),
   485 => (x"31",x"c8",x"49",x"72"),
   486 => (x"6c",x"7c",x"ff",x"c3"),
   487 => (x"ff",x"b2",x"71",x"4a"),
   488 => (x"e0",x"c0",x"48",x"d0"),
   489 => (x"02",x"9b",x"73",x"78"),
   490 => (x"7b",x"72",x"87",x"c2"),
   491 => (x"4d",x"26",x"48",x"75"),
   492 => (x"4b",x"26",x"4c",x"26"),
   493 => (x"26",x"1e",x"4f",x"26"),
   494 => (x"5b",x"5e",x"0e",x"4f"),
   495 => (x"86",x"f8",x"0e",x"5c"),
   496 => (x"a6",x"c8",x"1e",x"76"),
   497 => (x"87",x"fd",x"fd",x"49"),
   498 => (x"4b",x"70",x"86",x"c4"),
   499 => (x"a8",x"c2",x"48",x"6e"),
   500 => (x"87",x"f0",x"c2",x"03"),
   501 => (x"f0",x"c3",x"4a",x"73"),
   502 => (x"aa",x"d0",x"c1",x"9a"),
   503 => (x"c1",x"87",x"c7",x"02"),
   504 => (x"c2",x"05",x"aa",x"e0"),
   505 => (x"49",x"73",x"87",x"de"),
   506 => (x"c3",x"02",x"99",x"c8"),
   507 => (x"87",x"c6",x"ff",x"87"),
   508 => (x"9c",x"c3",x"4c",x"73"),
   509 => (x"c1",x"05",x"ac",x"c2"),
   510 => (x"66",x"c4",x"87",x"c2"),
   511 => (x"71",x"31",x"c9",x"49"),
   512 => (x"4a",x"66",x"c4",x"1e"),
   513 => (x"f8",x"c2",x"92",x"d4"),
   514 => (x"81",x"72",x"49",x"f9"),
   515 => (x"87",x"c2",x"c7",x"fe"),
   516 => (x"d5",x"ff",x"49",x"d8"),
   517 => (x"c0",x"c8",x"87",x"dd"),
   518 => (x"d6",x"e7",x"c2",x"1e"),
   519 => (x"fd",x"e2",x"fd",x"49"),
   520 => (x"48",x"d0",x"ff",x"87"),
   521 => (x"c2",x"78",x"e0",x"c0"),
   522 => (x"cc",x"1e",x"d6",x"e7"),
   523 => (x"92",x"d4",x"4a",x"66"),
   524 => (x"49",x"f9",x"f8",x"c2"),
   525 => (x"c5",x"fe",x"81",x"72"),
   526 => (x"86",x"cc",x"87",x"c9"),
   527 => (x"c1",x"05",x"ac",x"c1"),
   528 => (x"66",x"c4",x"87",x"c2"),
   529 => (x"71",x"31",x"c9",x"49"),
   530 => (x"4a",x"66",x"c4",x"1e"),
   531 => (x"f8",x"c2",x"92",x"d4"),
   532 => (x"81",x"72",x"49",x"f9"),
   533 => (x"87",x"fa",x"c5",x"fe"),
   534 => (x"1e",x"d6",x"e7",x"c2"),
   535 => (x"d4",x"4a",x"66",x"c8"),
   536 => (x"f9",x"f8",x"c2",x"92"),
   537 => (x"fe",x"81",x"72",x"49"),
   538 => (x"d7",x"87",x"c9",x"c3"),
   539 => (x"c2",x"d4",x"ff",x"49"),
   540 => (x"1e",x"c0",x"c8",x"87"),
   541 => (x"49",x"d6",x"e7",x"c2"),
   542 => (x"87",x"fb",x"e0",x"fd"),
   543 => (x"d0",x"ff",x"86",x"cc"),
   544 => (x"78",x"e0",x"c0",x"48"),
   545 => (x"e7",x"fc",x"8e",x"f8"),
   546 => (x"5b",x"5e",x"0e",x"87"),
   547 => (x"1e",x"0e",x"5d",x"5c"),
   548 => (x"d4",x"ff",x"4d",x"71"),
   549 => (x"7e",x"66",x"d4",x"4c"),
   550 => (x"a8",x"b7",x"c3",x"48"),
   551 => (x"c0",x"87",x"c5",x"06"),
   552 => (x"87",x"e2",x"c1",x"48"),
   553 => (x"d3",x"fe",x"49",x"75"),
   554 => (x"1e",x"75",x"87",x"f5"),
   555 => (x"d4",x"4b",x"66",x"c4"),
   556 => (x"f9",x"f8",x"c2",x"93"),
   557 => (x"fd",x"49",x"73",x"83"),
   558 => (x"c8",x"87",x"c5",x"fd"),
   559 => (x"ff",x"4b",x"6b",x"83"),
   560 => (x"e1",x"c8",x"48",x"d0"),
   561 => (x"73",x"7c",x"dd",x"78"),
   562 => (x"99",x"ff",x"c3",x"49"),
   563 => (x"49",x"73",x"7c",x"71"),
   564 => (x"c3",x"29",x"b7",x"c8"),
   565 => (x"7c",x"71",x"99",x"ff"),
   566 => (x"b7",x"d0",x"49",x"73"),
   567 => (x"99",x"ff",x"c3",x"29"),
   568 => (x"49",x"73",x"7c",x"71"),
   569 => (x"71",x"29",x"b7",x"d8"),
   570 => (x"7c",x"7c",x"c0",x"7c"),
   571 => (x"7c",x"7c",x"7c",x"7c"),
   572 => (x"7c",x"7c",x"7c",x"7c"),
   573 => (x"e0",x"c0",x"7c",x"7c"),
   574 => (x"1e",x"66",x"c4",x"78"),
   575 => (x"d2",x"ff",x"49",x"dc"),
   576 => (x"86",x"c8",x"87",x"d6"),
   577 => (x"fa",x"26",x"48",x"73"),
   578 => (x"71",x"1e",x"87",x"e4"),
   579 => (x"49",x"a2",x"c4",x"4a"),
   580 => (x"48",x"d0",x"f8",x"c2"),
   581 => (x"db",x"c2",x"78",x"6a"),
   582 => (x"78",x"69",x"48",x"fc"),
   583 => (x"bf",x"fc",x"db",x"c2"),
   584 => (x"87",x"c2",x"e8",x"49"),
   585 => (x"87",x"ca",x"d3",x"ff"),
   586 => (x"4f",x"26",x"48",x"c1"),
   587 => (x"c4",x"4a",x"71",x"1e"),
   588 => (x"f8",x"c2",x"49",x"a2"),
   589 => (x"c2",x"7a",x"bf",x"d0"),
   590 => (x"79",x"bf",x"fc",x"db"),
   591 => (x"71",x"1e",x"4f",x"26"),
   592 => (x"c0",x"02",x"9a",x"4a"),
   593 => (x"c2",x"1e",x"87",x"ec"),
   594 => (x"fd",x"49",x"cc",x"f4"),
   595 => (x"c4",x"87",x"f1",x"fa"),
   596 => (x"02",x"98",x"70",x"86"),
   597 => (x"e7",x"c2",x"87",x"dc"),
   598 => (x"f4",x"c2",x"1e",x"d6"),
   599 => (x"ff",x"fd",x"49",x"cc"),
   600 => (x"86",x"c4",x"87",x"d2"),
   601 => (x"c9",x"02",x"98",x"70"),
   602 => (x"d6",x"e7",x"c2",x"87"),
   603 => (x"87",x"da",x"fe",x"49"),
   604 => (x"48",x"c0",x"87",x"c2"),
   605 => (x"71",x"1e",x"4f",x"26"),
   606 => (x"c0",x"02",x"9a",x"4a"),
   607 => (x"c2",x"1e",x"87",x"ee"),
   608 => (x"fd",x"49",x"cc",x"f4"),
   609 => (x"c4",x"87",x"f9",x"f9"),
   610 => (x"02",x"98",x"70",x"86"),
   611 => (x"e7",x"c2",x"87",x"de"),
   612 => (x"d7",x"fe",x"49",x"d6"),
   613 => (x"d6",x"e7",x"c2",x"87"),
   614 => (x"cc",x"f4",x"c2",x"1e"),
   615 => (x"e2",x"ff",x"fd",x"49"),
   616 => (x"70",x"86",x"c4",x"87"),
   617 => (x"87",x"c4",x"02",x"98"),
   618 => (x"87",x"c2",x"48",x"c1"),
   619 => (x"4f",x"26",x"48",x"c0"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

