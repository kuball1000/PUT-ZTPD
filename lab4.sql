-- zad. 1A
SELECT id, SDO_UTIL.TO_WKTGEOMETRY(ksztalt) AS ksztalt_tekst
FROM figury;

INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES ('FIGURY', 'KSZTALT',
    mdsys.sdo_dim_array(
        mdsys.sdo_dim_element('X', 0, 8, 0.01),
        mdsys.sdo_dim_element('Y', 0, 8, 0.01)
    ),
    NULL
);

-- zad. 1B
SELECT SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0)
FROM DUAL;

-- zad. 1C
CREATE INDEX figury_ksztalt_idx ON FIGURY(KSZTALT)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- zad. 1D
-- Wynik nie odpowiada rzeczywistości, ponieważ punkt (3,3) leży faktycznie tylko wewnątrz figury 2;
-- Operator SDO_FILTER wykonuje jedynie filtrację wstępną w oparciu o prostokąty otaczające;
SELECT f.id
FROM figury f
WHERE SDO_FILTER(f.ksztalt, SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3, 3, NULL), NULL, NULL)) = 'TRUE';

-- zad. 1E
-- tak,teraz wynik odpowiada rzeczywistości;
SELECT f.id
FROM figury f
WHERE SDO_RELATE(f.ksztalt, SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(3, 3, NULL), NULL, NULL), 'mask=ANYINTERACT') = 'TRUE';


-- zad. 2A
SELECT c.city_name AS miasto, sdo_nn_distance(1) AS odl
FROM major_cities c
WHERE sdo_nn(c.geom, (SELECT geom FROM major_cities WHERE city_name = 'Warsaw'), 'sdo_num_res=10 unit=km', 1) = 'TRUE'
AND c.city_name <> 'Warsaw';

-- zad. 2B
SELECT c.city_name AS miasto
FROM major_cities c
WHERE sdo_within_distance(c.geom, (SELECT geom FROM major_cities WHERE city_name = 'Warsaw'), 'distance=100 unit=km') = 'TRUE'
AND c.city_name <> 'Warsaw';
  
-- zad. 2C
SELECT b.cntry_name AS kraj, c.city_name AS miasto
FROM country_boundaries b
JOIN major_cities c ON sdo_relate(c.geom, b.geom, 'mask=INSIDE+COVEREDBY') = 'TRUE'
WHERE b.cntry_name = 'Slovakia';
  
-- zad. 2D
SELECT b.cntry_name AS panstwo, sdo_geom.sdo_distance(a.geom, b.geom, 0.01, 'unit=km') AS odl
FROM country_boundaries a, country_boundaries b
WHERE a.cntry_name = 'Poland'
AND b.cntry_name <> 'Poland'
AND NOT sdo_relate(b.geom, a.geom, 'mask=TOUCH') = 'TRUE'
ORDER BY odl;

-- zad. 3A
SELECT b.cntry_name, sdo_geom.sdo_length(sdo_geom.sdo_intersection(a.geom, b.geom, 1), 1, 'unit=km') AS odleglosc
FROM country_boundaries a
JOIN country_boundaries b ON sdo_relate(b.geom, a.geom, 'mask=TOUCH') = 'TRUE'
WHERE a.cntry_name = 'Poland' AND b.cntry_name <> 'Poland'
ORDER BY b.cntry_name;

-- zad. 3B
SELECT cb.cntry_name
FROM country_boundaries cb
ORDER BY sdo_geom.sdo_area(cb.geom, 1, 'unit=sq_km') DESC
FETCH FIRST 1 ROW ONLY;

-- zad. 3C
SELECT sdo_geom.sdo_area(sdo_geom.sdo_mbr(sdo_geom.sdo_union(w.geom, l.geom, 1)), 1, 'unit=sq_km') AS sq_km
FROM major_cities w
CROSS JOIN major_cities l
WHERE w.city_name = 'Warsaw'
AND l.city_name = 'Lodz';

-- zad. 3D
SELECT sdo_geom.sdo_union(p.geom, c.geom, 1).sdo_gtype AS gtype
FROM country_boundaries p
JOIN major_cities c ON c.city_name = 'Prague'
WHERE p.cntry_name = 'Poland';

-- zad. 3E
SELECT c.city_name, b.cntry_name
FROM country_boundaries b
JOIN major_cities c ON sdo_relate(c.geom, b.geom, 'mask=INSIDE+COVEREDBY') = 'TRUE'
ORDER BY sdo_geom.sdo_distance(sdo_geom.sdo_centroid(b.geom, 1), c.geom, 1, 'unit=km') ASC
FETCH FIRST 1 ROW ONLY;

-- zad. 3F
SELECT r.name, SUM(sdo_geom.sdo_length(sdo_geom.sdo_intersection(cb.geom, r.geom, 1), 1, 'unit=km')) AS dlugosc
FROM country_boundaries cb
JOIN rivers r ON sdo_relate(r.geom, cb.geom, 'mask=ANYINTERACT') = 'TRUE'
WHERE cb.cntry_name = 'Poland'
GROUP BY r.name
ORDER BY dlugosc DESC;
