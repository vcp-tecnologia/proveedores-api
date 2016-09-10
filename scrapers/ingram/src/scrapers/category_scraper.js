import {
  debug,
  error,
  info,
  log,
  exit,
  exitOnFailedStatus,
  logoff,
  login,
} from '../lib/utils';

import {
  BASE_URL,
  ERROR_EXIT_CODE,
  SUCCESS_EXIT_CODE,
  RESULTS_PER_PAGE_SELECTOR,
  NEXT_PAGE_SELECTOR,
  CURRENT_PAGE_SELECTOR,
  CHANGE_RESULTS_PER_PAGE_WAIT_TIME,
  PAGINATION_WAIT_TIME,
  RESULTS_PER_PAGE,
  NULL_VALUE,
} from '../../config/settings';

import { configurePhantomJS } from '../lib/phantom_configuration';


/* BROWSER EVALUATED FUNCTIONS */


function changeResultsPerPage(options) {
  document.querySelector(options.resultsPerPageSelector).value = options.resultsPerPage;
  document.querySelector(options.resultsPerPageSelector).onchange();
}

function scrapePaginatedPage(options) {
  var rows = document.querySelectorAll('.Row');
  var numrows = rows.length;

  var unitsRegex = /^(\d+) +\[(\d+)\]$/;
  var skuRegex = /^SKU: +(.*)$/;
  var priceRegex = /^\$ +([0-9\.,]+)( +\$ +([0-9\.,]+))?$/;

  var productUrl, units, sku, price;
  var i, match;
  var products = [];

  for(i = 0; i < numrows; ++i) {
    var row = rows[i];

    productUrl = options.baseUrl + '/' + row.children[1].children[0].children[0].children[0].children[0].children[0].children[1].getAttribute('href');
    
    match = unitsRegex.exec(row.children[2].innerText.trim());
    units = match ? match[2] : options.nullValue;

    match = skuRegex.exec(row.children[0].children[0].children[0].children[0].children[2].innerText.trim());
    sku = match ? match[1] : options.nullValue;

    match = priceRegex.exec(row.children[3].innerText.trim().replace('\n', ' '));
    price = match ? (match[3] || match[1] || options.nullValue) : options.nullValue;

    products.push({
      proveedor: 'Ingram',
      url: productUrl,
      existencias: units,
      precio: price,
      sku: sku
    });
  }

  return {
    'status': 'success',
    'products': products
  };
}

function advanceResultsPage(options){
  if(options.noop) {
    return;
  }
  var nextPage = document.querySelector(options.nextPageSelector);
  if (nextPage) {
    nextPage.click();
  }
}

function getCurrentPage(options){
  var currentPage = document.querySelector(options.currentPageSelector).value;
  return parseInt(currentPage);
}

/* END BROWSER EVALUATED FUNCTIONS */






/* APPLICATION LOGIC FUNCTIONS */

function paginateAndScrapeListings(phantom, page) { 
  let pageNumber = null;

  const paginationIntervalId = window.setInterval(function() {
    let newPageNumber = page.evaluate(getCurrentPage, { currentPageSelector: CURRENT_PAGE_SELECTOR });

    window.setTimeout(function() {
      debug(`Page number is: ${newPageNumber}`);

      if (newPageNumber !== pageNumber) {
        pageNumber = newPageNumber;
        page.evaluate(advanceResultsPage, {
          nooop: pageNumber === 1,
          nextPageSelector: NEXT_PAGE_SELECTOR
        });

        const retVal = page.evaluate(scrapePaginatedPage, { 
          baseUrl: BASE_URL,
          nullValue: NULL_VALUE
        });
        
        if (retVal.status === 'error') {
          error(retVal.message);
          logoff(phantom, page, ERROR_EXIT_CODE);
        }

        debug(`Retrieved paginated data for ${retVal.products.length} products. Page ${pageNumber}`);

        for (let i = 0; i < retVal.products.length; ++i) {
          let product = retVal.products[i];
          log(product, 'DATA');
        }
      }
      else {
        clearInterval(paginationIntervalId);
        logoff(phantom, page, SUCCESS_EXIT_CODE);
      }      
    }, 2000);
  }, PAGINATION_WAIT_TIME);
}

function handleCategoryPage(phantom, page, categoryUrl) {
  page.open(categoryUrl, function (status){
    exitOnFailedStatus(phantom, page, status);

    /* Change the number of results per page to minimize pagination */
    page.evaluate(changeResultsPerPage, { 
      resultsPerPage: RESULTS_PER_PAGE,
      resultsPerPageSelector: RESULTS_PER_PAGE_SELECTOR
    });

    /* Wait for successfull refresh and proceed to scrape the whole paginated subcategory */
    window.setTimeout(paginateAndScrapeListings, CHANGE_RESULTS_PER_PAGE_WAIT_TIME, phantom, page);    
  });
}


/* END APPLICATION LOGIC FUNCTIONS */



function parseAndValidateCmdLineArgs(phantom) {
  const system = require('system');
  const args = system.args;

  if (args.length !== 3) {
    error('Usage: phantomjs category_scraper.js [category] [url]');
    exit(phantom, ERROR_EXIT_CODE);
  }
  
  return {
    categoryName: args[1],
    categoryUrl: args[2]
  }
}

function run(phantom) {
  const { categoryName, categoryUrl } = parseAndValidateCmdLineArgs(phantom);

  const page = require('webpage').create();
  configurePhantomJS(phantom, page);

  info(`Starting scraping of category: ${categoryName}, and url: ${categoryUrl}`);
  login(phantom, page, handleCategoryPage, categoryUrl);
}

run(phantom);
