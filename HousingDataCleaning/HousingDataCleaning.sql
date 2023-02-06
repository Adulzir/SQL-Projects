/*
Cleaning Data in SQL
*/


SELECT *
FROM Housing.NashvilleHousing;
-- ----------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(SaleDate, Date)
FROM Housing.NashvilleHousing;

-- Add Column to table
ALTER TABLE Housing.NashvilleHousing
ADD SaleDateConverted Date;

-- Update Table to add content to new column
SET SQL_SAFE_UPDATES = 0; -- Exit MYSQL Safe Mode to update table
UPDATE Housing.NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate, Date);
SET SQL_SAFE_UPDATES = 1; -- Return to Safe Mode Default

-- ----------------------------------------------------------------------------------------------------------------
-- Populate property address date
SELECT *
FROM Housing.NashvilleHousing
-- WHERE PropertyAddress is null -- Sanity check
ORDER BY ParcelID;

UPDATE Housing.NashvilleHousing as a, housing.NashvilleHousing as b
SET a.ParcelID = b.ParcelID,
    a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress is null;

-- ----------------------------------------------------------------------------------------------------------------
-- Breaking out address into individual columns (Address, City, State)

-- Cleaning Property Address
ALTER TABLE Housing.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255),
ADD PropertySplitCity Nvarchar(255);

UPDATE Housing.NashvilleHousing
SET NashvilleHousing.PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, (','), 1),
    NashvilleHousing.PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, (','), -1);

-- Cleaning Owner Address
ALTER TABLE Housing.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255),
ADD OwnerSplitCity Nvarchar(255),
ADD OwnerSplitState Nvarchar(255);

UPDATE Housing.NashvilleHousing
SET NashvilleHousing.OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    NashvilleHousing.OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',' ,1),
    NashvilleHousing.OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

-- ----------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE Housing.NashvilleHousing SET SoldAsVacant =
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- ----------------------------------------------------------------------------------------------------------------
-- Remove duplicates

-- Using a CTE table + Inner Join
USE Housing;
WITH RowNumCTE AS(
SELECT UniqueID ,
    ROW_NUMBER() over (
    PARTITION BY ParcelID,
                PropertyAddress,
                SaleDate,
                LegalReference
        ORDER BY
            UniqueID
        ) as row_num
FROM Housing.NashvilleHousing
)
/*
SELECT *
FROM RowNumCTE
WHERE row_num > 1;
*/
DELETE hd
FROM Housing.NashvilleHousing hd INNER JOIN RowNumCTE r ON hd.UniqueID = r.UniqueID
WHERE row_num > 1;

-- ----------------------------------------------------------------------------------------------------------------
-- Delete unused columns

ALTER TABLE Housing.NashvilleHousing
DROP SaleDate,
DROP OwnerAddress,
DROP TaxDistrict,
DROP PropertyAddress;





