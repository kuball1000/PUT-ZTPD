-- zad. 1
CREATE TABLE movies AS SELECT * FROM ZTPD.MOVIES;

-- zad. 2
DESC MOVIES;
SELECT * FROM MOVIES;

-- zad. 3
SELECT id, title FROM MOVIES WHERE cover IS NULL;

-- zad. 4
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM MOVIES WHERE cover IS NOT NULL;

-- zad. 5
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM MOVIES WHERE cover IS NULL;

-- zad. 6
SELECT DIRECTORY_NAME, DIRECTORY_PATH
FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'TPD_DIR';

-- zad. 7
UPDATE MOVIES
SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg' 
WHERE id = 66;

-- zad. 8
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM MOVIES WHERE id IN (65, 66);

-- zad. 9
DECLARE
    v_bfile BFILE := BFILENAME('TPD_DIR', 'escape.jpg');
    v_blob BLOB;
BEGIN
    SELECT cover INTO v_blob FROM MOVIES WHERE id = 66 FOR UPDATE;
    
    DBMS_LOB.FILEOPEN(v_bfile, DBMS_LOB.FILE_READONLY);
    
    DBMS_LOB.LOADFROMFILE(
        dest_lob => v_blob,
        src_lob => v_bfile,
        amount => DBMS_LOB.GETLENGTH(v_bfile)
    );
    
    DBMS_LOB.FILECLOSE(v_bfile);
    
    COMMIT;
END;
/

-- zad. 10
CREATE TABLE TEMP_COVERS(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

-- zad. 11
INSERT INTO TEMP_COVERS VALUES (65, BFILENAME('TPD_DIR', 'escape.jpg'), 'image/jpeg');
COMMIT;

-- zad. 12
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS filesize
FROM TEMP_COVERS;

-- zad. 13
DECLARE 
    v_file BFILE;
    v_mime_type MOVIES.mime_type%TYPE;
    v_blob BLOB;
BEGIN
    SELECT image, mime_type
    INTO v_file, v_mime_type
    FROM TEMP_COVERS
    WHERE movie_id = 65;
    
    DBMS_LOB.CREATETEMPORARY(
        lob_loc => v_blob,
        cache => TRUE
    );
    
    DBMS_LOB.FILEOPEN(v_file,DBMS_LOB.FILE_READONLY);
    
    DBMS_LOB.LOADFROMFILE(
        dest_lob => v_blob,
        src_lob => v_file,
        amount => DBMS_LOB.GETLENGTH(v_file)
    );

    DBMS_LOB.FILECLOSE(file_loc => v_file);
    
    UPDATE MOVIES
    SET cover = v_blob, mime_type = v_mime_type
    WHERE id = 65;
    
    DBMS_LOB.FREETEMPORARY(lob_loc => v_blob);
    
    COMMIT;
END;
/

-- zad. 14
SELECT id, DBMS_LOB.GETLENGTH(cover) AS filesize 
FROM MOVIES WHERE id IN (65, 66);

-- zad. 15
DROP TABLE MOVIES;
DROP TABLE TEMP_COVERS;

set serveroutput on size 30000;

-- zad. 16
CREATE TABLE DOKUMENTY (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

-- zad. 17
DECLARE
    tekst CLOB := EMPTY_CLOB();
BEGIN
    FOR i IN 1..10000 LOOP
        tekst := tekst || 'Oto tekst. ';
    END LOOP;
    INSERT INTO DOKUMENTY VALUES (1, tekst);
END;
/
-- zad 18
SELECT * FROM DOKUMENTY;

SELECT UPPER(dokument) FROM DOKUMENTY;

SELECT LENGTH(dokument) FROM DOKUMENTY;

SELECT DBMS_LOB.GETLENGTH(dokument) FROM DOKUMENTY;

SELECT SUBSTR(dokument, 5, 1000) FROM DOKUMENTY;

SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM DOKUMENTY;

-- zad. 19
INSERT INTO DOKUMENTY VALUES (2, EMPTY_CLOB());

-- zad. 20
INSERT INTO DOKUMENTY VALUES(3, NULL);

-- zad. 21
SELECT * FROM DOKUMENTY;

SELECT UPPER(dokument) FROM DOKUMENTY;

SELECT LENGTH(dokument) FROM DOKUMENTY;

SELECT DBMS_LOB.GETLENGTH(dokument) FROM DOKUMENTY;

SELECT SUBSTR(dokument, 5, 1000) FROM DOKUMENTY;

SELECT DBMS_LOB.SUBSTR(dokument, 1000, 5) FROM DOKUMENTY;

-- zad. 22
DECLARE
    v_plik_bfile BFILE := BFILENAME('TPD_DIR', 'dokument.txt');
    v_obiekt_clob CLOB;
    v_offset_docelowy NUMBER := 1;
    v_offset_zrodlowy NUMBER := 1;
    v_id_zestawu_znakow NUMBER := 0;
    v_kontekst_jezykowy NUMBER := 0;
    v_kod_ostrzezenia NUMBER;
BEGIN
    SELECT dokument INTO   v_obiekt_clob
    FROM   dokumenty WHERE  id = 2
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(
        file_loc => v_plik_bfile, 
        open_mode => DBMS_LOB.FILE_READONLY
    );

    DBMS_LOB.LOADCLOBFROMFILE(
        dest_lob => v_obiekt_clob,
        src_bfile => v_plik_bfile,
        amount => DBMS_LOB.LOBMAXSIZE,
        dest_offset => v_offset_docelowy,
        src_offset => v_offset_zrodlowy,
        bfile_csid => v_id_zestawu_znakow,
        lang_context => v_kontekst_jezykowy,
        warning => v_kod_ostrzezenia
    );

    DBMS_LOB.FILECLOSE(file_loc => v_plik_bfile);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(v_kod_ostrzezenia);
    
END;
/

-- zad. 23
UPDATE DOKUMENTY SET DOKUMENT = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt')) WHERE ID = 3;

-- zad. 24
SELECT * FROM DOKUMENTY;

-- zad. 25
SELECT ID, DBMS_LOB.GETLENGTH(DOKUMENT) FROM DOKUMENTY;

-- zad. 26
DROP TABLE DOKUMENTY;