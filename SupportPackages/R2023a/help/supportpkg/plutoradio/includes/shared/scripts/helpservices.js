(function(e, a) { for(var i in a) e[i] = a[i]; }(window, /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(1);
__webpack_require__(2);
module.exports = __webpack_require__(3);


/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

/* globals $:false */
/* global
    isFromMatlabOnline,
    isMatlabColonLink,
    getSelectedUrl,
    setupFinished,
    handleMatlabColonLink
*/
$(document).ready(initMatlabOnline);

window._appendDocViewerParameter = _appendDocViewerParameter;

function initMatlabOnline () {
    if (isFromMatlabOnline()) {
        if (window.parent && window.parent.location !== window.location) {
            $(window).bind('examples_cards_added', function (e) {
                $('.card_container a[href^="matlab:"]').off('click');
                handleMatlabColonLink();
            });
            _handleMatlabOnlineDocLinksClick();
            setupFinished();
        } else {
            clearMatlabOnlineDocViewer(); // reset the cookies
        }
    }
}

function clearMatlabOnlineDocViewer () {
    const docviewerCookie = 'MW_Doc_Template';
    document.cookie = docviewerCookie + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;path=/help';
}

function _handleMatlabOnlineDocLinksClick () {
    $(window).bind('click', 'a', function (evt) {
        if (evt.target) {
            const href = getSelectedUrl(evt.target);
            if (href) {
                if (!isMatlabColonLink(href) && (evt.target.target !== '_blank')) {
                    evt.originalEvent.target.href = _appendDocViewerParameter(href);
                }
            }
        }
    });
}

function _appendDocViewerParameter (href) {
    const docViewerParamIdx = href.indexOf('docviewer=ml_online');
    if (docViewerParamIdx !== -1) {
        return href; // already have, return
    }

    let appendHref = href.indexOf('?') > 0 ? '&' : '?';
    appendHref += 'docviewer=ml_online';

    const hashIndex = href.indexOf('#');
    if (hashIndex === -1) {
        return href + appendHref;
    } else {
        return href.substring(0, hashIndex) + appendHref + href.substring(hashIndex, href.length);
    }
}

if (true) {
    exports._appendDocViewerParameter = _appendDocViewerParameter; // for test
}


/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

// TODO: automate generate this file
function getDocRelease () {
    return 'R2021a';
}

if (true) {
    exports.getDocRelease = getDocRelease;
}


/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

/* globals $:false */
/* global
    getProdFilterWebServiceUrl
*/
window.initDeferred = $.Deferred();
window.helpService = {
    timestampCtr: 0,
    callbacks: {},

    callMessageService: function (channel, data, callback) {
        this.doConnectorRequest('channel', channel, data, callback);
    },

    callRequestResponse: function (serviceName, data, callback) {
        this.doConnectorRequest('service', serviceName, data, callback);
    },

    doConnectorRequest: function (type, name, data, callback) {
        const msgDeferred = $.Deferred();
        msgDeferred.then(callback);
        const id = name + '_' + window.performance.now() + '' + this.timestampCtr++;

        this.registerCallbackDeferred(msgDeferred, id);
        const messageObj = {
            data: data,
            id: id
        };
        messageObj[type] = name;
        helpserviceIframePostMessage(messageObj);
    },

    registerCallbackDeferred: function (deferredObj, id) {
        const cb = this.callbacks;
        cb[id] = deferredObj;

        setTimeout(function () {
            if (cb[id] && deferredObj.state() === 'pending') {
                delete cb[id];
                deferredObj.reject();
            }
        }, 30000);
    },

    docDomRequestHandler: {
        back: function () {
            window.history.back();
        },
        forward: function () {
            window.history.forward();
        },
        find: function (msgEvt) {
            const strFound = window.find(msgEvt.data.findstring, msgEvt.data.casesensitive, msgEvt.data.backwards, true);
            const id = 'docinfo_' + new Date().getTime();
            const messageObj = {
                domchannel: 'domeventinfo',
                domevent: 'findresponse',
                eventData: '',
                id: id
            };
            if (!strFound) {
                messageObj.eventData = 'false';
            } else {
                messageObj.eventData = 'true';
            }
            helpserviceIframePostMessage(messageObj);

            // Try scrolling the selection into view.
            if (strFound) {
                try {
                    window.getSelection().anchorNode.parentElement.scrollIntoViewIfNeeded();
                } catch (e) {
                    // Do nothing.
                }
            }
        },
        clearselection: function () {
            if (window.getSelection) {
                if (window.getSelection().empty) { // Chrome
                    window.getSelection().empty();
                } else if (window.getSelection().removeAllRanges) { // Firefox
                    window.getSelection().removeAllRanges();
                }
            } else if (document.selection) { // IE?
                document.selection.empty();
            }
        },
        print: function (msgEvt) {
            const messageObj = {
                domchannel: 'domeventinfo',
                domevent: 'printresponse',
                eventData: msgEvt.data.id
            };
            helpserviceIframePostMessage(messageObj);
            window.print();
        }
    },

    receiveMessage: function (msgEvt) {
        const id = msgEvt.data.id;
        if (this.callbacks[id]) {
            this.callbacks[id].resolve(msgEvt.data.data);
            delete this.callbacks[id];
        }

        if (msgEvt.data.domchannel) {
            if (msgEvt.data.domchannel === 'domeventinfo') {
                if (msgEvt.data.domevent) {
                    this.docDomRequestHandler[msgEvt.data.domevent](msgEvt);
                }
            }
        }
    }
};

let helpServicesInitialized = false;

function getSessionStorageItem (key) {
    if (!helpServicesInitialized) {
        initHelpServices();
    }
    return _getSessionStorageForKey(key);
}

function isSessionStorageItem (key, value) {
    if (!helpServicesInitialized) {
        initHelpServices();
    }
    return _isSessionStorageContains(key, value);
}

$(document).ready(initHelpServices);

function initHelpServices () {
    if (helpServicesInitialized) {
        return;
    }

    const browserContainerKey = 'help_browser_container';
    const browserContainerValue = 'jshelpbrowser';

    // MOS: to uncomment this
    // document.cookie = "MW_Doc_Template=ONLINE||||||||||";

    _detectBrowserProperties('container=jshelpbrowser', browserContainerKey, browserContainerValue);
    _detectBrowserProperties('linkclickhandle=csh', 'link_handle_type', 'csh');
    _detectBrowserProperties('browser=F1help', 'hide_new_tab_menu', 'true');

    const searchSourceKey = 'searchsource';
    const searchSourceValue = getQueryStringValue(searchSourceKey);
    if (searchSourceValue) {
        _detectBrowserProperties(searchSourceKey, searchSourceKey, searchSourceValue);
    }

    const helpBrowserContainer = _getSessionStorageForKey(browserContainerKey);

    if (window.parent && window.parent.location !== window.location) {
        window.helpserviceframe = window.parent;
        // We are in an iframe, presumably the JavaScript Help Browser's
        // help panel.
        if (helpBrowserContainer && helpBrowserContainer === browserContainerValue) {
            handleContextMenu();
            handleDomKeyDown();
            registerUninstalledDocLink();
            handleDocLinksClick();
            handleMiddleMouseClick();
            handleMouseOverAndOutOnLink();
            registerWindowOnLoadAction();
            setupFinished();
            handleWindowOpen();
            handleTitleChange();
            registerWebDocLink();
        }
    } else if (window.location.origin.match(/^https?:\/\/localhost:.*/) || window.location.origin.match(/^https?:\/\/127\.0\.0\.1:.*/)) {
        const techpreview = 'techpreview';
        const techpreviewValue = getQueryStringValue(techpreview);
        // This looks like local doc served by the connector but not
        // in the JavaScript Help Browser.
        if (!isFromMatlabOnline() && techpreviewValue !== undefined && techpreviewValue != null && techpreviewValue === 'true') {
            window.helpserviceframe = createHelpServiceFrame();
            handleDocLinksClick();
        } else {
            // We don't have an iframe available. Clear the helpService variable and resolve initDeferred.
            window.helpService = null;
            window.initDeferred.resolve();
        }
    }

    if (window.helpserviceframe) {
        handleMatlabColonLink();
        handleCustomDocLink();
    }

    helpServicesInitialized = true;
}

function _detectBrowserProperties (urlFeatureParameter, featureKey, featureValue) {
    if (window.location.href && window.location.href.indexOf(urlFeatureParameter) > 0) {
        window.sessionStorage.setItem(featureKey, featureValue);
    }
}

function getQueryStringValue (key) {
    let value;
    try {
        value = decodeURIComponent(window.location.search.replace(new RegExp('^(?:.*[&\\?]' + encodeURIComponent(key).replace(/[.+*]/g, '\\$&') + '(?:\\=([^&]*))?)?.*$', 'i'), '$1'));
    } catch (e) {
        value = null;
    }
    return value;
}

function handleContextMenu () {
    const contextMenuAction = _contextMenuAction;
    $('body').contextmenu(contextMenuAction);
}

function _contextMenuAction (e) {
    e.preventDefault();

    let selectedUrl = getSelectedUrl(e.target);
    if (_isEnglishRedirect(selectedUrl)) {
        selectedUrl = _replaceEnglishRoute(selectedUrl);
    } else {
        selectedUrl = _normalizeEnglishRoute(selectedUrl);
    }

    if (!isCustomDocLink(selectedUrl)) {
        _openContextMenu(e, selectedUrl);
    } else {
        const messageObj = {
            url: selectedUrl
        };
        callMessageService('custom_doc_link', messageObj, function (response) {
            if (response && response.length > 0) {
                const newUrl = response[0];
                _openContextMenu(e, newUrl);
            }
        });
    }
}

function _openContextMenu (e, selectedUrl) {
    const id = 'docinfo_' + new Date().getTime();

    const selectedText = getSelectedText();
    const browserContainerKey = 'help_browser_container';
    const isHideOpenNewTab = _isSessionStorageContains('hide_new_tab_menu', 'true');

    let pageUrl = window.location.href;
    pageUrl = _normalizeEnglishRoute(pageUrl);

    const messageObj = {
        domchannel: 'domeventinfo',
        title: window.document.title,
        url: pageUrl,
        domevent: 'contextmenu',
        eventData: {
            pageX: e.pageX,
            pageY: e.pageY,
            clientX: e.clientX,
            clientY: e.clientY,
            selectedText: selectedText,
            selectedUrl: selectedUrl,
            isHideOpenNewTab: isHideOpenNewTab,
            helpBrowserContainer: _getSessionStorageForKey(browserContainerKey)
        },
        id: id
    };
    helpserviceIframePostMessage(messageObj);
}

function _getSessionStorageForKey (key) {
    let value;
    try {
        value = window.sessionStorage.getItem(key);
    } catch (e) {
        value = null;
    }
    return value;
}

function _isSessionStorageContains (key, value) {
    return value === window.sessionStorage.getItem(key);
}

function handleDomKeyDown () {
    const keyDownAction = function (e) {
        const id = 'docinfo_' + new Date().getTime();

        const nativeEvent = document.createEvent('HTMLEvents');
        nativeEvent.initEvent('keydown', !!e.bubbles, !!e.cancelable);
        // and copy all our properties over
        for (const i in e) {
            nativeEvent[i] = e[i];
        }

        const selectedText = getSelectedText();
        let selectedUrl = getSelectedUrl(e.target);
        if (_isEnglishRedirect(selectedUrl)) {
            selectedUrl = _replaceEnglishRoute(selectedUrl);
        } else {
            selectedUrl = _normalizeEnglishRoute(selectedUrl);
        }
        let pageUrl = window.location.href;
        pageUrl = _normalizeEnglishRoute(pageUrl);

        const browserContainerKey = 'help_browser_container';
        const helpBrowserContainer = _getSessionStorageForKey(browserContainerKey);

        nativeEvent.selectedText = selectedText;
        nativeEvent.selectedUrl = selectedUrl;
        nativeEvent.helpBrowserContainer = helpBrowserContainer;

        const nativeEventObj = JSON.parse(simpleStringify(nativeEvent));

        const messageObj = {
            domchannel: 'domeventinfo',
            title: window.document.title,
            url: pageUrl,
            domevent: 'keydown',
            eventData: nativeEventObj,
            id: id
        };

        helpserviceIframePostMessage(messageObj);
    };
    window.addEventListener('keydown', keyDownAction);
}

function simpleStringify (object) {
    const simpleObject = {};
    for (const prop in object) {
        if (!object.hasOwnProperty(prop)) {
            continue;
        }
        if (typeof (object[prop]) === 'object') {
            continue;
        }
        if (typeof (object[prop]) === 'function') {
            continue;
        }
        simpleObject[prop] = object[prop];
    }
    return JSON.stringify(simpleObject); // returns cleaned up JSON
}

function registerWindowOnLoadAction () {
    window.addEventListener('load', function (e) {
        if (window.parent && window.parent.location !== window.location) {
            // We are in an iframe, presumably the JavaScript Help Browser's
            // help panel.
            const id = 'docinfo_' + new Date().getTime();
            const htmlSource = document.getElementsByTagName('html')[0].outerHTML;
            let pageUrl = window.location.href;
            pageUrl = _normalizeEnglishRoute(pageUrl);
            const messageObj = {
                domchannel: 'domeventinfo',
                domevent: 'onload',
                title: window.document.title,
                url: pageUrl,
                htmlsource: htmlSource,
                id: id
            };

            helpserviceIframePostMessage(messageObj);
        }
    }, { once: true });
}

function handleTitleChange () {
    // Set up an observer for the title element.
    const target = document.querySelector('head > title');
    const observer = new window.MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
            const newtitle = mutation.target.textContent;
            const id = 'docinfo_' + new Date().getTime();
            const messageObj = {
                domchannel: 'domeventinfo',
                domevent: 'titlechange',
                newtitle: newtitle,
                id: id
            };
            helpserviceIframePostMessage(messageObj);
        });
    });
    observer.observe(target, { subtree: true, characterData: true, childList: true });
}

