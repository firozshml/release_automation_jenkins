CREATE TABLE "TPRQC"(POL_ID Character (10) Not Null,
CVG_NUM Character (2) Not Null,
QUOT_SEQ_NUM Character (2) Not Null,
RDR_RENW_DTL_CD Character (1) Not Null,
PLAN_NM Character (70) Not Null with Default,
CVG_STBL_1_CD_TXT Character (2) Not Null with Default,
CVG_STBL_4_CD_TXT Character (2) Not Null with Default,
CVG_FACE_AMT Decimal (15,2) Not Null with Default,
CVG_MPREM_AMT Decimal (13,2) Not Null with Default,
RENW_XPRY_CLAS_CD Character (2) Not Null with Default,
ERR_MSG_CD Character (1) Not Null with Default)	
                  IN "TSSMS05"
                  ORGANIZE BY ROW;


-- DDL STATEMENTS FOR INDEXES ON TABLE "TPRQC"

CREATE UNIQUE INDEX "X01PRQC" ON "TPRQC"
                ("POL_ID",
                 "CVG_NUM",
                 "QUOT_SEQ_NUM",
                 "RDR_RENW_DTL_CD")
                COMPRESS NO
                INCLUDE NULL KEYS DISALLOW REVERSE SCANS;
				
-- DDL STATEMENTS FOR PRIMARY KEY ON TABLE "TPRQC"

ALTER TABLE "TPRQC"
        ADD PRIMARY KEY
                ("POL_ID",
                 "CVG_NUM",
                 "QUOT_SEQ_NUM",
                 "RDR_RENW_DTL_CD");



-- DDL Statements for Aliases based on Table "INGMP1S "."TPRQC"

CREATE ALIAS "INGENIUM"."TPRQC" FOR TABLE "INGMP1S "."TPRQC";

CREATE ALIAS "INGMP3S "."TPRQC" FOR TABLE "INGMP1S "."TPRQC";








--------------------------------------------
-- Authorization Statements on Tables/Views
--------------------------------------------


GRANT CONTROL ON TABLE "INGMP1S "."TPRQC" TO GROUP "INGMP1M1" ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQC" TO GROUP "INGMP1M2" ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQC" TO GROUP "INGMP3M1" ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQC" TO ROLE "IT_READ_ONLY_SUPPORT" ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQC" TO ROLE "IT_READ_ONLY_SUPPORT" ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1  " ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1  " ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1B " ;

GRANT DELETE ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1S " ;

GRANT INSERT ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1S " ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1S " ;

GRANT UPDATE ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP1S " ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQC" TO USER "INGMP3S " ;

---------------------------------------
-- Authorization Statements on Indexes
---------------------------------------


GRANT CONTROL ON INDEX "INGMP1S "."X01PRQC" TO USER "INGMP1  " ;

GRANT CONTROL ON INDEX "INGMP1S "."X01PRQC" TO USER "INGMP3S " ;

COMMIT WORK;

