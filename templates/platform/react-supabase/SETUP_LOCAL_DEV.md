# React/Supabase Local Development Setup

This guide helps you set up local development with browser testing for your React/Supabase project.

## Prerequisites

- Node.js and npm/pnpm/yarn installed
- Supabase project with dev, test, and prod environments
- Your React project repository cloned locally

## Step 1: Create Supabase Dev Environment

1. Log into your Supabase dashboard
2. Create a new branch/environment called "dev" from your main project
   - This gives you: `https://your-dev-project.supabase.co`
   - Separate database for development
   - Can be reset/synced as needed

3. Note your dev credentials:
   - Project URL: `https://xxxxx.supabase.co`
   - Anon/Public Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Step 2: Configure Local Environment

Create `.env.local` in your React project root (this file is git-ignored):

```bash
# Local Development Environment
VITE_SUPABASE_URL=https://your-dev-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-dev-anon-key

# Optional: Development flags
VITE_ENV=development
VITE_DEBUG=true
```

**Important:** The environment variable prefix depends on your bundler:
- Vite: `VITE_`
- Create React App: `REACT_APP_`
- Next.js: `NEXT_PUBLIC_`

Adjust variable names accordingly.

## Step 3: Install Dependencies

```bash
cd /path/to/your/react/project
npm install
# or: pnpm install
# or: yarn install
```

## Step 4: Test Local Dev Server

```bash
npm run dev
# Should start on http://localhost:5173 (or similar)
```

Visit http://localhost:5173 in your browser and verify:
- Page loads without errors
- Supabase connection works
- You can authenticate/access data

## Step 5: Run Agentic Workflow

Now you can use the orchestration script:

```bash
# Full workflow with browser testing
~/Documents/agentic_coding/scripts/run-agentic-workflow.sh \
    -p /path/to/your/react/project \
    -t react-supabase

# Or just browser testing phase
~/Documents/agentic_coding/scripts/run-agentic-workflow.sh \
    -p /path/to/your/react/project \
    --browser-test
```

The script will:
1. Start your dev server automatically
2. Monitor compilation errors
3. Run Kilocode with browser-action for testing
4. Capture screenshots and console errors
5. Provide feedback for iterative fixes

## Environment Structure

```
.env.local          # Local dev (git-ignored) → Supabase dev instance
.env.preview        # Vercel preview → Supabase test instance (via Vercel dashboard)
.env.production     # Vercel prod → Supabase prod instance (via Vercel dashboard)
```

## Supabase Environment Strategy

```
Supabase Project
├── dev (new)     - for local development & agent testing
├── test/preview  - for Vercel preview branches
└── prod          - production
```

### Schema Synchronization

When you need to update database schema:

```bash
# 1. Make changes in dev environment
# 2. Test with local dev server
# 3. Generate migration (optional)
npx supabase db diff --use-migrations

# 4. Apply to test environment for preview testing
# 5. Apply to prod after verification
```

## Project Structure for Agentic Coding

Your React project should have:

```
your-react-project/
├── DESIGN.md              # Design document
├── IMPLEMENTATION.md      # Implementation plan
├── .env.local            # Local dev config (git-ignored)
├── .kilorules            # Project-specific rules (optional)
├── feedback/             # Auto-generated feedback
│   ├── COMPILE_ERRORS.md
│   └── COMPILE_SUCCESS.md
└── screenshots/          # Browser test screenshots
```

## Troubleshooting

### Port Already in Use
If port 5173 is taken, the dev server will use the next available port. Check the console output.

### Supabase Connection Errors
- Verify your `.env.local` variables are correct
- Check that the dev environment is active in Supabase dashboard
- Ensure CORS is configured (usually automatic for localhost)

### Compilation Errors Not Detected
- Check that `feedback/` directory exists
- Verify the watcher script is running (look for `.watcher.pid`)
- Check `.dev-server.log` for dev server output

### Browser Testing Not Working
- Ensure Kilocode has browser-action tool available
- Verify dev server is accessible at http://localhost:5173
- Check for firewall/proxy issues

## Tips for Effective Agentic Development

1. **Keep dev environment clean**: Reset/resync from prod periodically
2. **Use descriptive commit messages**: Helps agents understand changes
3. **Document edge cases**: Add to DESIGN.md or IMPLEMENTATION.md
4. **Review screenshots**: Agents capture visual evidence of issues
5. **Iterate quickly**: The feedback loop is designed for rapid fixes

## Next Steps

1. Create your design documents (DESIGN.md, IMPLEMENTATION.md)
2. Run design review phase
3. Run implementation phase (dev server starts automatically)
4. Run browser testing phase (Kilocode tests with browser-action)
5. Review results and iterate

See main orchestration script help for all options:
```bash
~/Documents/agentic_coding/scripts/run-agentic-workflow.sh --help
```
