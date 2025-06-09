# Contributing to HenFire Browser

Thank you for your interest in contributing to HenFire! This guide will help you get started with contributing to our privacy-focused Firefox fork.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Issue Reporting](#issue-reporting)
- [Feature Requests](#feature-requests)
- [Documentation](#documentation)
- [Community](#community)

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

### Our Pledge
- Be respectful and inclusive
- Focus on constructive feedback
- Prioritize user privacy and security
- Maintain professional communication
- Help create a welcoming environment for all contributors

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or inflammatory comments
- Publishing private information without consent
- Any behavior that compromises user privacy or security

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Development Environment**
   - macOS 10.15+ (primary development platform)
   - Xcode Command Line Tools
   - Python 3.11+
   - Git
   - 15GB+ free disk space

2. **Knowledge Areas**
   - JavaScript/C++ (for browser development)
   - CSS (for UI modifications)
   - Shell scripting (for build tools)
   - Firefox/Gecko architecture (helpful)

### First Steps

1. **Fork the Repository**
   ```bash
   git clone https://github.com/henryperzinski/henfire.git
   cd henfire
   ```

2. **Set Up Development Environment**
   ```bash
   ./scripts/bootstrap.sh
   ```

3. **Build HenFire**
   ```bash
   ./mach setup
   ./mach build
   ```

4. **Run Tests**
   ```bash
   ./mach test
   ```

## Development Setup

### Repository Structure

```
HenFire/
├── browser/branding/henfire/     # HenFire branding
├── config/                       # Build configuration
├── modules/                      # Custom HenFire modules
│   ├── memory-manager/          # RAM management
│   └── ui-cleaner/              # Clean UI components
├── scripts/                     # Build and setup scripts
├── gecko-dev/                   # Firefox source (after bootstrap)
└── docs/                        # Documentation
```

### Development Workflow

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow our coding standards
   - Test your changes thoroughly
   - Update documentation as needed

3. **Test Changes**
   ```bash
   ./mach clean-customizations
   ./mach setup
   ./mach build
   ./mach run
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add new memory management feature"
   ```

## Contributing Guidelines

### Types of Contributions

#### 🐛 Bug Fixes
- Fix crashes or unexpected behavior
- Resolve memory leaks
- Correct UI/UX issues
- Security vulnerability patches

#### ✨ New Features
- Memory management improvements
- UI/UX enhancements
- Privacy feature additions
- Performance optimizations

#### 📚 Documentation
- Code documentation
- User guides
- Developer tutorials
- API documentation

#### 🧪 Testing
- Unit tests
- Integration tests
- Performance benchmarks
- Security audits

### Contribution Process

1. **Check Existing Issues**
   - Look for existing issues or feature requests
   - Comment on issues you'd like to work on
   - Ask questions if requirements are unclear

2. **Discuss Major Changes**
   - Open an issue for significant features
   - Discuss architecture and approach
   - Get feedback before implementation

3. **Follow Development Standards**
   - Use consistent code style
   - Write comprehensive tests
   - Update documentation
   - Follow security best practices

## Code Style

### JavaScript

```javascript
// Use modern ES6+ syntax
const MemoryManager = {
  // Use descriptive names
  async checkMemoryUsage() {
    try {
      const memInfo = await this.getMemoryInfo();
      return memInfo;
    } catch (error) {
      console.error('Memory check failed:', error);
      throw error;
    }
  },

  // Document complex functions
  /**
   * Suspends inactive tabs to free memory
   * @param {number} threshold - Memory threshold percentage
   * @returns {Promise<number>} Number of tabs suspended
   */
  async suspendInactiveTabs(threshold = 75) {
    // Implementation
  }
};
```

### CSS

```css
/* Use clear, semantic class names */
.henfire-memory-indicator {
  display: flex;
  align-items: center;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

/* Group related styles */
.henfire-tab-suspended {
  opacity: 0.6;
  font-style: italic;
}

.henfire-tab-suspended::before {
  content: "💤 ";
  margin-right: 4px;
}
```

### Shell Scripts

```bash
#!/bin/bash

# Use strict error handling
set -euo pipefail

# Document functions
# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Use descriptive variable names
HENFIRE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GECKO_SOURCE="${HENFIRE_ROOT}/gecko-dev"
```

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(memory): add configurable memory thresholds

fix(ui): resolve tab suspension indicator positioning

docs(install): update macOS build requirements
```

## Testing

### Test Categories

#### Unit Tests
```javascript
// Test memory management functions
describe('MemoryManager', () => {
  it('should suspend tabs when memory threshold exceeded', async () => {
    const manager = new MemoryManager();
    const result = await manager.suspendInactiveTabs(75);
    expect(result).toBeGreaterThan(0);
  });
});
```

#### Integration Tests
```javascript
// Test UI and memory management integration
describe('Memory UI Integration', () => {
  it('should update memory indicator when usage changes', async () => {
    // Test implementation
  });
});
```

#### Manual Testing

1. **Memory Management**
   - Open 20+ tabs
   - Monitor memory usage
   - Verify tab suspension
   - Check memory recovery

2. **UI Testing**
   - Test clean UI elements
   - Verify dark mode
   - Check responsive design
   - Test accessibility

3. **Privacy Testing**
   - Verify no telemetry
   - Check tracking protection
   - Test ad blocking
   - Validate secure defaults

### Running Tests

```bash
# Run all tests
./mach test

# Run specific test suites
./mach test browser/modules/memory-manager/

# Run performance tests
./mach test --performance

# Run privacy audit
./mach test --privacy-audit
```

## Submitting Changes

### Pull Request Process

1. **Prepare Your PR**
   - Ensure all tests pass
   - Update documentation
   - Add changelog entry
   - Rebase on latest main

2. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Performance improvement

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Manual testing completed
   - [ ] Performance impact assessed

   ## Privacy Impact
   - [ ] No new data collection
   - [ ] Privacy settings reviewed
   - [ ] Security implications considered

   ## Screenshots (if applicable)
   [Add screenshots for UI changes]
   ```

3. **Review Process**
   - Automated tests must pass
   - Code review by maintainers
   - Privacy and security review
   - Performance impact assessment

### Review Criteria

- **Code Quality**: Clean, readable, maintainable
- **Testing**: Adequate test coverage
- **Documentation**: Updated and accurate
- **Privacy**: No compromise to user privacy
- **Performance**: No significant performance regression
- **Security**: Follows security best practices

## Issue Reporting

### Bug Reports

Use this template for bug reports:

```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- HenFire Version: 
- Operating System: 
- Hardware: 

**Additional Context**
Screenshots, logs, etc.
```

### Security Issues

**Do not report security issues publicly!**

For security vulnerabilities:
1. Email: security@henfire.org
2. Include detailed reproduction steps
3. Wait for acknowledgment before disclosure

## Feature Requests

### Feature Request Template

```markdown
**Feature Description**
Clear description of the proposed feature

**Use Case**
Why is this feature needed?

**Proposed Solution**
How should this feature work?

**Alternatives Considered**
Other approaches you've considered

**Privacy Impact**
How does this affect user privacy?

**Implementation Complexity**
- [ ] Simple (few hours)
- [ ] Medium (few days)
- [ ] Complex (weeks)
```

### Feature Evaluation Criteria

- **Privacy First**: Does it enhance or maintain privacy?
- **User Benefit**: Clear value to users
- **Maintenance**: Long-term maintainability
- **Performance**: Impact on browser performance
- **Complexity**: Implementation and testing effort

## Documentation

### Documentation Standards

1. **Code Documentation**
   - JSDoc for JavaScript functions
   - Inline comments for complex logic
   - README files for modules

2. **User Documentation**
   - Clear, step-by-step instructions
   - Screenshots for UI features
   - Troubleshooting sections

3. **Developer Documentation**
   - Architecture decisions
   - API documentation
   - Build process details

### Documentation Updates

When contributing:
- Update relevant documentation
- Add new documentation for new features
- Keep examples current and working
- Review for clarity and accuracy

## Community

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Email**: security@henfire.org (security issues only)

### Getting Help

1. **Check Documentation**: README, INSTALL, this guide
2. **Search Issues**: Look for existing solutions
3. **Ask Questions**: Open a discussion or issue
4. **Join Development**: Contribute to ongoing work

### Recognition

Contributors are recognized through:
- Contributor list in README
- Changelog acknowledgments
- GitHub contributor statistics
- Special recognition for significant contributions

## Development Tips

### Performance Considerations

- Profile memory usage changes
- Test with limited RAM scenarios
- Monitor CPU impact
- Verify startup time impact

### Privacy Guidelines

- Never add telemetry or tracking
- Minimize network requests
- Respect user preferences
- Default to most private settings

### Debugging

```bash
# Debug build
./mach build --debug

# Run with debugging
./mach run --debug

# Memory debugging
./mach run --memory-debug
```

## Questions?

If you have questions about contributing:

1. Check this guide and other documentation
2. Search existing issues and discussions
3. Open a new discussion with your question
4. Tag relevant maintainers if needed

Thank you for contributing to HenFire! Together, we're building a more private and efficient browsing experience.