-- Database: ru_equipment

CREATE TABLE equipment (
    id SMALLINT UNIQUE,
    model VARCHAR(500),
    state VARCHAR(50),
    photo_link VARCHAR(1000),
    category VARCHAR(50)
)

COPY equipment(id, model, state, photo_link, category)
FROM 'C:\Users\Public\ru_equipment\ru_equipment.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE ukr_reporting (
    date DATE,
    day SMALLINT,
    aircraft SMALLINT,
    helicopter SMALLINT,
    tank SMALLINT,
    APC SMALLINT,
    field_artillery SMALLINT,
    MLRS SMALLINT,
    drone SMALLINT,
    naval_ship SMALLINT,
    anti_aircraft SMALLINT,
    special_equipment SMALLINT,
    auto SMALLINT
)

COPY ukr_reporting(date, day, aircraft, helicopter, tank, APC, field_artillery, MLRS, drone, naval_ship, anti_aircraft, special_equipment, auto)
FROM 'C:\Users\Public\ru_equipment\ukr\russia_losses_equipment.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM equipment

UPDATE equipment
SET state = 
    CASE
        WHEN state = 'repair' THEN 'destroyed'
        WHEN state is NULL THEN 'destroyed'
        WHEN state = 'amaged' THEN 'damaged'
        WHEN state = 'ground' THEN 'destoyed'
        WHEN state = 'incident' THEN 'destroyed in non-combat related incident'
        WHEN state = 'stripped' THEN 'captured'
        ELSE state
    END


DELETE FROM equipment
WHERE id = 7479

UPDATE equipment
SET model = ltrim(model)

ALTER TABLE equipment
ADD type varchar(50)

UPDATE equipment
SET type = category;

ALTER TABLE equipment
ADD estimated_price int

ALTER TABLE equipment
ADD model2 varchar(300)

UPDATE equipment
SET category = 
    CASE
        WHEN category IN ('IFV', 'armoured', 'APC', 'MRAP', 'IMV') THEN 'infantry vehicles'
        WHEN category IN ('towed', 'support', 'self propelled') THEN 'artillery'
        WHEN category IN ('anti aircraft gun', 'self propelled AA', 'surface-to-air missile system') THEN 'air defence system'
        WHEN category IN ('combat UAV', 'reconnaissance UAV') THEN 'drones'
        WHEN category IN ('anti-tank guided missile', 'C2 vehicle', 'engineering', 'jammer', 'radar') THEN 'special equipment'
        ELSE category
    END


UPDATE equipment
SET type = 
    CASE
        WHEN type = 'armoured' THEN 'AFV'
        WHEN type = 'anti-tank guided missile' THEN 'ATGM'
        ELSE type
    END


------------------------------ because of the scraper
WITH ModelsToDelete AS (
  SELECT model
  FROM equipment
  WHERE category = 'special equipment'
  INTERSECT
  SELECT model
  FROM equipment
  WHERE category = 'aircraft'
)
DELETE FROM equipment
WHERE category = 'special equipment'
  AND model IN (SELECT model FROM ModelsToDelete);
------------------------------ because of the scraper



--------------------------------------------------------------------
-------------------------------------------------------------- TANKS
--------------------------------------------------------------------

UPDATE equipment
SET model = 
    CASE
        WHEN model = 'Unknown T-80' THEN 'T-80'
        WHEN model = 'Unknown T-72' THEN 'T-72'
        WHEN model = 'Unknown T-54/55' THEN 'T-55'
        


UPDATE equipment
SET model2 = 
    CASE
        WHEN category = 'tank' AND model LIKE 'T-72%' THEN 'T-72'
        WHEN category = 'tank' AND model LIKE 'T-80%' THEN 'T-80'
        WHEN category = 'tank' AND model LIKE 'T-64%' THEN 'T-64'
        WHEN category = 'tank' AND model LIKE 'T-62%' THEN'T-62'
        WHEN category = 'tank' AND model LIKE 'T-90%' THEN 'T-90'
        WHEN category = 'tank' AND model LIKE 'T-55%' THEN 'T-55'
        WHEN category = 'tank' AND model LIKE 'Unknown tank' THEN 'Unknown tank'
        ELSE model2
    END
    


-- T-72: $1,200,00
-- T-72B3: $3,000,00
-- T-55: $160,000
-- T-80 +variants: $3,000,000
-- T-62 + variants: $300,000
-- T-90 + variants: $4,500,000
-- T-64 + variants: 1100000
-- Unknown tank

UPDATE equipment
SET estimated_price = 
  CASE 
    WHEN model LIKE '%T-72%' AND model NOT IN ('T-72B3 Mk. 2016', 'T-72B3 Mk. 2022', 'T-72B3 Mk. 2014', 'T-72B3') THEN 1200000
    WHEN model IN ('T-72B3 Mk. 2016', 'T-72B3 Mk. 2022', 'T-72B3 Mk. 2014', 'T-72B3') THEN 3000000
    WHEN model LIKE '%T-55%' THEN 160000
    WHEN model = 'Unknown T-54/55' THEN 160000
    WHEN model LIKE '%T-80%' THEN 3000000
    WHEN model LIKE '%T-62%' THEN 300000
    WHEN model LIKE '%T-90%' THEN 4500000
    WHEN model LIKE '%T-64%' THEN 1100000
    ELSE estimated_price
  END;

