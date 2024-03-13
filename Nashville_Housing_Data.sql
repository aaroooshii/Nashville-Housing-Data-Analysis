/*

CLeaning Data in SQL Queries


*/

SELECT * FROM `nashville housing data`.`housing data`;

-- Standardize Data Format

SELECT SaleDate
FROM `nashville housing data`.`housing data`;

USE `nashville housing data`;
ALTER TABLE `housing data`
ADD SaleDateConverted DATE;

USE `nashville housing data`;
SET sql_mode = '';
UPDATE `housing data`
SET SaleDateConverted = str_to_date(SaleDate,'%M %e, %Y'); -- %e is for day of the month

SELECT SaleDate, SaleDateConverted
FROM `nashville housing data`.`housing data`;


-- Populate Property Address data

SELECT *
FROM `nashville housing data`.`housing data`
WHERE PropertyAddress ='';
-- PropertyAddress is same of same pacelid
-- self join

SELECT a.ParcelID, a.PropertyAddress AS AddressA, b.PropertyAddress AS AddressB, COALESCE(a.PropertyAddress, b.PropertyAddress) 
FROM `nashville housing data`.`housing data` a
JOIN `nashville housing data`.`housing data` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress ='';


 
UPDATE `nashville housing data`.`housing data` a
JOIN `nashville housing data`.`housing data` b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress = '';


-- Breaking out PropertyAddress into Address, City, State

SELECT PropertyAddress
FROM `nashville housing data`.`housing data`;


SELECT
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1 ) AS Address  -- -1 NOT TO INCLUDE ,
  , SUBSTRING(PropertyAddress, (LOCATE(',', PropertyAddress)+1), LENGTH(PropertyAddress)) AS Address
FROM
  `nashville housing data`.`housing data`;
  

ALTER TABLE `nashville housing data`.`housing data`
  ADD PropertySplitAddress CHAR(255);

UPDATE `nashville housing data`.`housing data`
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1 );

ALTER TABLE `nashville housing data`.`housing data`
  ADD PropertySplitCity  CHAR(255);

UPDATE `nashville housing data`.`housing data`
SET PropertySplitCity  = SUBSTRING(PropertyAddress, (LOCATE(',', PropertyAddress)+1), LENGTH(PropertyAddress));

SELECT * FROM `nashville housing data`.`housing data`;

SELECT OwnerAddress FROM `nashville housing data`.`housing data`;

-- parsename only works with periods
/*
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM `nashville housing data`.`housing data`;

ALTER TABLE `nashville housing data`.`housing data`
Add OwnerSplitAddress Nvarchar(255);

Update `nashville housing data`.`housing data`
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE `nashville housing data`.`housing data`
Add OwnerSplitCity Nvarchar(255);

Update `nashville housing data`.`housing data`
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE `nashville housing data`.`housing data`
Add OwnerSplitState Nvarchar(255);

Update `nashville housing data`.`housing data`
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From `nashville housing data`.`housing data`
*/

-- change Y and N to yes and no in solid as vacant field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `nashville housing data`.`housing data`
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM `nashville housing data`.`housing data`;


UPDATE `nashville housing data`.`housing data`
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
    ELSE SoldAsVacant
    END;
    
    
-- REMOVE DUPLICATES

/*
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From `nashville housing data`.`housing data`
-- order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1;
-- Order by PropertyAddress

*/

DELETE t1
FROM `nashville housing data`.`housing data` t1
JOIN (
    SELECT ParcelID,
           PropertyAddress,
           SalePrice,
           SaleDate,
           LegalReference,
           UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM `nashville housing data`.`housing data`
) t2
ON t1.ParcelID = t2.ParcelID
   AND t1.PropertyAddress = t2.PropertyAddress
   AND t1.SalePrice = t2.SalePrice
   AND t1.SaleDate = t2.SaleDate
   AND t1.LegalReference = t2.LegalReference
   AND t1.UniqueID = t2.UniqueID
WHERE t2.row_num > 1;


-- DELETE UNUSED COLUMNS
Select *
From `nashville housing data`.`housing data`;


ALTER TABLE `nashville housing data`.`housing data`
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;












