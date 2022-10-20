<?php
/**
 * GetItemDescription.php
 * 
 * Receive request of item number and warehouse. Retrieve stock location 
 * and quantity information from Harris and return it to calling request. 
 * 
 * @author Michael Delk
 * @package TransferItem  
 * @version 2022-07-08
 */
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE) ;
ini_set('display_errors', 'on') ;
header("Access-Control-Allow-Origin: *") ;
header("Access-Control-Allow-Methods: PUT, GET, POST") ;
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept") ;
header("Content-Type: application/json") ;

/**
 * Process request parameters from $_REQUEST so script will 
 * respond to both GET and POST requests.
 */
$request = $_REQUEST ;

/**
 * Set script defaults.
 */
$requestDefaults = [
  'db' => 'GI',
  'item_number' => '',
  'item_warehouse' => '0',
] ;

$response = [
  'success' => 'N',
  'response_text' => ''
] ;

/**
 * Note that GConB.php sets library list according to Harris
 * environment value (e.g. GI, GT, IV, etc.) sent in request
 * parameter $_GET['DB']. HTML form for this application
 * passes that parm and value in the submitted form.
 */
include '../../../GConB.php' ;

/**
 * Retrieve and sanitize request values.
 */
if (array_key_exists('DB', $request)) {
  $request['DB'] = sanitizeInputString($request['DB']) ;
}
if (array_key_exists('item-number', $request)) {
  $request['item-number'] = sanitizeInputString($request['item-number']) ;
}
if (array_key_exists('item-warehouse', $request)) {
  $request['item-warehouse'] = sanitizeInputString($request['item-warehouse']) ;
}

/**
 * Convert char input values to upper case so tablet users don't
 * have to endure the headache of touch-pad CAPS keys.
 */
$strItemNumber = strtoupper($request['item-number']) ;

/**
 * Ensure integer input values.
 */
if (filter_var($request['item-warehouse'], FILTER_VALIDATE_INT) === false) {
  $request['item-warehouse'] = $requestDefaults['item_warehouse'] ;
 }
 $intItemWarehouse = intval($request['item-warehouse']) ;

/**
 * Retrieve stock location and quantity information from item-stock-location
 * and item-warehouse tables.
 */
$strSql = 'SELECT c.isstkr AS stock_room' ;
$strSql .= '    , c.isaile AS aisle' ;
$strSql .= '    , c.issloc AS stock_location' ;
$strSql .= '    , (c.isqoh - c.isqres) AS qty_on_hand' ;
$strSql .= '    , b.iwstkl AS stock_locator_active' ;
$strSql .= '  FROM hdimst AS a' ;
$strSql .= '  INNER JOIN hdiwhs AS b' ;
$strSql .= '    ON a.imitem = b.iwitem' ;
$strSql .= '  INNER JOIN hditsl AS c' ;
$strSql .= '    ON b.iwitem = c.isitem' ;
$strSql .= '      AND b.iwwhs = c.iswhs' ;
$strSql .= "  WHERE a.imimac = ''" ;
$strSql .= '    AND a.imitem = :imitem' ;
$strSql .= "    AND b.iwiwac = ''" ;
$strSql .= '    AND b.iwwhs  = :iwwhs' ;
$strSql .= ';' ;

try {
  $statement = $conPDO->prepare($strSql);
  $statement->bindParam('imitem', $strItemNumber, PDO::PARAM_STR);
  $statement->bindParam('iwwhs', $intItemWarehouse, PDO::PARAM_INT);
  $statement->execute();
  $result = $statement->fetchAll(\PDO::FETCH_ASSOC) ;
  if ($result) {
    $response['success'] = 'Y' ;
    $response['response_text'] = $result ;
  } else {
    $response['success'] = 'N' ;
    $response['response_text'] = 'No locations found for requested item/warehouse.' ;
  }
} catch (\PDOException $e) {
  $response['success'] = 'N' ;
  $response['response_text'] = 'SQL failed: ' . $e ;
}

/**
 * Return response to caller.
 */
echo json_encode($response) ;

exit() ;

/**
 * Sanitize user input for expected type String.
 * @param string $value
 * @return string String sanitized for SQL PDO use.
 */
function sanitizeInputString($value = '') {

  $value = trim($value) ;
  $value = strip_tags($value) ;
  $value = filter_var($value, FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_LOW) ; // Remove /t/n/g/s
  $value = filter_var($value, FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_HIGH) ; // Remove é à ò ì ` ecc...
  $value = htmlentities($value, ENT_QUOTES,'UTF-8') ;

  return $value ;
}
