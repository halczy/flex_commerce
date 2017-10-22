# Flex Commerce [![Build Status](https://travis-ci.org/halczy/flex_commerce.svg?branch=master)](https://travis-ci.org/halczy/flex_commerce)

[English](../README.md)

## 简介
Flex Commerce 是一个灵活，可快速扩展的电子商务解决方案。

## 系统需求
* Ruby 2.4 或以上
* PostgreSQL 9.4 或以上

## 演示
演示网站数据随机生成并定时重置 

[演示商城](https://flex.omicronplus.com)

#### 演示账户
```
管理员:
admin@example.com \ example

顾客:
customer_0@example.com \ example
```

备注: 演示网站已接入支付宝的沙箱环境。如需尝试支付或提款功能。您可以前往支付宝官网下载一个 [沙箱钱包](https://open.alipay.com/platform/manageHome.htm)。

## 特性
* 多种注册/登录方式
  - 顾客可以使用他们的邮箱地址，手机号码或者会员号其一登录。
* 灵活库存管理
  - 您可以追踪每件库存的位置及状态。
  - 每个产品可选择严格库存管理或宽松管理。启用严格库存管理的商品在库存卖完后会自动下架产品。宽松管理则会忽略该限制。  
* 高自定性物流
  - 运费计算可精确到街道或可粗略到以省。
  - 可创建自提为一种物流选择。
  - 订单内各不同产品可选择不同的物流方式。顾客可以在同一订单内一些产品选择快递到某一个地址，另一些产品选择自提。
* 支付系统已整合支付宝
* 余额管理系统
  - 顾客可以使用余额支付订单或申请将余额提出。
  - 提款/转帐组件可一键转帐到顾客支付宝。
* 可扩展的奖励系统
  - 奖励金额不局限为现金。奖励可按比例或全额设未不可提款金额。让您的市场团队有更多的创意空间。
  - 新的奖励方式可容易的写入 `RewardService` 组件，整合进商城系统。

## 安装步骤

*请确认您已配置好所有依赖组件后再执行以下安装步骤*

[依赖组件](DEPENDENCIES.md)

取得源码
```
git clone https://github.com/halczy/flex_commerce.git
```

安装 Gems
```
bundle install
```

配置数据库及安装 Flex Commerce
```
rails db:create
rails db:migrate
rails flex:setup
```

配置 Assets
```
yarn install
rails assets:precompile 
```