;;all letters are low case
globals[

  newcar1    ;;新车
  newcar2
  diecar1;;每一轮淘汰的
  diecar2

]


patches-own[
  charger    ;; the status of charging stations or private chargers in patches , 1 represnets there is a charger 0 represent there is not charger.
  district   ;;the kinds of districts
  central     ;; if the patch is in central area 0 is not 1 is in
]

turtles-own[
  car1
  car2
  income
  income-level
  average-travel
  home-location-x
  home-location-y
  work-place-x
  work-place-y
  long-travel
  innovative
  environmental
  ev-percentage
  buy-or-not   ;; it represents the status if the agent want to buy a car  1 repsent want 0 represents not
  saving   ;;if the ev is money saving for the agent

]

to setup
  clear-all

  color-district ;;make the color different in diffent zones
  set-people ;; create people and initialization
  set-chargers;; chargers model
  cal-ev-percentage
  reset-ticks




end

to color-district
  ask patches [
    if pxcor = pycor
    [ set district "middle"]      ;; middle income
    if pxcor > 0 and pycor < 0
      [ set district "low income"    ;;lowincome district
        set pcolor orange]
    if pxcor < 0 and pycor > 0
      [ set district "wealthy"    ;; wealthy district
        set pcolor white
      ]
    if pxcor > -51 and pxcor < 51 and pycor > -51 and pycor < 51
        [ set central 1  ;; it is in central
          set pcolor grey    ;; grey is central
    ]
  ]

end


to set-people
  crt  population [

    set income random-normal average-income income-standard-error    ;;set income as normal
    set-income-level
    set-place
    set-car1
    set-car2
    set average-travel random-normal 55 20
    set long-travel random-normal 200 50
    set innovative random 4
    set environmental random 4
    set saving (( price-gasoil - price-electricity ) * average-travel) - ((price-difference * ev-price ) + charger-price ) / ( 72 * 30 )
    set buy-or-not 0    ;; at first all people do not want to buy
  ]


end

to set-income-level

  ifelse income >= 5000    ;;家庭收入10000
    [ set income-level 3]     ;;wealthy
    [ ifelse income >= 2200        ;;家庭收入6000

      [ set income-level 2 ]      ;;middle-income
      [ set income-level 1 ]       ;;low-income
    ]

end

to set-place

    ifelse income-level = 3
    [ set home-location-x random -250     ;;wealthy district
      set home-location-y random 250
    ]
    [ ifelse income-level = 2
      [ set home-location-x random-xcor     ;;middle-income district
        set home-location-y random-xcor]
      [
        set home-location-x random 250      ;;low0income district
        set home-location-y random -250

      ]

    ]

  setxy home-location-x home-location-y    ;;set homelocation
  set work-place-x random-xcor               ;;save work loacation
  set work-place-y random-ycor

end


to set-car1

    ifelse random population < initial-cars       ;; have convetional cars
    [ set car1 ((random 71) + 1)
      set color red
    ]
    [ set car1 0
      set color green
    ]



end


to set-car2   ;;try to 0

    ifelse random 100 < 5             ;; lower than 4% have EVs
    [ set car2 random-normal 36 1
      set color blue]
  [ set car2 0 ]



end

to cal-ev-percentage
  ask turtles [
    let a count turtles with [ car1 > 0 ] in-radius 100   ;; conventional cars
    if a = 0 [ set a  1]   ;;incase there is no car1
    let b count turtles with [ car2 > 0 ] in-radius 100   ;; evs
    let c count patches with [ charger = 1 ] in-radius 100 ;;chagers
    set ev-percentage  ( b + 10 * c ) / a    ;; it is the ev-percentage

  ]
end


to set-chargers
  if charging-pattern = "a"    ;; with pattern "a"
    [
      ask n-of 4 patches with [ central = 1]
      [ set pcolor blue
        set charger 1
       ]
      ask n-of 4 patches with [ district = "wealthy"]
      [ set pcolor blue
        set charger 1
       ]
      ask n-of 8 patches with [ district = "middle"]
      [ set pcolor blue
        set charger 1
       ]
  ]

  if charging-pattern = "b"      ;;with patter b
  [
    ask n-of 5 patches with [ central = 1 ]
    [ set pcolor blue
      set charger 1 ]
    ask turtles with [ car2 > 0 ]
    [
      ask patch-at home-location-x home-location-y
      [
      set pcolor blue
      set charger 1
      ]


    ]
  ]




  if charging-pattern = "c"      ;;with patter c
  [
  ask n-of 16 patches
    [ set pcolor blue
      set charger 1
  ]
  ]





