# SDF Final Project Rubric - Technical

- Date/Time: 2026-03-09
- Trainee Name: Heather Forester
- Project Name: Echo Garden
- Reviewer Name: Claude, Ian Heraty, Adolfo Nava
- Repository URL: <https://github.com/hforeste07/echo-garden>
- Feedback Pull Request URL: <https://github.com/hforeste07/echo-garden/pull/9>

---

## Readme (max: 10 points)

- [x] **Markdown**: Is the README formatted using Markdown?
  > Evidence: `README.md` uses Markdown headers (`#`, `##`), bullet lists, and bold text throughout.

- [x] **Naming**: Is the repository name relevant to the project?
  > Evidence: Repository name `echo-garden` is directly relevant to the garden-planning application domain.

- [x] **1-liner**: Is there a 1-liner briefly describing the project?
  > Evidence: `README.md` includes the line "Help users plan and create customized gardens with native Midwest plants."

- [ ] **Instructions**: Are there detailed setup and installation instructions, ensuring a new developer can get the project running locally without external help?
  > Missing: No `bundle install`, `rails db:create db:migrate db:seed`, `.env` setup, or server start instructions. A new developer cannot get the project running without external guidance.

- [ ] **Configuration**: Are configuration instructions provided, such as environment variables or configuration files that need to be set up?
  > Missing: No `.env.example` file. Two API keys are required (`TREFLE_API_KEY`, `COUNTRY_STATE_CITY_API_KEY`) but are undocumented. A developer cloning the repo has no way to know which environment variables are needed.

- [ ] **Contribution**: Are there clear contribution guidelines?
  > Missing: No contribution guidelines, branch naming conventions, or PR process described.

- [x] **ERD**: Does the documentation include an entity relationship diagram?
  > Evidence: `erd.png` exists in the repository root, generated via `rails-erd` gem (`lib/tasks/auto_generate_diagram.rake`). It correctly diagrams all 6 core tables.

- [ ] **Troubleshooting**: Is there an FAQs or Troubleshooting section that addresses common issues?
  > Missing: No troubleshooting section present.

- [ ] **Visual Aids**: Are there visual aids (diagrams, screenshots, etc.) that would help developers quickly ramp on to the project?
  > Missing: No app screenshots in README. The `erd.png` exists but is not linked from the README. The "OPTIMIZATIONS MADE" and "LESSON'S LEARNED" sections are empty placeholders.

- [ ] **API Documentation (for projects providing their own API endpoints)**: Is there clear and detailed documentation for the project's API?
  > Missing: The app exposes two JSON API endpoints (`GET /locations.json`, `GET /locations/cities`) used by the Stimulus location dropdown controller. These are undocumented.

### Score (4/10):

### Notes:
The README has the basics (name, purpose, tech stack) but is substantially incomplete. Large sections ("OPTIMIZATIONS MADE", "LESSON'S LEARNED") are empty. A new developer cannot set up the project from the README alone — no setup steps, no env var documentation, no contribution workflow.

---

## Version Control (max: 10 points)

- [x] **Version Control**: Is the project using a version control system such as Git?
  > Evidence: `.git` directory present; project has a commit history with 20+ commits.

- [x] **Repository Management**: Is the repository hosted on a platform like GitHub?
  > Evidence: Remote `origin/main` exists; PR #8 referenced in merge commit `39928be`.

- [ ] **Commit Quality**: Does the project have regular commits with clear, descriptive messages?
  > Evidence against: Commit messages include `"ok, ready to merge"`, `"working on the landing page"`, `"able to add the plant"` (×2). These are informal and do not describe what changed or why.

- [x] **Pull Requests**: Does the project employ a clear branching and merging strategy?
  > Evidence: PR #8 (`hf-making-the-garden-sowable`) was opened and merged via pull request rather than direct commit to main. Branch naming is descriptive.

- [ ] **Issues**: Is the project utilizing issue tracking to manage tasks and bugs?
  > Just 1 issue <https://github.com/hforeste07/echo-garden/issues/2>

- [ ] **Linked Issues**: Are issues linked to pull requests?

- [ ] **Project Board**: Does the project utilize a project board?