-- median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'tank')
WHERE category = 'tank'
AND estimated_price IS null
    
----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN tank2 numeric

UPDATE ukr_reporting
SET tank2 = subquery.diff
FROM (
    SELECT date, tank - LAG(tank) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;

                 
---------------------------------------------------------------------------------------------
--------------------------------------------------------------------------- INFANTRY VEHICLES
---------------------------------------------------------------------------------------------

UPDATE equipment
SET model2 = TRIM(SPLIT_PART(model, ' ', 1))
WHERE category = 'infantry vehicles'
AND model NOT IN ('KamAZ Patrol', 'Iveco LMV Rys', 'KamAZ-63968 Typhoon', 'KamAZ-435029 Patrol-A', 'GAZ Tigr', 
                 'GAZ-3937 Vodnik', 'GAZ Tigr-M', 'Vityaz DT-10PM articulated tracked carrier', 'Vityaz DT-30 articulated tracked carrier',
                 '2S1 with ZU-23 AA gun')
                 
                 
UPDATE equipment
SET model2 = 
    CASE
        WHEN model = 'KamAZ Patrol' THEN 'KamAZ Patrol'
        WHEN model = 'Iveco LMV Rys' THEN 'Iveco LMV Rys'
        WHEN model = 'KamAZ-63968 Typhoon' THEN 'KamAZ Typhoon' 
        WHEN model = 'KamAZ-435029 Patrol-A' THEN 'KamAZ Patrol'
        WHEN model = 'GAZ Tigr' THEN 'GAZ Tigr' 
        WHEN model = 'GAZ-3937 Vodnik' THEN 'GAZ Vodnik'
        WHEN model = 'GAZ Tigr-M' THEN 'GAZ Tigr-M'
        WHEN model = 'Vityaz DT-10PM articulated tracked carrier' THEN 'Vityaz DT-10PM'
        WHEN model = 'Vityaz DT-30 articulated tracked carrier' THEN 'Vityaz DT-30'
        WHEN model = '2S1 with ZU-23 AA gun' THEN '2S1 with ZU-23 AA gun'
        WHEN model = 'Unknown' THEN 'Uknown infantry vehicle'
        ELSE model2
     END


-- BMP-2: 300000
-- BMP-3: 1100000
-- KamAZ Patrol: 193000
-- K-53949 Typhoon-K: 1000000
-- MT-LB + variants: 154000
-- AMN-590951: 160000
-- BTR-70 + variants: 57000
-- BTR-MDM Rakushka: 1000000
-- BTR-82A(M): 1400000
-- Iveco LMV Rys: 560000
-- BTR-D: 400000
-- BRDM-2RKhb chemical reconnaissance vehicle: 800000
-- KamAZ-63968 Typhoon: 1000000
-- BMP-1(P): 600000
-- KamAZ-435029 Patrol-A: 193000
-- GAZ Tigr: 160000
-- Unknown BTR-D/BMD-2: 400000
-- GAZ-3937 Vodnik: 160000
-- GAZ Tigr-M: 160000 
-- BTR-80 with 57mm UB-32 unguided aircraft rocket pods: 400000
-- BMM-80 ambulance: 40000
-- BMP-3 688M sb. 3KDZ: 3200000
-- BMD-2: 300000
-- BMO-T: 388000
-- BMP-1AM: 200000
-- Unknown BTR-80/BTR-82A: 1300000
-- BTR-80: 400000
-- K-53949 Linza: 160000
-- Unknown BMP-1/2: 300000
-- BMD-4M: 1000000
-- BMPT Terminator: 1750000

UPDATE equipment
SET estimated_price = 
  CASE
    WHEN model LIKE '%BMP-2%' THEN 300000
    WHEN model = 'BMP-3' THEN 1100000
    WHEN model = 'KamAZ Patrol' THEN 193000
    WHEN model = 'K-53949 Typhoon-K' THEN 1000000
    WHEN model LIKE '%MT-LB%' THEN 700000
    WHEN model = 'MN-590951' THEN 160000
    WHEN model LIKE '%BTR-70%' THEN 57000
    WHEN model = 'BTR-MDM Rakushka' THEN 1000000
    WHEN model = 'BTR-82A(M)' THEN 1400000
    WHEN model = 'Iveco LMV Rys' THEN 560000
    WHEN model = 'BTR-D' THEN 400000
    WHEN model = 'BRDM-2RKhb chemical reconnaissance vehicle' THEN 800000
    WHEN model = 'KamAZ-63968 Typhoon' THEN 1000000
    WHEN model = 'BMP-1(P)' THEN 600000
    WHEN model = 'KamAZ-435029 Patrol-A' THEN 193000
    WHEN model = 'GAZ Tigr' THEN 160000
    WHEN model = 'Unknown BTR-D/BMD-2' THEN 400000
    WHEN model = 'GAZ-3937 Vodnik' THEN 130000
    WHEN model = 'GAZ Tigr-M' THEN 160000
    WHEN model = 'BTR-80 with 57mm UB-32 unguided aircraft rocket pods' THEN 400000
    WHEN model = 'BMM-80 ambulance' THEN 40000
    WHEN model = 'BMP-3 688M sb. 3KDZ' THEN 3200000
    WHEN model = 'BMD-2' THEN 300000
    WHEN model = 'BMO-T' THEN 388000
    WHEN model = 'BMP-1AM' THEN 350000
    WHEN model = 'Unknown BTR-80/BTR-82A' THEN 1300000
    WHEN model = 'BTR-80' THEN 400000
    WHEN model = 'K-53949 Linza' THEN 160000
    WHEN model = 'Unknown BMP-1/2' THEN 300000
    WHEN model = 'BMD-4M' THEN 1000000
    WHEN model = 'BMPT Terminator' THEN 1750000
    ELSE estimated_price 
  END;


-- median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'infantry vehicles')
WHERE category = 'infantry vehicles'
AND estimated_price IS null