end


;;the above is for setup the envoronment


to go
  set newcar1 count turtles with [ car1 > 0 ]  ;;set the newcar1 and car2
  set newcar1 count turtles with [ car1 > 0 ]
  set diecar1 0 ;;the car1 and car 2 die
  set diecar2 0


  car-aged
  need-or-not
  afford-or-not
  range-enough
  long-travel?
  money-saving?
  environment?
  cal-ev-percentage
  enough-evs?
  set newcar1 ( count turtles with [ car1 > 0 ] ) - newcar1 + diecar1
  set newcar2 ( count turtles with [ car2 > 0 ] ) - newcar2 + diecar2
  tick
end

to car-aged          ;; the car aged and die
  ask turtles with [car1 > 0 ]
  [
    set car1 car1 + 1
    if car1 > 72
    [set car1 0
    set diecar1 diecar1 + 1
    ]
  ]
  ask turtles with [car2 > 0 ]
  [
    set car2  car2 + 1
    if car2 > 72
    [set car2 0
     set diecar2 diecar2 + 1
    ]
  ]
end

to need-or-not       ;; if the agent need or not to buy  step a
  ask n-of ( int (0.01 * count ( turtles with [ car1 = 0 and car2 = 0 ]))) turtles with [ car1 = 0 and car2 = 0 ]   ;;改为80%
  [
    set buy-or-not 1
  ]
  ask n-of (int (0.05 * count (turtles with [ car1 > 0 and car2 = 0 ])))  turtles with [ car1 > 0 and car2 = 0 ]   ;;改为50
  [
    set buy-or-not 1
  ]
end

to afford-or-not               ;;if they can afford step b and step d
  ask turtles with [ buy-or-not = 1 ]
  [
    ifelse ( 0.11 * income ) < ( ev-price / 72 )             ;; if the 11% income < payment
    [ ifelse ( 0.15 * income ) < ( ev-price / 72 )          ;; if the 11% income < payment
      [ set buy-or-not 0 ]             ;; they will not buy any car
      [ if car1 = 0 [ set car1  1 ]     ;; if they havn't car1 , buy one.
      ]
    ]

    [ set buy-or-not 1 ]       ;;potential to buy ev

  ]

end

to range-enough      ;;Step c: If the EV’s range can cover the household’s average travel length
  ask turtles with [ buy-or-not = 1 ] [
    ifelse average-travel > maximum-mileage
    [ set buy-or-not 0
      if car1 = 0 [ set car1 1 ]      ;;if dont have buy a conventional
    ]
    [ set buy-or-not 1 ]

  ]


end


to long-travel?   ;;Step e: If the EV’s range > the agent’s long travel threshold
  ask turtles with [ buy-or-not = 1 ][

     if maximum-mileage < long-travel
    [ set buy-or-not 0

      if car1 = 0
      [ set car1 1

       ]      ;;if dont have car1, buy a conventional
    ]
  ]

end


to money-saving?    ;; if the ev is money saving    stepf and step h

  ;;The saving money = (the price of gasoil - the price of electricity) * average travel length -
  ;;the [ (price difference + the private charger price) / (72 months*30 days)].
  ask turtles with [ buy-or-not = 1 ]

  [
    ;;let saving (( price-gasoil - price-electricity ) * average-travel) - ((( 1 + price-difference ) * ev-price ) + charger-price ) / ( 72 * 30 )  ;;   saving  上调
    ifelse saving > 0
    [   ifelse ( count patches with [ charger = 1 ]  in-radius 100 ) > 0             ;; if the ev is money saving  and there is charging station  , search for chargingstations step h
      [
        let threshold-innovation 0
        if  innovative = 0 [ set threshold-innovation 90 ]
        if  innovative = 1 [ set threshold-innovation 70 ]
        if  innovative = 2 [ set threshold-innovation 50 ]
        if  innovative = 3 [ set threshold-innovation 20 ]
        ifelse random 100 < threshold-innovation
        [
          set buy-or-not 0
          set car2 1 ;; innovative enough  buy a ev

        ]
        [
          set buy-or-not 0
          if car1 = 0 [ set car1 1



          ] ;; if they don't have a car1, buy a new

        ]

      ]   ;; if there is charging stations  , check for innovations step   g


      [ if car1 = 0 [
        set car1 1
        set buy-or-not 0
      ] ]     ;; if there is not charging stations, if they do not have car1 ,buy a car1

    ]
    [
    set buy-or-not 1
    ]                                  ;; if the ev is not money saving , nothing to do

  ]


