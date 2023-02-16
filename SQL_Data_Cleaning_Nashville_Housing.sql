SELECT*
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

-- Standardizing the date formatting.

-- Step 1 confirming the formatting will look as I want it to once updated.
SELECT SaleDate, CONVERT(date, SaleDate)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Step 2 Update to desired format.
UPDATE Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
SET SaleDate = CONVERT(date, SaleDate)

--Step 3 - Confirm changes were effective
SELECT SaleDate, CONVERT(date, SaleDate)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Changes were unsuccessful. Trying another method.
--Step 1 Alter Table and adding new column to fill in desired date info.
ALTER TABLE Nashville_Housing_Data
ADD SaleDateConverted date

--Filling in date information
UPDATE Nashville_Housing_Data
SET SaleDateConverted = CONVERT(date, SaleDate)

--Confirm changes were successful
SELECT SaleDateConverted
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
--Woohoo!!
-------------------------------------------------------------------------------

--Viewing property address column
SELECT PropertyAddress
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Checking for NULLS
SELECT PropertyAddress
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
WHERE PropertyAddress is null

--View by order of parcel ID to determine if duplicate rows have the needed missing address.
SELECT *
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
ORDER BY ParcelID

--Determined duplicated ParcelID rows have the missing address. Example queries below. Noted that unique ID is different in some rows.
SELECT *
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
WHERE ParcelID = '026 05 0 017.00'

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	on a.parcelID = b.parcelID
	AND a.UniqueID <>b.UniqueID
WHERE a.propertyaddress is null

--Query is confirming desired results will be achieved.
SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	on a.parcelID = b.parcelID
	AND a.UniqueID <>b.UniqueID
WHERE a.propertyaddress is null

--Updating missing addresses based on query results above.
UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data a
JOIN Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data b
	on a.parcelID = b.parcelID
	AND a.UniqueID <>b.UniqueID
WHERE a.propertyaddress is null

--Confirmed requested changes were successful
SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM Nashville_Housing_Data a
JOIN Nashville_Housing_Data b
	on a.parcelID = b.parcelID
	AND a.UniqueID <>b.UniqueID

-------------------------------------------------------------------------------


--Breaking apart street address and city in property address column
--View column to determine if delimiter is found throughought the entire set
SELECT propertyaddress
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Viewing desired new address format
SELECT
SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress)) AS property_street_address
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Viewing with delimiter removed
SELECT
SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) AS property_street_address
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Viewing with city separated out along with street address
SELECT
SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) AS property_street_address,
SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) AS property_city
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Creating two new columns to fill in split property address information
ALTER TABLE Nashville_Housing_Data
Add property_street_address nvarchar(255)

UPDATE Nashville_Housing_Data
SET property_street_address = SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)


ALTER TABLE Nashville_Housing_Data
Add property_city nvarchar(255)

UPDATE Nashville_Housing_Data
SET property_city = SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))

--Confirming changes were successful
SELECT*
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

-------------------------------------------------------------------------------


--Breaking apart owner address column into street address, city, and state.

--Viewing property owner column
SELECT Owneraddress
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Replacing commas with periods and using PARSENAME function to view separated desired values
SELECT
PARSENAME(REPLACE(Owneraddress, ',','.'), 3),
PARSENAME(REPLACE(Owneraddress, ',','.'), 2),
PARSENAME(REPLACE(Owneraddress, ',','.'), 1)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Adding columns to receive separated owner address values

ALTER TABLE Nashville_Housing_Data
ADD owner_street_address nvarchar(255)

UPDATE Nashville_Housing_Data
SET owner_street_address = PARSENAME(REPLACE(Owneraddress, ',','.'), 3)

ALTER TABLE Nashville_Housing_Data
ADD owner_city nvarchar(255)

UPDATE Nashville_Housing_Data
SET owner_city = PARSENAME(REPLACE(Owneraddress, ',','.'), 2)

ALTER TABLE Nashville_Housing_Data
ADD owner_state nvarchar(255)

UPDATE Nashville_Housing_Data
SET owner_state = PARSENAME(REPLACE(Owneraddress, ',','.'), 1)

--Viewing to confirm changes were successful
SELECT*
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

-------------------------------------------------------------------------------

--Viewing soldasvacant column to determine consistent Y/N values
SELECT DISTINCT(soldasvacant)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Which values should be used to replace? 
--Y and N values appear less often, so will replace with the Yes and No values for the sake of consistency.
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
GROUP BY soldasvacant
ORDER BY 2

--Checking view for replacing values 
SELECT soldasvacant,
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data

--Replacing values
UPDATE Nashville_Housing_Data
SET soldasvacant = 
	CASE WHEN soldasvacant = 'Y' THEN 'Yes'
		 WHEN soldasvacant = 'N' THEN 'No'
		 ELSE soldasvacant
		 END

--Confirming changes were successful
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
GROUP BY soldasvacant
ORDER BY 2

-------------------------------------------------------------------------------

--Removing duplicates
--Identifying duplicate rows. Determined column row 2 is a duplicate with same data as the row above it when sorted in order of parcelID
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueID) row_num
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
ORDER BY parcelID

--Using CTE to filter out column 2
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueID) row_num
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress

--Removing duplicated rows per exploration above

WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueID) row_num
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Checking to see if changes were successful
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
					uniqueID) row_num
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress

-------------------------------------------------------------------------------

--Removing unneccessary columns after cleanup. Address columns are now duplicated after splitting the values into separate columns.
--SaleDate column will also be deleted after separating out the month/day information needed. Time stamp provided in original source is not useful.

ALTER TABLE Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress

--Confirming changes were successful

SELECT*
FROM Nashville_Housing_Data_Cleaning_Project.dbo.Nashville_Housing_Data