(function (history) {
    const pushState = history.pushState;
    history.pushState = function (state) {
        if (typeof history.onpushstate === 'function') {
            history.onpushstate({ state: state });
        }

        handleHistoryChange();
        return pushState.apply(history, arguments);
    };
    window.onpopstate = function (evt) {
        handleHistoryChange();
    };
})(window.history);

function handleHistoryChange () {
    if (window.parent && window.parent.location !== window.location) {
        // We are in an iframe, presumably the JavaScript Help Browser's
        // help panel.
        const id = 'docinfo_' + new Date().getTime();
        const messageObj = {
            domchannel: 'domeventinfo',
            domevent: 'historystatechange',
            id: id
        };
        helpserviceIframePostMessage(messageObj);
        setTimeout(function () {
            helpserviceIframePostMessage(messageObj);
        }, 1000);
    }
}

function handleWindowOpen () {
    window.open = function (url, name, features) {
        if (url) {
            callMessageService('windowopen', { link: url }, function () {});
        }
    };
}

function handleMouseOverAndOutOnLink () {
    $(window).bind('mouseenter', 'a', mouseOnLinkEventHandler);
    $(window).bind('mouseleave', 'a', mouseOnLinkEventHandler);
}

function mouseOnLinkEventHandler (evt) {
    if (evt.target) {
        const href = getSelectedUrl(evt.target);
        if (href) {
            callMessageService(evt.type + 'link', { link: href }, function () {});
        }
    }
}

