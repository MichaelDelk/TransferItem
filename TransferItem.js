/**
 * TransferItem.js
 * 
 * Process HTML of form fields requesting item transfer
 * operation. Pass fields to PHP as JS AJAX request.
 * 
 * Provide minimal field validation and process response
 * from called PHP script.
 * 
 * @author Michael Delk
 * @version 2021-10-08
 * 
 * @todo lint, comments, narrate db2-vs-mysql
 * @todo disable locations button while awaiting ajax return.
 */
 $(document).ready(function() {

  /**
   * Initialize ALL form values and presentation.
   */
  inzEntirePage() ;

  /**
   * Get the messages div.
   */
  var formMessages = $('#form-messages') ;

  /**
   * Submit TROU (Transfer Out + TRIN Transfer In) transaction.
   */
  $("#btnSubmitTrou").on("click", function( event ) {

    var $this 	 = $("#btnSubmitTrou") ;
    var $caption = $this.html() ; // We store the html of the submit button.
    var form 		 = "#frmSubmitTrou" ;
    var formData = $(form).serializeArray() ;
    var route 	 = $(form).attr('action') ; // Route stored in form attribute.

    event.preventDefault() ;

    /**
     * Remove/reset message content.
     */
     formMessages.empty() ;
    
    /**
     * Prepare and send data request. Process response.
     */
     $.ajax({
	    type: "GET",
	    url: route,
	    data: formData,
	    beforeSend: function () { // Prevent multiple clicks.
	      $this.attr('disabled', true).html("Processing...") ;
	    },
	    success: function (response) {
	      $this.attr('disabled', false).html($caption) ;
        if (response.success == 'Y') {
          formMessages.append('<div class="alert alert-success alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-check-circle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Success!</strong> '
            + response["item-quantity"] 
            + ' of item ' + response["item-number"] 
            + ' transferred from whs ' + response["item-warehouse-from"] 
            + ' stockroom ' + response["stockroom-from"] 
            + ' aisle ' + response["aisle-from"] 
            + ' location ' + response["stock-location-from"] 
            + ' to whs ' + response["item-warehouse-to"] 
            + ' stockroom ' + response["stockroom-to"] 
            + ' aisle ' + response["aisle-to"] 
            + ' location ' + response["stock-location-to"] + '.') ;
            formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
          clrFormInputs() ;
        } else {
          formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + response.response_text) ;
          formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
        }
	    },
	    error: function (XMLHttpRequest, textStatus, errorThrown) {
        formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
        formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
        formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + textStatus + " : " + errorThrown) ;
        formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
	    }
	  });
    /**
     * Return to top of page to see response messages.
     */
    $('html, body').animate({ scrollTop: 0 }, 0) ;
	}) ;

  /**
   * Submit ISSU (Issue) transaction.
   */
  $("#btnSubmitIssu").on("click", function( event ) {
    var $this    = $("#btnSubmitIssu") ;
    var $caption = $this.html() ;
    var form     = "#frmSubmitIssu" ;
    var formData = $(form).serializeArray() ;
    var route    = $(form).attr('action') ;
    
    event.preventDefault() ;

    /**
     * Remove/reset message content.
     */
    $("#form-messages").empty() ;
    
    /**
     * Prepare and send data request. Process response.
     */
     $.ajax({
      type: "GET",
      url: route,
      data: formData,
      beforeSend: function () {
        $this.attr('disabled', true).html("Processing...");
      },
      success: function (response) {
        $this.attr('disabled', false).html($caption) ;
        if (response.success == 'Y') {
          formMessages.append('<div class="alert alert-success alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-check-circle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Success!</strong> '
            + response["item-quantity"] 
            + ' of item ' + response["item-number"] 
            + ' issued from whs ' + response["item-warehouse-from"] 
            + ' stockroom ' + response["stockroom-from"] 
            + ' aisle ' + response["aisle-from"] 
            + ' location ' + response["stock-location-from"] 
            + ' for reason ' + response["adj-reason"]+ '.') ;
            formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
          clrFormInputs() ;
        } else {
          formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + response.response_text) ;
          formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
        }
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
        formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
        formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + textStatus + " : " + errorThrown) ;
        formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
      }
    }) ;
    /**
     * Return to top of page to see response messages.
     */
     $('html, body').animate({ scrollTop: 0 }, 0) ;
  }) ;

  /**
   * Submit ADJ (Adjustment) transaction.
   */
  $("#btnSubmitAdj").on("click", function( event ) {
    var $this    = $("#btnSubmitAdj") ;
    var $caption = $this.html() ;
    var form     = "#frmSubmitAdj" ;
    var formData = $(form).serializeArray() ;
    var route    = $(form).attr('action') ;
    
    event.preventDefault() ;

    /**
     * Remove/reset message content.
     */
    $("#form-messages").empty() ;
  
    /**
     * Prepare and send data request. Process response.
     */
     $.ajax({
      type: "GET",
      url: route,
      data: formData,
      beforeSend: function () {
        $this.attr('disabled', true).html("Processing...");
      },
      success: function (response) {
        $this.attr('disabled', false).html($caption) ;
        if (response.success == 'Y') {
          formMessages.append('<div class="alert alert-success alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-check-circle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Success!</strong> '
            + 'Item ' + response["item-number"] 
            + ' in whs ' + response["item-warehouse-from"]
            + ' stockroom ' + response["stockroom-from"] 
            + ' aisle ' + response["aisle-from"] 
            + ' location ' + response['stock-location-from'] 
            + ' adjusted (ADJ) by quantity ' + response["item-quantity"] 
            + ' for reason ' + response["adj-reason"] + '.') ;
            formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
          clrFormInputs() ;
        } else {
          formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + response.response_text) ;
          formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
        }
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
        formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
        formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + textStatus + " : " + errorThrown) ;
        formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
      }
    });
    /**
     * Return to top of page to see response messages.
     */
     $('html, body').animate({ scrollTop: 0 }, 0) ;
  });

  /**
   * Submit PROD (Adjustment (PROD)) transaction.
   */
  $("#btnSubmitProd").on("click", function( event ) {
    var $this    = $("#btnSubmitProd") ;
    var $caption = $this.html() ;
    var form     = "#frmSubmitProd" ;
    var formData = $(form).serializeArray() ;
    var route    = $(form).attr('action') ;
    
    event.preventDefault() ;

    /**
     * Remove/reset message content.
     */
    $("#form-messages").empty() ;
  
    /**
     * Prepare and send data request. Process response.
     */
     $.ajax({
      type: "GET",
      url: route,
      data: formData,
      beforeSend: function () {
        $this.attr('disabled', true).html("Processing...");
      },
      success: function (response) { // Success
        $this.attr('disabled', false).html($caption) ;
        if (response.success == 'Y') {
          formMessages.append('<div class="alert alert-success alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-check-circle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Success!</strong> '
            + 'Item ' + response["item-number"] 
            + ' in whs ' + response["item-warehouse-from"]
            + ' stockroom ' + response["stockroom-from"] 
            + ' aisle ' + response["aisle-from"] 
            + ' location ' + response['stock-location-from'] 
            + ' adjusted (PROD) by quantity ' + response["item-quantity"] 
            + ' for reason ' + response["adj-reason"] + '.') ;
            formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
          clrFormInputs() ;
        } else {
          formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
          formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
          formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + response.response_text) ;
          formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
        }
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        formMessages.append('<div class="alert alert-danger alert-dismissible d-flex align-items-center fade show"></div>') ;
        formMessages.find('div').append('<i class="bi-exclamation-triangle-fill"></i>') ;
        formMessages.find('div').append('<strong class="mx-2">Error!</strong> ' + textStatus + " : " + errorThrown) ;
        formMessages.find('div').append('<button type="button" class="btn-close" data-bs-dismiss="alert"></button>') ;
      }
    });
    /**
     * Return to top of page to see response messages.
     */
     $('html, body').animate({ scrollTop: 0 }, 0) ;
  });

  /**
   * Attempt to retrieve item description from Harris ERP
   * and display it on form.
   */
  $('input[name="item-number"]').focusout(function() {

    var $form = $(this).closest("form") ;
    var route    = "GetItemDescription.php" ;
    var database = $form.find('#DB').val() ;
    var itemNumber = $(this).val() ;
    var aryData = { "DB" : database, "item-number" : itemNumber } ;

    $.ajax({
      type: "GET",
      url: route,
      data: aryData,
      success: function (response) {
        if (response.success == 'Y') {
          $form.find('#item-description').text(response.response_text) ;
        } else {
          $form.find('#item-description').text(response.response_text) ;
        }
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        $form.find('#item-description').text('Error! ' + textStatus + " : " + 
          errorThrown) ;
      }
    }) ;
  }) ;

  /**
   * Attempt to retrieve item stock location information from Harris ERP
   * and display it using modal box.
   */
  $("#btnLocations").on("click", function( event ) {

    var $caption = $(this).html() ;
    var $form = $(this).closest("form");
    var route    = "GetItemStockLocations.php" ;
    var database = $form.find('#DB').val() ;
    var itemNumber = $form.find('#item-number').val() ;
    var warehouse = $form.find('#item-warehouse-from').val() ;
    var aryData = { 
      'DB' : database, 
      'item-number' : itemNumber, 
      'item-warehouse' : warehouse 
    } ;
    
    event.preventDefault() ;

    /**
     * Remove/reset message content.
     */
    $("#form-messages").empty() ;

    /**
     * Process with retrieval of location information.
     */
    $.ajax({
      type: "GET",
      url: route,
      data: aryData,
      beforeSend: function () {
        $(this).attr('disabled', true).html("Processing...") ;
      },
      success: function (response) { // Success
        $(this).attr('disabled', false).html($caption) ;
        loadLocationsModal(response) ;
      },
      error: function (XMLHttpRequest, textStatus, errorThrown) {
        var response = {
          success : 'N',
          response_text : 'Error! ' + textStatus + " : " + errorThrown
        }
        loadLocationsModal(response) ;
      }
    }) ;
  }) ;

}) ;

/**
 * Initialize all messages and forms.
 */
function inzEntirePage() {
  $("#form-messages").empty() ;
  $("form")[0].reset() ;
}

/**
 * Clear forms for entry.
 * - Clears all input fields marked with .reset-value class.
 * - Original design does not reset warehouse and hidden fields.
 */
function clrFormInputs() {
  $("form").find("input.reset-value").val('') ;
  $("form").find("p.reset-value").val('') ;
}

/**
 * Load selected location values to 'from location' inputs on TROU form.
 * 
 * @param {object} e HTML <tr> element of aisle/stockroom/location
 * @returns none
 */
function returnSelectedLocationToForm(e) {
  if ((e.cells) && (e.cells.length > 2)) {
    let form = document.getElementById('frmSubmitTrou') ;
    form.querySelector('#aisle-from').value = e.cells[0].innerHTML ;
    form.querySelector('#stockroom-from').value = e.cells[1].innerHTML ;
    form.querySelector('#stock-location-from').value = e.cells[2].innerHTML ;
    var locationsEl = document.getElementById('locationsModal') ;
    var modal = bootstrap.Modal.getInstance(locationsEl) ;
    modal.hide() ;
     $('html, body').animate({ scrollTop: 0 }, 0) ;
  }
}

/**
 * Load location selection modal body.
 * 
 * If response is successful, parse response data into table and load
 * that table into locations modal.
 * 
 * If response is not succesful, load response text into locations modal.
 * 
 * @param {Object} response - Response from ajax call to get location data
 * @param {string} response.success - 'Y' | 'N'
 * @param {string} response.response_text Array of JSON objs | Error message
 * @returns none
 */