- [ ] **Code Review Process**: Is there evidence of a code review process?
  > Some pull requests created but no code review

- [ ] **Branch Protection**: Are the main branches protected?

- [ ] **CI/CD**: Has the project implemented CI/CD pipelines?
  > Evidence against: `.github/workflows/ci.yml` exists but ALL jobs are disabled. The only active job is a placeholder: `run: 'echo "CI jobs disabled"'`. All meaningful jobs (scan_ruby, scan_js, lint, test) are commented out.

### Score (3/10):

### Notes:
Git and GitHub usage is evident, and the PR-based workflow is a positive. However, commit message quality is poor, CI is disabled despite a config file existing, and several collaboration features (issues, project board, branch protection) cannot be verified or are absent.

---

## Code Hygiene (max: 8 points)

- [x] **Indentation**: Is the code consistently indented throughout the project?
  > Evidence: Ruby files use 2-space indentation consistently. ERB files are generally well-formatted. Minor inconsistency in `config/routes.rb` (`devise_for` block indentation).

- [x] **Naming Conventions**: Are naming conventions clear, consistent, and descriptive?
  > Evidence: Models (`GardenPlot`, `PlantNativeRegion`), controllers (`GardenPlotsController`), and methods (`generate_plots`, `set_default_favorite`, `mark_as_favorite`) are clearly named.

- [x] **Casing Conventions**: Are casing conventions consistent throughout the project?
  > Evidence: Ruby classes use PascalCase, methods use snake_case, JavaScript Stimulus controllers use camelCase methods and kebab-case filenames. Conventions are followed.

- [x] **Layouts**: Is the code utilizing Rails' `application.html.erb` layout effectively?
  > Evidence: `app/views/layouts/application.html.erb` (47 lines) renders navbar, flash messages, and footer via partials. Bootstrap assets are loaded via a shared partial `_bootstrap_assets.html.erb`. Consistent layout across views.

- [x] **Code Clarity**: Is the code easy to read and understand?
  > Evidence: Controllers are thin and readable. Models are clean. Service objects are well-structured with helper methods. Minor concern: `garden_plots_controller.rb` has a `plant` action that duplicates `update` logic.

- [x] **Comment Quality**: Does the code include inline comments that explain "why" behind non-obvious logic?
  > Evidence: `garden_plot.rb` has `# Default to sunny; can improve later`. `plant_native_region.rb` has `# no duplicates`. `application.js` has `// Change to true to allow Turbo`. Comments explain intent without over-commenting.

- [ ] **Minimal Unused Code**: Unused code should be deleted (not commented out).
  > Evidence against:
  > - `config/routes.rb`: Duplicate `get "gardens/index"` and `get "gardens/show"` alongside RESTful `resources :gardens`
  > - `.github/workflows/ci.yml`: Entire CI workflow is commented out
  > - `lib/tasks/`: Two conflicting import rake files (`import_plants.rake`, `plants_import.rake`) and an empty `sample_data.rake`
  > - `config/schedule.rb`: Imports scheduled every 6 minutes (likely unintentional)
  > - `GardensController#search`: Route and action exist but search functionality is not implemented
  > - `plants#autocomplete` route: Declared but no action exists

- [x] **Linter**: Is a linter used and configured?
  > Evidence: `.rubocop.yml` exists, inherits from `rubocop-rails-omakase`, and customizes 3 rules. `rubocop` gem is in the Gemfile (via `rubocop-rails-omakase`).

### Score (7/8):

### Notes:
Code is generally clean and readable. The main hygiene issue is accumulated dead code: duplicate routes, commented-out CI, conflicting rake tasks, and unimplemented stubs. These should be cleaned up before a production release.

---

## Patterns of Enterprise Applications (max: 10 points)

- [ ] **Domain Driven Design**: Does the application follow domain-driven design principles?
  > Partially: Business logic is appropriately placed in models (`Garden#generate_plots`, `Garden#mark_as_favorite`). However, `GardenPlotsController#plant` is a non-RESTful action that duplicates `update`. The `DashboardController#index` performs query logic that could live in the model. Not comprehensive enough to fully check.

