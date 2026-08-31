Libname heart "/home/u63788668/Heart_ Disease";

/* Import the CSV into SAS */

proc import datafile="/home/u63788668/Heart_ Disease/heart_disease.csv"
    out=heart.heart_raw
    dbms=csv
    replace;
    guessingrows=max;
    getnames=yes;
run;

/* Check the imported dataset */

proc contents data=heart.heart_raw;
run;

proc print data=heart.heart_raw(obs=10);
run;

proc means data=heart.heart_raw n nmiss mean std min max;
run;

/* Check  Categorical Variables*/

proc freq data=heart.heart_raw;
    tables Gender
           education
           currentSmoker
           BPMeds
           prevalentStroke
           prevalentHyp
           diabetes
           Heart_stroke
           / missing;
run;

/* Create the clean Data */

data heart_clean;
    set heart.heart_raw;

    /* Create numeric binary outcome */
    if upcase(strip(Heart_stroke)) = "YES" then heart_disease = 1;
    else if upcase(strip(Heart_stroke)) = "NO" then heart_disease = 0;
    else heart_disease = .;

    /* Create readable categorical variables */
    if currentSmoker = 1 then smoker = "Yes";
    else if currentSmoker = 0 then smoker = "No";

    if prevalentHyp = 1 then hypertension = "Yes";
    else if prevalentHyp = 0 then hypertension = "No";

    if diabetes = 1 then diabetes_status = "Yes";
    else if diabetes = 0 then diabetes_status = "No";

    if BPMeds = 1 then bp_medication = "Yes";
    else if BPMeds = 0 then bp_medication = "No";

    /* Standardize character variables */
    Gender = propcase(strip(Gender));
    education = lowcase(strip(education));
    prevalentStroke = lowcase(strip(prevalentStroke));

    /* Add labels */
    label
        age = "Age (years)"
        cigsPerDay = "Cigarettes Per Day"
        totChol = "Total Cholesterol"
        sysBP = "Systolic Blood Pressure"
        diaBP = "Diastolic Blood Pressure"
        BMI = "Body Mass Index"
        heartRate = "Heart Rate"
        glucose = "Glucose"
        heart_disease = "Heart Disease Outcome";

    /* Remove original outcome variable */
    drop Heart_stroke;
run;

proc freq data=heart_clean;
    tables heart_disease / missing;
run;

proc freq data=heart_clean;
    tables smoker
           hypertension
           diabetes_status
           bp_medication
           heart_disease
           / missing;
run;

proc contents data=heart_clean;
run;

proc print data=heart_clean(obs=10);
run;

data heart_clean2;
    set heart_clean;

    /* Convert character variables to numeric.
       Treat "NA" as missing. */

    if upcase(strip(cigsPerDay)) = "NA" or strip(cigsPerDay) = "" then
        cigsPerDay_num = .;
    else
        cigsPerDay_num = input(strip(cigsPerDay), best32.);

    if upcase(strip(totChol)) = "NA" or strip(totChol) = "" then
        totChol_num = .;
    else
        totChol_num = input(strip(totChol), best32.);

    if upcase(strip(BMI)) = "NA" or strip(BMI) = "" then
        BMI_num = .;
    else
        BMI_num = input(strip(BMI), best32.);

    if upcase(strip(glucose)) = "NA" or strip(glucose) = "" then
        glucose_num = .;
    else
        glucose_num = input(strip(glucose), best32.);

    /* Remove original character variables */
    drop cigsPerDay totChol BMI glucose;

    /* Rename converted variables */
    rename
        cigsPerDay_num = cigsPerDay
        totChol_num = totChol
        BMI_num = BMI
        glucose_num = glucose;
run;

proc contents data=heart_clean2;
run;

proc means data=heart_clean2
           n
           nmiss
           mean
           std
           median
           min
           max;
var age
        cigsPerDay
        totChol
        sysBP
        diaBP
        BMI
        heartRate
        glucose;
run;

proc freq data=heart_clean2;
    tables cigsPerDay
           totChol
           BMI
           glucose
           / missing;
run;

proc means data=heart_clean2 n nmiss mean std median min max;
    var age cigsPerDay totChol sysBP diaBP BMI heartRate glucose;
run;

proc freq data=heart_clean2;
    tables heart_disease / missing;
run;

data heart_clean2;
    set heart_clean2;

    /* Create indicator for missing glucose */
    if missing(glucose) then glucose_missing=1;
    else glucose_missing=0;

    label glucose_missing = "Glucose Missing Indicator";
run;

proc freq data=heart_clean2;
    tables heart_disease*glucose_missing / chisq norow nocol;
run;

proc means data=heart_clean2 n nmiss;
    var age
        cigsPerDay
        totChol
        sysBP
        diaBP
        BMI
        heartRate
        glucose;
run;

proc freq data=heart_clean2;
    tables Gender
           education
           currentSmoker
           BPMeds
           prevalentStroke
           prevalentHyp
           diabetes
           heart_disease
           / missing;
run;

data heart_clean3;
    set heart_clean2;

    /* Convert "na" in education to SAS missing */
    if lowcase(strip(education)) = "na" then education = "";

run;

proc freq data=heart_clean3;
    tables education / missing;
run;

proc freq data=heart_clean3;
    tables Gender
           education
           currentSmoker
           BPMeds
           prevalentStroke
           prevalentHyp
           diabetes
           heart_disease
           / missing;
run;

