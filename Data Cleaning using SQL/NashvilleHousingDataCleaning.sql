SELECT *
FROM   nashvillehousing

--Standardizing Date Format
SELECT saledate,
       CONVERT(DATE, saledate)
FROM   nashvillehousing

UPDATE nashvillehousing
SET    saledate = CONVERT(DATE, saledate)

SELECT saledate
FROM   nashvillehousing 


--Populate Property Address Data
--When looking at the data we can see that the the same ParcelID has the same PropertyAddress
--So we can populate mising PropertyAddress by pulling the PropertyAddress from a row with the same ParcelID
SELECT a.parcelid,
       a.propertyaddress,
       b.parcelid,
       b.propertyaddress,
       Isnull(a.propertyaddress, b.propertyaddress)
FROM   nashvillehousing a
       JOIN nashvillehousing b
         ON a.parcelid = b.parcelid
            AND a.[uniqueid] <> b.[uniqueid]
WHERE  a.propertyaddress IS NULL 

UPDATE a
SET    PropertyAddress = Isnull(a.propertyaddress, b.propertyaddress)
FROM   nashvillehousing a
       JOIN nashvillehousing b
         ON a.parcelid = b.parcelid
            AND a.[uniqueid] <> b.[uniqueid]
WHERE  a.propertyaddress IS NULL 


--Splitting PropertyAddress into Address, City
SELECT propertyaddress
FROM   nashvillehousing

SELECT Substring(propertyaddress, 1, Charindex(',', propertyaddress) - 1) AS Address,
       Substring(propertyaddress, Charindex(',', propertyaddress) + 1, Len(propertyaddress)) AS City
FROM   nashvillehousing

ALTER TABLE nashvillehousing
  ADD propertysplitaddress NVARCHAR(255);

UPDATE nashvillehousing
SET    propertysplitaddress = Substring(propertyaddress, 1, Charindex(',', propertyaddress) - 1)

ALTER TABLE nashvillehousing
  ADD propertysplitcity NVARCHAR(255);

UPDATE nashvillehousing
SET    propertysplitcity = Substring(propertyaddress, Charindex(',', propertyaddress) + 1, Len(propertyaddress)) 



--Splitting OwnerAddress into Address, City and State 
SELECT owneraddress
FROM   nashvillehousing

ALTER TABLE nashvillehousing
  ADD ownersplitaddress NVARCHAR(255);

UPDATE nashvillehousing
SET    ownersplitaddress = Parsename(Replace(owneraddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
  ADD ownersplitcity NVARCHAR(255);

UPDATE nashvillehousing
SET    ownersplitcity = Parsename(Replace(owneraddress, ',', '.'), 2)

ALTER TABLE nashvillehousing
  ADD ownersplitstate NVARCHAR(255);

UPDATE nashvillehousing
SET    ownersplitstate = Parsename(Replace(owneraddress, ',', '.'), 1) 


--Removing duplicate values
WITH rownumcte
     AS (SELECT *, Row_number()OVER (partition BY parcelid, propertyaddress, saleprice, saledate,legalreference ORDER BY uniqueid ) row_num
         FROM   nashvillehousing
        --order by ParcelID
        )
DELETE
FROM   rownumcte
WHERE  row_num > 1