----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN apc2 numeric

UPDATE ukr_reporting
SET apc2 = subquery.diff
FROM (
    SELECT date, apc - LAG(apc) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;

---------------------------------------------------------------------------
------------------------------------------------------------------ AIRCRAFT
---------------------------------------------------------------------------

UPDATE equipment
SET model2 = TRIM(SPLIT_PART(model, ' ', 1))
WHERE category = 'aircraft'

UPDATE equipment
SET model2 = 
    CASE
        WHEN model2 like 'Su-24%' THEN 'Su-24'
        WHEN model2 like 'Su-34%' THEN 'Su-34'
        ELSE model2
   END


UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model LIKE 'An-26%' THEN 740000
        WHEN model LIKE 'Il-22%' THEN 500000 -- the minimum possible price (not using median becaues this are really old planes)
        WHEN model LIKE 'Il-76%' THEN 50000000
        WHEN model LIKE 'MiG-31BM%' THEN 33200000
        WHEN model LIKE 'Su-24%' THEN 24000000
        WHEN model LIKE 'Su-25%'THEN 11000000
        WHEN model LIKE 'Su-30%' THEN 38000000
        WHEN model LIKE 'Su-34%' THEN 36000000
        WHEN model LIKE 'Su-35%' THEN 43000000
        WHEN model LIKE 'Tu-22M3%' THEN 40000000
        WHEN model LIKE 'Tu-95MS%' THEN 26000000
        WHEN category = 'aircraft' AND model LIKE 'Unknown%' THEN 500000 -- the minimum possible price (not using median becaues this are really old planes)
        ELSE estimated_price
    END

----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN aircraft2 numeric

UPDATE ukr_reporting
SET aircraft2 = subquery.diff
FROM (
    SELECT date, aircraft - LAG(aircraft) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;
-----------------------------------------------------------------------------
----------------------------------------------------------------- HELICOPTERS
-----------------------------------------------------------------------------
UPDATE equipment
SET model2 = TRIM(SPLIT_PART(model, ' ', 1))
WHERE category = 'helicopter'

UPDATE equipment
SET model2 = 'Mi-24'
WHERE model2 like 'Mi-24%'

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model LIKE 'Ka-52%' THEN 16000000
        WHEN model like 'Mi-24%' THEN 12500000
        WHEN model like 'Mi-28%' THEN 18000000
        WHEN model like 'Mi-35%' THEN 36000000
        WHEN model like 'Mi-8%' THEN 9000000
        ELSE estimated_price
    END
    
-- median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'helicopter')
WHERE category = 'helicopter'
AND estimated_price IS null


----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN helicopter2 numeric

UPDATE ukr_reporting
SET helicopter2 = subquery.diff
FROM (
    SELECT date, helicopter - LAG(helicopter) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;
-----------------------------------------------------------------------------
------------------------------------------------------------------------ NAVY
-----------------------------------------------------------------------------

UPDATE equipment
SET model2 = 
    CASE
        WHEN model LIKE 'Project 02510%' THEN 'High-speed assault boat'
        WHEN model LIKE 'Project 03160%' THEN 'Raptor-class patrol boat'
        WHEN model LIKE 'Project 1164%' THEN 'Missile cruiser Moskva' 
        WHEN model LIKE 'Project 1171%' THEN 'Tapir-class landing ship'
        WHEN model LIKE 'Project 11770%' THEN 'Serna-class landing craft' 
        WHEN model LIKE 'Project 22870%' THEN 'Rescue tug'
        WHEN model LIKE 'Project 266M%' THEN 'Natya-class minesweeper'
        WHEN model LIKE 'Project 636.3%' THEN 'Kilo-class submarine'
        WHEN model LIKE 'Project 640%' THEN 'Small patrol boat'
        WHEN model LIKE 'Project 775%' THEN 'Ropucha-class landing ship'
        ELSE model2
     END

-- Project 02510 BK-16E high-speed assault boat: 12000000
-- Project 03160 Raptor-class patrol boat: 3000000
-- Project 1164 Slava-class guided missile cruiser: 750000000 (Moskva)
-- Project 1171 Tapir-class landing ship: 180000000
-- Project 11770 Serna-class landing craft: 2100000
-- Project 22870 rescue tug ...
-- Project 266M Natya-class minesweeper ...
-- Project 636.3 Improved Kilo-class submarine: 300000000
-- Project 640 small patrol boat: 5000000
-- Project 775 Ropucha-class landing ship: 300000000

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model like 'Project 02510%' then 12000000
        when model like 'Project 03160%' then 3000000
        when model like 'Project 1164%' then 750000000
        when model like 'Project 1171%' then 180000000
        when model like 'Project 11770%' then 2100000
        when model like 'Project 636.3%' then 300000000
        when model like 'Project 640%' then 5000000
        when model like 'Project 775%' then 300000000
        else estimated_price
    END

-- dealing with missing values..median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'navy')
WHERE category = 'navy'
AND estimated_price IS null


----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN navy2 numeric

UPDATE ukr_reporting
SET navy2 = subquery.diff
FROM (
    SELECT date, naval_ship - LAG(naval_ship) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;
-----------------------------------------------------------------------------
----------------------------------------------------------------- AIR DEFENSE
-----------------------------------------------------------------------------
SELECT DISTINCT model FROM equipment
WHERE category = 'air defence system'

SELECT DISTINCT type FROM equipment
WHERE category = 'air defence system'

SELECT DISTINCT model FROM equipment
WHERE type = 'anti aircraft gun'

-- 23mm ZU-23-2: 20000 (based on Mogadishu black market :)) )
-- 57mm AZP S-60: 50000 (based on Libya black market - WWII gun)

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model = '23mm ZU-23-2' THEN 20000
        WHEN model = '57mm AZP S-60' THEN 50000
        ELSE estimated_price
    END
       
