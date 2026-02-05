# Browser Testing Checklist - React/Supabase

**Project**: {PROJECT_NAME}
**Dev Server**: http://localhost:{PORT}
**Environment**: Supabase Dev Instance

## Critical: Use browser-action Tool

You have access to the `browser-action` tool (Puppeteer/Chromium). Use it to:
- Navigate the application
- Interact with UI elements
- Capture console errors
- Take screenshots of issues
- Verify functionality

## Testing Workflow

### 1. Initial Load Test
- [ ] Open http://localhost:{PORT}
- [ ] Verify page loads without errors
- [ ] Check browser console for errors (capture if found)
- [ ] Verify no 404 errors on assets
- [ ] Screenshot: `screenshots/initial-load.png`

### 2. Authentication Flow (if applicable)
- [ ] Navigate to login/signup
- [ ] Verify Supabase connection works
- [ ] Test authentication flows
- [ ] Check for console errors during auth
- [ ] Verify redirect after login

### 3. Core Functionality Testing
- [ ] Test primary user flows
- [ ] Verify data loads from Supabase
- [ ] Check for TypeScript errors in console
- [ ] Test form submissions
- [ ] Verify error handling works

### 4. Visual/UI Verification
- [ ] Check layout renders correctly
- [ ] Verify responsive design (if applicable)
- [ ] Check for CSS/styling issues
- [ ] Verify all images load
- [ ] Check for hydration errors

### 5. Console Error Check
Use browser-action to capture console:
```javascript
// Check for console errors
const errors = await browser.evaluate(() => {
    return window._consoleErrors || []
})
```

Expected: No errors or only acceptable warnings

### 6. Network/API Checks
- [ ] Verify Supabase API calls succeed
- [ ] Check for failed network requests
- [ ] Verify authentication headers present
- [ ] Check for CORS issues

## Error Capture Template

When errors are found, document in BROWSER_TEST_RESULTS.md:

```markdown
## Error: [Brief Description]

**Type**: Console Error / Visual Bug / Network Failure
**Location**: [URL or component]
**Severity**: Critical / Major / Minor

### Error Details
[Paste console error or describe issue]

### Screenshot
![error screenshot](screenshots/error-name.png)

### Steps to Reproduce
1. Step one
2. Step two
3. Error occurs

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]
```

## Success Criteria

Create `BROWSER_TEST_PASS.md` when ALL of these are true:
- ✅ Page loads without errors
- ✅ No console errors (or only acceptable warnings)
- ✅ Core functionality works as expected
- ✅ No visual/layout issues
- ✅ All API calls succeed
- ✅ Authentication works (if applicable)

## If Tests Fail

1. Document all issues in `BROWSER_TEST_RESULTS.md`
2. Fix the issues in source code
3. Wait for dev server to rebuild (watch for COMPILE_SUCCESS.md)
4. Re-run browser tests
5. Repeat until all tests pass

## Browser-Action Examples

### Navigate and screenshot
```javascript
await browser.goto('http://localhost:5173')
await browser.screenshot('screenshots/page.png')
```

### Click and wait
```javascript
await browser.click('#login-button')
await browser.waitForSelector('.dashboard')
```

### Check for element
```javascript
const exists = await browser.evaluate(() => {
    return document.querySelector('.error-message') !== null
})
```

### Get console errors
```javascript
const logs = await browser.evaluate(() => {
    return window.console.logs
})
```

## Maximum Iterations

- Maximum 3 test-fix-retest cycles
- If still failing after 3 cycles, create `BROWSER_TEST_BLOCKED.md` with details
- Request human intervention for complex issues