end

to environment?


  ask turtles with [ buy-or-not = 1 ]
  [
    let threshold-environmental 0
     if  environmental = 0 [ set threshold-environmental 90 ]
     if  environmental = 1 [ set threshold-environmental 80 ]
     if  environmental = 2 [ set threshold-environmental 40 ]
     if  environmental = 3 [ set threshold-environmental 10 ]
        ifelse random 100 < threshold-environmental

    ;; the agent is environmental enough , go to step h once again.
    [   ifelse ( count patches with [ charger = 1 ]  in-radius 100 ) > 0             ;; if the ev is money saving  and there is charging station  , search for chargingstations step h
       [
         let threshold-innovation 0
         if  innovative = 0 [ set threshold-innovation 90 ]
         if  innovative = 1 [ set threshold-innovation 70 ]
         if  innovative = 2 [ set threshold-innovation 50 ]
         if  innovative = 3 [ set threshold-innovation 20 ]
        ifelse random 100 < threshold-innovation
        [
          set buy-or-not 0
          set car2 1 ;; innovative enough  buy a ev
        ]
        [
          set buy-or-not 0
          if car1 = 0 [ set car1 1 ] ;; if they don't have a car1, buy a new

         ]

       ]   ;; if there is charging stations  , check for innovations step   g


       [ set buy-or-not 0
        if car1 = 0 [
        set car1 1
       ] ]     ;; if there is not charging stations, if they do not have car1 ,buy a car1

    ]




    [     ;; the agent is not envioumental enough, check if there is or not charging stations ,if not , buy a conventional car1
      ;; step h2
      ifelse ( count patches with [ charger = 1 ]  in-radius 100 ) < 1
      [ set buy-or-not 0
        if car1 = 0 [ set car1 1 ]
      ]      ;; no charging stations buy a car1
      [ set buy-or-not 1 ]   ;; if there is charging station, go to next step ,
    ]

  ]
end



