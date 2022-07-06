/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject.dbo.nashville_housing


-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.nashville_housing

Update portfolioproject.dbo.Nashville_Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date;

Update portfolioproject.dbo.Nashville_Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject.dbo.Nashville_Housing


--Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.nashville_housing a
JOIN PortfolioProject.dbo.nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.propertyaddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.nashville_housing a
JOIN PortfolioProject.dbo.nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.propertyaddress is null



--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.nashville_housing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address_of_property,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

FROM PortfolioProject.dbo.nashville_housing


ALTER TABLE Nashville_Housing
ADD PropertySplitAddress Nvarchar(255);

Update portfolioproject.dbo.Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)



ALTER TABLE Nashville_Housing
ADD PropertySplitCity Nvarchar(255);

Update portfolioproject.dbo.Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.nashville_housing



SELECT OwnerAddress
FROM PortfolioProject.dbo.nashville_housing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.nashville_housing
WHERE PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) IS NOT NULL




ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress Nvarchar(255);

Update portfolioproject.dbo.Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)



ALTER TABLE Nashville_Housing
ADD OwnerSplitCity Nvarchar(255);

Update portfolioproject.dbo.Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)



ALTER TABLE Nashville_Housing
ADD OwnerSplitState Nvarchar(255);

Update portfolioproject.dbo.Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


SELECT *
FROM PortfolioProject.dbo.Nashville_Housing



--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant
, CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.nashville_housing


UPDATE Nashville_Housing
SET SoldASVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
	END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2 DESC




-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) as row_num


FROM PortfolioProject..nashville_housing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1




-- Delete Unused Columns


ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..nashville_housing