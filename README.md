# Fossil-ma-jig - A Community Fossil Tracker for ACNH

### Requirements

* Ruby >= 2.3

### Overview

Fossil-ma-jig presents a simple web interface with a database back-end that 
allows communities to come together and track what ACNH fossils they collectively
do and do not have.  Theoretically this should make it easier for people to 
share and trade fossils with each other.


### Installing

*  Get all the gems (I think the Gemfile is missing some oops)
*  Initialize the database by running `ruby create.rb`
*  Launch the app by running `rackup config.ru`

Important `rackup` flags:

* `-o 0.0.0.0` - Listen on all interfaces, defaults to localhost
* `-p xxxx` - Use port xxxx, defaults to 4567 or 9292
* `-D` - daemonize and run in background


### Usage

* Users are given a unique UUID by hitting the appropriate button on the 'login' page.  This is because I am lazy and didn't want to implement a real user/password system.
* Upon logging in, users are presented with a list of all 73 fossils in the game, with a Y/N selector beside each.  Users should simply select 'Y' next to any fossils they've already found and hit the 'Save' button at the bottom to store that in the database.

#### Menu

* 'Login Link' provides an easily copied/bookmarked link with the User's UUID in it so they can get back into the system should they log out or clear cookies.
* 'Home' brings users back to the main fossil selection list.
* 'Set Alias' allows users to set their own custom user alias so they don't have to see that big ugly UUID all the time.  NOTE: This is cosmetic only and the big ugly UUID is still required to log in.
* 'Your Fossil Report' presents an easily screencapped grid of each fossil highlighted in green or red depending on ownership.
* 'All users report' presents a matrix of all the users in the database along with whether or not they have a given fossil.  This is the 'community sharing' part of the app, allowing users to see who in their community needs what fossils in case they dig up an extra one.
* 'Logout' clear the session cookie and returns to the login screen


### Known Issues

* The 'all users report' is...unreliably laid out.  I set it up on a screen with a weird 3000x2000 resolution and it took me like 3 hours just to get -that- to show up right so yeah any other resolutions it probably doesn't work right sorry.

### Coming Soon

* A Dockerfile for easy containerization of the app
* An easier way to use MariaDB or Postgres instead of Sqlite3
* Maybe some more fancy graphics or something idk


v0.7.203 - 9/Apr/2020 - FoxBox @ Melondog Software