data heart_final;
    set heart_clean3;

    /* Convert BPMeds from character to numeric */
    if upcase(strip(BPMeds)) = "NA" or strip(BPMeds) = "" then
        BPMeds_num = .;
    else
        BPMeds_num = input(strip(BPMeds), best32.);

    /* Replace original BPMeds */
    drop BPMeds;
    rename BPMeds_num = BPMeds;

run;

proc freq data=heart_final;
    tables BPMeds / missing;
run;


proc freq data=heart_final;
    tables Gender
           education
           currentSmoker
           BPMeds
           prevalentStroke
           prevalentHyp
           diabetes
           heart_disease
           / missing;
run;

data heart_analysis;
    set heart_final;

    /* Identify complete observations */
    if not missing(age)
       and not missing(Gender)
       and not missing(education)
       and not missing(currentSmoker)
       and not missing(cigsPerDay)
       and not missing(BPMeds)
       and not missing(prevalentStroke)
       and not missing(prevalentHyp)
       and not missing(diabetes)
       and not missing(totChol)
       and not missing(sysBP)
       and not missing(diaBP)
       and not missing(BMI)
       and not missing(heartRate)
       and not missing(glucose)
       and not missing(heart_disease);

run;

proc sql;
    select count(*) as complete_cases
    from heart_analysis;
quit;

proc sql;
    select 
        349 as original_sample,
        count(*) as analysis_sample,
        349 - count(*) as excluded
    from heart_analysis;
quit;

proc means data=heart_analysis n nmiss;
    var age
        cigsPerDay
        totChol
        sysBP
        diaBP
        BMI
        heartRate
        glucose;
run;

proc freq data=heart_analysis;
    tables Gender
           education
           currentSmoker
           BPMeds
           prevalentStroke
           prevalentHyp
           diabetes
           heart_disease
           / missing;
run;


proc sql;
    select count(*) as complete_cases
    from heart_analysis;
quit;

proc means data=heart_analysis n nmiss;
    var age cigsPerDay totChol sysBP diaBP BMI heartRate glucose;
run;

/* Descriptive Statistics */
proc means data=heart_analysis
           n
           mean
           std
           median
           min
           max;
    var age
        cigsPerDay
        totChol
        sysBP
        diaBP
        BMI
        heartRate
        glucose;
run;

proc means data=heart_analysis
           mean
           std
           median
           min
           max;
    class heart_disease;

    var age
        cigsPerDay
        totChol
        sysBP
        diaBP
        BMI
        heartRate
        glucose;
run;

proc means data=heart_analysis
           n
           mean
           std
           median
           min
           max;
    class heart_disease;

    var age cigsPerDay totChol sysBP diaBP BMI heartRate glucose;
run;


ods pdf
file="/home/u63788668/Heart_ Disease/print_output.pdf";
proc ttest data=heart_analysis;
    class heart_disease;

    var age
        cigsPerDay
        totChol
        sysBP
        diaBP
        BMI
        heartRate
        glucose;
run;
ods pdf close;

/* Analysis of Categorical variables */

ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_2.pdf";
proc freq data=heart_analysis;
    tables
        Gender*heart_disease
        education*heart_disease
        currentSmoker*heart_disease
        BPMeds*heart_disease
        prevalentStroke*heart_disease
        prevalentHyp*heart_disease
        diabetes*heart_disease
        / chisq expected;
run;

ods pdf close;

/* Univariate logistics Regression */

ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_3.pdf";
proc logistic data=heart_analysis;
    class prevalentHyp (ref='0') / param=ref;
    model heart_disease(event='1') = prevalentHyp;
run;

ods pdf close;

ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_4.pdf";

proc logistic data=heart_analysis;
    model heart_disease(event='1') = age;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = cigsPerDay;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = totChol;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = sysBP;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = diaBP;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = BMI;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = heartRate;
run;

proc logistic data=heart_analysis;
    model heart_disease(event='1') = glucose;
run;

ods pdf close;

/* Multivariate logistic regression */
proc logistic data=heart_analysis descending;
    model heart_disease =
        age
        totChol
        sysBP
        diaBP
        BMI
        glucose
        prevalentHyp
        / clodds=wald;
run;

proc logistic data=heart_analysis descending;
    model heart_disease =
        age
        totChol
        sysBP
        diaBP
        BMI
        glucose
        prevalentHyp
        / clodds=wald
          lackfit
          rsquare;
run;

ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_5.pdf";
proc logistic data=heart_analysis descending;
    model heart_disease =
        age
        totChol
        sysBP
        diaBP
        BMI
        glucose
        prevalentHyp
        / clodds=wald
          lackfit
          rsquare;
run;

ods pdf close;


ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_6.pdf";
proc reg data=heart_analysis;
    model heart_disease =
          age
          totChol
          sysBP
          diaBP
          BMI
          glucose
          / vif tol;
run;
quit;


proc corr data=heart_analysis pearson;
    var age
        totChol
        sysBP
        diaBP
        BMI
        glucose;
run;

ods pdf close;

ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_7.pdf";

proc logistic data=heart_analysis descending;
    model heart_disease =
        age
        totChol
        prevalentHyp
        / clodds=wald
          lackfit
          rsquare;
run;

ods pdf close;

ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_8.pdf";
proc logistic data=heart_analysis descending;
    model heart_disease =
        age
        totChol
        prevalentHyp
        sysBP
        diaBP
        / clodds=wald
          lackfit
          rsquare;
run;

ods pdf close;


ods pdf 
file="/home/u63788668/Heart_ Disease/print_output_9.pdf";
proc logistic data=heart_analysis descending plots(only)=roc;
    model heart_disease =
        age
        totChol
        prevalentHyp
        sysBP
        diaBP
        / clodds=wald;
    roc;
run;

ods pdf close;