to enough-evs?  ;;Step j: If the agent has seen enough EVs in all cars they see.
  ask turtles with [ buy-or-not = 1 ]
  [
         let threshold-evs 0
         if  ( innovative + environmental )/ 2 =  0  or ( innovative + environmental )/ 2 =  0.5  [ set threshold-evs 1 ]
         if  ( innovative + environmental )/ 2 =  1  or ( innovative + environmental )/ 2 =  1.5  [ set threshold-evs 5 ]
         if  ( innovative + environmental )/ 2 =  2  or ( innovative + environmental )/ 2 =  2.5   [ set threshold-evs 15 ]
         if  ( innovative + environmental )/ 2 =  3  or ( innovative + environmental )/ 2 =  3.5 and ( innovative + environmental )/ 2 =  4
             [ set threshold-evs 60 ]

         ifelse ev-percentage < threshold-evs
         [ set buy-or-not 0
      if car1 = 0 [ set car1 1]
    ] ;; if the percentage lower than threhold ,buy a conventional car1
         [
      set buy-or-not 0
      set car2 1
    ]

  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
436
119
945
629
-1
-1
1.0
1
3
1
1
1
0
1
1
1
-250
250
-250
250
1
1
1
ticks
30.0

SLIDER
20
122
228
155
income-standard-error
income-standard-error
100
5000
1500.0
100
1
NIL
HORIZONTAL

SLIDER
248
123
420
156
population
population
100
50000
5300.0
100
1
NIL
HORIZONTAL

SLIDER
20
213
192
246
initial-cars
initial-cars
100
10000
1350.0
50
1
NIL
HORIZONTAL

SLIDER
20
167
192
200
ev-price
ev-price
15000
40000
28500.0
500
1
NIL
HORIZONTAL

SLIDER
22
260
194
293
price-gasoil
price-gasoil
0.1
2
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
21
304
193
337
price-electricity
price-electricity
0.01
2
0.25
0.01
1
NIL
HORIZONTAL

CHOOSER
236
65
374
110
charging-pattern
charging-pattern
"a" "b" "c"
2

SLIDER
22
353
194
386
maximum-mileage
maximum-mileage
150
600
186.0
1
1
NIL
HORIZONTAL

SLIDER
20
393
192
426
price-difference
price-difference
-0.5
0.5
0.05
0.05
1
NIL
HORIZONTAL

SLIDER
21
432
193
465
charger-price
charger-price
100
2000
1100.0
100
1
NIL
HORIZONTAL

BUTTON
29
10
95
43
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

BUTTON
125
13
188
46
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

PLOT
218
181
418
331
Conventional cars number
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -955883 true "" "plot count turtles with [ car1 > 0 ]"

PLOT
217
353
417
503
EVs number
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [ car2 > 0 ]"

PLOT
964
49
1164
199
Ner concentional car number
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot newcar1"

PLOT
965
239
1165
389
new EVs number 
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot  newcar2"

PLOT
968
441
1168
591
die conventional car and EVs
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot diecar1"
"pen-1" 1.0 0 -4079321 true "" "plot diecar2"

SLIDER
21
70
193
103
average-income
average-income
500
8000
500.0
50
1
NIL
HORIZONTAL

TEXTBOX
608
58
758
109
Note!!!  It is slow. Be careful. \nI am sorry.
14
0.0
1

@#$#@#$#@
## WHAT IS IT?

Tool of exploring technological breakthrough’s influence on the adoption of EVs

## PURPOSE 

This model will be mainly used to simulate the changes in the adoption of electric vehicles (EV) brought by the technical breakthrough. It is an urgent problem as the global climate is now facing challenges. Apart from technological breakthroughs, market subsidies and government intervention can also play important roles in promoting the EV’s adoption. However, these interventions are not always effective all over the world. This model links the ABM model with the purchase behavior of electric vehicles. The main focus is on technological breakthroughs in four areas: the decline in vehicle prices, decline in charging prices, transformation in charging methods, and growth of the maximum mileage. 

In fact, technological breakthroughs are often compounded. For example, the decline in charging price will be accompanied by changes in charging methods (concentrated charging or universal home charging equipment). Therefore, it is difficult for traditional static models to simulate the process of this interaction. This model will be able to predict changes in the degree of popularity of electric vehicles on both macro and micro levels after technological breakthroughs. Because the thinking process for purchasing a vehicle is fixed, this model can also be modified to simulate changes brought about by market instruments, government intervention, and other means.




## Agents 

The agent represent a household, the households have the variables in Table 1 and the coordinates represent their location.
![Example](file:table1.png)
![Example](file:table2.png)


## Enviroument

In the environment, the size of the closed world is 501*501 representing a 501 * 501(m) space and the space scale can be applied in any research area. The center (grey)area (51*51) is surround by (black)middle-income (50%), (orange)lower income (25%) and (white)wealthy (25%) district and these districts overlap the center area.     

The environment also includes a few charging stations based on the pattern of charging solution. The time unit is month represented by a tick.    


## The process and scheduling.  

The process is illustrated in Fig2.  Every agent would experience the process flow once a tick. If the agent does not need any car or buy a new car, it is the end of an step of the agent.
![Example](file:process.png)

Step a: If the agent need to buy a new car? When the car’s age is over 72 months, the agent is thinking of purchasing a new car, and 3% of all agents without any car randomly think of buying a new car, in addition, randomly 10% of agents who own car1 but do not own car2 think of purchasing a new car.  If they need, go to the step b. 

Step b: If the agent affords to buy a new car? If the agent’s 10% income is higher than month payment for an EV car (the car price / 72), go to step c, if the agent’s 15% (step d) is higher and 11% is lower than month payment, the agent buys a conventional car.


Step c: If the EV’s range can cover the household’s average travel length, the agent goes to step d, otherwise buys a conventional car.

Step e: If the EV’s range > the agent’s long travel threshold, the agent goes to step f, otherwise, the agent would buy a conventional car as they do not have a conventional car already. 

Step f: If the EV is money saving, the agents goes to step h, otherwise goes to step i. 
The saving money = (the price of gasoil - the price of electricity) * average travel length - the [ (price difference + the private charger price) / (72 months*30 days)]. If the saving money is positive, the EV is saving money and vice versa. 

Step h: If there is charging station within 1 km radius (The charging patter 2 can make agents ignore the step) If there is, the agent goes to step g, and if not, the agent goes to buy a conventional car. 

Step g: If the agent is interested in innovative technology. It is decided by the innovative level which have a related probability (Table 3) to buy an EV.  

![Example](file:table3.png)



## Design concepts

Concepts

The model’s environment is based on Chris and Rachel’s model in 2015. And the parameters are based on the prosocial behavior about EVs and the diffusion of EVs. 

Adaptive

Adaptive behavior: The key individual decision is whether to buy a car each month. Every agent goes through the process in Figure2. 

Learning, Prediction

The agent behaviors are not based on expected future state and do not change; no learning or prediction are represented.


Interaction

In the step j (Figure 2), the agents’ behaviors are based on how many EVs they have seen.

Sensing

The agents (Household) can see the charging stations, chargers, EVs and cars with 1 km radius from their home and workplace. 

Stochasticity

Stochastic functions are used to initialize households’ locations, income, and other attributes according to Table1 and table2.

Collectives

Agents are separated into a few groups based on the innovative Level and environmental attitude, and the groups have different rules deciding whether to buy an EV.

Observation

The observation is the same with emergency.




## Emergence

![Example](file:table4.png)

## Input
 
 You have to set the parameters in advance.
![Example](file:table5.png)

## Initialization 

Parameters are set as rules in Table1 and Table2

## Notice 

The process is slow, We recommend you not to repeat it too many times.

## To explore 

1. You can try to improve the models to accelerate its computing speed.

2. As for the rules of Initialization in Table 1 and table 2. It is need to be set according to the change of object you want to explore. It is meaningful to find better methods to set those parameters.


## Cite 

It is an anonymous work. But if you can find this model. I am glad to see someone to use for free as if it works 

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
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt; 60</exitCondition>
    <metric>count turtles with [ car1 &gt; 0 ]</metric>
    <metric>count turtles with [ car2 &gt; 0 ]</metric>
    <metric>count turtles with [ car1 &gt; 0 and car2 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car1 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car2 &gt; 0 ]</metric>
    <metric>newcar1</metric>
    <metric>newcar2</metric>
    <enumeratedValueSet variable="maximum-mileage">
      <value value="186"/>
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="income-standard-error">
      <value value="1400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-pattern">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ev-price">
      <value value="28000"/>
      <value value="18000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charger-price">
      <value value="1100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-income">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-difference">
      <value value="0.5"/>
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-gasoil">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cars">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-electricity">
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment1 原来和最大里程变成186-350" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt; 60</exitCondition>
    <metric>count turtles with [ car1 &gt; 0 ]</metric>
    <metric>count turtles with [ car2 &gt; 0 ]</metric>
    <metric>count turtles with [ car1 &gt; 0 and car2 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car1 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car2 &gt; 0 ]</metric>
    <metric>newcar1</metric>
    <metric>newcar2</metric>
    <enumeratedValueSet variable="maximum-mileage">
      <value value="186"/>
      <value value="350"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="income-standard-error">
      <value value="1400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-pattern">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ev-price">
      <value value="28000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charger-price">
      <value value="1100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-income">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-difference">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-gasoil">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cars">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-electricity">
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment价格18000" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt; 60</exitCondition>
    <metric>count turtles with [ car1 &gt; 0 ]</metric>
    <metric>count turtles with [ car2 &gt; 0 ]</metric>
    <metric>count turtles with [ car1 &gt; 0 and car2 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car1 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car2 &gt; 0 ]</metric>
    <metric>newcar1</metric>
    <metric>newcar2</metric>
    <enumeratedValueSet variable="maximum-mileage">
      <value value="186"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="income-standard-error">
      <value value="1400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-pattern">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ev-price">
      <value value="18000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charger-price">
      <value value="1100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-income">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-difference">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-gasoil">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cars">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-electricity">
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment价差变为0.05" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt; 60</exitCondition>
    <metric>count turtles with [ car1 &gt; 0 ]</metric>
    <metric>count turtles with [ car2 &gt; 0 ]</metric>
    <metric>count turtles with [ car1 &gt; 0 and car2 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car1 &gt; 0 ]</metric>
    <metric>mean [ income ] of turtles with [ car2 &gt; 0 ]</metric>
    <metric>newcar1</metric>
    <metric>newcar2</metric>
    <enumeratedValueSet variable="maximum-mileage">
      <value value="186"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="income-standard-error">
      <value value="1400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charging-pattern">
      <value value="&quot;c&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ev-price">
      <value value="28000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="charger-price">
      <value value="1100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="5000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-income">
      <value value="2500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-difference">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-gasoil">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-cars">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="price-electricity">
      <value value="0.25"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