function helpserviceIframePostMessage (msgObject) {
    if (window.helpserviceframe) {
        window.helpserviceframe.postMessage(msgObject, '*');
    }
}

// -------------- Start: Dom Access Helper functions ----------------------

function getSelectedText () {
    let text = '';
    if (window.getSelection) {
        text = window.getSelection().toString();
    } else if (window.document.selection &&
        window.document.selection.type !== 'Control') {
        text = window.document.selection.createRange().text;
    }
    return text;
}

function getSelectedUrl (targetNode) {
    const link = '';
    if (targetNode) {
        let cur = targetNode;
        while (cur && !isAnchor(cur)) { // keep going up until we find a match
            cur = cur.parentElement; // go up
        }

        if (cur && cur.href) {
            return cur.href;
        }
    }
    return link;
}

function isAnchor (el) {
    const selector = 'a';
    return (el.matches || el.matchesSelector || el.msMatchesSelector || el.mozMatchesSelector ||
    el.webkitMatchesSelector || el.oMatchesSelector).call(el, selector);
}
// -------------- End: Dom Access Helper functions ----------------------

function createHelpServiceFrame () {
    const ifrm = document.createElement('iframe');
    const hsUrl = window.location.origin + '/ui/help/helpbrowser/helpbrowser/helpservices.html';
    ifrm.setAttribute('src', hsUrl);
    ifrm.setAttribute('onLoad', 'setupFinished();');
    ifrm.setAttribute('name', 'helpServiceFrame');
    ifrm.style.width = '0px';
    ifrm.style.height = '0px';
    document.body.appendChild(ifrm);
    return $(ifrm).get(0).contentWindow;
}

