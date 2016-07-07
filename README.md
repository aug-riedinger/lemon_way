# LemonWay DirectKit Ruby SDK

Ruby SDK client to query [LemonWay DirectKit API](http://documentation.lemonway.fr/api-en/directkit).

Built by [Augustin Riedinger](http://augustin-riedinger.fr/) for the awesome [mojjo](https://www.mojjo.fr) project.

## Usage

### 1. Add Lemonway to your Gemfile:

```
gem 'lemon_way', github: 'aug-riedinger/lemon_way'
```
and run the now classical `bundle install`

### 2. Create an initializer

In `config/initializers`, create `lemon_way.rb` with the following:

```
case Rails.env
when 'production'
  Rails.configuration.LemonWay = LemonWay::Client.new({
    wlLogin: YOUR_PROD_LOGIN,
    wlPass: YOUR_PROD_PASSWORD,
    language: 'fr',
    walletIp: (`curl http://v4.ifconfig.co`).sub(/\n/, ''),
    uri: YOUR_PROD_URI
  })
when 'staging'
  Rails.configuration.LemonWay = LemonWay::Client.new({
    wlLogin: YOUR_TEST_LOGIN,
    wlPass: YOUR_TEST_PASSWORD,
    language: 'fr',
    walletIp: (`curl http://v4.ifconfig.co`).sub(/\n/, ''),
    uri: YOUR_TEST_URI,
    prefix: 'staging',
    debug: true
  })
else
  Rails.configuration.LemonWay = LemonWay::Client.new({
  wlLogin: YOUR_TEST_LOGIN,
  wlPass: YOUR_TEST_PASSWORD,
  language: 'fr',
  walletIp: (`curl http://v4.ifconfig.co`).sub(/\n/, ''),
  uri: YOUR_TEST_URI,
  prefix: YOUR_DEV_SPECIFIC_PREFIX,
  debug: true
  })
end
```

Because only 1 test environment is available for everybody, and you want to make sure that your local `john.doe@example.com` won't share the same wallet as your teammate's one, or the staging one, all fields are prefixed.

Hence if you set `prefix: 'staging'`, the user will be created with :

```
{
  clientMail: 'staging-john.doe@example.com',
  wallet: 'staging-john-doe-wallet'
}
```

To make sure you don't overlap with other accounts, make sure you choose a `YOUR_DEV_SPECIFIC_PREFIX` unique per developper.

### 3. Start using custom methods anywhere in your app:

Every method available is called with the same signature:

```
result, error = Rails.configuration.LemonWay.register_wallet(VERSION_NUMBER, PARAMS)
```

- `VERSION_NUMBER` is a string of the version number of the method call. Eg. `'1.1'`
- `PARAMS` is an hash with all the params camlCased (as in the doc)

And it returns an array `[result, error]` which is encouraged to be double assigned, in a Golang style.

If query worked fine:
- `result` contains the API return data
- `err` is `nil`
else
- `result` is `nil`
- `err` has the form: `{code: ERROR_CODE, msg: ERROR_MSG}`


Eg.

```
result, err = Rails.configuration.LemonWay.register_wallet('1.1', {
  wallet: 'john-doe-wallet',
  clientMail: 'john.doe@example.com',
  clientFirstName: 'John',
  clientLastName: 'Doe',
  phoneNumber: '0033612345678',
  mobileNumber: '0033612345678',
  clientTitle: '',
  language: 'fr',
  isDebtor: '',
  birthcity: '',
  birthcountry: '',
  isOneTimeCustomer: '0',
  walletIp: '127.0.0.1',
  street: '1 avenue du Maine',
  postCode: '75001',
  city: 'Paris',
  ctry: 'FRA',
  birthdate: '01/01/1970',
  isCompany: '',
  companyName: '',
  companyWebsite: '',
  companyDescription: '',
  companyIdentificationNumber: '',
  nationality: 'FRA',
  payerOrBeneficiary: '1'
})
if err
  # handle error with err[:code] and err[:msg]
else
  do_something_else(result)
end
```

### 4. Available methods

- [GetBalances](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/getbalances-getting-all-wallet-balances)
- [GetKycStatus](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/getkycstatus-looking-for-user-document-iban-modified-since-an-entry-date)
- [GetMoneyInIBANDetails](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-bank-wire-sct-sepa-credit-transfer/getmoneyinibandetails-looking-for-a-money-in-by-fund-transfer)
- [GetMoneyInTransDetails](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/getmoneyintransdetails-looking-for-a-money-in)
- [GetMoneyOutTransDetails](http://documentation.lemonway.fr/api-en/directkit/money-out-debit-a-wallet-and-credit-a-bank-account/getmoneyouttransdetails-looking-for-a-money-out)
- [GetPaymentDetails](http://documentation.lemonway.fr/api-en/directkit/p2p-transfer-between-wallets/getpaymentdetails-looking-for-payments-between-wallets)
- [GetWalletDetails](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/getwalletdetails-getting-detailed-wallet-data)
- [MoneyIn](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/moneyin-credit-a-wallet-with-a-non-3d-secure-card-payment)
- [MoneyIn3DConfirm](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/moneyin3dconfirm-direct-mode-finalization-of-the-money-in-by-3dsecure)
- [MoneyIn3DInit](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/moneyin3dinit-direct-mode-3d-secure-payment-init-to-credit-a-wallet)
- [MoneyInWebInit](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/moneyinwebinit-indirect-mode-money-in-by-card-crediting-a-wallet)
- [MoneyInWithCardId](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/moneyinwithcardid-credit-of-a-wallet-with-a-tokenized-card)
- [MoneyOut](http://documentation.lemonway.fr/api-en/directkit/money-out-debit-a-wallet-and-credit-a-bank-account/moneyout-external-fund-transfer-from-a-wallet-to-a-bank-account)
- [RefundMoneyIn](http://documentation.lemonway.fr/api-en/directkit/other-functions/refundmoneyin)
- [RegisterCard](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/registercard-linking-a-card-number-to-a-wallet-for-one-click-payment-or-rebill)
- [RegisterIBAN](http://documentation.lemonway.fr/api-en/directkit/money-out-debit-a-wallet-and-credit-a-bank-account/registeriban-enregistrement-diban)
- [RegisterWallet](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/registerwallet-creating-a-new-wallet)
- [SendPayment](http://documentation.lemonway.fr/api-en/directkit/p2p-transfer-between-wallets/sendpayment-on-us-payment-between-wallets)
- [UnregisterCard](http://documentation.lemonway.fr/api-en/directkit/money-in-credit-a-wallet/by-card/unregistercard-delete-a-card-token)
- [UpdateWalletDetails](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/updatewalletdetails-update-wallet-data)
- [UpdateWalletStatus](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/updatewalletstatus)
- [UploadFile](http://documentation.lemonway.fr/api-en/directkit/manage-wallets/uploadfile-document-upload-for-kyc) (not tested yet)

### 5. Detailed examples

Please [create an issue](https://github.com/aug-riedinger/lemon_way/issues) if you have trouble using this gem or implementing a specific feature. I'll add practical examples along the way.

## Contribute

Feel free to contribute. Not all methods have been used yet, so there might need some specific behavior for some API calls (eg. `UploadFile`).

You can always reach mere [here](http://augustin-riedinger.fr/contact/) or [create an issue](https://github.com/aug-riedinger/lemon_way/issues)

## The MIT License (MIT)

Copyright (c) 2016 Augustin Riedinger

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
