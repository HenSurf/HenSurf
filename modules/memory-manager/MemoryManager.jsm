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
      console.warn("Failed to load memory manager preferences:", e);
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
    Services.obs.addObserver(this, "browser-delayed-startup-finished");
    Services.obs.addObserver(this, "quit-application");
  },

  /**
   * Check current memory usage and take action if needed
   */
  _checkMemoryUsage() {
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
      console.error("Error checking memory usage:", e);
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
      console.error("Error suspending tabs:", e);
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
      console.error("Error suspending tab:", e);
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
      console.error("Error restoring tab:", e);
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
      console.error("Error triggering garbage collection:", e);
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
      console.error("Error clearing caches:", e);
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
      console.error("Error minimizing memory usage:", e);
    }
  },

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
      console.error("Error getting memory stats:", e);
      return null;
    }
  },

  /**
   * Observer interface
   */
  observe(subject, topic, data) {
    switch (topic) {
      case "browser-delayed-startup-finished":
        // Browser is ready, start monitoring
        break;
      case "quit-application":
        this.shutdown();
        break;
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
    
    Services.obs.removeObserver(this, "browser-delayed-startup-finished");
    Services.obs.removeObserver(this, "quit-application");
    
    this._initialized = false;
    console.log("HenFire Memory Manager shutdown");
  }
};