function handleMatlabColonLink () {
    $(document).on('click', 'a[href^="matlab:"]', function (evt) {
        if (evt.target) {
            const href = getSelectedUrl(evt.target);
            let pageUrl = window.location.href;
            pageUrl = _normalizeEnglishRoute(pageUrl);
            if (href && isMatlabColonLink(href)) {
                evt.preventDefault();
                const messageObj = {
                    url: href,
                    currenturl: pageUrl
                };
                callMessageService('matlab', messageObj, function () {});
            }
        }
    });
}

function handleCustomDocLink () {
    $(window).bind('click', 'a', function (evt) {
        if (evt.target) {
            const href = getSelectedUrl(evt.target);
            if (href && isCustomDocLink(href)) {
                evt.preventDefault();
                const messageObj = {
                    url: href
                };
                callMessageService('custom_doc_link', messageObj, function (response) {
                    if (response && response.length > 0) {
                        const newUrl = response[0];
                        if (evt.ctrlKey) {
                            openUrlInNewTab(newUrl);
                        } else {
                            window.location.href = newUrl;
                        }
                    }
                });
            }
        }
    });
}

function handleDocLinksClick () {
    $(window).bind('click', 'a', function (evt) {
        if (evt.target) {
            const href = getSelectedUrl(evt.target);
            if (href && !isMatlabColonLink(href) && !isCustomDocLink(href) && (!href.match(/javascript:/))) {
                const currentPageHost = window.location.host;
                const currentPageProtocol = window.location.protocol;
                let pageUrl = window.location.href;
                pageUrl = _normalizeEnglishRoute(pageUrl);

                if (href &&
                   (href.indexOf(currentPageProtocol) < 0 || href.indexOf(currentPageHost) < 0) &&
                   href.indexOf('http') === 0 &&
                   (!_isLocalConnectorUrl(href)) &&
                   (!isWebDocUrl(href))) {
                    evt.preventDefault();
                    callMessageService('externalclick', { url: href }, function () {});
                } else if (_isExternalLinkForWebDoc(pageUrl, href)) {
                    // external link click for web doc
                    evt.preventDefault();
                    callMessageService('externalclick', { url: href }, function () {});
                } else if ((evt.target.target && evt.target.target === '_blank') || evt.ctrlKey) {
                    evt.preventDefault();
                    const openNewTabMsgObj = {
                        openaction: 'newtab',
                        openurl: href,
                        selecttab: 'false'
                    };
                    callMessageService('openbrowserstrategy', openNewTabMsgObj, function () {});
                } else if (_isEnglishRedirect(href)) {
                    evt.originalEvent.target.href = _replaceEnglishRoute(href);
                } else if (_isEnglishRoute(href)) {
                    evt.originalEvent.target.href = _normalizeEnglishRoute(href);
                }
            }
        }
    });
}

