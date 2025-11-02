/*

Cleaning Data in SQL Queries

*/



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE housing.nashville_housing
MODIFY COLUMN SaleDate date;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (each ParcelID leads to its own address so if we have the parcelID we can populate nulls with the right address)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From housing.nashville_housing a
JOIN housing.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

SET SQL_SAFE_UPDATES = 0;

UPDATE housing.nashville_housing a
JOIN housing.nashville_housing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL
AND a.UniqueID IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS PropertyStreetAddress,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS PropertyCityAddress
FROM housing.nashville_housing;

ALTER TABLE housing.nashville_housing
Add PropertyStreetAddress Nvarchar(255);

Update housing.nashville_housing
SET PropertyStreetAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE housing.nashville_housing
Add PropertyCityAddress Nvarchar(255);

Update housing.nashville_housing
SET PropertyCityAddress = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 2), ',', -1));

ALTER TABLE housing.nashville_housing
Add OwnerStreetAddress Nvarchar(255);

Update housing.nashville_housing
SET OwnerStreetAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1));


ALTER TABLE housing.nashville_housing
Add OwnerCityAddress Nvarchar(255);

Update housing.nashville_housing
SET OwnerCityAddress = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));


ALTER TABLE housing.nashville_housing
Add OwnerStateAddress Nvarchar(255);

Update housing.nashville_housing
SET OwnerStateAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE housing.nashville_housing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'y' THEN 'yes'
    WHEN SoldAsVacant = 'n' THEN 'no'
    ELSE SoldAsVacant
END;


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (ignoring unique ID. If parcel ID, saleDate, property address, the sale price are the same then it's the same data)
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY a.ParcelID,
				 a.PropertyAddress,
				 a.SalePrice,
				 a.SaleDate,
				 a.LegalReference
				 ORDER BY
					a.UniqueID
					) row_num

From housing.nashville_housing as a
order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;







---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE housing.nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;


