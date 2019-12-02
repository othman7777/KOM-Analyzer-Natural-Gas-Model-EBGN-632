set
i "production wells" /W1, W2, W3, W4, W5, W6, W7, W8, W9, W10/,
j "enduse option" /power_plant, LDC, LNG_export_company, petrochemical_plant, Waha_Hub/;

parameter

e(j) "gas delivering cost ($ / BTU / day)"
/
LNG_export_company 150,
Power_plant 50,
Waha_Hub 85,
LDC 75,
Petrochemical_plant 180
/

p(j) "revenue from enduse option ($ / BTU / day)"
/
LNG_export_company 1000,
Power_plant 700,
Waha_Hub 800,
LDC 600,
Petrochemical_plant 550
/,

k(i) "capacity per well (BTUs / day)"
/
W1 1554000000,
W2 1554000000,
W3 1554000000,
W4 1554000000,
W5 1554000000,
W6 1554000000,
W7 1554000000,
W8 1554000000,
W9 1554000000,
W10 1554000000
/,

l(j) "capacity of enduse option (BTUs / day)"
/
LNG_export_company 5000000000000,
Power_plant 1000000000000,
Waha_Hub 3000000000000,
LDC 4000000000000,
Petrochemical_plant 2000000000000
/,

T(j) "cost of Transportation ($)"
/
LNG_export_company 5000,
Power_plant 1000,
Waha_Hub 3000,
LDC 4000,
Petrochemical_plant 2000
/,

C(j) "Transportation Capacity ($)"
/
LNG_export_company 2500000000000,
Power_plant 10000000000,
Waha_Hub 2000000000000,
LDC 2000000000000,
Petrochemical_plant 4000000000000
/,

W(i) "cost of each well ($)"
/
W1 1000000,
W2 1300000,
W3 1000000,
W4 2000000,
W5 1500000,
W6 1200000,
W7 1400000,
W8 1000000,
W9 1100000,
W10 2000000
/;


scalar m "cost of extracting and processing gas ($ / BTU / day)"
/
0.0004003
/;


Positive variables
X "Total production (BTUs / day)",
Y(j) "enduse activity (BTUs / day)",
B(i,j) "conversion from i to j (BTUs / day)",
F "Total cost of wells ($)";

positive variable well_production(i);
equation well_accounting(i);

Variables Z "objective function value";


Equations
Total_Production "total produced gas",
ObjFn "computed objective function value",
End_Limit(j) "cannot sell more than what options are allowed",
Sell_Limit(j) "can only sell what you have processed",
Total_Cost "total cost of production and transport",
capacity_limit(j)
;

Total_Cost .. F =e= sum(i,W(i)*m);

Total_Production .. X =e= sum(i,k(i));

well_accounting(i).. well_production(i) =e= sum(j,B(i,j));

scalar dollars_to_million_dollars /1e-6/;

ObjFn .. Z =e= dollars_to_million_dollars *
*profit on units sold
                (sum(j,(p(j)-e(j)-T(j))*Y(j))
*cost of gas extraction
               -(m*X)
*cost per each well - note not tracking extraction for each well
*therefore need the double sum of the B_i,j variable
               -sum(i,well_production(i)*W(i)))
               ;
               

parameter well_capacity(i);
well_capacity(i) = 1e13;

equation well_limit(i);
well_limit(i).. well_capacity(i) =g= well_production(i);

*note this was an equality...
Capacity_Limit(j).. C(j) =g= Y(j);

*note here that this is an equality, requiring a certain amount of demand to be met
End_Limit(j).. l(j) =g= Y(j);

Sell_Limit(j).. sum(i,B(i,j)) =g= Y(j);

Model workshop /all/;

*first one c(j) -- is necessary for feasibility
*c(j) = c(j) * 1e2;
W(i) = W(i) * 1e-5;
p(j) = p(j) * 1e2;


*decrease all well capacity by a whole bunch
well_capacity(i) = well_capacity(i) / 30;




solve workshop using lp maximizing Z;

parameter b_out(i,j,*);

b_out(i,j,"reference") = b.l(i,j);

*objective function breakdown..
parameter objfn_out;
objfn_out("profit on units sold","reference") = sum(j,(p(j)-e(j)-T(j))*Y.l(j));

objfn_out("cost of gas extraction","reference") = (m*X.l);

objfn_out("cost for all wells","reference") = sum(i,well_production.l(i) * W(i));

parameter profit_per_unit;

profit_per_unit(j) = p(j) - e(j) - t(j);

*begin mb_counterfactual
* removing w1 and w3 from production
b.up("w1",j) = 0;
b.up("w3",j) = 0;
b.up("w8",j) = 0;


solve workshop using lp maximizing Z;

b_out(i,j,"counterfactual") = b.l(i,j);

*w(i) = w(i) * 1.25;
*price to power plant decreased by 50%
*p("power_plant") = p("power_plant") * 0.5;

*objective function breakdown..

objfn_out("profit on units sold","counterfactual") = sum(j,(p(j)-e(j)-T(j))*Y.l(j));

objfn_out("cost of gas extraction","counterfactual") = (m*X.l);

objfn_out("cost for all wells","counterfactual") = sum(i,well_production.l(i) * W(i));



execute_unload 'allresults.gdx';






