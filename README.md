# Flex Commerce [![Build Status](https://travis-ci.org/halczy/flex_commerce.svg?branch=master)](https://travis-ci.org/halczy/flex_commerce)

[中文简介](docs/README_zh-CN.md)

## Overview
Flex Commerce is an easily expandable and customizable e-commerce solution.

## Requirements
* Ruby 2.4 or above
* PostgreSQL 9.4 or above

## Demo
Demo site with randomly generated data. 

[Demo Store](https://flex.omicronplus.com)

#### Credentials
```
Admin:
admin@example.com \ example

Customer:
customer_0@example.com \ example
```

Note: The demo store is configured with the Alipay sandbox environment. If you would like test out the Alipay payment features. You can download a [sandbox wallet](https://open.alipay.com/platform/manageHome.htm) from Alipay.

## Notable Features
* Multiple sign in/sign up options
  - Customers can sign in with either their email, cell number, or their membership id.
* Flexible inventory control
  - You can track the location and status of each inventory.
  - You can decide to enforce either strict or loose inventory control for each product. Product with strict inventory control will be taken offline once all sellable inventories are exhausted.  
* Highly customizable shipping calculator
  - Shipping rate code can match as detail as street level address or as broad as province/state level address.
  - Customer self-pickup is an option.
  - An order can mix shipping methods. The customer can create an order with some products for delivery and some for pickup.
* Payment integration with Alipay
* Account balance management
  - The customer can pay with their account balance or withdraw their account balance.
  - Fund withdrawal is integrated with Alipay and can be automated with one-click.
* Expandable reward function
  - Rewards can be distributed as withdrawable or un-withdrawable fund. Giving more room for marketing creativity.
  - New reward function can be easily created through the `RewardService` class.

## Setup

*Please make sure you have all the dependencies setup properly before running the following steps.*

[Dependencies](docs/DEPENDENCIES.md)

Get the Flex Commerce code
```
git clone https://github.com/halczy/flex_commerce.git
```

Install Gems
```
bundle install
```

Setup Database and Application
```
rails db:create
rails db:migrate
rails flex:setup
```

Build Assets
```
yarn install
rails assets:precompile 
```