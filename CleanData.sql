/* Cleaning Data in SQL */


SELECT * FROM nashville

--------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate
FROM nashville

UPDATE nashville SET SaleDate = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT * FROM nashville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------------------------------------

-- Breaking out Adress into Individual Columns (Address, City, State)

SELECT PropertyAddress FROM nashville

SELECT PropertyAddress,CHARINDEX(',', PropertyAddress),
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) AS ADDRESS
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS CITY
FROM nashville

ALTER TABLE nashville
ADD PropertySplitAddress NVARCHAR(255);
UPDATE nashville SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE nashville
ADD PropertySplitCity NVARCHAR(255);
UPDATE nashville SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

 -------------------------------------------------------------------------------

 SELECT OwnerAddress
 ,PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
 ,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
 ,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
 FROM nashville

 ALTER TABLE nashville
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashville SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE nashville
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashville SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE nashville
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashville SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field
SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END
FROM nashville

UPDATE nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant END

SELECT DISTINCT(SoldAsVacant), COUNT(*)
FROM nashville
GROUP BY SoldAsVacant

------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) Row_num
FROM nashville
--ORDER BY ParcelID
)
SELECT * -- DELETE
FROM RowNumCTE
WHERE Row_num > 1


---------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE nashville
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress


SELECT *
FROM nashville
