/*
Cleaning Data in SQL Quesries
*/

Select *
From PortfolioProject..NashvilleHousing
------------------------------------------------------------------------------------
--Standardize Date Format
------------------------------------------------------------------------------------

Select SaleDate
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Alter Column SaleDate Date

------------------------------------------------------------------------------------
--Populate Property Address Data
------------------------------------------------------------------------------------

--Investigate the NULL value in the Property Address
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID

--Fill the NULL value with the property address in the same PacelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------
-- Breaking out PropertyAddress into individual columns (Address and City)
------------------------------------------------------------------------------------

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------
-- Breaking out OwnerAddress into individual columns (Address, City, State)
------------------------------------------------------------------------------------

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2) as City
, PARSENAME(REPLACE(OwnerAddress, ',','.'),1) as State
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select *
From PortfolioProject..NashvilleHousing

------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as vacant" field
------------------------------------------------------------------------------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case	when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = Case	when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------------
-- Remove duplicates
------------------------------------------------------------------------------------

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
From PortfolioProject..NashvilleHousing
)

SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

------------------------------------------------------------------------------------
-- Delete unused columns
------------------------------------------------------------------------------------

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress