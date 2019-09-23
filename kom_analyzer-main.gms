set
i "production wells" /well 1, well 2, ..., well i/,
j "end-use option" /power plant, LDC, LNG export company, petrochemical plant, Waha Hub/;

parameter
c(i) "cost of extracting and processing gas ($ / BTU / day)"
/
.0004003
/,

e(j) "gas delivering cost ($ / BTU / day)"
/
1000
/,

p(j) "revenue from end-use option ($ / BTU / day)"
/
1000
/,

k(j) "capacity per well (BTUs / day)"
/
1554000000
/,

l(j) "capacity of end use option (BTUs/ day)"
/
LNG 1000,
Power plant 1000,
Waha Hub 1000,
LDC 1000,
Petrochemical 1000
/;

Positive variables
X(i) "well production (BTUs / day)",
Y(i) "end-use activity (BTUs / day)",
W(i,j) "conversion from i to j (BTUs / day)";

Variables Z "objective function value";


Equations
ObjFn "computed objective function value",
Ext_Limit(i) "cannot extract more from the wells than they have capacity for",
End_Limit(j) "cannot sell more than what options are allowed",
Sell_Limit(i,j) "can only sell what you have processed"
;

OnjFn.. Z =e= sum(j,p((j)-e(j))*Y(j)) - sum(i,c(i)*X(i));

Ext_Limit(i).. k(j) =g= X(i);
End_Limit(j).. l(j) =g= Y(j);
Sell_Limit(i,j).. sum(i,W(i,j)) =g= Y(j);

Model workshop /all/;

solve workshop using lp maximizing Z;
















