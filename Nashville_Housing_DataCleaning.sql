SELECT TOP 100 *
FROM NashvilleHousing

-- Sale date format
SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate);

--Populate Address
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a 
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Split address, city, state to separate columns
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS address,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS city
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertyAddressONLY nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressONLY = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertyCityONLY nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityONLY = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertyAddress, PropertyAddressONLY, PropertyCityONLY
FROM NashvilleHousing;

--
SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerAddressONLY nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressONLY = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerCityONLY nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCityONLY = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerStateONLY nvarchar(10);

UPDATE NashvilleHousing
SET OwnerStateONLY = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT OwnerAddress, OwnerAddressONLY, OwnerCityONLY, OwnerStateONLY
FROM NashvilleHousing

-- Change Y N to Yes n No
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant ='Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant ='Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END;

SELECT DISTINCT(SoldAsVacant)
FROM NashvilleHousing;

-- Remove duplicates
WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


SELECT *
FROM NashvilleHousing;

WITH RowNumCTE AS(
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Delete unused cols

SELECT *
FROM NashvilleHousing
