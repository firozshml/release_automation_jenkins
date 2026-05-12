CREATE TABLE "TPRQP"(POL_ID Character (10) Not Null,
QUOT_SEQ_NUM Character (2) Not Null,
PLAN_ID Character (6) Not Null with Default,
POL_ISS_EFF_DT_TXT Character (16) Not Null with Default,
INS_PROD_NM_TXT Character (70) Not Null with Default,
OWNER_ADDR_1_TXT Character (60) Not Null with Default,
OWNER_ADDR_2_TXT Character (60) Not Null with Default,
OWNER_ADDR_3_TXT Character (64) Not Null with Default,
OWNER_ADDR_4_TXT Character (12) Not Null with Default,
OWNER_NM_KJ_TXT Character (115) Not Null with Default,
INSRD_NM_KJ_TXT Character (60) Not null with default,
RDR_RENW_INSRD_AGE Character (3) Not Null with Default,
POL_CURR_MPREM_AMT Decimal (13,2) Not Null with Default,
POL_NEW_MPREM_AMT Decimal (13,2) Not Null with Default,
USER_ID Character (8) Not Null with Default,
RPT_CREAT_TS TIMESTAMP,
RENW_CNFRM_BY_DT Date,
SML_PROD_CD CHARACTER(3) NOT NULL WITH DEFAULT)	
                  IN "TSSMS05"
                  ORGANIZE BY ROW;


-- DDL STATEMENTS FOR INDEXES ON TABLE "TPRQP"

CREATE UNIQUE INDEX "X01PRQP" ON "TPRQP"
                ("POL_ID",
                 "QUOT_SEQ_NUM")
                COMPRESS NO
                INCLUDE NULL KEYS DISALLOW REVERSE SCANS;
				
-- DDL STATEMENTS FOR PRIMARY KEY ON TABLE "TPRQP"

ALTER TABLE "TPRQP"
        ADD PRIMARY KEY
                ("POL_ID",
                 "QUOT_SEQ_NUM");



-- DDL Statements for Aliases based on Table "INGMP1S "."TPRQP"

CREATE ALIAS "INGENIUM"."TPRQP" FOR TABLE "INGMP1S "."TPRQP";

CREATE ALIAS "INGMP3S "."TPRQP" FOR TABLE "INGMP1S "."TPRQP";








--------------------------------------------
-- Authorization Statements on Tables/Views
--------------------------------------------


GRANT CONTROL ON TABLE "INGMP1S "."TPRQP" TO GROUP "INGMP1M1" ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQP" TO GROUP "INGMP1M2" ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQP" TO GROUP "INGMP3M1" ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQP" TO ROLE "IT_READ_ONLY_SUPPORT" ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQP" TO ROLE "IT_READ_ONLY_SUPPORT" ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1  " ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1  " ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1B " ;

GRANT DELETE ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1S " ;

GRANT INSERT ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1S " ;

GRANT SELECT ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1S " ;

GRANT UPDATE ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP1S " ;

GRANT CONTROL ON TABLE "INGMP1S "."TPRQP" TO USER "INGMP3S " ;

---------------------------------------
-- Authorization Statements on Indexes
---------------------------------------


GRANT CONTROL ON INDEX "INGMP1S "."X01PRQP" TO USER "INGMP1  " ;

GRANT CONTROL ON INDEX "INGMP1S "."X01PRQP" TO USER "INGMP3S " ;


COMMIT WORK;

