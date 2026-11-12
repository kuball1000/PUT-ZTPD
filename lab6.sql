-- zad. 1A 
CREATE TABLE S6_LRS (geom SDO_GEOMETRY);

-- zad. 1B
INSERT INTO S6_LRS (geom)
SELECT s.geom
FROM streets_and_railroads s
JOIN major_cities c ON SDO_WITHIN_DISTANCE(s.geom, c.geom, 'distance=10 unit=km') = 'TRUE'
WHERE c.city_name = 'Koszalin';

COMMIT;

-- zad. 1C
SELECT ROUND(SDO_GEOM.SDO_LENGTH(geom, 1, 'unit=km'), 7) AS distance, 
ST_LINESTRING(geom).ST_NUMPOINTS() AS st_numpoints
FROM S6_LRS;

-- za.d 1D
UPDATE S6_LRS
SET geom = SDO_LRS.CONVERT_TO_LRS_GEOM(geom, 0, SDO_GEOM.SDO_LENGTH(geom, 1, 'unit=km'));

COMMIT;

-- zad. 1E
SELECT t.owner, d.sdo_dimname, d.sdo_lb, d.sdo_ub, d.sdo_tolerance, t.srid
FROM all_sdo_geom_metadata t, TABLE(t.diminfo) d
WHERE t.table_name = 'STREETS_AND_RAILROADS';

INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
SELECT 
    'S6_LRS',
    'GEOM',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', MIN(CASE WHEN d.sdo_dimname = 'X' THEN d.sdo_lb END), MAX(CASE WHEN d.sdo_dimname = 'X' THEN d.sdo_ub END), 1),
        MDSYS.SDO_DIM_ELEMENT('Y', MIN(CASE WHEN d.sdo_dimname = 'Y' THEN d.sdo_lb END), MAX(CASE WHEN d.sdo_dimname = 'Y' THEN d.sdo_ub END), 1),
        MDSYS.SDO_DIM_ELEMENT('M', 0, MAX(m.max_m), 1)
    ),
    MAX(t.srid)
FROM all_sdo_geom_metadata t
CROSS JOIN TABLE(t.diminfo) d
CROSS JOIN (
    SELECT CEIL(SDO_LRS.GEOM_SEGMENT_END_MEASURE(geom)) AS max_m 
    FROM s6_lrs
) m
WHERE t.table_name = 'STREETS_AND_RAILROADS';

COMMIT;

SELECT d.sdo_dimname, d.sdo_lb, d.sdo_ub, d.sdo_tolerance
FROM user_sdo_geom_metadata m,
     TABLE(m.diminfo) d
WHERE m.table_name = 'S6_LRS';

-- zad. 1F
CREATE INDEX s6_lrs_spatial_idx  ON S6_LRS(geom)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- zad. 2A
SELECT SDO_LRS.VALID_MEASURE(geom, 500) AS valid_500
FROM S6_LRS;

-- zad. 2B
-- SELECT SDO_LRS.GEOM_SEGMENT_END_PT(geom).sdo_ordinates AS end_pt
SELECT SDO_LRS.GEOM_SEGMENT_END_PT(geom) AS end_pt
FROM s6_lrs ;

-- zad. 2C
-- SELECT SDO_LRS.LOCATE_PT(GEOM, 150, 0).sdo_ordinates as km150
SELECT SDO_LRS.LOCATE_PT(GEOM, 150, 0) as km150
FROM S6_LRS;

-- zad. 2D
-- SELECT SDO_LRS.CLIP_GEOM_SEGMENT(geom, 120, 160).sdo_ordinates AS clipped
SELECT SDO_LRS.CLIP_GEOM_SEGMENT(geom, 120, 160) AS clipped
FROM S6_LRS;

-- zad. 2E
SELECT SDO_LRS.GET_NEXT_SHAPE_PT(s.geom, mc.geom) AS wjazd_na_s6
FROM S6_LRS s
CROSS JOIN major_cities mc
WHERE mc.city_name = 'Slupsk';

-- zad. 2F
SELECT SDO_GEOM.SDO_LENGTH(SDO_LRS.OFFSET_GEOM_SEGMENT(s.geom, m.diminfo, 50, 200, 50, 'unit=m arc_tolerance=1'), 1, 'unit=km') AS koszt
FROM S6_LRS s
JOIN user_sdo_geom_metadata m ON m.table_name = 'S6_LRS' AND m.column_name = 'GEOM';