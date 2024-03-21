$(document).ready(function(){
  params = parseParams3P();
  loadCustomDoc(params);
});

function parseParams3P() {
  var params = {};
    var qs = window.location.search;
    if (qs && qs.length > 0) {
        var paramsArray = qs.replace(/^\?/,"").split("&");
        for (var i = 0; i < paramsArray.length; i++) {
            var nameValPair = paramsArray[i].split("=");
            var name = nameValPair[0];
            var value = nameValPair.length > 1 ? decodeURIComponent(nameValPair[1].replace(/\+/g," ")) : "";
            params[name] = value;
        }
    }
    return params;
}

function loadCustomDoc(params) {
  var href = window.location.href;
  var allParams = {};
  var moreParams = {
    'url': href
  };
  $.extend(allParams, params);
  $.extend(allParams, moreParams);

  handledTocChanged(allParams);
  populateContent(allParams);
  populateTOC(allParams);
}

function handledTocChanged(allParams) {
    var docpage = getDocPage(allParams);
    // Set up an observer to expand the TOC when it changes.
    var target = document.getElementById('3ptoc');
    // Create an observer instance linked to the callback function
    var observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
              expandToc(docpage);
              // TODO: Get these elements from the mutation
              var aTags = document.getElementById('3ptoc').getElementsByTagName('a');
              handleDocLinksClick3P(aTags);
        });
    });
    observer.observe(target, { childList: true });
}

function _getDocroot() {
  var docroot = _getSessionStorageValue('docroot');
  if (docroot && docroot.length > 0) {
    return docroot;
  }
  var href = window.location.href;
  // Match on the first occurance of 'help'.
  var regexp = /^(.*?\/help\/)(.*)/;
  var match = regexp.exec(href);
  docroot = match[1];  
  _setSessionStorageValue('docroot', docroot);
  return docroot;
}

function _getSessionStorageValue(key) {
    var value;
    try {
        value = window.sessionStorage.getItem(key);
    } catch (e) {
        value = null;
    }
    return value;
}

function _setSessionStorageValue(key, value) {
  window.sessionStorage.setItem(key, value);
}

function populateTOC(allData) {
  var styleSheetLocation = getTocStyleSheet(allData);    
  var stylesheetparams = getStyleSheetParams(allData);
  var sourcelocation = getSourceLocaton(allData);

  var localizedStrings = getLocalizedStrings();
  var allStyleSheetparams = {};
  $.extend(allStyleSheetparams, stylesheetparams);
  $.extend(allStyleSheetparams, localizedStrings);

  doSaxonTransform(styleSheetLocation, sourcelocation, allStyleSheetparams);
}

function populateContent(allData) {
  var loadContentId;
  var hideContentId;

  if (isMainExamplePage(allData)) {
    loadContentId = "example_content";
    hideContentId = "doc_center_content";
    document.getElementById(hideContentId).style.display = "none";
    document.getElementById(loadContentId).style.display = "block";

    var styleSheetLocation = getContentStyleSheet(allData);    
    var stylesheetparams = getStyleSheetParams(allData);
    var sourcelocation = getSourceLocaton(allData);

    var localizedStrings = getLocalizedStrings();
    var allStyleSheetparams = {};
    $.extend(allStyleSheetparams, stylesheetparams);
    $.extend(allStyleSheetparams, localizedStrings);

    var examplepage = allData.examplepage;
    if (examplepage && examplepage.indexOf("demos.xml#") > -1) {
      var n = examplepage.lastIndexOf("#");
      var sectionparams = {};
      sectionparams.section = decodeURIComponent(examplepage.substring(n+1));
      $.extend(allStyleSheetparams, sectionparams);
    }
    doSaxonTransform(styleSheetLocation, sourcelocation, allStyleSheetparams);
  } else {
    loadContentId = "doc_center_content";
    hideContentId = "example_content";
    document.getElementById(hideContentId).style.display = "none";

    var page = getPageLocation(allData);
    var contentFrame = document.getElementById(loadContentId);
    contentFrame.src = page;

    iframeURLChanged(contentFrame, function (newURL) {
        // Get the page from the URL, matching characters 
        // after the last slash. 
        var page = newURL.match(/([^\/]*)$/);
        if (page) {
          expandToc(page[0]);
          contentFrame.contentWindow.scrollTo(0,0);
          window.scrollTo(0,0);
        }
    });
  }
}

