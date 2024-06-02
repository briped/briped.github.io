# DR Podcast module

This PowerShell module is designed to interact with the DR (Danish Broadcasting Corporation) API to search for podcasts, retrieve detailed podcast information, fetch episodes, and generate RSS feeds and HTML for displaying podcast information.

## Requirements

- PowerShell 5.1 or later
- An API key for the DR API.<br>Can be found by looking for the `x-apikey` header when browsing the DR Lyd podcasts.

## Usage

See the `Update-Podcasts.ps1` example.

## Todo

- Figure out release schedule, so script will only update a show if needed. No need to update weekly shows every hour, just to have hourly shows updated.
- Figure out what GitHub Actions are, and if it is possible to run something like this automatically using actions. Will probably need to learn Python or some such.
