----------------------------------------------------------------------------------------
--Data cleaning using SQL Queries
----------------------------------------------------------------------------------------
SELECT *
FROM PortfolioProject.dbo.nashvilleHousing
----------------------------------------------------------------------------------------
-- Standardize Date format
SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.nashvilleHousing

ALTER TABLE PortfolioProject.dbo.nashvilleHousing
ADD SaleDateCon Date;

UPDATE PortfolioProject.dbo.nashvilleHousing
SET SaleDateCon= CONVERT(date,SaleDate)

SELECT SaleDateCon
FROM PortfolioProject.dbo.nashvilleHousing
----------------------------------------------------------------------------------------
--populate property address data
SELECT PropertyAddress
FROM PortfolioProject.dbo.nashvilleHousing
where PropertyAddress is null

--checking null values in property address
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, 
	   ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.nashvilleHousing a
JOIN PortfolioProject.dbo.nashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null
-- populate property address values into the null valued cells
UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.nashvilleHousing a
JOIN PortfolioProject.dbo.nashvilleHousing b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null
----------------------------------------------------------------------------------------
-- splitting address in seperated colums(address, city, state)
SELECT PropertyAddress
FROM PortfolioProject.dbo.nashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.nashvilleHousing

--splitting city from the address column and insert it in new column
ALTER TABLE PortfolioProject.dbo.nashvilleHousing
ADD SplitAddress NVARCHAR(255) ;

UPDATE PortfolioProject.dbo.nashvilleHousing
SET SplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.nashvilleHousing
ADD City NVARCHAR(255) ;

UPDATE PortfolioProject.dbo.nashvilleHousing
SET City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.nashvilleHousing

-- using PARSENAME FUNCTION
SELECT 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.nashvilleHousing
----------------------------------------------------------------------------------------
-- change Y and N to yes and no in 'sold as vacant' field
SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.nashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.nashvilleHousing

UPDATE PortfolioProject.dbo.nashvilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
----------------------------------------------------------------------------------------
--Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY parcelID,
		propertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID) row_num
FROM PortfolioProject.dbo.nashvilleHousing
)
Delete 
FROM RowNumCTE
WHERE row_num >1
----------------------------------------------------------------------------------------
-- Delete unused columns
ALTER TABLE PortfolioProject.dbo.nashvilleHousing
DROP COLUMN PropertyAddress

SELECT *
FROM PortfolioProject.dbo.nashvilleHousing