function getDocPage(allData) {
  var docpage;
  var pagetype = allData.pagetype;
  switch(pagetype) {
    case 'doc':
      docpage = allData.page;
    break;
    case 'example':
      docpage = allData.examplepage;
    break;
  }
  return docpage;
}

function getPageLocation(allData) {
  var current_page;
  var current_dir;
  var page;
  if (allData.pagetype == "doc") {
    current_page = allData.page;
    current_dir = allData.helpdir;
  } else {
    current_page = allData.examplepage;
    current_dir = allData.exampledir;
  }
  if (allData.pageexists == "true") {
    var targetParts = current_page.split("#");
    page = current_dir + "/" + targetParts[0];
    if (page.indexOf("?") > -1) {
      page += "&";
    } else {
      page += "?";
    }
    page += "3pcontent=true";
    if (targetParts.length > 1) {
      page += "#" + targetParts[1];
    }
  } else {
    page = "3pblank.html";
  }  
  return page;
}

function isMainExamplePage(allData) {
  return ((allData.pagetype && allData.pagetype == "example") && 
          (allData.exampledir && allData.exampledir !== "") && 
          (allData.examplepage && allData.examplepage.indexOf("demos.xml") > -1));
}

function getSourceLocaton(allData) {
  var sourcelocationURL;
  var pagetype = allData.pagetype;
  switch(pagetype) {
    case 'doc':
      var helpdir = allData.helpdir;
      if (helpdir.charAt(helpdir.length - 1) != '/') {
        helpdir = helpdir + '/';
      }
      sourcelocationURL = new URL('helptoc.xml', helpdir);
    break;
    case 'example':
      var exampledir = allData.exampledir;
      if (exampledir.charAt(exampledir.length - 1) != '/') {
        exampledir = exampledir + '/';
      }
      sourcelocationURL = new URL('demos.xml', exampledir);
    break;
  }
  return sourcelocationURL.toString();
}

function getTocStyleSheet(allData) {
  var tocStyleSheetURL;
  var docroot = _getDocroot();
  var pagetype = allData.pagetype;
  switch(pagetype) {
    case 'doc':
      tocStyleSheetURL = new URL('includes/shared/scripts/3ptoc-sef.json', docroot);
    break;
    case 'example':
      tocStyleSheetURL = new URL('includes/shared/scripts/3pdemostoc-sef.json', docroot);
    break;
  }
  return tocStyleSheetURL.toString();
}

function getContentStyleSheet(allData) {
  var contentStyleSheetURL;
  var docroot = _getDocroot();
  if (allData.pagetype == 'example') {
    contentStyleSheetURL = new URL('includes/shared/scripts/3pdemos-sef.json', docroot);
  }
  return contentStyleSheetURL.toString();
}

function _getStyleSheetParam(allData, identifier) {
    if (allData[identifier]) {
        return allData[identifier];
    } else {
        return '';
    }
}

function getStyleSheetParams(allData) {
  var stylesheetparams = {};
  stylesheetparams.docroot = _getDocroot();
  var exampledir = _getStyleSheetParam(allData, 'exampledir');
  stylesheetparams.exampledir = exampledir;
  stylesheetparams.demosroot = exampledir;
  stylesheetparams.helpdir = _getStyleSheetParam(allData, 'helpdir');
  stylesheetparams.languageDir = _getStyleSheetParam(allData, 'languageDir');
  stylesheetparams.docpage = _getStyleSheetParam(allData, 'page');
  stylesheetparams.matlabres = _getDocroot() + 'includes';
  return stylesheetparams;
}

function getLocalizedStrings() {
  var localizedStrings = {};
  localizedStrings.mfile = getLocalizedString("3p_examples_mfile");
  localizedStrings.mfiledesc = getLocalizedString("3p_examples_mfiledesc");
  localizedStrings.mgui = getLocalizedString("3p_examples_mgui");
  localizedStrings.mguidesc = getLocalizedString("3p_examples_mguidesc");
  localizedStrings.model = getLocalizedString("3p_examples_model");
  localizedStrings.modeldesc = getLocalizedString("3p_examples_modeldesc");
  localizedStrings.productlink = getLocalizedString("3p_examples_productlink");
  localizedStrings.uses = getLocalizedString("3p_examples_uses");
  localizedStrings.video = getLocalizedString("3p_examples_video");
  localizedStrings.videodesc = getLocalizedString("3p_examples_videodesc");
  return localizedStrings;
}

