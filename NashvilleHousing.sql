USE [PortfollioProject]

/*

Cleaning Data in SQL Queries

*/
select *
from [dbo].[NashvilleHousing]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select SaleDate, CONVERT(Date, SaleDate)
from [dbo].[NashvilleHousing]

Update [dbo].[NashvilleHousing]
SET SaleDate = Convert(Date, SaleDate)

ALTER TABLE [dbo].[NashvilleHousing]
Add SaleDateConverted Date;

Update [dbo].[NashvilleHousing]
SET SaleDateConverted = Convert(Date, SaleDate)

select SaleDateConverted, CONVERT(Date, SaleDate)
from [dbo].[NashvilleHousing]

-------------------------------------------------------------------------------------------------------------

-- Populate Property Address date
Select *
From [dbo].[NashvilleHousing]
-- Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID<>b.UniqueID 
Where a.PropertyAddress is Null

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID<>b.UniqueID 
Where a.PropertyAddress is Null



-----------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Column(Address, City, State)

Select PropertyAddress
From [dbo].[NashvilleHousing]

 SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as BeforeComma,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) as AfterComma
FROM [dbo].[NashvilleHousing];


ALTER Table [dbo].[NashvilleHousing]
Add PropertySplitAddress Nvarchar(220);

Update [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER Table [dbo].[NashvilleHousing]
Add PropertySplitCity Nvarchar(220);

Update [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

SELECT *
FROM [dbo].[NashvilleHousing]

-- Use Different Method to split : 'PARSENAME'

SELECT OwnerAddress
FROM [dbo].[NashvilleHousing]

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [dbo].[NashvilleHousing]



ALTER Table [dbo].[NashvilleHousing]
Add OwnerSplitAddress Nvarchar(220);

Update [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER Table [dbo].[NashvilleHousing]
Add OwnerSplitCity Nvarchar(220);

Update [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER Table [dbo].[NashvilleHousing]
Add OwnerSplitState Nvarchar(220);

Update [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)





-----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in' Sold as Vacant' field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From [dbo].[NashvilleHousing]
Group by SoldAsVacant
Order by 2


SELECT  SoldAsVacant
 , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM [dbo].[NashvilleHousing]


Update [dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

----------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From [dbo].[NashvilleHousing]
)
SELECT *
FROM RowNumCTE
Where row_num>1
Order by PropertyAddress



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From [dbo].[NashvilleHousing]
)
DELETE
FROM RowNumCTE
Where row_num>1


------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From [dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN SaleDate
