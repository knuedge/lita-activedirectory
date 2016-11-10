# lita-activedirectory
[![Build Status](https://travis-ci.org/knuedge/lita-activedirectory.svg?branch=master)](https://travis-ci.org/knuedge/lita-activedirectory)

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

Check if a user account is locked out
`is <username> locked?`

Unlock a user account
`unlock <username>`

Username should take the form of the samaccount name, ie `jdoe`