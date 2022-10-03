/*

Cleaning Data in SQL Queries

*/

SELECT * FROM Portfolio_project..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE Portfolio_project..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE Portfolio_project..NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDate, SaleDateConverted
FROM Portfolio_project..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT * 
FROM Portfolio_project..NashvilleHousing


SELECT * 
FROM Portfolio_project..NashvilleHousing
WHERE PropertyAddress IS NULL


SELECT * 
FROM Portfolio_project..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT * 
FROM Portfolio_project..NashvilleHousing A
JOIN Portfolio_project..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_project..NashvilleHousing A
JOIN Portfolio_project..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM Portfolio_project..NashvilleHousing A
JOIN Portfolio_project..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_project..NashvilleHousing A
JOIN Portfolio_project..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Portfolio_project..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Portfolio_project..NashvilleHousing


ALTER TABLE Portfolio_project..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Portfolio_project..NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);



ALTER TABLE Portfolio_project..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Portfolio_project..NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));



SELECT OwnerAddress 
FROM Portfolio_project..NashvilleHousing

SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM Portfolio_project..NashvilleHousing
--WHERE OwnerAddress IS NOT NULL

ALTER TABLE Portfolio_project..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Portfolio_project..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);



ALTER TABLE Portfolio_project..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Portfolio_project..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);



ALTER TABLE Portfolio_project..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Portfolio_project..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM Portfolio_project..NashvilleHousing


UPDATE Portfolio_project..NashvilleHousing
SET 
SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
				END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECt *, 
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
					 UniqueID
					 ) row_num
FROM Portfolio_project..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT * 
FROM Portfolio_project..NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM Portfolio_project..NashvilleHousing

ALTER TABLE Portfolio_project..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict,SaleDate
