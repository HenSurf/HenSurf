# HenFire Browser Privacy Policy

**Effective Date:** January 2025  
**Last Updated:** January 2025

## Our Commitment to Privacy

HenFire Browser is built with privacy as a core principle. Unlike many browsers, HenFire is designed to minimize data collection and maximize user control over their browsing experience.

## What Makes HenFire Different

### 🚫 No Telemetry
- **Zero data collection**: HenFire completely disables Mozilla's telemetry system
- **No usage statistics**: We don't track how you use the browser
- **No crash reports**: Crash reporting is disabled by default
- **No performance data**: No performance metrics are sent to any servers

### 🔒 Enhanced Privacy Features
- **Built-in ad blocking**: uBlock Origin integrated by default
- **Enhanced tracking protection**: Stronger than Firefox's default settings
- **No Pocket integration**: Pocket service is completely removed
- **No Firefox Accounts**: No sync service that could collect data

### 🧠 Local-Only Features
- **RAM management**: All memory optimization happens locally
- **Tab suspension**: Suspended tabs are stored locally only
- **Settings sync**: No cloud sync means your settings stay on your device

## Data We Don't Collect

HenFire does **NOT** collect:
- Browsing history
- Search queries
- Downloaded files
- Form data
- Passwords (unless you choose to save them locally)
- Extension usage
- Performance metrics
- Crash data
- System information
- Location data
- Personal identifiers

## Data That Stays Local

The following data is stored locally on your device and never transmitted:

### Browser Settings
- Your preferences and configuration
- Custom UI settings
- Memory management preferences
- Security and privacy settings

### Browsing Data
- Browsing history (if enabled)
- Bookmarks
- Saved passwords (if you choose to save them)
- Form autofill data
- Cookies and site data
- Cache files

### HenFire-Specific Data
- Memory usage statistics
- Tab suspension state
- UI customization preferences

## Network Connections

HenFire makes network connections only for:

### Essential Browser Functions
- Loading web pages you visit
- Downloading updates (if you enable automatic updates)
- Security certificate validation
- DNS resolution

### Optional Services (User-Controlled)
- Search engine queries (to your chosen search provider)
- Extension updates (if you install extensions)
- Safe browsing checks (can be disabled)

### What We've Removed
- Mozilla telemetry servers
- Crash reporting servers
- Pocket API connections
- Firefox Accounts servers
- Marketing and analytics endpoints

## Third-Party Services

### Search Engines
When you search, your query goes directly to your chosen search engine. HenFire doesn't intercept or log these queries.

### Extensions
If you install extensions, they operate according to their own privacy policies. We recommend reviewing extension permissions carefully.

### Websites
Websites you visit may collect data according to their own privacy policies. HenFire's enhanced tracking protection helps block many tracking attempts.

## Security Features

### Enhanced Protection
- **Stronger content blocking**: More aggressive ad and tracker blocking
- **Disabled risky features**: Potentially privacy-invasive features are disabled
- **Secure defaults**: Privacy-focused settings enabled by default

### Regular Security Updates
HenFire receives security updates from the Firefox base, ensuring you get critical security fixes without the privacy-invasive features.

## Your Control

### Complete Local Control
- All settings are stored locally
- No remote configuration changes
- You control all privacy settings
- Easy to export/import your data

### Transparency
- Open source codebase
- All privacy modifications are documented
- No hidden data collection
- Community-auditable code

## Data Retention

Since HenFire doesn't collect data, there's no data retention policy needed. All your data stays on your device for as long as you choose to keep it.

### Local Data Management
- **Browser history**: Controlled by your settings
- **Cache**: Automatically managed or manually cleared
- **Cookies**: Controlled by your privacy settings
- **Downloads**: Stored where you choose

## Children's Privacy

HenFire doesn't collect any personal information, making it safe for users of all ages. Parents should still supervise children's internet usage and consider using parental control software.

## International Users

HenFire's privacy protections apply globally. Since we don't collect data, there are no regional differences in our privacy practices.

## Changes to This Policy

We may update this privacy policy to reflect changes in HenFire's features. Any changes will be:
- Documented in our changelog
- Announced in release notes
- Always in favor of stronger privacy protection

## Comparison with Other Browsers

| Feature | HenFire | Firefox | Chrome | Safari |
|---------|---------|---------|--------|---------|
| Telemetry | ❌ Disabled | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| Crash Reporting | ❌ Disabled | ✅ Enabled | ✅ Enabled | ✅ Enabled |
| Built-in Ad Blocking | ✅ Yes | ❌ No | ❌ No | ⚠️ Limited |
| Cloud Sync | ❌ None | ✅ Firefox Accounts | ✅ Google Account | ✅ iCloud |
| Default Search | 🔍 User Choice | 🔍 Google | 🔍 Google | 🔍 Google |
| Privacy Focus | 🛡️ Maximum | ⚠️ Moderate | ❌ Minimal | ⚠️ Moderate |

## Technical Implementation

### Code-Level Privacy
HenFire's privacy features are implemented at the code level:

```javascript
// Example: Telemetry completely disabled
pref("toolkit.telemetry.enabled", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("datareporting.policy.dataSubmissionEnabled", false);
```

### Build-Time Removal
Privacy-invasive features are removed during the build process, not just disabled, ensuring they can't be accidentally re-enabled.

## Verification

### Open Source Audit
- All code is available on GitHub
- Privacy modifications are clearly documented
- Community can verify our claims
- No obfuscated or hidden code

### Network Monitoring
You can verify HenFire's privacy claims by monitoring network traffic. You'll see:
- No connections to Mozilla telemetry servers
- No unexpected data transmissions
- Only connections you initiate

## Contact Information

For privacy-related questions:
- **GitHub Issues**: [Report privacy concerns](https://github.com/henryperzinski/henfire/issues)
- **Email**: privacy@henfire.org (if available)
- **Documentation**: [Privacy documentation](https://github.com/henryperzinski/henfire/wiki/privacy)

## Legal Compliance

HenFire's approach of not collecting data helps ensure compliance with:
- GDPR (General Data Protection Regulation)
- CCPA (California Consumer Privacy Act)
- COPPA (Children's Online Privacy Protection Act)
- Other privacy regulations worldwide

## Conclusion

HenFire is designed for users who want the power and compatibility of Firefox without the privacy concerns. By removing data collection entirely rather than just providing opt-out options, we ensure your privacy is protected by default.

**Remember**: The best privacy policy is not needing one because no data is collected. That's the HenFire approach.

---

*This privacy policy reflects HenFire's commitment to user privacy. For technical details about our privacy implementations, see our [technical documentation](https://github.com/henryperzinski/henfire/wiki).*