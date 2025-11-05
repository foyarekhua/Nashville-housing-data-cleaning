# Nashville-housing-data-cleaning
## Goal
- Standardize Date Format
- Populate Property Address data (each ParcelID leads to its own address so if we have the parcelID we can populate nulls with the right address)
- Breaking out Address into Individual Columns (Address, City, State)
- Change Y and N to Yes and No in "Sold as Vacant" field
- Remove Duplicates
- Delete Unused Columns
## key challenges and solutions
1. There were a bunch of blanks which made the data hard to import into MySQL using the table import wizard. **Fix:** I turned the blanks into nulls on Excel then imported the data
2. Standardizing data to import into MySQL. **Fix**: also in Excel, I made sure dates were classified as dates (instead of general) and numbers were numbers, etc.
## What I learned
- How to clean data that is improperly formatted, missing many values, and in general inconsistent data input
## Why it matters
- This demonstrates my ability to work with real-life data as in real-life, data is not always clean