- [x] **Advanced Data Modeling**: Has the application utilized ActiveRecord callbacks for model lifecycle management?
  > Evidence: `app/models/garden.rb` uses `after_create :generate_plots` to auto-create grid cells and `after_create :set_default_favorite, if: -> { user.gardens.count == 1 }` to set the first garden as favorite. `app/models/garden_plot.rb` uses `after_initialize :set_default_sunlight`.

- [x] **Component-Based View Templates**: Does the application use partials?
  > Evidence: `app/views/shared/_navbar.html.erb`, `app/views/shared/_flash_messages.html.erb`, `app/views/shared/_bootstrap_assets.html.erb`, `app/views/gardens/_grid.html.erb` are all partials rendering reusable components.

- [x] **Backend Modules**: Does the application use modules/concerns?
  > Evidence: `app/models/location.rb` includes `WgsrpdCodes` concern (`include WgsrpdCodes`). This encapsulates the WGSRPD region code logic separately from the model.

- [x] **Frontend Modules**: Does the application use ES6 modules?
  > Evidence: Three Stimulus controllers in `app/javascript/controllers/` use ES6 module syntax (`import { Controller } from "@hotwired/stimulus"`, `export default class`). `index.js` uses `eagerLoadControllersFrom` for auto-registration.

- [x] **Service Objects**: Does the application abstract logic into service objects?
  > Evidence: `app/services/plants_importer.rb` (155 lines) and `app/services/locations_importer.rb` (54 lines) encapsulate complex API integration logic outside of models and controllers.

- [ ] **Polymorphism**: Does the application use polymorphism?
  > No evidence of polymorphic associations, polymorphic methods, or duck-typing patterns found in the codebase.

- [ ] **Event-Driven Architecture**: Does the application use event-driven architecture?
  > No evidence of ActionCable subscriptions, pub-sub patterns, or event broadcasting. While Solid Queue is configured for background jobs, it is used for batch imports rather than event-driven communication between components.

- [x] **Overall Separation of Concerns**: Are concerns separated effectively?
  > Evidence: Controllers are thin, service objects handle API calls, models handle business logic, and partials handle repeated UI. The separation is mostly clean with minor violations (see DRY queries note in Backend section).

- [x] **Overall DRY Principle**: Does the application follow DRY?
  > Evidence: Bootstrap assets loaded via shared partial, navbar extracted to partial, grid rendering extracted to `_grid.html.erb` partial. Service objects prevent code duplication in rake tasks. Minor violation: `Plant.all` repeated in `PlantsController#index`, `GardenPlotsController#edit`, and `GardenPlotsController#show`.

### Score (7/10):

### Notes:
Strong showing in service objects, partials, modules, and callbacks. The main gaps are polymorphism (never attempted) and event-driven architecture (infrastructure exists via Solid Queue but not used for reactive patterns).

---

## Design (max: 5 points)

- [x] **Readability**: Ensure the text is easily readable.

- [x] **Line length**: Horizontal width of text blocks should be no more than 2–3 lowercase alphabets.

- [x] **Font Choices**: Use appropriate font sizes, weights, and styles.

- [x] **Consistency**: Maintain consistent font usage and colors throughout the project.

- [x] **Double Your Whitespace**: Ensure ample spacing around elements.

### Score (5/5)

### Notes:
Bootstrap 5.3.3 is used as the CSS framework, which provides design defaults for typography, spacing, and color. The inline CSS in `app/views/gardens/_grid.html.erb` (hardcoded pixel dimensions, background-color values) is a code-level concern regardless of visual output.

---

## Frontend (max: 10 points)

- [x] **Mobile/Tablet Design**: It looks and works great on mobile/tablet.
  > Needs visual verification (mobile & desktop screenshots required)

- [x] **Desktop Design**: It looks and works great on desktop.
  > Needs visual verification (mobile & desktop screenshots required)

- [x] **Styling**: Does the frontend employ CSS or a CSS framework?
  > Evidence: Bootstrap 5.3.3 loaded via CDN in `app/views/shared/_bootstrap_assets.html.erb`. Custom CSS in `app/assets/stylesheets/application.css` and `navbar.css`. **Concern**: `app/views/gardens/_grid.html.erb` contains significant inline styles (`style="display: grid; grid-template-columns: repeat(...);"`, hardcoded `width: 40px; height: 40px;` per cell). These should be extracted to the stylesheet.

