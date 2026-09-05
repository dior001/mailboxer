# mailboxer

**A fork of the upstream [mailboxer](https://github.com/mailboxer/mailboxer) gem**, not an
original UpWoof project — a generic Rails messaging system (conversations, receipts,
notifications) originally built for `ging/social_stream`.

## Working in a fork

This tracks a public upstream, so the usual portfolio conventions apply with one caveat: **every
local change is a future merge conflict.** Before changing anything, check whether the need can
be met in the consuming application instead. If a change genuinely belongs here, keep it small
and isolated so it rebases cleanly, and note why it could not live downstream.

Upstream's own conventions win inside `app/`, `lib/` and `db/` — match the surrounding code
rather than the portfolio house style.

## Stack

Ruby gem for Rails. `app/`, `lib/`, `db/`, `spec/`, with `gemfiles/` for the Appraisal matrix.

```bash
bundle install
bundle exec rspec
```
