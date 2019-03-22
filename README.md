
# firewallmanager

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with firewallmanager](#setup)
    * [Beginning with firewallmanager](#beginning-with-firewallmanager)
3. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module allows you to handle firewall rules using hiera declarations

## Setup

### Beginning with firewallmanager

Basically all you need to start using it is to include the firewall manager class 

```

include 'firewallmanager'

```



## Usage

Basically you will define the open ports you need on hiera files like this 

Usual example 

```
frwRule::ports:
  '10058':
    'tcp': 'allow'
  '54663':
    'tcp': 'allow'
    'udp': 'allow'
  '54664':
    'tcp': 'allow'
  '54953':
    'tcp': 'allow'

```

A more advanced rule set is also supported

```
frwRule::rules:
            -
              port: '8080'
              protocol: 'tcp'
              action: 'accept'
              source: '10.252.7.0'
              sourcemask: '24'
              destination: '0.0.0.0'
              destinationmask: '0'
            -
              port: '80'
              protocol: 'tcp'
              action: 'accept'
              source: '10.252.7.0'
              sourcemask: '24'
              destination: '0.0.0.0'
              destinationmask: '0'

```


## Limitations

This is only tested on RedHat environments

## Development

Please try to keep your code tested and well documented. 