# Quick Start: CI/CD for MUDRammer

Get up and running with the CI/CD pipeline in 5 minutes.

---

## Prerequisites

- **macOS** with Xcode 14.3+ installed
- **Ruby** 3.1+ (check: `ruby --version`)
- **Bundler** (install: `gem install bundler`)
- **Git** configured

---

## 1. Initial Setup (One Time)

```bash
# Clone repository
git clone https://github.com/AndrewGoldfinch/MUDRammer.git
cd MUDRammer

# Install Ruby dependencies
bundle install

# Install CocoaPods dependencies
bundle exec pod install --project-directory=src

# Verify setup
bundle exec fastlane test
```

**Expected**: Tests run and pass ✅

---

## 2. Running Tests Locally

### Quick Test Run

```bash
# Run all tests
bundle exec fastlane test
```

### With Coverage Report

```bash
# Run tests + generate HTML coverage report
bundle exec fastlane test_with_coverage

# View coverage
open output/coverage/index.html
```

### Just the New ANSI Tests

```bash
# Run comprehensive ANSI engine tests
bundle exec fastlane test_comprehensive
```

### Performance Benchmarks

```bash
# Run performance tests
bundle exec fastlane benchmark
```

---

## 3. Code Quality Checks

```bash
# Run all linting and quality checks
bundle exec fastlane lint
```

This checks:
- Lines of code count
- Outdated dependencies
- Unused imports
- Header style consistency
- Static analysis

---

## 4. Pre-Commit Checks (Fast)

```bash
# Quick checks before committing
bundle exec fastlane precommit
```

Runs a fast subset of tests (~2 min).

---

## 5. Full CI Pipeline

```bash
# Run everything (same as CI server)
bundle exec fastlane ci
```

Runs:
1. Setup
2. Tests with coverage
3. Linting
4. Coverage report generation

**Time**: ~8-12 minutes

---

## 6. GitHub Actions (Automatic)

### Triggering CI

CI runs automatically on:

```bash
# Push to main branches
git push origin master
git push origin develop

# Push to feature branch
git push origin claude/my-feature

# Open a pull request
# (CI runs automatically)
```

### Viewing Results

1. Go to repository on GitHub
2. Click **Actions** tab
3. See workflow runs
4. Click any run for details

### CI Status Badge

Add to README.md:

```markdown
![CI](https://github.com/AndrewGoldfinch/MUDRammer/workflows/CI/badge.svg)
```

---

## 7. Common Commands

### Build

```bash
# Build without running tests
bundle exec fastlane build
```

### Documentation

```bash
# Generate API documentation
bundle exec fastlane docs

# View documentation
open docs/index.html
```

### Code Metrics

```bash
# Analyze code size and complexity
bundle exec fastlane analyze_code_metrics

# View results
cat output/cloc.csv
open output/complexity.html  # if lizard installed
```

---

## 8. Troubleshooting

### Tests Fail Locally

```bash
# Clean build
rm -rf ~/Library/Developer/Xcode/DerivedData
bundle exec fastlane test
```

### CocoaPods Issues

```bash
# Clean and reinstall
bundle exec pod cache clean --all
rm -rf src/Pods src/Podfile.lock
bundle exec pod install --project-directory=src
```

### Ruby Dependencies

```bash
# Update gems
bundle update
```

### Simulator Not Found

```bash
# List available simulators
xcrun simctl list devices

# Create if needed
xcrun simctl create "iPhone 14" "iPhone 14" "iOS16.4"
```

---

## 9. Setting Up Pre-Commit Hook

Auto-run checks before every commit:

```bash
# Create hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."
bundle exec fastlane precommit || exit 1
echo "✓ Pre-commit checks passed!"
EOF

# Make executable
chmod +x .git/hooks/pre-commit

# Test it
git commit -m "test"
```

---

## 10. IDE Integration

### Xcode

Run tests in Xcode:

1. Open `src/Mudrammer.xcworkspace`
2. Select `MUDRammer Dev` scheme
3. Press `Cmd+U` to run tests

### VSCode

Install extensions:
- [Ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby)
- [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)

Add to `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Tests",
      "type": "shell",
      "command": "bundle exec fastlane test",
      "group": "test",
      "presentation": {
        "reveal": "always"
      }
    },
    {
      "label": "Pre-commit",
      "type": "shell",
      "command": "bundle exec fastlane precommit",
      "group": "test"
    }
  ]
}
```

---

## 11. Workflow Diagram

```
Developer → Commit → Push → GitHub
                              │
                              ├─→ CI Workflow (Automatic)
                              │   ├─ Test (8 min)
                              │   ├─ Lint (3 min)
                              │   ├─ Security (2 min)
                              │   └─ Coverage Upload
                              │
                              └─→ PR Checks (if PR)
                                  ├─ Title format
                                  ├─ Code review
                                  ├─ Size check
                                  └─ Coverage report
```

---

## 12. Configuration Files

| File | Purpose |
|------|---------|
| `.github/workflows/ci.yml` | Main CI workflow |
| `.github/workflows/pr-checks.yml` | PR validation |
| `fastlane/Fastfile` | Fastlane lanes |
| `fastlane/Appfile` | App configuration |
| `.slather.yml` | Coverage settings |
| `.swiftlint.yml` | Swift linting (future) |
| `Gemfile` | Ruby dependencies |
| `Rakefile` | Rake tasks |

---

## 13. Useful Aliases

Add to `.bashrc` or `.zshrc`:

```bash
# MUDRammer aliases
alias mr-test="bundle exec fastlane test"
alias mr-lint="bundle exec fastlane lint"
alias mr-ci="bundle exec fastlane ci"
alias mr-pre="bundle exec fastlane precommit"
alias mr-cov="bundle exec fastlane test_with_coverage && open output/coverage/index.html"
```

---

## 14. FAQ

**Q: How long does CI take?**
A: Full pipeline: 8-12 minutes. Tests only: ~5 minutes.

**Q: Can I run CI locally?**
A: Yes! `bundle exec fastlane ci` runs the same pipeline.

**Q: Do I need CocoaPods keys?**
A: For CI, they're auto-set to dummy values. For local dev, run `rake setup`.

**Q: How do I update Xcode version?**
A: Update `DEVELOPER_DIR` in `.github/workflows/ci.yml`.

**Q: Can I skip CI on a commit?**
A: Add `[skip ci]` or `[ci skip]` to commit message.

**Q: Where are test results?**
A: Local: `output/junit.xml`, GitHub: Artifacts tab.

---

## 15. Next Steps

✅ **Now you can:**

1. Run tests locally: `bundle exec fastlane test`
2. Check code quality: `bundle exec fastlane lint`
3. Generate coverage: `bundle exec fastlane test_with_coverage`
4. Run full CI: `bundle exec fastlane ci`
5. Push code and see CI run automatically

📚 **Learn more:**

- Full docs: [CI_CD_SETUP.md](CI_CD_SETUP.md)
- Fastlane: [fastlane.tools](https://fastlane.tools)
- GitHub Actions: [docs.github.com/actions](https://docs.github.com/en/actions)

---

## Need Help?

- Check [CI_CD_SETUP.md](CI_CD_SETUP.md) for detailed docs
- View [GitHub Actions runs](https://github.com/AndrewGoldfinch/MUDRammer/actions)
- Check [Fastlane docs](https://docs.fastlane.tools)

**Happy testing!** 🎉
