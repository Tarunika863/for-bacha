# For Bacha 🎀 — GitHub Pages + Supabase

This package keeps the existing birthday-page design and interactions, while replacing the platform-specific storage with Supabase. The public page works in modern browsers. The private dashboard is at `/#admin`.

## 1. Create the Supabase project

1. Create a project at https://supabase.com.
2. Open **Project Settings → API** and copy the Project URL and `anon` / publishable key.
3. In **SQL Editor**, create a new query and run all of `supabase-setup.sql`.
4. In that SQL file, replace both occurrences of `YOUR-PRIVATE-EMAIL@example.com` with your dashboard email, then run it. The SQL uses private token-based RPC functions for visitors, so the anonymous browser role cannot directly list or read the response table.
5. In **Authentication → Providers → Email**, keep Email enabled. Disable public sign-ups if available for your project; the owner account will be created by you in the next step.
6. In **Authentication → Users**, add/invite the owner email. Set a password if your Supabase dashboard offers it, or use the password reset flow to establish one. Do not share this password.

## 2. Configure the site

Edit `config.js`:

- `SUPABASE_URL`: your Supabase Project URL
- `SUPABASE_ANON_KEY`: the anon / publishable key (safe to expose when RLS is correctly configured)
- `ADMIN_EMAIL`: the exact owner email used in the SQL policies

Do not put a Supabase `service_role` key or any secret key in this file. GitHub Pages is public hosting; every file in this repository can be viewed by visitors.

## 3. Publish with GitHub Pages

1. Create a new GitHub repository, for example `for-bacha`.
2. Upload **all files and folders** from this package (at minimum `index.html`, `config.js`, and `supabase-setup.sql`) to the repository root.
3. Open **Settings → Pages**.
4. Under **Build and deployment**, choose **Deploy from a branch**.
5. Select branch `main` and folder `/ (root)`, then Save.
6. Wait for the deployment. GitHub will show a URL similar to `https://YOUR-USERNAME.github.io/for-bacha/`.

Use that public URL to share the birthday website with Himanshu.

## 4. Open your private dashboard

Visit the same site URL with `/#admin` appended, for example:

`https://YOUR-USERNAME.github.io/for-bacha/#admin`

Sign in using the owner email and password created in Supabase. Only the configured email can read or delete records under the supplied RLS policies. Do not share this dashboard URL as a security measure; access is enforced by Supabase authentication and database policies.

## 5. Test before sharing

- Open the public URL in a private/incognito window.
- Submit each question, including the text message.
- Refresh the page: the same browser should see its answers restored.
- Open `/#admin` and sign in as the owner.
- Confirm the response appears, then test CSV export.
- Do not test the admin page with a different email and expect access.

## Privacy and limitations

- The birthday site is public; the admin dashboard is private.
- The Supabase anon/publishable key is visible in browser source by design. Database Row Level Security is what protects the inbox.
- A random visitor ID and separate private token are stored in that browser's local storage. Clearing browser storage or switching devices creates a new visitor record. Visitors can retrieve only the response record matching their private token; they cannot directly list the response table.
- This starter allows anonymous visitors to insert/update their response row. It does not verify the visitor's identity, and a technically skilled visitor could tamper with their own submitted data.
- The site includes a large embedded photo in `index.html`, so the HTML file is large. This preserves the supplied photo and avoids breaking the gallery.
- The page's optional music setting remains unchanged; browsers require a user gesture before audio can play.
