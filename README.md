# lita-activedirectory
[![Build Status](https://travis-ci.org/knuedge/lita-activedirectory.svg?branch=master)](https://travis-ci.org/knuedge/lita-activedirectory) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://tldrlegal.com/license/mit-license) [![Gem Version](https://badge.fury.io/rb/lita-activedirectory.svg)](https://badge.fury.io/rb/lita-activedirectory) [![Code Climate](https://codeclimate.com/github/knuedge/lita-activedirectory/badges/gpa.svg)](https://codeclimate.com/github/knuedge/lita-activedirectory)

A [Lita](https://www.lita.io/) handler plugin for basic interactions with Active Directory.

## Installation

Add lita-activedirectory to your Lita instance's Gemfile:

``` ruby
gem "lita-activedirectory"
```

## Configuration

* `config.handlers.activedirectory.host` - LDAP host to query
* `config.handlers.activedirectory.port` - LDAP port used to connect to the host
* `config.handlers.activedirectory.basedn` - The basedn for the LDAP search
* `config.handlers.activedirectory.user_basedn` - the basedn for LDAP user searches
* `config.handlers.activedirectory.username` - User for connecting to LDAP
* `config.handlers.activedirectory.password` - Password for connecting to LDAP

## Usage
*username expects the samaccount name*
### Check if a user account is locked out
`is <username> locked?`

### Unlock a user account
`unlock <username>`

Requires membership in `ad_admins` authorization group.

The user account specified in `config.handlers.activedirectory.username` must have permission to write the `lockouttime` attribute for unlocking to succeed. We leave it up to you to secure this account accordingly.

### List a User's Group Memberships
`<username> groups>`

### List a Group's Members
`group <groupname> members`

### Add a User to a Group
`add <username> to <groupname>`

Requires membership in `ad_admins` authorization group.

The user account specified in `config.handlers.activedirectory.username` must have permission to write the `member` attribute on groups for the membership change to succeed. We leave it up to you to secure this account accordingly.

### Remove a User from a Group
`remove <username> from <groupname>`

Requires membership in `ad_admins` authorization group.

The user account specified in `config.handlers.activedirectory.username` must have permission to write the `member` attribute on groups for the membership change to succeed. We leave it up to you to secure this account accordingly.

### Disable a User
`disable user <username>`

Requires membership in `ad_admins` authorization group.

The user account specified in `config.handlers.activedirectory.username` must have permission to write the `userAccountControl` attribute on groups for the change to succeed. We leave it up to you to secure this account accordingly.

### Enable a User
`enable user <username>`

Requires membership in `ad_admins` authorization group.

The user account specified in `config.handlers.activedirectory.username` must have permission to write the `userAccountControl` attribute on groups for the change to succeed. We leave it up to you to secure this account accordingly.
