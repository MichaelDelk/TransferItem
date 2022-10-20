# TransferItem
Demo - Inventory Transfer App (Bootstrap, JS, PHP, SQL, RPGLE)

#URL
https://delkdev.com/projects/p08/

#Purpose

Production and warehouse staff request a tablet-based app that would condense the 4-8 screens and dozen transaction types of the back-end ERP inventory transaction process to a single page with four tabs, one tab for each of the transaction types they actually use and would only include the parameters they use. App would also display quantities in various stock locations. This application would replace manual recording of quantities/locations and transactions on paper and then re-keying them on a workstation in an office away from the actual inventory items.

#Technology

HTML, CSS, Javascript, Bootstrap 5, and some jQuery are used to present entry forms, perform front-end validation, pass AJAX GET requests to PHP, receive responses from PHP, and display request results to user. PHP receives GET requests, validates parameter data, performs SQL operations against the database, and returns results. 

In the production system, the PHP that receives the actual form submission (ItemTransfer.php) binds the requested parameters to an SQL stored procedure which then calls the included RPGLE Free program GIVIX01RA which uses the requested parameters to format and invoke the requested inventory transaction system in the ERP system. In this demonsatration, ItemTransfer.php just performs some validation and returns messages without invoking the RPGLE program.

All SQL operations use PDO and parameter binding.

Current production app uses DB2. I converted this demo to MySQL in order to make it publically available. (DB access abtraction would have made this faster.)

Note that the HTML page contains a separate form for each transaction type. The transactions are dissimilar enough that coding four forms was more efficient than creating a single dynamic form to support each transaction type. (Further, most of the staff developers are just learning web technology and can more easily understand HTML than Javascript ... for now. ;-) )

#Demo Caveats
- Only a subset of master tables are included (item master, item-warehouse master, and item-stock-location master) so some validations are assumed to pass in this example.
- No data transactions or updates are performed. User will not see any change in available quantities as a result of "successful" simulated transactions.
- All files for the app are in a single directory. If the app was larger and included additional tooling, js and css files would be moved to a subdirectory, and subdirectories for composer and vendor libraries would be included.
- The TransferItem.php and favicon-geminimade.png files are not included in this repository.

#Opportunities
- Convert from GET TO POST. (Original design required GET.)
- Increase amount of validation done by front-end.
- Only enable the <Available locations> button of the TROU transaction if both Item Number or Warehouse From are populated.

Comments/Questions: michael@delkdev.com
  