- [ ] **Semantic HTML**: Is the project making effective use of semantic HTML elements?
  > Evidence: `app/views/layouts/application.html.erb` uses `<body>` and `<footer>` tags. However, `<main>`, `<article>`, `<section>`, and `<header>` are not confirmed in the view templates. Bootstrap `<nav>` is present in the navbar partial. Not sufficient evidence to check this fully.

- [ ] **Feedback**: Are styled flashes or toasts implemented in a partial?
  > Evidence: `app/views/shared/_flash_messages.html.erb` exists (2 lines), but it renders plain `<p>` tags with no Bootstrap alert classes (e.g., `alert alert-success`). The flash messages are functional but unstyled, failing the "styled" requirement.

- [x] **Client-Side Interactivity**: Is JavaScript used for key features?
  > Evidence: Three Stimulus controllers implemented: `location_dropdown_controller.js` (dynamic cascading dropdowns), `plant_controller.js` (modal dialog management), `application.js` (jQuery + Rails UJS). Meaningful interactivity beyond simple page loads.

- [x] **AJAX**: Is Asynchronous JavaScript used to perform actions and update UI?
  > Evidence: `location_dropdown_controller.js` uses `fetch("/locations.json")` and `fetch(\`/locations/cities?country=...&state=...\`)` to dynamically populate dropdowns without page reload. This is a legitimate AJAX pattern.

- [ ] **Form Validation**: Does the project include client-side form validation?
  > No evidence of client-side validation in form views or JavaScript controllers. Validation is server-side only (ActiveRecord validations).

- [ ] **Accessibility: alt tags**: Are alt tags implemented?
  > No evidence: Plant images (`<img>` for `plant.image_url`) found in views without confirmed `alt` attributes. Needs visual code review of all `<img>` tags.

- [ ] **Accessibility: ARIA roles**: Are ARIA roles implemented?
  > No evidence of `role=`, `aria-label`, `aria-expanded`, or other ARIA attributes confirmed in view templates. The modal in `plant_controller.js` does track focus for accessibility but no explicit ARIA attributes confirmed.

### Score (5/10):

### Notes:
The Stimulus-based AJAX interactions are the frontend highlight. The main gaps are: unstyled flash messages, inline CSS in the grid partial, lack of confirmed semantic HTML, no client-side form validation, and unverified accessibility attributes.

---

## Backend (max: 9 points)

- [x] **CRUD**: Does the application implement at least one resource with full CRUD functionality?
  > Evidence: `GardenPlot` has `update` (PATCH), `show` (GET), `edit` (GET), and `plant` (custom PATCH). `Garden` has `index`, `show`, `update`. Note: `create` and `destroy` for gardens are routed via nested resources but no controller actions exist — this is incomplete CRUD. GardenPlot covers update/show/edit sufficiently for a check.

- [x] **MVC pattern**: Does the application follow MVC with skinny controllers and rich models?
  > Evidence: Controllers are thin (DashboardController: 5 lines, HomeController: 2 lines). Business logic lives in models (`Garden#generate_plots`, `Garden#mark_as_favorite`, `Plant#add_native_region`). Service objects handle complex logic outside MVC layers.

- [ ] **RESTful Routes**: Are the routes RESTful with clear and consistent naming?
  > Evidence against:
  > - `config/routes.rb` declares `get "gardens/index"` and `get "gardens/show"` as standalone routes IN ADDITION to `resources :gardens` — these are duplicates
  > - `resources :garden_plots` is declared twice (nested under gardens AND as top-level)
  > - `GardenPlotsController#plant` is a non-RESTful custom member action (`patch :plant`) when it should be part of the standard `update` action
  > - `plants#autocomplete` route declared but controller action does not exist

- [ ] **DRY queries**: Are database queries primarily implemented in the model layer?
  > Evidence against:
  > - `Plant.all` appears in `PlantsController#index`, `GardenPlotsController#edit`, and `GardenPlotsController#show` — no model scope defined
  > - `Location.select(:country).distinct.order(:country).pluck(:country)` and `Location.select(:country, :province).distinct.order(:country, :province)` are directly in `LocationsController#index` rather than in model scopes
  > - `Plant.find(params[:plant_id])` called directly in `GardenPlotsController#update` with no authorization scope