function _isExternalLinkForWebDoc (pageUrl, href) {
    // A link is external for web doc if:
    // 1) The page we're on:
    //    a) is not a connector url
    //    b) is under the web doc
    // 2) The page we're navigating to:
    //    a) is not a connector url
    //    b) is not under the web doc
    if ((!_isLocalConnectorUrl(pageUrl)) &&
        (pageUrl.indexOf('mathworks.com/help') > 0) &&
        (!_isLocalConnectorUrl(href)) &&
        (_notWebDoc(href))) {
        return true;
    }
    return false;
}

function _notWebDoc (href) {
    // A web doc page is not web doc if:
    // 1) It's not under the help
    // OR
    // 2) It's under the archived doc, pdf_doc
    //    When viewed in the help broswer, pdf doc is not treated as web doc,
    //    it's treated as an exteranl link
    const underHelp = (href.indexOf('mathworks.com/help') > 0);
    const pdfDoc = (!underHelp ? false : _isArchivePdfDoc(href));
    return ((!underHelp) || pdfDoc);
}

const releasesFolderPattern = /.*\/help\/releases\/(R20\d\d[ab])\/.*/;

function _isRequestFromArchiveArea (pageUrl) {
    return releasesFolderPattern.test(pageUrl);
}

function _getReleaseFromUrl () {
    const match = document.location.href.match(releasesFolderPattern);
    if (match) {
        return match[1];
    } else {
        return null;
    }
}

