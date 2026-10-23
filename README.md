# Fonix Chat

A single-room web chat built for the Fonix technical test.

- Sign up with an email address, confirmed by an emailed link.
- Messages are sent and received over WebSockets (Action Cable).
- Every Monday, each user is emailed how many messages were exchanged
  that week, and how many they've received since their last message.

Built with Rails 8.1 on Ruby 4.0, SQLite, Hotwire (Stimulus) and Tailwind.

## Running it

You need Ruby 4.0.7 (see `.ruby-version`) and Chrome for the browser tests.

```sh
bin/setup   # installs gems, creates the database and seeds demo data, then starts the server
```

Then open http://localhost:3000. If the server is already set up, start it with `bin/dev`.

The seeds create two confirmed accounts, `alice@example.com` and
`bob@example.com`, both with the password `password123`. To see messages
arrive live, sign in as Alice in one browser and as Bob in a private
window, then send messages from either.

### Emails in development

Development emails open in your browser (via [letter_opener](https://github.com/ryanb/letter_opener))
instead of being sent:

- **Confirmation:** create an account at `/registration/new` and the
  confirmation email opens in a new tab. Click its link to confirm and sign in.
- **Weekly digest:** run the job by hand with
  `bin/rails runner WeeklyDigestJob.perform_now`. Each user's digest opens in a tab.

You can also preview both emails at http://localhost:3000/rails/mailers.

## Tests

```sh
bundle exec rspec
```

The suite covers models, the channel and its connection, requests, mailers
and the job. It also has a system spec that signs two users into separate
headless Chrome sessions and checks that a message one sends appears for
the other without a reload. CI runs the specs, RuboCop, Brakeman,
bundler-audit and an importmap audit.

## How it works

### Accounts and email confirmation

Accounts use Rails 8's built-in authentication generator, plus a sign-up
page and email confirmation:

- Signing up creates an unconfirmed account and emails a link. It
  doesn't sign you in. Following the link confirms the account and signs
  you in.
- Unconfirmed accounts can't sign in. They're offered a fresh link instead.
- Links come from `generates_token_for`, so there's no token column. A
  token embeds the email address and the confirmation time, which makes
  each link single-use and invalidates it if the address changes. Links
  expire after 2 days.

I chose confirmation over a format check alone because the weekly digest
goes to this address, so it should belong to the user.

### Chat over WebSockets

Both directions use the socket:

1. The `chat` Stimulus controller (`app/javascript/controllers/chat_controller.js`)
   subscribes to `ChatChannel` and sends each message with
   `perform("speak", { body })`. There's no HTTP request.
2. `ChatChannel#speak` saves the message as the connection's user. If the
   message is invalid (blank, or over 1,000 characters), the errors go back
   to the sender only.
3. Once the message is committed, it renders its partial once and
   broadcasts the HTML to everyone subscribed. ERB escapes the body.
4. Each browser appends the HTML. The broadcast is identical for everyone,
   so the Stimulus controller highlights the viewer's own messages.

The WebSocket connection authenticates with the same signed session
cookie as the rest of the app and rejects anyone without one. Sessions
only exist for confirmed users, so only they can connect. The page loads
the 50 most recent messages, and the input stays disabled until the
socket connects.

### Weekly digest

`WeeklyDigestJob` runs at 9am every Monday, London time, as a Solid Queue
recurring task (`config/recurring.yml`). It emails every confirmed user:

> 600 messages have been exchanged in the last week.
> 750 since your last message on the 1st of February.

How I read the requirements:

- **"Sent and received in the last week"** counts every message in the
  room over the 7 days before the run. With one room, each message is
  both sent and received.
- **"Since your last message"** counts *other* people's messages after
  the user's most recent one. Someone who has never posted gets "since
  you joined on …" instead.
- Each run fixes one cut-off time and passes it to every email, so all
  digests from a run cover the same week, however long delivery takes.

The counting lives in `WeeklyDigest` (`app/models/weekly_digest.rb`).
Both counts use the index on `messages.created_at`.

## What I'd do next

- **Production email:** configure SMTP (or a provider) and the mailer
  host. Development and test deliver locally.
- **Older history:** load earlier messages as you scroll, instead of only
  the 50 most recent.
- **Abuse protection:** rate-limit `speak` per user. The HTTP sign-in,
  sign-up and resend endpoints are already rate-limited.
- **Presence:** show who's online, using the channel's subscribe and
  unsubscribe callbacks.
- **Scaling the digest:** with many users, compute the weekly total once
  per run instead of once per email. It's a single indexed count, so it
  isn't worth it at prototype scale.
