** importing the file for analysis;
Data SalesTerritory;
filename Sales '/home/u63572188/BAN130_NBB_SWATHY/AdventureWorks(2).xlsx';
PROC IMPORT DATAFILE= Sales
OUT=work.SalesTerritory
 DBMS=XLSX REPLACE;
 sheet='SalesTerritory';
GETNAMES=YES;
RUN;

Data SalesOrderHeader;
filename SalesHd '/home/u63572188/BAN130_NBB_SWATHY/AdventureWorks(2).xlsx';
PROC IMPORT DATAFILE= SalesHd
OUT=work.SalesOrderHeader
 DBMS=XLSX REPLACE;
 sheet='SalesOrderHeader';
GETNAMES=YES;
RUN;

** Data Cleaning for analysis;

/* Assuming the original Product dataset is already available in the WORK library */

data SalesOrderHeader_Clean;
    set SalesOrderHeader (keep=SalesOrderID OrderDate OnlineOrderFlag TerritoryID TotalDue);
run;


/* Display the contents of the new dataset */
proc print data=SalesOrderHeader_Clean (obs=10);
run;

proc contents data=salesorderheader;
run;


/* Assuming the original SalesOrderHeader dataset is already available in the WORK library */

/* Assuming the original SalesOrderHeader dataset is already available in the WORK library */

data SalesOrderHeader_Clean;
    set SalesOrderHeader (keep=SalesOrderID OrderDate OnlineOrderFlag TerritoryID TotalDue);
    /* Convert OrderDate to numeric with mmddyy10. format */
    OrderDate1 = input(OrderDate, anydtdte20.);

    /* Convert OnlineOrderFlag to numeric */
    OnlineOrderFlag = input(OnlineOrderFlag, 2.);
    
    TotalDue1 = input(TotalDue, 11.);
    TerritoryID = input(TerritoryID, 2.);

    /* Format TotalDue with a dollar sign and 2 decimal places */
    format TotalDue1 DOLLAR12.2;

    /* Display OrderDate with mmddyy10. format */
    format OrderDate1 mmddyy10.;
    Drop TotalDue;
    Drop OrderDate;
run;

data SalesOrderHeader_Clean;
	set salesorderheader_Clean (rename=(TotalDue1=TotalDue OrderDate1=OrderDate));
	drop TotalDue1;
	drop OrderDate1;

/* Display the contents of the new dataset */
proc print data=SalesOrderHeader_Clean (obs=10);
run;
proc sort data=SalesOrderHeader_Clean;
    by TerritoryID;
run;
data Territory_Clean;
set salesterritory (keep=TerritoryID Name CountryRegionCode Group SalesYTD);

SalesYTD1= input(SalesYTD, 11.);
TerritoryID = input(TerritoryID,2.);

format SalesYTD1 DOLLAR12.2;
drop SalesYTD;
run;
data Territory_Clean;
	set Territory_Clean (rename=(SALESYTD1=SalesYTD));
	run;
	Proc print data=territory_clean (obs=10);
	run;
	
	/* Assuming SalesOrderHeader_Clean and Territory_Clean datasets are available in the WORK library */

data SalesDetails;
    merge SalesOrderHeader_Clean(in=a) Territory_Clean(in=b);
    by TerritoryID;

    /* Output all observations from SalesOrderHeader_Clean */
    if a;

    /* Other processing steps as needed */

run;

/* Display the contents of the new dataset */
proc print data=SalesDetails (obs=10);
run;

data SalesAnalysis;
    set SalesDetails;
    by TerritoryID;

    /* Initialize subtotal and quantity for the first observation in each TerritoryID group */
    if first.TerritoryID then do;
        SubTotalDue = 0;
        SubQty = 0;
    end;

    /* Accumulate values for each TerritoryID group */
    SubTotalDue + TotalDue;
    SubQty + 1;

    /* Output the last observation in each TerritoryID group */
    if last.TerritoryID then output;

    /* Drop unnecessary variables */
    drop TotalDue  TerritoryID SalesOrderID OnlineOrderFlag OrderDate SubQTY ;
run;

/* Format the SubTotal column with a dollar sign and 2 decimal places */
data SalesAnalysis;
    set SalesAnalysis;
    format SubTotalDue dollar20.2;
run;

/* Display the contents of the new dataset */
proc print data=SalesAnalysis (obs=10);
run;

