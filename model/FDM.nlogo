extensions [ csv array ]

; include files for environment and agents
__includes [ "environment.nls" "trees.nls" "yummy-plants.nls" "flies.nls" "write-results.nls" ]

; global parameters
globals [

  output-file-name
  output-values

  ; ticks-per-day is also max. meters per day per fly
  ticks-per-day

  ; world
  tree-width
  tree-margin-x
  tree-margin-y
  border-margin
  trees-per-row
  tree-rows
  yummy-plant-width
  yummy-plant-margin

  yummy-fruits-per-plant

  visibility

  ; eggs (duration values in days)
  eggs-per-cycle
  egg-dev-duration

  ; mode durations depending on avg. temperature (values in days)
  mode-duration-temperatures
  female-dev-durations
  female-adult-longevities
  male-dev-durations
  male-adult-longevities

  current-female-dev-duration
  current-female-adult-longevity
  current-male-dev-duration
  current-male-adult-longevity

  ; mortality rates (arrays for every mode depending on avg. temperature)
  ; mortality-temperatures => array of temperatures (10-days avg. temp) in steps of 1°C (min and max serve as reference values for temperatures below and above the range)
  ; egg-mortality-rates-temp => array of mortality-rate per day (affects the flies at the beginning of the day)
  mortality-temperatures
  dev-mortality-rates-temp
  adult-mortality-rates-temp

  ; interval for mortality rates in days
  mortality-interval

  ; mortality rate between two seasons
  mortality-off-season

  ; mean 10d temperature for season start and end
  season-start-temp
  season-end-temp

  ; season trigger (on: true, off: false)
  season

  ; number of season (counts seasons)
  season-number

  ; eggs-per-day (array for eggs-per-day depending on avg. temperature)
  ; eggs-per-day-temperatures => array of temperatures (10-days avg. temp) in steps of 1°C (min and max serve as reference values for temperatures below and above the range)
  ; eggs-per-day => array of eggs-per-day rate at given avg. temperature
  eggs-per-day-temperatures
  eggs-per-day
  current-eggs-per-tick

  ; resistance rate
  resistance-rate

  ; fitness
  fitness-PP
  fitness-PR
  fitness-RR
  fitness-MM
  fitness-MR
  fitness-MP

  ; weather (precipitation, temperature)
  precipitation-list ; TODO: remove
  temperature-list
  current-prec ; TODO: remove
  current-temp
  ; list of temperatures of last 10 days in ticks
  temp-10d-log
  ; mean temperature of the last 10 days
  mean-10d-temp

  total-cherries ; TODO: guess we dont need this

  pesticide-concentration ; TODO: we dont need this for now

  ; path for input csv files
  path-csv-input

]

; initial setup procedure
to setup

  file-close
  __clear-all-and-reset-ticks

  ; init global variables
  set ticks-per-day 15

  set tree-width 3
  set tree-margin-x 3
  set tree-margin-y 5
  set border-margin 5
  set trees-per-row 10
  set tree-rows 5
  set yummy-plant-width 1
  set yummy-plant-margin 5

  set yummy-fruits-per-plant 2

  set visibility 15

  set eggs-per-cycle 10
  set egg-dev-duration 5

  ; mortality interval: 6 weeks
  set mortality-interval 6 * 7

  set mortality-off-season 0.8
  set season-start-temp 10
  set season-end-temp 9
  set season FALSE
  set season-number 0

  set resistance-rate 0.2

  set fitness-PP 1
  set fitness-PR 1
  set fitness-RR 1
  set fitness-MM 0.6
  set fitness-MR 0.8
  set fitness-MP 0.8

  set total-cherries 0

  set path-csv-input "../params/"

  set mean-10d-temp 0
  set temp-10d-log []

  ; create output file
  create-file

  ; world area setup
  env-setworld

  ; load weather data
  load-weather-data

  ; plant trees
  plant-trees

  ; plant yummy-plants
  plant-yummy-plants

  ; set mortality rates for modes
  set-mortality-rates

  ; set eggs-per-day rates
  set-eggs-per-day-rates

  ; set mode durations
  set-mode-durations

  ask patches [
    set pcolor [0 41 0]
  ]

end

to go

  if ceiling ( ticks / ticks-per-day ) > ( 365 * max-years ) [
    user-message "simulation is over"
    stop
  ]

  get-current-weather
  calculate-mean-temperatures

  if season = FALSE and round ( mean-10d-temp ) >= season-start-temp [
    ; start season
    ifelse season-number = 0 [
      fly-init-pop
    ] [
      kill-flies-off-season
      ; reset the age of the starting population otherwise they get killed immediately due to reached life expectancy
      ask flies [
        set total-age 0
        set mode "adult"
        set mode-duration 0
        set partner-search TRUE
        set color red
      ]
    ]
    set season TRUE
    set season-number ( season-number + 1 )
  ]

  if season = TRUE and round ( mean-10d-temp ) <= season-end-temp [
    ; end season
    set season FALSE
  ]

  grow-cherries
  grow-yummy-fruits

  ; gene-drive: on/off switch
  if gene-drive [
    if ticks = release-day * ticks-per-day [
      release-gene-drive
    ]
  ]

  ; if off-season => freeze
  if season [

    ; kill flies at beginning of the day ( mortality rate per tick is unefficient )
    if ticks mod ticks-per-day = 0 [
      get-current-mode-durations
      kill-flies
    ]

    calculate-current-eggs-per-tick-rate
    fly-activities
  ]

  write-values-to-file

  tick

end

