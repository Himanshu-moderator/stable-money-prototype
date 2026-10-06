# Updating the live prototype

Live at **https://stable-money-prototype.himanshu-etc1.workers.dev**

The Worker `stable-money-prototype` already exists on your Cloudflare account.
Every update goes to that same Worker, which means the link never changes and
nobody has to be told a new one.

**Do not delete it. Do not create a new one.** Uploading again creates a new
*version* of the same Worker and the old version stays in the Deployments tab,
so a bad build can be rolled back in one click.

---

## Step 1 — rebuild (always do this first)

```
cd C:\Users\kkahc\StudioProjects\stable_money_clone
flutter build web --release
```

The output lands in `build/web`. That folder is the entire site: 31 files,
about 24 MB.

`build/web` is **overwritten** on every build, not added to. Rebuilding does
not grow your disk. If you want the space back afterwards, `flutter clean`
removes `build` and `.dart_tool` (about 260 MB), and the next build recreates
them.

---

## Step 2 — upload

### Option A: one command (needs Node.js installed)

```
npx wrangler deploy
```

`wrangler.jsonc` in the project root already points at `build/web` and at the
existing Worker name, so there is nothing to configure. Wrangler compares
hashes and only uploads the files that actually changed, so repeat deploys
take seconds.

The first run opens a browser to log in to Cloudflare. After that it
remembers.

If `npx` is not recognised, install Node.js from https://nodejs.org (the LTS
build), reopen the terminal, and run it again.

### Option B: the dashboard, same as last time

1. https://dash.cloudflare.com → **Compute (Workers)** → **stable-money-prototype**
2. Use the upload / edit-files screen you used before
3. Drag the **contents of `build/web`** in, not the folder itself, so
   `index.html` sits at the root
4. Deploy

Slower than Option A because it re-uploads everything, but nothing to install.

---

## Cost

Nothing to pay, and no card is needed.

The Workers free plan gives 100,000 requests a day, up to 20,000 static files
per version, and 25 MB per file. This build is 31 files and the largest single
file is 6.7 MB, so it is nowhere near any limit. A demo link shared with
reviewers will use a few hundred requests at most.

Creating extra Workers is also free, which is why the question of a
subscription does not arise either way — but reusing this one is still the
right move, purely so the URL stays put.

---

## After deploying

Hard-refresh before you judge it. Flutter web registers a service worker, so
a normal refresh can serve you the *old* build from cache:

- Desktop: Ctrl+Shift+R
- Phone: open the link in a private tab

Then check, in order:

1. Profile tab → **Appearance** → switch between Light, Dark and Gradient
2. Any bank → the header frontage, the banners, the calculator
3. Book an FD → Amount → KYC → Nominee → **Review terms** → the two-step
   terms screen → Payment

---

## Notes

- Everything is in memory. A refresh resets the prototype to logged out, which
  is usually what you want when demoing.
- Any 10-digit number works at login, and any 6 digits work as the OTP.
- On a phone the app runs edge to edge; on a laptop it renders inside a centred
  phone frame, so one link serves both a screen-share and a tap-through.
