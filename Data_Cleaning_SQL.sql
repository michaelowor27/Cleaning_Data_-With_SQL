/*

Cleaning Data in SQL Queries

*/
use house_database
Select*
From house_database..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------


--Standardize Date Format
Select SaleDate, CONVERT(Date, SaleDate)
From house_database..NashvilleHousing 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE  NashvilleHousing
SET SaleDateConverted=Convert(Date, SaleDate)



-------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select*
From house_database..NashvilleHousing
--Where propertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.propertyAddress)
From house_database..NashvilleHousing a 
JOIN house_database..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress=ISNULL(a.PropertyAddress, b.propertyAddress)
From house_database..NashvilleHousing a 
JOIN house_database..NashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City State)

--Property Address
Select PropertyAddress
From House_database..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From House_database..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity NVarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Owner Address
Select OwnerAddress
From house_database..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From house_database..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From house_database..NashvilleHousing
Group by SoldAsVacant
Order by SoldAsVacant


Select SoldAsVacant,
	CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	     WHEN SoldAsVacant='N' THEN 'No'
	     ELSE  SoldAsVacant
	END
From house_database..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'Yes'
					   WHEN SoldAsVacant='N' THEN 'No'
					   ELSE  SoldAsVacant
						END
				 From house_database..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS (
Select*,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
				UniqueID
				) row_num

From house_database..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1




---------------------------------------------------------------------------------------------------------------------------------


--Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate