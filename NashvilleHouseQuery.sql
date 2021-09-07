--Data Cleaning Project

-- Cleaning Data in SQL Queries



SELECT *
FROM 
	PortfolioProject.dbo.NashvilleHousing




----------------------------------------------------------------------------------------



--Standardize Date 

ALTER TABLE 
	NashvilleHousing
ADD 
	SaleDateConverted Date;

UPDATE 
	NashvilleHousing
SET 
	SaleDateConverted = CONVERT(Date, SaleDate);

-- Checking update

SELECT
	SaleDateConverted
FROM
	NashvilleHousing;


----------------------------------------------------------------------------------------


--Populate Property Address date

--Checking how many null values
SELECT
	PropertyAddress
FROM 
	PortfolioProject.dbo.NashvilleHousing
WHERE
	PropertyAddress is Null

-- Checking to verify ParcelIDs have the same address to replace null values.
SELECT *
FROM 
	NashvilleHousing
ORDER BY 
	ParcelID

-- Self Joining Table 

SELECT 
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
FROM 
	PortfolioProject.dbo.NashvilleHousing a
JOIN 
	PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is NULL


--  Updating Table to remove nulls and replace them with the correct property address

UPDATE
	a
SET 
	PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
FROM 
	PortfolioProject.dbo.NashvilleHousing a
JOIN 
	PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE 
	a.PropertyAddress is NULL




----------------------------------------------------------------------------------------


-- Breaking out Address into Individual Colums (Address, City, State) 


SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM 
	PortfolioProject.dbo.NashvilleHousing




-- Creating New Columns for Split Address (1) 

ALTER TABLE 
	NashvilleHousing
ADD 
	PropertySplitAddress NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);




-- Creating New Columns for Split City (2) 

ALTER TABLE 
	NashvilleHousing
ADD 
	PropertySplitCity NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));




-- Checking to make sure new columns are created
Select*
From NashvilleHousing



-- Updating Owner Address with a different method

SELECT 
	OwnerAddress
FROM 
	PortfolioProject.dbo.NashvilleHousing

SELECT
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 3),
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 2),
	PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
FROM 
	PortfolioProject.dbo.NashvilleHousing



-- Updating Table Address -- 

ALTER TABLE 
	NashvilleHousing
ADD 
	OwnerSplitAddress NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3);



--Updating Table City --

ALTER TABLE 
	NashvilleHousing
ADD 
	OwnerSplitCity NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2);



--Updating Table State --

ALTER TABLE 
	NashvilleHousing
ADD 
	OwnerSplitState NVARCHAR(255);

UPDATE 
	NashvilleHousing
SET 
	OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1);



--Verifying address columns have updated
Select *
FROM 
	NashvilleHousing




----------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM 
	NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	2


SELECT
	SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM 
	PortfolioProject.dbo.NashvilleHousing




-- Update Nashville Housing

UPDATE 
	NashvilleHousing
SET 
	SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes' 
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



--Verifying Update Worked
SELECT 
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM 
	PortfolioProject.dbo.NashvilleHousing
GROUP BY 
	SoldAsVacant


----------------------------------------------------------------------------------------

--Remove Duplicates 

-- Use CTE to find duplicates 

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID, 
		SalePrice,
		SaleDate,
		LegalReference
	ORDER BY 
			UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing)
DELETE 
FROM 
	RowNumCTE
WHERE
	row_num > 1


----------------------------------------------------------------------------------------


-- Delete Unused Columns 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN 
	OwnerAddress,
	TaxDistrict, 
	PropertyAddress,
	SaleDate

