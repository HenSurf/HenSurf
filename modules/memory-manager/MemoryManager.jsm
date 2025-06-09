/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

"use strict";

var EXPORTED_SYMBOLS = ["MemoryManager"];

const { Services } = ChromeUtils.import("resource://gre/modules/Services.jsm");
const { XPCOMUtils } = ChromeUtils.import("resource://gre/modules/XPCOMUtils.jsm");

/**
 * HenFire Memory Manager
 * Provides intelligent RAM management and limiting capabilities
 */
var MemoryManager = {
  _initialized: false,
  _maxMemoryMB: 2048,
  _suspendThresholdMB: 1536,
  _autoGCEnabled: true,
  _monitoringInterval: null,
  _suspendedTabs: new Set(),
  _isCheckingMemory: false,

  /**
   * Initialize the memory manager
   */
  init() {
    if (this._initialized) {
      return;
    }

    this._loadPreferences();
    this._startMonitoring();
    this._setupEventListeners();
    // UI setup is now deferred to final-ui-startup
    
    this._initialized = true;
    console.log("HenFire Memory Manager initialized");
  },

  /**
   * Load preferences from about:config
   */
  _loadPreferences() {
    try {
      this._maxMemoryMB = Services.prefs.getIntPref("henfire.memory.max_usage_mb", 2048);
      this._suspendThresholdMB = Services.prefs.getIntPref("henfire.memory.tab_suspend_threshold", 1536);
      this._autoGCEnabled = Services.prefs.getBoolPref("henfire.memory.auto_gc_enabled", true);
    } catch (e) {
      console.warn("HenFire: Error in _loadPreferences, could not load one or more preferences. Using defaults.", e);
    }
  },

  /**
   * Start memory monitoring
   */
  _startMonitoring() {
    // Monitor memory usage every 30 seconds
    this._monitoringInterval = setInterval(() => {
      this._checkMemoryUsage();
    }, 30000);
  },

  /**
   * Setup event listeners
   */
  _setupEventListeners() {
    // Listen for tab events
    Services.obs.addObserver(this, "quit-application");
    // Services.obs.addObserver(this, "domwindowopened"); // Will be added after initial UI setup
    Services.obs.addObserver(this, "final-ui-startup");
  },

  /**
   * Check current memory usage and take action if needed
   */
  _checkMemoryUsage() {
    if (this._isCheckingMemory) {
    }
    this._isCheckingMemory = true;
    try {
      const memoryReporter = Cc["@mozilla.org/memory-reporter-manager;1"]
        .getService(Ci.nsIMemoryReporterManager);
      
      const currentMemoryMB = memoryReporter.resident / (1024 * 1024);
      
      console.log(`HenFire Memory Usage: ${currentMemoryMB.toFixed(1)}MB / ${this._maxMemoryMB}MB`);
      
      // If we're approaching the limit, take action
      if (currentMemoryMB > this._suspendThresholdMB) {
        this._handleHighMemoryUsage(currentMemoryMB);
      }
      
      // If we're over the limit, be more aggressive
      if (currentMemoryMB > this._maxMemoryMB) {
        this._handleCriticalMemoryUsage(currentMemoryMB);
      }
    } catch (e) {
      console.error("HenFire: Error in _checkMemoryUsage:", e);
    } finally {
      this._isCheckingMemory = false;
    }
  },

  /**
   * Handle high memory usage (approaching limit)
   */
  _handleHighMemoryUsage(currentMemoryMB) {
    console.log("HenFire: High memory usage detected, taking preventive action");
    
    // Suspend inactive tabs
    this._suspendInactiveTabs();
    
    // Trigger garbage collection if enabled
    if (this._autoGCEnabled) {
      this._triggerGarbageCollection();
    }
    
    // Clear caches
    this._clearCaches();
  },

  /**
   * Handle critical memory usage (over limit)
   */
  _handleCriticalMemoryUsage(currentMemoryMB) {
    console.warn("HenFire: Critical memory usage detected, taking aggressive action");
    
    // More aggressive tab suspension
    this._suspendInactiveTabs(true);
    
    // Force garbage collection
    this._triggerGarbageCollection(true);
    
    // Clear all possible caches
    this._clearCaches(true);
    
    // Minimize memory usage
    this._minimizeMemoryUsage();
  },

  /**
   * Suspend inactive tabs to free memory
   */
  _suspendInactiveTabs(aggressive = false) {
    try {
      const windows = Services.wm.getEnumerator("navigator:browser");
      
      while (windows.hasMoreElements()) {
        const window = windows.getNext();
        const tabbrowser = window.gBrowser;
        
        if (!tabbrowser) continue;
        
        for (let i = 0; i < tabbrowser.tabs.length; i++) {
          const tab = tabbrowser.tabs[i];
          const browser = tab.linkedBrowser;
          
          // Don't suspend the active tab unless in aggressive mode
          if (tab === tabbrowser.selectedTab && !aggressive) {
            continue;
          }
          
          // Don't suspend already suspended tabs
          if (this._suspendedTabs.has(tab)) {
            continue;
          }
          
          // Don't suspend tabs with active media
          if (tab.hasAttribute("soundplaying") || tab.hasAttribute("muted")) {
            continue;
          }
          
          this._suspendTab(tab, browser);
        }
      }
    } catch (e) {
      console.error("HenFire: Error in _suspendInactiveTabs during tab iteration:", e);
    }
  },

  /**
   * Suspend a specific tab
   */
  _suspendTab(tab, browser) {
    try {
      // Mark tab as suspended
      tab.setAttribute("henfire-suspended", "true");
      this._suspendedTabs.add(tab);
      
      // Store tab state
      const tabState = {
        url: browser.currentURI.spec,
        title: tab.label
      };
      
      tab._henFireState = tabState;
      
      // Replace content with placeholder
      browser.loadURI(Services.io.newURI("about:blank"), {
        triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal()
      });
      
      console.log(`HenFire: Suspended tab: ${tabState.title}`);
    } catch (e) {
      console.error("HenFire: Error in _suspendTab:", e);
    }
  },

  /**
   * Restore a suspended tab
   */
  restoreTab(tab) {
    try {
      if (!this._suspendedTabs.has(tab)) {
        return;
      }
      
      const tabState = tab._henFireState;
      if (tabState) {
        const browser = tab.linkedBrowser;
        browser.loadURI(Services.io.newURI(tabState.url), {
          triggeringPrincipal: Services.scriptSecurityManager.getSystemPrincipal()
        });
      }
      
      tab.removeAttribute("henfire-suspended");
      this._suspendedTabs.delete(tab);
      delete tab._henFireState;
      
      console.log("HenFire: Restored suspended tab");
    } catch (e) {
      console.error("HenFire: Error in restoreTab:", e);
    }
  },

  /**
   * Trigger garbage collection
   */
  _triggerGarbageCollection(force = false) {
    try {
      if (force) {
        // Force immediate GC
        Cu.forceGC();
        Cu.forceCC();
      } else {
        // Schedule GC
        Cu.schedulePreciseGC(() => {
          console.log("HenFire: Garbage collection completed");
        });
      }
    } catch (e) {
      console.error("HenFire: Error in _triggerGarbageCollection:", e);
    }
  },

  /**
   * Clear various caches
   */
  _clearCaches(aggressive = false) {
    try {
      // Clear network cache
      Services.cache2.clear();
      
      // Clear image cache
      const imgCache = Cc["@mozilla.org/image/cache;1"].getService(Ci.imgICache);
      imgCache.clearCache(false);
      
      if (aggressive) {
        // Clear more caches in aggressive mode
        imgCache.clearCache(true); // Clear chrome cache too
        
        // Clear DNS cache
        Services.dns.clearCache(true);
      }
      
      console.log("HenFire: Caches cleared");
    } catch (e) {
      console.error("HenFire: Error in _clearCaches:", e);
    }
  },

  /**
   * Minimize memory usage (equivalent to about:memory minimize)
   */
  _minimizeMemoryUsage() {
    try {
      const memoryReporter = Cc["@mozilla.org/memory-reporter-manager;1"]
        .getService(Ci.nsIMemoryReporterManager);
      memoryReporter.minimizeMemoryUsage(() => {
        console.log("HenFire: Memory usage minimized");
      });
    } catch (e) {
      console.error("HenFire: Error in _minimizeMemoryUsage:", e);
    }
  },

  /**
   * Setup UI elements for a given browser window
   */
  _setupWindowUI(window) {
    try {
      let tabContextMenu = window.document.getElementById("tabContextMenu");
      if (!tabContextMenu) {
      // Create "Restore Suspended Tab" menu item
      let menuItem = window.document.createXULElement("menuitem");
      menuItem.id = "context_restoreHenFireTab";
      menuItem.label = "Restore Suspended Tab";
      // Ensure 'this' refers to MemoryManager when restoreTab is called
      menuItem.addEventListener("command", () => this.restoreTab(window.gBrowser.selectedTab));
      tabContextMenu.appendChild(menuItem);

      // Store for cleanup
      window.henFireRestoreTabMenuItem = menuItem;

      // Control visibility
      window.henFireTabContextMenuListener = event => {
        try {
          const currentTab = window.gBrowser.selectedTab;
          // The menuItem might be gone if the context menu is shown during shutdown/cleanup
          const currentMenuItem = window.document.getElementById("context_restoreHenFireTab");
          if (currentMenuItem && currentTab) {
            const isSuspended = currentTab.hasAttribute("henfire-suspended");
            currentMenuItem.hidden = !isSuspended;
          }
        } catch (uiEventError) {
          console.error("HenFire: Error in tabContextMenu popupshowing listener:", uiEventError);
        }
      };
      tabContextMenu.addEventListener("popupshowing", window.henFireTabContextMenuListener);
      console.log("HenFire: Added context menu item to a window.");

      // Add TabClose listener for _henFireState cleanup
      if (window.gBrowser && window.gBrowser.tabContainer) {
        let tabContainer = window.gBrowser.tabContainer;
        window.henFireTabCloseListener = event => {
          try {
            let tab = event.target;
            if (tab && this._suspendedTabs.has(tab)) {
              this._suspendedTabs.delete(tab);
              delete tab._henFireState;
              console.log("HenFire: Cleaned up _henFireState for closed suspended tab:", tab.label);
            }
          } catch (tabCloseError) {
            console.error("HenFire: Error in TabClose listener:", tabCloseError);
          }
        };
        tabContainer.addEventListener("TabClose", window.henFireTabCloseListener);
      }
    } catch (e) {
      console.error("HenFire: Error in _setupWindowUI:", e);
    }
  },

  /**
   * Handle a new window being opened
   */
  // _onWindowOpened method is removed as its logic is integrated into observe for domwindowopened.

  /**
   * Get current memory statistics
   */
  getMemoryStats() {
    try {
      const memoryReporter = Cc["@mozilla.org/memory-reporter-manager;1"]
        .getService(Ci.nsIMemoryReporterManager);
      
      return {
        resident: memoryReporter.resident,
        residentMB: memoryReporter.resident / (1024 * 1024),
        maxMemoryMB: this._maxMemoryMB,
        suspendThresholdMB: this._suspendThresholdMB,
        suspendedTabsCount: this._suspendedTabs.size
      };
    } catch (e) {
      console.error("HenFire: Error in getMemoryStats:", e);
      return null;
    }
  },

  /**
   * Observer interface
   */
  observe(subject, topic, data) {
    switch (topic) {
      case "quit-application":
        this.shutdown();
        break;
      // Removed tab-closed case
      case "final-ui-startup": {
        console.log("HenFire: Received final-ui-startup. Setting up UI for existing windows.");
        const windows = Services.wm.getEnumerator("navigator:browser");
        while (windows.hasMoreElements()) {
          const window = windows.getNext();
          try {
            let domWin = window.QueryInterface(Ci.nsIDOMWindow);
            this._setupWindowUI(domWin);
          } catch (e) {
            console.error("HenFire: Error setting up UI for an existing window during final-ui-startup:", e);
          }
        }
        // Now that initial windows are handled, listen for newly opened windows.
        Services.obs.addObserver(this, "domwindowopened");
        break;
      }
      case "domwindowopened": {
        try {
          let openedWindow = subject.QueryInterface(Ci.nsIDOMWindow);
          if (openedWindow.document.documentElement.getAttribute("windowtype") == "navigator:browser") {
            // Add a load event listener to ensure the window's UI is ready
            openedWindow.addEventListener("load", () => {
              // 'this' inside arrow function will be MemoryManager
              this._setupWindowUI(openedWindow);
            }, { once: true });
          }
        } catch (e) {
          console.error("HenFire: Error in domwindowopened handler:", e);
        }
        break;
      }
    }
  },

  /**
   * Shutdown the memory manager
   */
  shutdown() {
    if (this._monitoringInterval) {
      clearInterval(this._monitoringInterval);
      this._monitoringInterval = null;
    }
    
    Services.obs.removeObserver(this, "quit-application");
    Services.obs.removeObserver(this, "final-ui-startup");
    Services.obs.removeObserver(this, "domwindowopened"); // Ensure this is removed if it was added

    // Cleanup UI for all open windows
    const windows = Services.wm.getEnumerator("navigator:browser");
    while (windows.hasMoreElements()) {
        if (window.henFireRestoreTabMenuItem && window.henFireRestoreTabMenuItem.parentNode) {
          window.henFireRestoreTabMenuItem.parentNode.removeChild(window.henFireRestoreTabMenuItem);
        }
        delete window.henFireRestoreTabMenuItem;

        if (window.henFireTabContextMenuListener) {
          let tabContextMenu = window.document.getElementById("tabContextMenu");
          if (tabContextMenu) {
            tabContextMenu.removeEventListener("popupshowing", window.henFireTabContextMenuListener);
          }
        }
        delete window.henFireTabContextMenuListener;

        if (window.gBrowser && window.gBrowser.tabContainer && window.henFireTabCloseListener) {
          window.gBrowser.tabContainer.removeEventListener("TabClose", window.henFireTabCloseListener);
          delete window.henFireTabCloseListener;
        }
      } catch (e) {
      }
    }
    
    this._initialized = false;
    console.log("HenFire Memory Manager shutdown");
  }
};