/*
Cleaning Dta in SQL Queries
*/

Select * 
From PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Populate Property Adress Data


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNuLL(a.PropertyAddress, b.PropertyAddress)
From portfolioproject..NashvilleHousing a
JOIN portfolioproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioproject..NashvilleHousing a
JOIN portfolioproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into individual columns (Address, City, State)


Select PropertyAddress
From portfolioproject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From portfolioproject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select *
From portfolioproject..NashvilleHousing



Select OwnerAddress
From portfolioproject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From portfolioproject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolioproject..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From portfolioproject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates
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
From portfolioproject..NashvilleHousing
)
DELETE
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


--Delete Unused Columns

Select *
From portfolioproject..NashvilleHousing

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioproject..NashvilleHousing
DROP COLUMN SaleDate