function doSaxonTransform(stylesheetlocation, sourcelocation, stylesheetparams) {
    SaxonJS.transform({
        stylesheetLocation: stylesheetlocation,
        sourceLocation: sourcelocation,
        stylesheetParams: stylesheetparams
    });
}

function expandToc(page) {
   // Remove the query string parameters inorder to match against the TOC ids.
   var hasQS = page.indexOf('?');
   if (hasQS > 0) {
     page = page.substring(0, hasQS);
   }
   page = page.replace(/([;&,\.\+\*\~':"\!\^#$%@\[\]\(\)=>\|\/])/g, '\\$1');
   toc = $("#3ptoc");   
   // Clear the current page highlight.
   toc.find("li.current_page").removeClass('current_page');
   var current = toc.find('[id="' + page + '"]');
   // Add the current page highlight.
   current.addClass('current_page');
   if (current.hasClass("toc_collapsed")) {
     current.removeClass("toc_collapsed");
     current.addClass("toc_expanded");
   }
   var tocParents = current.parents();
   tocParents.removeClass("toc_collapsed");
   tocParents.addClass("toc_expanded");
}

function handledOnload() {
  updateLinksFromSessionStorage();
  updateContentSize(); 
  handleContextMenu();
  var aTags = document.getElementById("doc_center_content").contentDocument.documentElement.getElementsByTagName("a");
  handleDocLinksClick3P(aTags);
  var iframeElement = document.getElementById('doc_center_content');
  handleContextMenu3P(iframeElement);     
}                 

function updateLinksFromSessionStorage() {
  var docLandingPage = getSessionStorageItem("landing_page_url");
  if (docLandingPage && docLandingPage.length > 0) {
    var webDocParam = "webdocurl";
    var landingPageATags = $(".doc_landing_page");              
    landingPageATags.each(function(index) {
      var currentHref = $(this).attr("href");
      if (currentHref.indexOf(webDocParam) !== -1) {
        // nothing to add
        return;
      } 
      // preserve any old qs params
      var hasQuery = currentHref.indexOf('?');
      var currentQuery = (hasQuery >= 0 ? currentHref.substring(hasQuery + 1) : null);
      var newQuery = (currentQuery ? "?" + currentQuery + "&" + webDocParam : "?" + webDocParam);
        $(this).attr("href", docLandingPage + newQuery);
    });
    handleDocLinksClick3P(landingPageATags);
  } 
  var searchPage = getSessionStorageItem("search_page_url");
  if (searchPage && searchPage.length > 0) {
    $("#docsearch_form").attr('action', searchPage);
  }
}

function updateContentSize() {
  var contentFrame = document.getElementById("doc_center_content");
  var contentDoc = contentFrame.contentWindow.document;
  var contentHeight = contentDoc.body.scrollHeight;
  var newHeight = parseInt(contentHeight,10) + 10;
  contentFrame.style.height = "" + newHeight + "px";
  // var contentWidth = contentDoc.body.scrollWidth;
  // var newWidth = parseInt(contentWidth, 10) + 10;
  // contentFrame.style.width = "" + newWidth + "px";
  $(contentFrame).show();
  var title = contentDoc.title;
  if (title.length > 0) {
    document.title = title;
  }
}

function iframeURLChanged(iframe, callback) {
    var lastDispatched = null;
    var dispatchURLChanged = function () {
        var newHref = iframe.contentWindow.location.href;
        if (newHref !== lastDispatched) {
            callback(newHref);
            lastDispatched = newHref;
        }
    };
    var unloadHandler = function () {
        // Timeout needed because the URL changes immediately after
        // the unload event is dispatched.
        setTimeout(dispatchURLChanged, 0);
    };
    function attachUnloadHandler() {
        // Remove the unloadHandler in case it was already attached.
        iframe.contentWindow.removeEventListener("unload", unloadHandler);
        iframe.contentWindow.addEventListener("unload", unloadHandler);
    }
    iframe.addEventListener("load", function () {
        attachUnloadHandler();
        // Just in case the change wasn't dispatched during the unload event.
        dispatchURLChanged();
    });
    attachUnloadHandler();
}