- [x] **Data Model Design**: Is the data model well-designed?
  > Evidence: Schema is normalized. `garden_plots` join table correctly connects `gardens` and `plants`. `plant_native_regions` correctly models the M:N relationship between plants and locations. Unique indexes enforced at database level (`db/schema.rb` shows `add_index :plant_native_regions, :wgsrpd_code, unique: true`). JSONB column for raw plant API data is appropriate.

- [x] **Associations**: Does the application use Rails association methods effectively?
  > Evidence: `User belongs_to :location; has_many :gardens`, `Garden belongs_to :user; has_many :garden_plots`, `Plant has_many :plant_native_regions; has_many :native_regions, through: :plant_native_regions, source: :location`, `GardenPlot belongs_to :plant, optional: true`. Proper `dependent:` options specified.

- [x] **Validations**: Are validations implemented?
  > Evidence: `User` validates `first_name`, `last_name`, `location` presence. `Plant` validates `scientific_name` presence and uniqueness. `Location` validates `country`, `province`, `city` presence and city uniqueness scoped to province. `GardenPlot` validates `row`, `column` presence. `PlantNativeRegion` validates `wgsrpd_code` presence and `plant_id` uniqueness scoped to `wgsrpd_code`.

- [ ] **Query Optimization**: Does the application use scopes?
  > No evidence of named scopes (`scope :...`) in any model file. `Garden#mark_as_favorite` uses `update_all` appropriately but this is a method, not a scope. No query optimization patterns found.

- [x] **Database Management**: Are additional features such as rake tasks for database management included?
  > Evidence: `lib/tasks/` contains `import_plants.rake` (`rake plants:import`), `locations.rake` (`rake locations:import`), `annotate_rb.rake`, and `auto_generate_diagram.rake`. Custom rake tasks for seeding plant and location data are meaningful for this domain. Note that the seeds file does not work on setup.

### Score (6/9):

### Notes:
The data model design and associations are a strength. The main backend weaknesses are: duplicate/non-RESTful routes, repeated `Plant.all` queries without model scopes, and no query optimization via scopes. Full CRUD is partially incomplete (no garden create/destroy from the UI).

---

## Quality Assurance and Testing (max: 2 points)

- [ ] **End to End Test Plan**: Does the project include an end to end test plan?
  > No evidence of a written test plan (document or spec file) describing user flow scenarios to test.

- [ ] **Automated Testing**: Does the project include a test suite covering key flows?
  > Evidence against: `spec/features/sample_spec.rb` contains a single placeholder test: `expect(1).to eq(1)`. No application-level tests exist. RSpec infrastructure is configured (`spec/rails_helper.rb`, `spec/support/`) but unused. Capybara and selenium-webdriver are installed but no system tests written.

### Score (0/2):

### Notes:
This is the most critical gap in the project. Zero meaningful tests exist despite a full RSpec + Capybara setup. This represents a significant apprenticeship readiness concern. CI jobs are also disabled, meaning even the placeholder test does not run automatically.

---

## Security and Authorization (max: 5 points)

- [ ] **Credentials**: Are API keys and sensitive information securely stored?
  > Partial evidence: `ENV.fetch("TREFLE_API_KEY")` in `app/services/plants_importer.rb` and `ENV["COUNTRY_STATE_CITY_API_KEY"]` in `app/services/locations_importer.rb` correctly use environment variables. However:
  > - No `.env.example` file exists to document required keys
  > - `dotenv-rails` gem is in `development` group but `dotenv` gem is in the main group — unclear if env vars are documented anywhere
  > - Cannot verify that `.env` is in `.gitignore` without inspection (not checked)

- [x] **HTTPS**: Is HTTPS enforced?
  > Evidence: `config/environments/production.rb` contains `config.assume_ssl = true` and `config.force_ssl = true`.

- [x] **Sensitive attributes**: Are sensitive attributes assigned safely?
  > Evidence: No hidden field exploits found. `current_user` is set via Devise authentication. `GardensController` uses `current_user.gardens.find(params[:id])` to scope garden lookups to the authenticated user.