function _isArchivePdfDoc (href) {
    const archiveDoc = _isRequestFromArchiveArea(href);
    const archivePdfDoc = (!archiveDoc ? false : (href.indexOf('pdf_doc') > 0));
    return archivePdfDoc;
}

function isWebDocUrl (href) {
    const url = new URL(href);
    const searchParams = new URLSearchParams(url.search.slice(1));
    return searchParams.has('webdocurl');
}

function isMatlabColonLink (href) {
    return href.match(/^\s*matlab:(.*)/i);
}

function isCustomDocLink (href) {
    return href.match(/^.*\/3ptoolbox\/.*/);
}

function handleMiddleMouseClick () {
    $(window).bind('mousedown', 'a', function (evt) {
        if (evt.target) {
            if (_isMiddleMouse(evt)) {
                evt.preventDefault();
                const href = getSelectedUrl(evt.target);
                if (href && !isMatlabColonLink(href) && !isCustomDocLink(href)) {
                    openUrlInNewTab(href);
                } else if (href && isCustomDocLink(href)) {
                    const messageObj = {
                        url: href
                    };
                    callMessageService('custom_doc_link', messageObj, function (response) {
                        if (response && response.length > 0) {
                            const newUrl = response[0];
                            openUrlInNewTab(newUrl);
                        }
                    });
                }
            }
        }
    });
}

function openUrlInNewTab (href) {
    const openNewTabMsgObj = {
        openaction: 'newtab',
        openurl: href,
        selecttab: 'false'
    };
    callMessageService('openbrowserstrategy', openNewTabMsgObj, function () {});
}

function registerUninstalledDocLink () {
    // apply only to installed product doc.
    if (_isLocalConnectorUrl(window.location.href)) {
        $('a').bind('click', handleUninstalledDocLink);
    }
}

function registerWebDocLink () {
    if (_isWebDocUrl(window.location.href)) {
        $('a').bind('click', handleWebDocLink);
    }
}

function _isWebDocUrl (href) {
    return !_notWebDoc(href);
}

function _isMiddleMouse (evt) {
    return evt.which === 2;
}

function handleUninstalledDocLink (evt) {
    const href = $(this).prop('href'); // will return full url based on current href
    const hrefAttr = $(this).attr('href'); // will return actual href text
    if (href && (!href.match(/javascript:/i)) && !isMatlabColonLink(href) && !isCustomDocLink(href) && _isLocalConnectorUrl(href) && !_isMiddleMouse(evt) && !evt.ctrlKey && hrefAttr.indexOf('#') !== 0 && evt.target.target !== '_blank') {
        evt.preventDefault();
        const aTag = this;

        if (callMessageService) {
            callMessageService('doclink', { source: document.location.href, target: aTag.href }, function (response) {
                if (response.response === 'ok') {
                    checkCshDocLink(evt, href, aTag);
                } else {
                    const webUrl = (_isSessionStorageContains('link_handle_type', 'csh') ? response.data.replace('browser=F1help', '') : response.data);
                    const messageObj = {
                        domchannel: 'domeventinfo',
                        domevent: 'pagenotinstalled',
                        weburl: webUrl
                    };
                    helpserviceIframePostMessage(messageObj);
                }
            });
        }
    }
}

function handleWebDocLink (evt) {
    const href = $(this).prop('href'); // will return full url based on current href
    const hrefAttr = $(this).attr('href'); // will return actual href text
    if (href && (!href.match(/javascript:/i)) && _isWebDocUrl(href) && !_isMiddleMouse(evt) && !evt.ctrlKey && hrefAttr.indexOf('#') !== 0 && evt.target.target !== '_blank') {
        evt.preventDefault();
        const aTag = this;
        checkCshDocLink(evt, href, aTag);
    }
}

function checkCshDocLink (evt, href, aTag) {
    let pageUrl = window.location.href;
    pageUrl = _normalizeEnglishRoute(pageUrl);
    if (_isSessionStorageContains('link_handle_type', 'csh') && (href.indexOf('#') !== 0)) {
        const clickedUrl = getSelectedUrl(evt.target);
        const openDocMessageObj = {
            url: clickedUrl.replace('browser=F1help', ''),
            currenturl: pageUrl
        };
        callMessageService('openhelpbrowser', openDocMessageObj, function () {});
    } else {
        $(aTag).unbind('click');
        aTag.click();
    }
}

// this method only used when initial click on the link with 'lang=en' parameter
function _isEnglishRedirect (href) {
    return href && href.indexOf('lang=en') >= 0 && _isLocalConnectorUrl(href);
}

function _isEnglishRoute (href) {
    return href && href.indexOf('/static/en/help/') >= 0 && _isLocalConnectorUrl(href);
}

function _isLocalConnectorUrl (url) {
    if (!url) {
        return url;
    }
    return url.indexOf('https://localhost:') >= 0 || url.indexOf('https://127.0.0.1:') >= 0;
}

function isConnectorUrl (url) {
    return _isLocalConnectorUrl(url);
}