SELECT DISTINCT model FROM equipment
WHERE type = 'self propelled AA'

-- 2K22M1 Tunguska: 16000000
-- BTR-ZD Skrezhet: 450000
-- ZSU-23-4 Shilka: 357000

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model = '2K22M1 Tunguska' THEN 16000000
        WHEN model = 'BTR-ZD Skrezhet'THEN 450000
        WHEN model = 'ZSU-23-4 Shilka' THEN 357000
        ELSE estimated_price
    END


SELECT DISTINCT model FROM equipment
WHERE type = 'surface-to-air missile system'

-- 5P85SD/SM (launcher for S-300 PMU(-1)): 150000000
-- 5P85SM2-01 (launcher for S-400): 600000000
-- 5P85T2 (launcher for S-400): 600000000
-- 9A310M1-2 TELAR (for Buk-M1-2): 100000000
-- 9A316 TEL (for Buk-M2): 100000000
-- 9A317 TELAR (for Buk-M2): 100000000
-- 9A317M TELAR (for Buk-M3): 100000000
-- 9A330 TLAR (for 9K330 Tor): 24000000
-- 9A331 TLAR (for 9K331 Tor-M1): 24000000
-- 9A331M TLAR (for 9K332 Tor-M2): 24000000
-- 9A39M1-2 TEL (for Buk-M1-2): 100000000
-- 9A83M2 TELAR (for S-300V4): 150000000
-- 9A84-2 TEL (for S-300V4): 150000000
-- 9K33 Osa: 4000000
-- 9K331MDT TLAR Tor-M2DT: 25000000
-- 9K35 Strela-10: ................
-- Pantsir-S1: 14000000
-- Unknown Buk M1-2/M2/M3 TEL(AR): 100000000
-- Unknown Tor TLAR: 24000000

