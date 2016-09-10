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
  INITIAL_PAGE_LOAD_WAIT_TIME,
} from '../../config/settings';

import { configurePhantomJS } from '../lib/phantom_configuration';


/* BROWSER EVALUATED FUNCTIONS */


function changeResultsPerPage(options) {
  document.querySelector(options.resultsPerPageSelector).value = options.resultsPerPage;
  document.querySelector(options.resultsPerPageSelector).onchange();
}

function scrapePaginatedPage(options) {
  function extractProductRowData(row) {
    var unitsRegex = /^(\d+) +\[(\d+)\]$/;
    var skuRegex = /^SKU: +(.*)$/;
    var priceRegex = /^\$ +([0-9\.,]+)( +\$ +([0-9\.,]+))?$/;
    var productUrl, units, sku, price, match;

    productUrl = options.baseUrl + '/' + row.children[1].children[0].children[0].children[0].children[0].children[0].children[1].getAttribute('href');
    
    match = unitsRegex.exec(row.children[2].innerText.trim());
    units = match ? match[2] : options.nullValue;

    match = skuRegex.exec(row.children[0].children[0].children[0].children[0].children[2].innerText.trim());
    sku = match ? match[1] : options.nullValue;

    match = priceRegex.exec(row.children[3].innerText.trim().replace('\n', ' '));
    price = match ? (match[3] || match[1] || options.nullValue) : options.nullValue;

    return {
      proveedor: 'Ingram',
      url: productUrl,
      existencias: units,
      precio: price,
      sku: sku
    };
  }

  var rows = document.querySelectorAll('.Row');
  var numrows = rows.length;
  var products = [];
  var i;

  for(i = 0; i < numrows; ++i) {
    products.push(extractProductRowData(rows[i]));
  }

  return {
    'status': 'success',
    'products': products
  };
}

function advanceResultsPage(options){
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
  paginateAndScrape();
    
  /* Change the page on an interval */
  const paginationIntervalId = window.setInterval(paginateAndScrape, PAGINATION_WAIT_TIME);

  function paginateAndScrape() {
    let newPageNumber = page.evaluate(getCurrentPage, { currentPageSelector: CURRENT_PAGE_SELECTOR });

    debug(`Page number is: ${newPageNumber}`);

    if (newPageNumber !== pageNumber) {
      const retVal = page.evaluate(scrapePaginatedPage, { 
        baseUrl: BASE_URL,
        nullValue: NULL_VALUE
      });
      
      if (retVal.status === 'error') {
        error(retVal.message);
        logoff(phantom, page, ERROR_EXIT_CODE);
      }

      debug(`Retrieved paginated data for ${retVal.products.length} products. Page ${newPageNumber}`);

      for (let i = 0; i < retVal.products.length; ++i) {
        let product = retVal.products[i];
        log(JSON.stringify(product), 'DATA');
      }

      pageNumber = newPageNumber;
      page.evaluate(advanceResultsPage, { nextPageSelector: NEXT_PAGE_SELECTOR });
    
      info(`Waiting ${PAGINATION_WAIT_TIME / 1000} seconds for page change.`);
    } 
    else {
      info(`Reached last page. Finished scraping.`); 
      clearInterval(paginationIntervalId);
      logoff(phantom, page, SUCCESS_EXIT_CODE);
    }
  }
}

function handleCategoryPage(phantom, page, categoryUrl) {
  page.open(categoryUrl, function (status){
    exitOnFailedStatus(phantom, page, status);

    window.setTimeout(function() {
      /* Change the number of results per page to minimize pagination */
      page.evaluate(changeResultsPerPage, { 
        resultsPerPage: RESULTS_PER_PAGE,
        resultsPerPageSelector: RESULTS_PER_PAGE_SELECTOR
      });

      /* Wait for successfull refresh and proceed to scrape the whole paginated subcategory */
      window.setTimeout(paginateAndScrapeListings, CHANGE_RESULTS_PER_PAGE_WAIT_TIME, phantom, page);    
      info(`Waiting ${CHANGE_RESULTS_PER_PAGE_WAIT_TIME / 1000} seconds for change in number of items per page.`);  
    }, INITIAL_PAGE_LOAD_WAIT_TIME);    
    info(`Waiting ${INITIAL_PAGE_LOAD_WAIT_TIME / 1000} seconds for page load.`);
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