function _replaceEnglishRoute (url) {
    if (!url) {
        return url;
    }
    return url.replace(/\/static\/help\//, '/static/en/help/');
}

function _normalizeEnglishRoute (url) {
    if (!url) {
        return url;
    }
    return url.replace(/\/static\/en\/help\//, '/static/help/');
}

function setupFinished () {
    window.initDeferred.resolve();
    window.addEventListener('message', function (msgEvt) {
        this.helpService.receiveMessage(msgEvt);
    });
}

function requestHelpService (params, services, callback, errorhandler) {
    let servicePrefs;

    const releaseFromUrl = _getReleaseFromUrl();
    const servicePrefsStorageKey = 'help_services_' + (releaseFromUrl || 'latest');

    try {
        servicePrefs = $.parseJSON(window.sessionStorage.getItem(servicePrefsStorageKey));
    } catch (e) {
        servicePrefs = null;
    }

    if (servicePrefs) {
        doServiceRequest(servicePrefs, params, services, callback, errorhandler);
    } else {
        let url = '/help/search/supported_services.json';
        if (document.location.pathname.startsWith('/static')) {
            url = '/static' + url;
        }

        const jqxhr = $.getJSON(url);
        jqxhr.done(function (servicePrefs) {
            window.sessionStorage.setItem(servicePrefsStorageKey, JSON.stringify(servicePrefs));
            doServiceRequest(servicePrefs, params, services, callback, errorhandler);
        });
        jqxhr.fail(function () {
            servicePrefs = [{ name: 'webservice' }, { name: 'messageservice' }];
            doServiceRequest(servicePrefs, params, services, callback, errorhandler);
        });
    }
}

const handlerFunctions = {
    webservice: handleWebServiceRequest,
    localservice: handleWebServiceRequest,
    messagechannel: callMessageService,
    messageservice: handleMessageServiceMessage,
    rnservice: handleMessageServiceMessage
};

function doServiceRequest (servicePrefs, params, services, callback, errorhandler) {
    for (const svc of servicePrefs) {
        if (services[svc.name] && handlerFunctions[svc.name]) {
            const fcn = handlerFunctions[svc.name];
            if (fcn(services[svc.name], params, callback, errorhandler)) {
                return;
            }
        }
    }

    // If we get here, we didn't find a service to call. Call the error handler instead.
    if (errorhandler && typeof errorhandler === 'function') {
        errorhandler();
    }
}

function handleWebServiceRequest (serviceData, params, callback, errorhandler) {
    let url = serviceData;
    const qs = $.param(params);
    if (qs && qs.length > 0) {
        url += url.indexOf('?') > 0 ? '&' : '?';
        url += qs;
    }
    const jqxhr = $.getJSON(url);
    jqxhr.done(callback);
    if (errorhandler) {
        jqxhr.fail(errorhandler);
    }
    return true;
}

function handleMessageServiceMessage (serviceData, params, callback, errorhandler) {
    window.initDeferred.done(function () {
        if (window.helpService) {
            window.helpService.callRequestResponse(serviceData, params, callback);
        } else {
            errorhandler();
        }
    });
    return true;
}

function callMessageService (serviceData, params, callback, errorhandler) {
    window.initDeferred.done(function () {
        if (window.helpService) {
            window.helpService.callMessageService(serviceData, params, callback);
        } else {
            errorhandler();
        }
    });
    return true;
}
function isFromMatlabOnline () {
    const cookieRegexp = /MW_Doc_Template="?([^;"]*)/;
    const cookies = document.cookie;
    const matches = cookieRegexp.exec(cookies);
    if (matches != null && matches.length > 0) {
        const docCookie = matches[1];
        const parts = docCookie.split(/\|\|/);
        if (parts[0].indexOf('ONLINE') !== -1) {
            return true;
        }
    }
    return false;
}

function getProductsDeferred () {
    const deferred = $.Deferred(function () {});
    const services = {
        messagechannel: 'prodfilter',
        localservice: '/help/search/prodfilter',
        webservice: getProdFilterWebServiceUrl()
    };
    const errorhandler = function () {
        deferred.reject();
    };
    const successhandler = function (data) {
        deferred.resolve(data);
    };
    requestHelpService({}, services, successhandler, errorhandler);
    return deferred;
}

if (true) {
    exports.requestHelpService = requestHelpService;
    exports.isFromMatlabOnline = isFromMatlabOnline;
    exports.isMatlabColonLink = isMatlabColonLink;
    exports.handleMatlabColonLink = handleMatlabColonLink;
    exports.setupFinished = setupFinished;
    exports.getSelectedUrl = getSelectedUrl;
    exports.getSessionStorageItem = getSessionStorageItem;
    exports.isSessionStorageItem = isSessionStorageItem;
    exports.handleContextMenu = handleContextMenu;
    exports.isConnectorUrl = isConnectorUrl;
    exports.isWebDocUrl = isWebDocUrl;
    exports.helpserviceIframePostMessage = helpserviceIframePostMessage;
    exports.isCustomDocLink = isCustomDocLink;
    exports.handleCustomDocLink = handleCustomDocLink;
    exports.getProductsDeferred = getProductsDeferred;
    exports.registerUninstalledDocLink = registerUninstalledDocLink;
    exports.openUrlInNewTab = openUrlInNewTab;
}


/***/ })
/******/ ])));