UPDATE equipment
SET estimated_price =
    CASE
        WHEN model = '5P85SD/SM (launcher for S-300 PMU(-1))' THEN 150000000
        WHEN model = '5P85SM2-01 (launcher for S-400)' THEN 600000000
        WHEN model = '5P85T2 (launcher for S-400)' THEN 600000000
        WHEN model = '9A310M1-2 TELAR (for Buk-M1-2)' THEN 100000000
        WHEN model = '9A316 TEL (for Buk-M2)' THEN 100000000
        WHEN model = '9A317 TELAR (for Buk-M2)' THEN 100000000
        WHEN model = '9A317M TELAR (for Buk-M3)' THEN 100000000
        WHEN model = '9A330 TLAR (for 9K330 Tor)' THEN 24000000
        WHEN model = '9A331 TLAR (for 9K331 Tor-M1)' THEN 24000000
        WHEN model = '9A331M TLAR (for 9K332 Tor-M2)' THEN 24000000
        WHEN model = '9A39M1-2 TEL (for Buk-M1-2)' THEN 100000000
        WHEN model = '9A83M2 TELAR (for S-300V4)' THEN 150000000
        WHEN model = '9A84-2 TEL (for S-300V4)' THEN 150000000
        WHEN model = '9K33 Osa' THEN 4000000
        WHEN model = '9K331MDT TLAR Tor-M2DT' THEN 25000000
        WHEN model = 'Pantsir-S1' THEN 14000000
        WHEN model = 'Unknown Buk M1-2/M2/M3 TEL(AR)' THEN 100000000
        WHEN model = 'Unknown Tor TLAR' THEN 24000000
        ELSE estimated_price
    END


UPDATE equipment
SET model2 = 
    CASE
        WHEN model LIKE '%S-300%' THEN 'S-300'
        WHEN model LIKE '%S-400%' THEN 'S-400'
        WHEN model LIKE '%Buk%' THEN 'Buk'
        WHEN model LIKE '%Tor%' THEN 'Tor'
        WHEN model = '9K33 Osa' THEN 'Osa'
        WHEN model = 'Pantsir-S1' THEN 'Pantsir'
        WHEN model = '2K22M1 Tunguska' THEN 'Tunguska'
        WHEN model = 'BTR-ZD Skrezhet' THEN 'Skrezhet'
        WHEN model = 'ZSU-23-4 Shilka' THEN 'Shilka'
        WHEN model = '23mm ZU-23-2' THEN 'ZU-23-2'
        WHEN model = '57mm AZP S-60' THEN 'AZP S-60'
        WHEN model = '9K35 Strela-10' THEN 'Strela-10'
        ELSE model2
    END

-- dealing with missing values..median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE type = 'surface-to-air missile system')
WHERE type = 'surface-to-air missile system'
AND estimated_price IS null


----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN anti_aircraft2 numeric

UPDATE ukr_reporting
SET anti_aircraft2 = subquery.diff
FROM (
    SELECT date, anti_aircraft - LAG(anti_aircraft) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;
-----------------------------------------------------------------------------
------------------------------------------------------------------- ARTILLERY
-----------------------------------------------------------------------------

UPDATE equipment
SET model2 = model
WHERE category = 'artillery'

UPDATE equipment
SET model2 = 'artillery support vehicle'
WHERE model2 IN ('1V110 BM-21 Grad battery command vehicle', '9T452 transporter-loader (for BM-27 Uragan MRL)', 
                '1V13(M) battery fire control center', '1V15M fire control and observation vehicle', 'PRP-4(M) artillery reconnaissance vehicle', 
                '1V16 battalion fire direction vehicle', '1V1003 command and observation vehicle (for 1V198 artillery fire control system)', 
                'TZM-T reloader vehicle (for TOS-1A)', 'PRP-4A Argus artillery reconnaissance vehicle', '1V14 battery command and forward observer vehicle', 
                'TZM 9T234-2 transporter-loader (for BM-30 Smerch)', '1V119 artillery fire direction vehicle')


UPDATE equipment
SET model2 = 
    CASE
        WHEN model = '82mm 2B9 Vasilek automatic gun mortar' THEN '82mm automatic mortar'
        WHEN model = '152mm 2A36 Giatsint-B field-gun' THEN '152mm 2A36 Giatsint-B'
        WHEN model LIKE '%Klyon-1%' THEN 'artillery support vehicle'
        ELSE model2
     END

-- 120mm 2S34 Khosta: ..
-- 1V110 BM-21 Grad battery command vehicle: 600000
-- 9T452 transporter-loader (for BM-27 Uragan MRL): ...
-- 120mm 2S9 Nona: 300000
-- 1V13(M) battery fire control center: 600000
-- 122mm 2S1 Gvozdika: ...
-- 82mm 2B9 Vasilek automatic gun mortar: ...
-- 1V15M fire control and observation vehicle: 600000
-- 152mm 2A65 Msta-B howitzer: 1500000
-- PRP-4(M) artillery reconnaissance vehicle: 600000
-- 152mm 2S5 Giatsint-S: 3500000
-- 152mm 2S19 Msta-S: 3500000
-- 1V16 battalion fire direction vehicle: 600000
-- 240mm 2S4 Tyulpan: 1700000
-- 122mm D-30 howitzer: 54000
-- 1V1003 command and observation vehicle (for 1V198 artillery fire control system): 600000
-- Unknown towed artillery: ...
-- 120mm 2B16 Nona-K gun mortar: ...
-- TZM-T reloader vehicle (for TOS-1A): ...
-- 120mm 2S23 Nona-SVK: 750000
-- 1V18 'Klyon-1' artillery command and forward observer vehicle: 600000
-- 152mm 2A36 Giatsint-B field-gun: 800000
-- 152mm 2S3(M) Akatsiya: 1600000
-- PRP-4A Argus artillery reconnaissance vehicle: 600000
-- 203mm 2S7(M) Pion/Malka: 3000000
-- 100mm MT-12 anti-tank gun: 54000
-- 1V14 battery command and forward observer vehicle: 600000
-- TZM 9T234-2 transporter-loader (for BM-30 Smerch): ...
-- 152mm D-20 gun-howitzer: ...
-- 152mm 2S33 Msta-SM2: 3500000
-- 1V119 artillery fire direction vehicle: 600000
-- Unknown SPG: 1500000

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model = '1V110 BM-21 Grad battery command vehicle' THEN  600000
        WHEN model = '120mm 2S9 Nona' THEN 300000
        WHEN model = '1V13(M) battery fire control center' THEN 600000
        WHEN model = '1V15M fire control and observation vehicle' THEN 600000
        WHEN model = '152mm 2A65 Msta-B howitzer' THEN 1500000
        WHEN model = 'PRP-4(M) artillery reconnaissance vehicle' THEN 600000
        WHEN model = '152mm 2S5 Giatsint-S' THEN 3500000
        WHEN model = '152mm 2S19 Msta-S' THEN 3500000
        WHEN model = '1V16 battalion fire direction vehicle' THEN 600000
        WHEN model = '240mm 2S4 Tyulpan' THEN 1700000
        WHEN model = '122mm D-30 howitzer' THEN 54000
        WHEN model = '1V1003 command and observation vehicle (for 1V198 artillery fire control system)' THEN 600000
        WHEN model = '120mm 2S23 Nona-SVK' THEN 750000
        WHEN model LIKE '%Klyon-1%' THEN 600000
        WHEN model = '152mm 2A36 Giatsint-B field-gun' THEN 800000
        WHEN model = '152mm 2S3(M) Akatsiya' THEN 1600000
        WHEN model = 'PRP-4A Argus artillery reconnaissance vehicle' THEN 600000
        WHEN model = '203mm 2S7(M) Pion/Malka' THEN 3000000
        WHEN model = '100mm MT-12 anti-tank gun' THEN 54000
        WHEN model = '1V14 battery command and forward observer vehicle' THEN 600000
        WHEN model = '152mm 2S33 Msta-SM2' THEN 3500000
        WHEN model = '1V119 artillery fire direction vehicle' THEN 600000
        WHEN model = 'Unknown SPG' THEN 1500000
        ELSE estimated_price
    END
        
-- dealing with missing values..median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'artillery')
WHERE category = 'artillery'
AND estimated_price IS null


----- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN field_artillery2 numeric

UPDATE ukr_reporting
SET field_artillery2 = subquery.diff
FROM (
    SELECT date, field_artillery - LAG(field_artillery) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;

-----------------------------------------------------------------------------
------------------------------------------------------------------------ AUTO
-----------------------------------------------------------------------------

UPDATE equipment
SET model = 'Unknown vehicle'
WHERE model LIKE '(Unknown)%'

UPDATE equipment
SET model2 = model
WHERE category = 'auto'

UPDATE equipment
SET model2 = 
    CASE
        WHEN model = '9T217 transloader (for 9K33 Osa)' THEN '9T217 transloader'
        WHEN model = 'UAZ-23632 pickup truck' THEN 'UAZ-23632'
        WHEN model = 'UAZ-23632-148-64 armed pickup truck' THEN 'UAZ-23632'
        WHEN model = 'Ural-542301 tank transporter' THEN 'Ural-542301'
        WHEN model = 'Truck-based support equipment (for S-400)' THEN 'S-400 support'
        WHEN model = 'KamAZ-5350 with armoured cabin' THEN 'KamAZ-5350'
        WHEN model = 'KamAZ-6350 8x8 artillery tractor' THEN 'KamAZ-6350 8x8'
        WHEN model = 'KamAZ with MM-501 armoured cabin' THEN 'KamAZ 6x6'
        WHEN model = 'Ural-63704-0010 Tornado-U' THEN 'Ural-63704'
        WHEN model = '2F77M transloading vehicle for 2K22M Tunguska-M' THEN '2F77M transloader'
        WHEN model = '9T244 transloader (for 9A330/1 Tor)' THEN '9T244 transloader'
        ELSE model2
    END
 
-- Ural-4320: 20000
-- MAZ TZ-500 tanker: 
-- UAZ-452 van: 5000
-- GAZ-3308: 2500
-- (Unknown) truck:
-- KamAZ 8x8 tanker: 30000
-- Ural-5323: 20000
-- KamAZ 'Gorets' 3958: 30000
-- UAZ-515195 'Esaul': 25000
-- KamAZ 4x4: 15000
-- Ural-4320 tanker: 15000
-- KrAZ-255B: 6000
-- ZiL-131 tanker: 8000
-- UAZ-394511 ‘Esaul’: 40000
-- ZiL-131: 8000
-- UAZ-31514: 5000
-- Ural Avtozaks: 10000
-- Ural-63501-AT: 20000
-- UAZ-3303: 5000
-- KamAZ 6x6: 30000
-- LuAZ-969: 5000
-- 9T217 transloader (for 9K33 Osa): ...
-- Ural-43206: 20000
-- KrAZ-255B tanker: 15000
-- Ural-375D: 6000
-- GAZ-66: 6000
-- UAZ-3151: 5000
-- UAZ-23632 pickup truck: 12000
-- UAZ-23632-148-64 armed pickup truck: 12000
-- GAZ Sobol: 2000
-- KamAZ 6x4: 25000
-- Ural-542301 tank transporter: ...
-- KamAZ 8x8: 30000
-- Truck-based support equipment (for S-400): ...
-- KamAZ-5350 with armoured cabin: 30000
-- KrAZ-260 tanker: 15000
-- Ural-375D tanker: 6000
-- KamAZ-6350 8x8 artillery tractor: 30000
-- GAZ-51: 3500
-- KamAZ Avtozaks: 25000
-- KamAZ with MM-501 armoured cabin: 30000
-- MAZ 531605 tanker: 15000
-- Ural-63704-0010 Tornado-U: 20000
-- KamAZ 6x6 tanker: 30000
-- Ural Federal: 20000
-- Unknown fuel tanker: ...
-- UAZ-469 jeep: 5000
-- KamAZ tank low-loader: 30000
-- UAZ-39094: 5000
-- 2F77M transloading vehicle for 2K22M Tunguska-M: ...
-- UAZ Patriot jeep: 12500
-- 9T244 transloader (for 9A330/1 Tor) ...
-- (Unknown) vehicle: ..

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model = 'Ural-4320' THEN 20000
        WHEN model = 'UAZ-452 van' THEN 5000
        WHEN model = 'GAZ-3308' THEN 2500
        WHEN model = 'KamAZ 8x8 tanker' THEN 30000
        WHEN model = 'Ural-5323' THEN 20000
        WHEN model LIKE 'KamAZ%3958' THEN 30000
        WHEN model LIKE 'UAZ-515195%' THEN 25000
        WHEN model = 'KamAZ 4x4' THEN 15000
        WHEN model = 'Ural-4320 tanker' THEN 15000
        WHEN model = 'KrAZ-255B' THEN 6000
        WHEN model = 'ZiL-131 tanker' THEN 8000
        WHEN model LIKE 'UAZ-394511%' THEN 40000
        WHEN model = 'ZiL-131' THEN 8000
        WHEN model = 'UAZ-31514' THEN 5000
        WHEN model = 'Ural Avtozaks' THEN 10000
        WHEN model = 'Ural-63501-AT' THEN 20000
        WHEN model = 'UAZ-3303' THEN 5000
        WHEN model = 'KamAZ 6x6' THEN 30000
        WHEN model = 'LuAZ-969' THEN 5000
        WHEN model = 'Ural-43206' THEN 20000
        WHEN model = 'KrAZ-255B tanker' THEN 15000
        WHEN model = 'Ural-375D' THEN 6000
        WHEN model = 'GAZ-66' THEN 6000
        WHEN model = 'UAZ-3151' THEN 5000
        WHEN model = 'UAZ-23632 pickup truck' THEN 12000
        WHEN model = 'UAZ-23632-148-64 armed pickup truck' THEN  12000
        WHEN model = 'GAZ Sobol' THEN 2000
        WHEN model = 'KamAZ 6x4' THEN 2500
        WHEN model = 'KamAZ 8x8' THEN 30000
        WHEN model = 'KamAZ-5350 with armoured cabin' THEN 30000
        WHEN model = 'KrAZ-260 tanker' THEN 15000
        WHEN model = 'Ural-375D tanker' THEN 6000
        WHEN model = 'KamAZ-6350 8x8 artillery tractor' THEN 30000
        WHEN model = 'GAZ-51' THEN 3500
        WHEN model = 'KamAZ Avtozaks' THEN 25000
        WHEN model = 'KamAZ with MM-501 armoured cabin' THEN 30000
        WHEN model = 'MAZ 531605 tanker' THEN 15000
        WHEN model = 'Ural-63704-0010 Tornado-U' THEN 20000
        WHEN model = 'KamAZ 6x6 tanker' THEN 30000
        WHEN model = 'Ural Federal' THEN 20000
        WHEN model = 'UAZ-469 jeep' THEN 5000
        WHEN model = 'KamAZ tank low-loader' THEN 30000
        WHEN model = 'UAZ-39094' THEN 5000
        WHEN model = 'UAZ Patriot jeep' THEN 12500
        ELSE estimated_price
    END

-- dealing with missing values..median
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'auto')
WHERE category = 'auto'
AND estimated_price IS null


