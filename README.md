# Together, Together — Chicago 2027

A collaborative trip planner for five friends heading to Harry Styles at Soldier Field on **Monday, May 31, 2027 at 7:45 p.m. CT**, with The Womack Sisters.

## Publish with GitHub Pages

1. Open this repository's **Settings → Pages**.
2. Under **Build and deployment**, set **Source** to **GitHub Actions**.
3. Open the **Actions** tab and watch the “Deploy static trip planner to GitHub Pages” workflow.
4. After the deployment succeeds, the page will be available at:

   https://katieaamodt1105.github.io/together-together-chicago/

## Enable shared votes and edits with Supabase

1. Open your project: https://supabase.com/dashboard/project/qvpwsqeqmidddpyoaigj
2. Go to **SQL Editor → New query**.
3. Open schema.sql in this repository and copy the full contents into the editor.
4. Click **Run**, then refresh the public website.
5. The small status at the top should change to **Shared sync connected**.

The browser-facing Supabase project URL and publishable key are bundled into the page. A publishable key is designed for browser use; never put a Supabase secret/service-role key or database password into this repository.

## Sharing and safety

This is intentionally a public group planner. Anyone with the link can view and edit the shared trip record. The name picker is a label for voting, not authentication. Do not put sensitive personal or financial information in the planner. The Supabase SQL uses Row Level Security, but grants anonymous read/write to the single trip row so the group can collaborate without accounts.

Until the Supabase SQL has been run, edits are saved in the current browser only. After the table is installed, the app uses Supabase for shared data and realtime updates.

## Travel data

No flight schedule, flight number, fare, or Airbnb listing is invented. The flight cards open a fresh Google Flights search and provide fields for confirmed details. Stay cards start empty for real listings to be added by the group. Outfit prices are the initial estimates supplied for the trip; verify current pricing, sizes and stock at each retailer. Harry reference looks open an image search rather than using unverified or misattributed photos.

Cubs game time is TBD and the MLB schedule can change. The Cubs extension is designed for a **Friday, June 4 return**; it deliberately does not offer a June 3 flight home.