function loadLocationsModal(response) {

  const divLocations = document.getElementById('divLocations') ;
  divLocations.innerHTML = "" ;

  /**
   * Process response text as table of data or a response message.
   */
  if (response.success == 'Y') {
    divLocations.appendChild(loadLocationsModalTable(response)) ;
  } else {
    divLocations.appendChild(loadLocationsModalMessage(response)) ;
  }

}

/**
 * Parse response data into table and load that table into locations modal.
 * 
 * @param {Object} response - Response from ajax call to get location data
 * @param {string} response.success - 'Y' | 'N'
 * @param {string} response.response_text Array of JSON objs | Error message
 * @returns {Object} HTML table element of locations data
 */
function loadLocationsModalTable(response) {

  const aryLocations = response.response_text ;

  /**
   * Extract column names from location data.
   */
  let columnNames = [] ;
  for (let i = 0; i < aryLocations.length; i++) {
    for (let key in aryLocations[i]) {
      if (columnNames.indexOf(key) === -1) {
        columnNames.push(key) ;
      }
    }
  }

  /**
   * Create table, row, cell elements for location data
   * and append table to location modal body.
   */
  const tblLocations = document.createElement("table") ;
  tblLocations.classList.add('table', 'table-hover', 'table-striped') ;

  let tr = tblLocations.insertRow(-1);
  for (let i = 0; i < columnNames.length; i++) {
    let th = document.createElement("th") ;
    /**
     * Apply any special formatting required by column data type.
     */
    switch (columnNames[i]) {
      case 'qty_on_hand':
        th.classList.add('text-end') ;
        break ;  
      case 'stock_locator_active':
        th.classList.add('text-center') ;
        break ;  
      default:
        break ;  
    }
    th.innerHTML = toTitleCase(columnNames[i]) ;
    th.setAttribute('scope', 'col') ;
    tr.appendChild(th) ;
  }
  
  for (let i = 0; i < aryLocations.length; i++) {
    tr = tblLocations.insertRow(-1) ;
    tr.setAttribute('onclick', 'returnSelectedLocationToForm(this)') ;
    for (let j = 0; j < columnNames.length; j++) {
      let td = tr.insertCell(-1) ;
      /**
       * Apply any special formatting required by column data type.
       */
      switch (columnNames[j]) {
        case 'qty_on_hand':
          td.classList.add('text-end') ;
          break ;  
        case 'stock_locator_active':
          td.classList.add('text-center') ;
          break ;  
        default:
          break ;  
      }
      td.innerHTML = aryLocations[i][columnNames[j]] ;
    }
  }
  
  return tblLocations ;
}

/**
 * Parse response, as message text, into locations modal.
 * 
 * @param {Object} response - Response from ajax call to get location data
 * @param {string} response.success - 'Y' | 'N'
 * @param {string} response.response_text Array of JSON objs | Error message
 * @returns {Object} HTML paragraph element of response message text
 */
function loadLocationsModalMessage(response) {

  const p = document.createElement("p") ;
  // p.classList.add('table', 'table-hover', 'table-striped') ;
  p.innerHTML = response.response_text ;

  return p ;
}

/**
 * Replace underscores with spaces and capitalize words.
 * 
 * @param {string} str String to be title-cased.
 * @returns {string} Title-cased string.
 */
function toTitleCase(str) {
  const arr = str.split('_');
  const result = [] ;
  for (const word of arr) {
    result.push(word.charAt(0).toUpperCase() + word.slice(1)) ;
  }
  return result.join(' ') ;
}