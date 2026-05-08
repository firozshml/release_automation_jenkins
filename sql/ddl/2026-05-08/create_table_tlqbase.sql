CREATE TABLE TLQBASE (
    ID          INTEGER NOT NULL,
    NAME        VARCHAR(50),
    CREATED_TS  TIMESTAMP DEFAULT CURRENT TIMESTAMP
);

-------------------------------------------------------------------------------
-- Add primary key
-------------------------------------------------------------------------------

ALTER TABLE TLQBASE
    ADD CONSTRAINT PK_TLQBASE PRIMARY KEY (ID);