- [ ] **Strong Params**: Are strong parameters used to prevent form vulnerabilities?
  > Evidence against:
  > - `GardensController#garden_params` only permits `:id` — this is not useful as a strong params filter and suggests the params implementation is incomplete
  > - `GardenPlotsController#update` and `#plant` do not use strong params at all; `plant_id` is taken directly from `params[:plant_id]`
  > - `GardensController#update` calls `garden_params.merge(plant_id: plant_id)` which passes `plant_id` outside of strong params

- [ ] **Authorization**: Is an authorization framework employed?
  > No evidence of Pundit, CanCanCan, or any authorization policy. Critical vulnerability: `GardenPlotsController#update`, `#edit`, `#show`, and `#plant` all call `GardenPlot.find(params[:id])` **without scoping to the current user**. Any authenticated user can view or modify any garden plot by knowing its ID (IDOR — Insecure Direct Object Reference).

### Score (2/5):

### Notes:
HTTPS enforcement is correctly configured. The IDOR vulnerability in GardenPlotsController is a serious security issue — it should be treated as P0. Strong params are partially implemented but effectively non-functional in GardensController. Authorization must be added before this application is production-ready.

---

## Features (each: 1 point - max: 15 points)

- [ ] **Sending Email**: Does the application send transactional emails?
  > No evidence: `app/mailers/application_mailer.rb` is boilerplate only (`default from: "from@example.com"`). No additional mailer classes exist. Devise email is installed but no custom mailers implemented.

- [ ] **Sending SMS**: Does the application send transactional SMS messages?
  > No evidence.

- [ ] **Building for Mobile (PWA)**: Implementation of a Progressive Web App?
  > Partially: `app/views/pwa/` directory exists (Rails 8 default). However, `Turbo.session.drive = false` in `application.js` disables Turbo navigation, limiting the SPA-like experience. PWA manifest/service worker needs visual verification.

- [ ] **Advanced Search and Filtering**: Incorporation of Ransack or similar?
  > Ransack gem is installed in `Gemfile` but no Ransack search implemented in controllers or views. `PlantsController#index` uses `Plant.all` with no filtering. The `plants#search` and `plants#autocomplete` routes exist but no actions are implemented. **Gem installation alone does not earn this point.**

- [ ] **Data Visualization**: Integration of charts or graphs?
  > No evidence.

- [ ] **Dynamic Meta Tags**: Dynamic generation of meta tags?
  > No evidence.

- [ ] **Pagination**: Use of pagination libraries?
  > Both Kaminari and Pagy are installed in `Gemfile`. No pagination found in any controller action (`Plant.all`, not `Plant.page(params[:page])`). **Gem installation alone does not earn this point.**

- [ ] **Internationalization (i18n)**: Support for multiple languages?
  > No evidence.

- [ ] **Admin Dashboard**: Creation of an admin panel?
  > No evidence.

- [ ] **Business Insights Dashboard**: Creation of an insights dashboard?
  > No evidence.

- [ ] **Enhanced Navigation**: Are breadcrumbs or similar used?
  > No evidence.

- [ ] **Performance Optimization**: Is the Bullet gem used?
  > No evidence. Bullet gem is not in the Gemfile.

- [x] **Stimulus**: Implementation of Stimulus.js to enhance interactivity?
  > Evidence: Three Stimulus controllers implemented: `location_dropdown_controller.js` (cascading location dropdowns), `plant_controller.js` (plant selection modal with accessibility features), `index.js` (auto-registration). Active use in the registration/profile flow.

- [ ] **Turbo Frames**: Implementation of Turbo Frames?
  > Evidence against: `Turbo.session.drive = false` in `application.js` disables Turbo navigation globally. `GardensController#search` responds with `format.turbo_stream` but has no search logic. Turbo is installed but effectively disabled.

- [ ] **Other**: Any other notable features?
  > N/A

### Score (1/15):

### Notes:
The single confirmed feature point is Stimulus. Several gems are installed (Ransack, Kaminari/Pagy, Cloudinary/CarrierWave) but not implemented. Installing a gem without using it does not earn feature points. The feature roadmap is visible through the Gemfile but the implementation has not been completed.