----- ukr_reporting
ALTER TABLE ukr_reporting
ADD COLUMN auto2 numeric

UPDATE ukr_reporting
SET auto2 = subquery.diff
FROM (
    SELECT date, auto - LAG(auto) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;
-----------------------------------------------------------------------------
-- MLRS
-----------------------------------------------------------------------------

SELECT DISTINCT model FROM equipment
WHERE category = 'MLRS'

UPDATE equipment
SET model2 = model
WHERE category = 'MLRS'

UPDATE equipment
SET model2 = 'MT-LB with 140mm'
WHERE model = 'MT-LB with 140mm Ogon-18 MRLS'

-- 300mm BM-30 Smerch: 12000000
-- TOS-1A: 6500000
-- 122mm 2B26 Grad-K: 165000 .. based on the price of its czech version of RM-70 Vampir
-- 122mm BM-21 Grad: 165000
-- 122mm 2B17 Tornado-G: 450000
-- MT-LB with 140mm Ogon-18 MRLS: 154000
-- Grad-1: 165000
-- 220mm BM-27 Uragan: 250000

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model = '300mm BM-30 Smerch' THEN 12000000
        WHEN model = 'TOS-1A' THEN 6500000
        WHEN model = '122mm 2B26 Grad-K' THEN 165000
        WHEN model = '122mm 2B17 Tornado-G' THEN 450000
        WHEN model = 'MT-LB with 140mm Ogon-18 MRLS' THEN 154000
        WHEN model = 'Grad-1' THEN 165000
        WHEN model = '220mm BM-27 Uragan' THEN 250000
        ELSE estimated_price
    END

UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'MLRS')
WHERE category = 'MLRS'
AND estimated_price IS null


---- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN mlrs2 numeric

UPDATE ukr_reporting
SET mlrs2 = subquery.diff
FROM (
    SELECT date, mlrs - LAG(mlrs) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;

-----------------------------------------------------------------------------
---------------------------------------------------------------------- DRONES
-----------------------------------------------------------------------------

-- 'Orlan-20' ''Kartograf'': 120000
-- Eleron-10: ...
-- Eleron-3: 100000
-- Eleron-3SV: 150000
-- Eleron T-16: 100000
-- Eleron T28ME: 100000
-- Forpost: 6000000
-- Forpost-RU: 6000000
-- Granat%: ...
-- Grifon-12:...
-- Korsar: ...
-- Lastochka-M: ...
-- Merlin-VR: ...
-- Mohajer-6: 3000000
-- Orion: 5000000
-- Orlan-10%: 100000
-- Orlan-30: 120000
-- Supercam S150: ...
-- ZALA%: 35000

UPDATE equipment
SET model2 = model
WHERE category = 'drones'

UPDATE equipment
SET model2 = 'Orlan Kartograf'
WHERE model LIKE '%Kartograf%'

UPDATE equipment
SET estimated_price = 
    CASE
        WHEN model LIKE '%Kartograf%' THEN 120000
        WHEN model = 'Eleron-3' THEN 100000
        WHEN model = 'Eleron-3SV' THEN 150000
        WHEN model = 'Eleron T-16' THEN 100000
        WHEN model = 'Eleron T28ME' THEN 100000
        WHEN model = 'Forpost' THEN 6000000
        WHEN model = 'Forpost-RU' THEN 6000000
        WHEN model = 'Mohajer-6' THEN 3000000
        WHEN model = 'Orion' THEN 5000000
        WHEN model LIKE 'Orlan-10%' THEN 100000
        WHEN model = 'Orlan-30' THEN 120000
        WHEN model LIKE 'ZALA%' THEN 35000
        ELSE estimated_price
     END
     
UPDATE equipment
SET estimated_price = 
(SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY estimated_price) AS median
FROM equipment
WHERE category = 'drones')
WHERE category = 'drones'
AND estimated_price IS null



---- ukr_reporting table
ALTER TABLE ukr_reporting
ADD COLUMN drone2 numeric

UPDATE ukr_reporting
SET drone2 = subquery.diff
FROM (
    SELECT date, drone - LAG(drone) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;



----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
---- ukr_reporting table -----> special equipment
ALTER TABLE ukr_reporting
ADD COLUMN special_equipment2 numeric

UPDATE ukr_reporting
SET special_equipment2 = subquery.diff
FROM (
    SELECT date, special_equipment - LAG(special_equipment) OVER (ORDER BY date) AS diff
    FROM ukr_reporting
) AS subquery
WHERE ukr_reporting.date = subquery.date;

UPDATE ukr_reporting
SET special_equipment2 = 0
WHERE special_equipment2 IS null


UPDATE equipment
SET category = 
    CASE
        WHEN category = 'special equipment' THEN 'special equipments'
        WHEN category = 'auto' THEN 'trucks and vehicles'
        WHEN category = 'air defense system' THEN 'air defense'
        WHEN category = 'helicopter' THEN 'helicopters'
        WHEN category = 'tank' THEN 'tanks'
        ELSE category
    END
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
