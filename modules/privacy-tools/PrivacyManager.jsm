/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

"use strict";

var EXPORTED_SYMBOLS = ["PrivacyManager"];

const { Services } = ChromeUtils.import("resource://gre/modules/Services.jsm");
const { XPCOMUtils } = ChromeUtils.import("resource://gre/modules/XPCOMUtils.jsm");

/**
 * HenFire Privacy Manager
 * Handles privacy-focused features and configurations
 */
var PrivacyManager = {
  _initialized: false,

  /**
   * Initialize the Privacy Manager
   */
  init() {
    if (this._initialized) {
      return;
    }

    console.log("[HenSurf] Initializing Privacy Manager...");

    // Disable telemetry
    this._disableTelemetry();

    // Configure tracking protection
    this._configureTrackingProtection();

    // Disable crash reporting
    this._disableCrashReporting();

    // Configure DNS over HTTPS
    this._configureDNSOverHTTPS();

    this._initialized = true;
    console.log("[HenSurf] Privacy Manager initialized successfully");
  },

  /**
   * Disable Firefox telemetry and data collection
   */
  _disableTelemetry() {
    const telemetryPrefs = [
      "toolkit.telemetry.enabled",
      "toolkit.telemetry.unified",
      "toolkit.telemetry.archive.enabled",
      "toolkit.telemetry.newProfilePing.enabled",
      "toolkit.telemetry.shutdownPingSender.enabled",
      "toolkit.telemetry.updatePing.enabled",
      "toolkit.telemetry.bhrPing.enabled",
      "toolkit.telemetry.firstShutdownPing.enabled",
      "datareporting.healthreport.uploadEnabled",
      "datareporting.policy.dataSubmissionEnabled",
      "app.shield.optoutstudies.enabled",
      "browser.discovery.enabled",
      "browser.ping-centre.telemetry"
    ];

    telemetryPrefs.forEach(pref => {
      try {
        Services.prefs.setBoolPref(pref, false);
      } catch (e) {
        console.warn(`[HenSurf] Error in _disableTelemetry: Could not set preference ${pref}.`, e);
      }
    });
  },

  /**
   * Configure enhanced tracking protection
   */
  _configureTrackingProtection() {
    try {
      // Enable strict tracking protection
      // Services.prefs.setStringPref("privacy.trackingprotection.mode", "always"); // Deprecated / Not needed with granular settings
      Services.prefs.setBoolPref("privacy.trackingprotection.enabled", true);
      Services.prefs.setBoolPref("privacy.trackingprotection.pbmode.enabled", true); // Ensure ETP is on in Private Browsing
      Services.prefs.setBoolPref("privacy.trackingprotection.socialtracking.enabled", true);
      Services.prefs.setBoolPref("privacy.trackingprotection.fingerprinting.enabled", true);
      Services.prefs.setBoolPref("privacy.trackingprotection.cryptomining.enabled", true);
      
      // Enhanced cookie protection
      Services.prefs.setIntPref("network.cookie.cookieBehavior", 5); // Total Cookie Protection
      Services.prefs.setBoolPref("privacy.firstparty.isolate", true);
      
      console.log("[HenSurf] Enhanced tracking protection configured");
    } catch (e)
      console.error("[HenSurf] Error in _configureTrackingProtection: Failed to set one or more tracking protection preferences.", e);
    }
  },

  /**
   * Disable crash reporting
   */
  _disableCrashReporting() {
    const crashPrefs = [
      "breakpad.reportURL",
      "browser.crashReports.unsubmittedCheck.autoSubmit2",
      "browser.crashReports.unsubmittedCheck.enabled"
    ];

    crashPrefs.forEach(pref => {
      try {
        if (pref === "breakpad.reportURL") {
          Services.prefs.setStringPref(pref, "");
        } else {
          Services.prefs.setBoolPref(pref, false);
        }
      } catch (e) {
        console.warn(`[HenSurf] Error in _disableCrashReporting: Could not set crash preference ${pref}.`, e);
      }
    });
  },

  /**
   * Configure DNS over HTTPS for enhanced privacy
   */
  _configureDNSOverHTTPS() {
    try {
      // Enable DNS over HTTPS
      // Mode 5: TRR-Only mode. Prevents fallback to system DNS, enhancing privacy.
      Services.prefs.setIntPref("network.trr.mode", 5);
      Services.prefs.setStringPref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
      Services.prefs.setStringPref("network.trr.bootstrapAddress", "1.1.1.1"); // Ensure correct type
      
    } catch (e) {
      console.error("[HenSurf] Error in _configureDNSOverHTTPS: Failed to set one or more DNS over HTTPS preferences.", e);
    }
  },

  /**
   * Get privacy status information
   */
  getPrivacyStatus() {
    return {
      telemetryDisabled: !Services.prefs.getBoolPref("toolkit.telemetry.enabled", true),
      trackingProtectionEnabled: Services.prefs.getBoolPref("privacy.trackingprotection.enabled", false),
      dohEnabled: Services.prefs.getIntPref("network.trr.mode", 0) > 0,
      crashReportingDisabled: !Services.prefs.getBoolPref("browser.crashReports.unsubmittedCheck.enabled", true)
    };
  },

  /**
   * Shutdown the Privacy Manager
   */
  shutdown() {
    if (!this._initialized) {
      return;
    }

    console.log("[HenSurf] Privacy Manager shutting down...");
    this._initialized = false;
  }
};