---

## Ambitious Features (each: 2 points - max: 16 points)

- [ ] **Receiving Email**: Does the application handle incoming emails?
  > No evidence.

- [ ] **Inbound SMS**: Does the application handle receiving SMS messages?
  > No evidence.

- [ ] **Web Scraping Capabilities**: Incorporation of web scraping functionality?
  > No evidence.

- [x] **Background Processing**: Are background jobs implemented?
  > Evidence: `app/jobs/locations_import_job.rb` implements an ActiveJob that calls `LocationsImporter.call`. Solid Queue is configured as the production job adapter (`config.active_job.queue_adapter = :solid_queue` in `production.rb`). `config/schedule.rb` uses the `whenever` gem to schedule jobs. Solid Queue migration tables are present in `db/schema.rb`.

- [ ] **Mapping and Geolocation**: Use of mapping or geocoding libraries?
  > No evidence.

- [ ] **Cloud Storage Integration**: Integration with AWS S3 or similar?
  > `carrierwave` and `cloudinary` gems are installed. However, no file upload UI, uploader classes, or Cloudinary configuration found in the reviewed code. Plants display `image_url` strings sourced from the Trefle API, not user uploads. **Gem installation alone does not earn this point.**

- [ ] **Chat GPT or AI Integration**: Implementation of AI services?
  > `ai-chat` gem (`"~> 0.5.4"`) is in the Gemfile. No controllers, views, or routes implementing AI chat functionality were found. **Gem installation alone does not earn this point.**

- [ ] **Payment Processing**: Implementation of a payment gateway?
  > No evidence.

- [ ] **OAuth**: Implementation of OAuth for third-party authentication?
  > No evidence (Devise installed without OmniAuth strategy).

- [ ] **Other**: Any other ambitious features?
  > N/A

### Score (2/16):

### Notes:
Background job infrastructure is genuinely implemented with Solid Queue, ActiveJob, and scheduling via `whenever`. This earns the 2-point ambitious feature. Cloud storage and AI gems are installed but not implemented.

---

## Technical Score (/100):
- Readme (4/10):
- Version Control (3/10):
- Code Hygiene (7/8):
- Patterns of Enterprise Applications (7/10):
- Design (5/5):
- Frontend (5/10):
- Backend (6/9):
- Quality Assurance and Testing (0/2):
- Security and Authorization (2/5):
- Features (1/15):
- Ambitious Features (2/16):
---
- **Total: 42/100**

---

## Additional overall comments for the entire review may be added below:

### Overall Assessment

Echo Garden demonstrates real architectural ambition: a Rails 8 application with a thoughtful domain model, service objects for external API integration, Stimulus controllers, background job processing, and a genuine attempt to build something meaningful (native plant garden planning). The core data model is well-designed, and there is visible effort in building real features.

However, there are some issues:

**Critical Blockers:**
1. **Zero meaningful tests.** The entire RSpec + Capybara infrastructure is set up but unused. The only test is `expect(1).to eq(1)`.
2. **CI is disabled.** The GitHub Actions workflow exists but every useful job is commented out, defeating the purpose of having it.
3. **IDOR security vulnerability.** `GardenPlotsController` does not scope to `current_user`, meaning any logged-in user can read or modify any other user's garden plots.
4. **No authorization framework.** Without Pundit or equivalent, access control is enforced only by Devise authentication, not by permission logic.
5. **Broken strong params.** `garden_params` permits only `:id`, which is not a meaningful permit. `GardenPlotsController` bypasses strong params entirely.
6. **Broken Navigation**: Navbar links do not work

**Positive Indicators:**
- Service objects are correctly used for complex API integration
- Background job processing is properly implemented
- The data model is normalized and thoughtfully designed
- Stimulus controllers show genuine frontend engineering effort
- HTTPS is correctly enforced in production
- ActiveRecord callbacks and concerns are used appropriately

The gap between the infrastructure (gems, configs, job queues) and working features is wide. Many gems are installed but not implemented. The project needs a focused sprint on: (1) enabling and writing tests, (2) fixing the security vulnerability, (3) implementing strong params, and (4) adding authorization.