; returns the current date in the format 1.1.[1] (the number in brackets reflects the year - note: NO LEAP YEARS!)
to-report current-date

  let days ceiling ( ticks / ticks-per-day )
  if days = 0 [ set days 1 ]
  let return "0"
  let year 0

  set year ( floor ( days / 365 ) ) + 1
  set days ( days mod 365 )
  if days = 0 [ set days 365 ]

  ifelse days < 32 [ set return ( word days ".1." ) ] [
    ifelse days < 60 [ set return ( word ( days - 31 ) ".2." ) ] [
      ifelse days < 91 [ set return ( word ( days - 59 ) ".3." ) ] [
        ifelse days < 121 [ set return ( word ( days - 90 ) ".4." ) ] [
          ifelse days < 152 [ set return ( word ( days - 120 ) ".5." ) ] [
            ifelse days < 182 [ set return ( word ( days - 151 ) ".6." ) ] [
              ifelse days < 213 [ set return ( word ( days - 181 ) ".7." ) ] [
                ifelse days < 244 [ set return ( word ( days - 212 ) ".8." ) ] [
                  ifelse days < 274 [ set return ( word ( days - 243 ) ".9." ) ] [
                    ifelse days < 305 [ set return ( word ( days - 273 ) ".10." ) ] [
                      ifelse days < 335 [ set return ( word ( days - 304 ) ".11." ) ] [
                        if days < 366 [ set return ( word ( days - 334 ) ".12." ) ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]

  set return ( word return "[" year "]" )

  report return

end
@#$#@#$#@
GRAPHICS-WINDOW
18
18
906
665
-1
-1
11.0
1
13
1
1
1
0
0
0
1
0
79
0
57
1
1
1
ticks
30.0

BUTTON
929
23
992
56
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1189
119
1643
152
init-pop
init-pop
0
1000
200.0
1
1
NIL
HORIZONTAL

MONITOR
1006
22
1064
67
flies
count(flies)
17
1
11

BUTTON
929
62
993
96
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1008
119
1181
152
resistant-ratio
resistant-ratio
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
1074
22
1134
67
wild flies
count flies with [\n  genotype = \"++\" or\n  genotype = \"R+\" or\n  genotype = \"+R\"\n]
17
1
11

MONITOR
1142
22
1230
67
resistant flies
count flies with [ \n  genotype = \"RR\" \n]
17
1
11

MONITOR
1239
22
1325
67
modified flies
count flies with [ member? \"M\" genotype ]
17
1
11

MONITOR
1558
24
1642
69
NIL
current-date
17
1
11

MONITOR
1336
22
1424
67
NIL
total-cherries
17
1
11

MONITOR
1432
23
1542
68
occupied-cherries
sum [occupied-cherries] of trees
17
1
11

PLOT
1310
512
1657
681
Weather data
tick
NIL
0.0
5475.0
-1.0
35.0
false
true
"" ""
PENS
"prev-t" 1.0 0 -534828 true "" ""
"prev-p" 1.0 0 -2695187 true "" ""
"temp" 1.0 0 -8053223 true "" ""
"prec" 1.0 0 -14730904 true "" ""

MONITOR
1006
70
1064
115
temp
current-temp
17
1
11

MONITOR
1074
70
1132
115
prec
current-prec
17
1
11

SLIDER
1009
163
1166
196
mean-cherries
mean-cherries
0
4000
252.0
1
1
NIL
HORIZONTAL

SLIDER
1169
163
1308
196
sd-cherries
sd-cherries
0
1000
18.0
1
1
NIL
HORIZONTAL

SLIDER
1322
164
1482
197
cherries-growth-start
cherries-growth-start
0
365
101.0
1
1
NIL
HORIZONTAL

SLIDER
1485
164
1647
197
cherries-growth-period
cherries-growth-period
0
180
45.0
1
1
NIL
HORIZONTAL

PLOT
920
246
1308
510
flies
tick
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"dev" 1.0 0 -1184463 true "" "plot count flies with [mode = \"dev\"]"
"adult" 1.0 0 -2674135 true "" "plot count flies with [mode = \"adult\"]"

PLOT
918
512
1306
682
cherries
tick
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"grown" 1.0 0 -2674135 true "" "plot sum [grown-cherries] of trees"
"occupied" 1.0 0 -13840069 true "" "plot sum [occupied-cherries] of trees"

PLOT
1308
247
1654
511
genotypes
tick
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"M/M" 1.0 0 -5825686 true "" "plot count flies with [ genotype = \"MM\" ]"
"M/+" 1.0 0 -2064490 true "" "plot count flies with [ genotype = \"M+\" or genotype = \"+M\" ]"
"M/R" 1.0 0 -8630108 true "" "plot count flies with [ genotype = \"MR\" or genotype = \"RM\" ]"
"+/+" 1.0 0 -13345367 true "" "plot count flies with [ genotype = \"++\" ]"
"R/R" 1.0 0 -10899396 true "" "plot count flies with [ genotype = \"RR\" ]"
"R/+" 1.0 0 -11221820 true "" "plot count flies with [ genotype = \"R+\" or genotype = \"+R\" ]"

SWITCH
920
207
1034
240
gene-drive
gene-drive
1
1
-1000

SLIDER
1036
206
1209
239
release-day
release-day
1
365
58.0
1
1
NIL
HORIZONTAL

SLIDER
1216
206
1653
239
release-amount
release-amount
0
10000
100.0
10
1
NIL
HORIZONTAL

MONITOR
1145
72
1208
117
max-gen
max [ generation ] of flies
17
1
11

INPUTBOX
927
144
1002
204
max-years
3.0
1
0
Number

MONITOR
1216
73
1296
118
yummy-fruits
sum [grown-fruits] of yummy-plants
17
1
11

MONITOR
1303
73
1369
118
10d temp
mean-10d-temp
17
1
11

TEXTBOX
1542
75
1709
95
NIL
11
0.0
1

MONITOR
1594
73
1644
118
season
season
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
